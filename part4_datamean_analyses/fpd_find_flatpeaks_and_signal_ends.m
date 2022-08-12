function [DataPeaks_summary] = fpd_find_flatpeaks_and_signal_ends(fpd_threshold_percent,...
    low_freq, filenumbers, datacolumns, ...
    DataInfo, DataPeaks, DataPeaks_mean, DataPeaks_summary,plotting_results)
% function [DataPeaks_summary] = fpd_find_flatpeaks_and_signal_ends(fpd_threshold_percent,...
%     low_freq, filenumbers, datacolumns, ...
%     DataInfo, DataPeaks, DataPeaks_mean, DataPeaks_summary,plotting_results)
narginchk(0,9)
nargoutchk(0,1)

% default threshold: 0.1
if nargin < 1 || isempty(fpd_threshold_percent)
    fpd_threshold_percent = 0.1;
end

% default low pass filter start freq: 1500 Hz
if nargin < 2 || isempty(fpd_threshold_percent)
    low_freq = 1500;
end


if nargin < 5 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end

if nargin < 3 || isempty(filenumbers)
    filenumbers = 1:DataInfo.files_amount; 
end
if nargin < 4 || isempty(datacolumns)
    datacolumns = 1:length(DataInfo.datacol_numbers);
end

if nargin < 6 || isempty(DataPeaks)
    try
        DataPeaks = evalin('base', 'DataPeaks');
    catch
        error('No proper DataPeaks')
    end    
end


if nargin < 7 || isempty(DataPeaks_mean)
    try
        DataPeaks_mean = evalin('base', 'DataPeaks_mean');
    catch
        error('No proper DataPeaks_mean')
    end    
end

if nargin < 8 || isempty(DataPeaks_summary)
    try
        DataPeaks_summary = evalin('base', 'DataPeaks_summary');
    catch
        error('No proper DataPeaks_summary')
    end    
end

if nargin < 9 || isempty(plotting_results)
   plotting_results = 0; 
end

if nargout < 1 % || isempty(DataPeaks_summary)
    warning('DataPeaks_summary will not be updated!')
end
%%
DataPeaks_summary.fpd_end_index =[];
DataPeaks_summary.fpd_end_value = [];
DataPeaks_summary.fpd = [];


running_file_index = 1;
for file_index = filenumbers
    disp(['Finding flat peak and fpd end from file#', num2str(file_index),...
        ', ',num2str(length(datacolumns)), ' datacolumns'])
    for col_index = datacolumns
        fs = DataInfo.framerate(file_index);
        data_all = DataPeaks_mean{file_index, 1}.data(:,col_index);
        time = 0:1/fs:(length(data_all)-1)/fs;
        datapoints_for_baseline = round(fs/4*abs(DataPeaks.time_range_from_peak(1)));
        baseline = median(data_all(1:datapoints_for_baseline,:)); % mean or median?
        if all(isnan(data_all)) % if all nan
            warning('No DataPeaks_mean found!')
        else
            fpd_start_index = DataPeaks_summary.fpd_start_index(file_index, col_index);
%             first_peak_index = DataPeaks_summary.peaks{col_index}.firstp_loc(file_index);
            first_peak_index = DataPeaks_summary.peaks{col_index}.firstp_loc(running_file_index);
            data_to_end = data_all(first_peak_index:end);
            % TODO: ? mean(abs(abs(data)-abs(datafil))) % joku virhetarkistus tällä?!? onko low_freq hyvä
            datafil = lowpass(data_to_end,low_freq,fs,'ImpulseResponse','iir','Steepness',0.95);
            [val_flatp, ind_flatp] = max(datafil); % figure, plot(datafil)
            % if val < 0 --> not peak?
            if val_flatp <= 0
                flat_peak_index = NaN;
                % peak_end_index = NaN;
                % peak_end_index when back to 10% line of baseline value
                peak_amp =  DataPeaks_summary.depolarization_amplitude(file_index, col_index);
                Amp = peak_amp-baseline;
                threshold_value = baseline + fpd_threshold_percent*Amp;
                % peak start: backwards from peak: data_from_firstpeak to start
