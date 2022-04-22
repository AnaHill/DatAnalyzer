function [fft_calc_results] = calculate_fft_avg_median_max(fftcalcparam)
% calculates average, max and median fft values in freqyencies below fmaxHz
% and arrange data candinates based on certain criteria
% input: fftcalcparam should be a struct variable including
    % fmaxHz, method_to_choose_data_order,f,P1
        % fmaxHz = maximum frequency value, default = 2.5 Hz
        % method_to_choose_data_order = method to used to arrange data
            % default = 'max_vs_median_below_fmaxHz';
        % f = frequency domain of calculated P1
        % P1 = calculated single-sided amplitude spectrum P at frequency domain f
% fftres is structure with variables
    % .AverageAmplitude_fft, .MedianAmplitude_fft, .MaxAmplitude_fft
    
narginchk(0,1)
nargoutchk(0,1)
% set default values
if nargin < 1 
    fmaxHz = 2.5;
    method_to_choose_data_order = 'max_vs_median_below_fmaxHz';
    try 
        f = evalin('base','f');
    catch
        error('no fft frequency found!')
    end
    try 
        P1 = evalin('base','P1');
    catch
        error('no fft frequency found!')
    end   
else % check that input-struct has required fields, and if not, setting default
    if isfield(fftcalcparam,'fmaxHz')
        fmaxHz = fftcalcparam.fmaxHz;
    else
        fmaxHz = 2.5;
    end
    if isfield(fftcalcparam,'method_to_choose_data_order')
        method_to_choose_data_order = fftcalcparam.method_to_choose_data_order;
    else
        method_to_choose_data_order = 'max_vs_median_below_fmaxHz';
    end
    if isfield(fftcalcparam,'f')
        f = fftcalcparam.f;
        
    else
        try
            f = evalin('base','f');
        catch
            error('no fft frequency found!')
        end
    end
    if isfield(fftcalcparam,'P1')
        P1 = fftcalcparam.P1;
        
    else
        try
            P1 = evalin('base','P1');
        catch
            error('no Single sided P1 fft found!')
        end
    end
    
end
    
    

%%%%%%%%%%%%%%%%%%%%%%%
fft_calc_results.AverageAmplitude_fft = [];
fft_calc_results.MaxAmplitude_fft = [];
fft_calc_results.MedianAmplitude_fft = [];
row_indexes = 1:find(f < fmaxHz,1,'last');
row_index_start = find(f > 0, 1,'first'); % DC, 0Hz, removed from the analysis
row_indexes = row_indexes(row_indexes >=row_index_start);

% for index = 1:length(ordered_datacolumn_index)
%     current_datacol = ordered_datacolumn_index(index);
for index = 1:length(fftcalcparam.P1(1,:))
    current_datacol = index;
    fft_calc_results.AverageAmplitude_fft(index,1) = ...
        mean(P1(row_indexes,current_datacol));
    fft_calc_results.MaxAmplitude_fft(index,1) = ...
        max(P1(row_indexes,current_datacol));
    fft_calc_results.MedianAmplitude_fft(index,1) = ...
        median(P1(row_indexes,current_datacol));
   % if fftres.MaxAmplitude_fft is too low, set to zero (DC components etc)
   if fft_calc_results.MaxAmplitude_fft(index,1) < 1e-8 % some limit
       fft_calc_results.MaxAmplitude_fft(index,1) = 0;
   end

   try
       if disp_something == 1
           disp(['Index ', num2str(index),': Datacol#',num2str(current_datacol),...
               '- mean = ', num2str((fft_calc_results.AverageAmplitude_fft(index,1))),...
               '- max = ', num2str((fft_calc_results.MaxAmplitude_fft(index,1)))])
       end
   catch
       % no disp_something variable
   end
end

