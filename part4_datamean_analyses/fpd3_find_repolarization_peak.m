function DataPeaks_summary = fpd3_find_repolarization_peak(...
    peakloc_start_and_end_indexes, max_or_min_value,...
    used_filter, filter_parameters,...
    DataInfo, DataPeaks_mean, DataPeaks_summary)
% fpd calculation #3
% finds repolization flat peak location starting from the first peak 
% with optional to set time window for that
% outcomes
    % DataPeaks_summary.peaks table including columns 
    % {'file_index','flatp_loc','flatp_val'}   
% Examples
% with defaults: DataPeaks_summary = fpd3_find_repolarization_peak;
max_inputs = 7;    
narginchk(0,max_inputs)
nargoutchk(0,1)

% default: finding peak from whole data (using nan value)
if nargin < 1 || isempty(peakloc_start_and_end_indexes)
    peakloc_start_and_end_indexes = [nan nan]; 
end
if length(peakloc_start_and_end_indexes) < 2
    % if length == 1 --> find from given first index to end of data
    peakloc_start_and_end_indexes(2) = nan;
end
if length(peakloc_start_and_end_indexes) > 2
    error('More than two parameters given! Check location window indexes.')
end

 % default: finding maximum for repolarization
if nargin < 2 || isempty(max_or_min_value)
    max_or_min_value = 'max';
end

% filter; default is lowpass IIR filter at 200Hz with Steepness 0.95
if nargin < 3 || isempty(used_filter) 
    used_filter = 'lowpass_iir'; % default filter for fp-start
end
if nargin < 4 || isempty(filter_parameters)
    fs_low_freq = 200; % lowpass frequency level, typically used for repolariz. peak
    filter_parameters = [fs_low_freq, 0.95];
end
if length(filter_parameters) == 1
    filter_parameters(2) = 0.95; % default iir steepness, see filter_data function
end
if length(filter_parameters) > 2
    error('More than two parameters given! Check filter_parameters.')
end


% reading from workspace if not given: DataInfo, DataPeaks_mean, DataPeaks_summary)
if nargin < max_inputs - 2 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
        disp('DataInfo read from workspace.')
    catch
        error('No proper DataInfo!')
    end
end
if nargin < max_inputs - 1 || isempty(DataPeaks_mean)
    try
        DataPeaks_mean = evalin('base', 'DataPeaks_mean');
        disp('DataPeaks_mean read from workspace.')
    catch
        error('No proper DataPeaks_mean!')
    end
end
if nargin < max_inputs || isempty(DataPeaks_summary)
    try
        DataPeaks_summary = evalin('base', 'DataPeaks_summary');
        disp('DataPeaks_summary read from workspace.')
    catch
        error('No proper DataPeaks_summary!')
    end
end

%%
for file_ind = 1:length(DataPeaks_mean)
    disp(['Finding second peak of fp-signal, file#',...
        num2str(file_ind),'/',num2str(length(DataPeaks_mean))])
    for col_ind = 1:length(DataInfo.datacol_numbers)
        try 
            fs = DataInfo.framerate(file_ind, col_ind);
        catch % if each datacolumn has same fs
            fs = DataInfo.framerate(file_ind); 
        end       
                
        start_index = round(peakloc_start_and_end_indexes(1));
        % if start_index = nan -> set to DataPeaks_summary.peaks{col_ind}.firstp_loc 
        if isnan(start_index)
            start_index = DataPeaks_summary.peaks{col_ind}.firstp_loc(file_ind);
        end
        
        end_index = round(peakloc_start_and_end_indexes(end));
        if isnan(end_index) % if nan, take end of data
            data = DataPeaks_mean{file_ind, 1}.data(start_index:end,col_ind);
            end_index = length(data)+start_index-1;
        else
            data = DataPeaks_mean{file_ind, 1}.data(...
                start_index:end_index,col_ind);
        end        
        % now data is only from start_index to end, i.e. peakloc_start_and_end_indexes
        % meaning, that data(1) = DataPeaks_mean{file_ind, 1}.data(start_index)
        % filter_data(data, fs, filter_type, filter_parameters, plot_result,print_filter)
        data_filtered = filter_data(data, fs, used_filter, filter_parameters,'no','no');   
               
        % find maximum or minimum for peak
        [peak_value, peak_location] = find_max_or_min...
            (data_filtered, [], [], max_or_min_value);
        % function [values,location_indexes] = find_max_or_min(data, start_index, ...
        %     location_window_start_and_end_indexes, max_or_min_value)

        % fig_full, plot(data,'.-'), hold all, plot(data_filtered,'--'), plot(peak_location,peak_value,'ro','markersize', 30)
        
        flatp_loc = peak_location + start_index-1;
        % update DataPeaks_summary
        DataPeaks_summary.peaks{1,col_ind}.flatp_loc(file_ind) = ...
            flatp_loc;
        DataPeaks_summary.peaks{1,col_ind}.flatp_val(file_ind) = ...
            peak_value; 
       
    end    
    
end

end