%                 first_peak_index = DataPeaks_summary.peaks{col_index}.firstp_loc(file_index);
                first_peak_index = DataPeaks_summary.peaks{col_index}.firstp_loc(running_file_index);
                datafil = lowpass(data_all,low_freq,fs,'ImpulseResponse','iir','Steepness',0.95);
                datafildrop = datafil(first_peak_index:end); 
                ind = find(datafildrop >= threshold_value,1,'first'); 
                peak_end_index = first_peak_index+ind-1;
                peak_end_value = datafildrop(ind);
            else % if flat peak positive            
                flat_peak_index = first_peak_index+ind_flatp-1;
                end_index_for_data = length(data_all);
                % checking, if max place is too far from first peak location
                t_plateau = abs(first_peak_index-flat_peak_index)/fs;
                % if found peak that is in the end --> most probably wrong peak
                % taking only data from 0-90% (eliminate possible end peak)        
                if t_plateau > 0.9
                    data_to_modified = data_all;
                    while t_plateau > 0.9
                        % take data from low peak to end * 0.9 (eliminate possible end peak)
                        end_index_for_data = round(length(data_to_modified)*0.9);
                        data_not_to_end = data_to_modified(first_peak_index:end_index_for_data);
                        datafil = lowpass(data_not_to_end,low_freq,fs,'ImpulseResponse','iir','Steepness',0.95);
                        [val_flatp, ind] = max(datafil);
                        flat_peak_index = first_peak_index+ind-1;
                        t_plateau = abs(first_peak_index-flat_peak_index)/fs;
                        data_to_modified = data_to_modified(1:end_index_for_data);
                    end
                end
                % finding flat peak end location
                % from flat peak to end
                % now peak_amp = flat peak amplitude
                peak_amp =  val_flatp; % data_all(flat_peak_index);
                Amp = peak_amp-baseline;
                threshold_value = baseline + fpd_threshold_percent*Amp;
                data_to_end = data_all(flat_peak_index:end_index_for_data);
                datafil2 = lowpass(data_to_end,low_freq,fs,'ImpulseResponse','iir','Steepness',0.95);
                % when signal from flat peak first drops below threshold_value
                ind2 = find(datafil2 <= threshold_value,1,'first'); 
                peak_end_index = flat_peak_index+ind2-1; 
                peak_end_value = datafil2(ind2);
                if plotting_results == 1
                    % % file_index=1; col_index=1;               
                    fig_full, plot(DataPeaks_mean{file_index, 1}.data(:,col_index),'--'), 
                    hold all,plot(first_peak_index:end_index_for_data, datafil)
                    scatter(fpd_start_index, data_all(fpd_start_index),100,'>','filled')
                    scatter(first_peak_index,data_all(first_peak_index),100,'o','filled')
                    scatter(flat_peak_index,val_flatp,100,'sq','filled')
                    scatter(peak_end_index,peak_end_value,100,'<','filled')
                    %%%
                end
            end
            DataPeaks_summary.peaks{1,col_index}.flatp_loc(file_index) = ...
                flat_peak_index;
            DataPeaks_summary.peaks{1,col_index}.flatp_val(file_index) = ...
                val_flatp;
        end
        try
            DataPeaks_summary.fpd_end_index(file_index, col_index) = peak_end_index;
            DataPeaks_summary.fpd_end_value(file_index, col_index) = peak_end_value;
            DataPeaks_summary.fpd(file_index, col_index) = (peak_end_index-fpd_start_index)/fs;
        catch
            DataPeaks_summary.fpd_end_index(file_index, col_index) = NaN;
            DataPeaks_summary.fpd_end_value(file_index, col_index) = NaN;
            DataPeaks_summary.fpd(file_index, col_index) = NaN;    
        end

        clear peak_end_index peak_start_index val ind flat_peak_index end_index_for_data
        clear data_to_modified data_all clear datafil ind2 
    end
    running_file_index = running_file_index + 1;
end


end