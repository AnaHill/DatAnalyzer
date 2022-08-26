% fpd4: finds signal end and calculates fpd
% second (flat) peak used for initial starting point to define signal end
% outcomes 
    % DataPeaks_summary.fpd_end_index
    % DataPeaks_summary.fpd_end_value
    % DataPeaks_summary.precise_fpd_end
    % DataPeaks_summary.fpd

% if these are empty, finding fpd end between
% DataPeaks_summary.peaks.flatp_loc and signal end
% start_index = []; 
% end_index = []; 
if ~exist('end_index','var') || isempty(end_index)
    end_index = NaN; % default: end of the signal
end

filter_options = {'lowpass_iir','rlowess'}; 
if ~exist('filter_parameters','var') 
    filter_parameters = []; % using default filter parameters 
    used_filter = filter_options{1}; % using lowpass_iir
end    

if ~exist('threshold_level_from_baseline','var') 
    threshold_level_from_baseline = 0.10; % using default = 10%
end

% if 0.1% or more change around threshold, interpolate more points
if ~exist('ratio_threshold','var') || isempty(ratio_threshold)
    ratio_threshold = 0.1;
end

% interpolation gain; how many times data is divided into smaller parts
if ~exist('interpolation_gain','var') || isempty(interpolation_gain)
    interpolation_gain = 100;
end

for file_ind = 1:length(DataPeaks_mean)
    disp(['Finding fpd end and calculate total fpd time, file#',...
        num2str(file_ind),'/',num2str(length(DataPeaks_mean))])
    for col_ind = 1:length(DataInfo.datacol_numbers)
        %%
        try
            fs = DataInfo.framerate(file_ind, col_ind);
        catch
            fs = DataInfo.framerate(file_ind); % each datacolumn has same fs
        end
        % starting from DataPeaks_summary.peaks{col_ind}.flatp_loc 
        try
            start_index = DataPeaks_summary.peaks{col_ind}.flatp_loc(file_ind);
            % disp(['Set start_index to flatpeak index: ',num2str(start_index)])
        catch
            start_index = 1;
            disp('Set start_index to one.')
        end
        
        % if ending index is not given, take end of data
        
        if  ~exist('end_index','var') || isempty(end_index) || isnan(end_index)
            data = DataPeaks_mean{file_ind, 1}.data(start_index:end,col_ind);
            end_index_for_search = length(data);
        else
            data = DataPeaks_mean{file_ind, 1}.data(start_index:end_index,col_ind);
            end_index_for_search = end_index-start_index+1;
        end
        
        start_index_for_search = 1; % filtered data started from start_index
        % filtering
        data_filtered = filter_data(data, fs, used_filter, ...
            filter_parameters,[],'no');
        % fig_full, plot(data,'.-'), hold all, plot(data_filtered,'--'),
        data_current = data_filtered;
        % calculate baseline 
        datapoints_for_baseline = round...
            (fs/4*abs(DataPeaks.time_range_from_peak(1)));
        baseline_value = median(DataPeaks_mean{file_ind, 1}.data...
            (1:datapoints_for_baseline,col_ind));
        
        % calculate threshold value which used to find fpd end
        try
            peak_value = DataPeaks_summary.peaks{col_ind}.flatp_val(file_ind);
            % disp(['Use found flatpeak value as peak: ',num2str(peak_value)])
        catch
            peak_value = max(data_current);
            disp(['Set maximum of data as peak value: ',num2str(peak_value)])
        end
        
        threshold_value = calculate_threshold_value(peak_value, ...
            baseline_value, threshold_level_from_baseline);
        
        % find location where data reach threshold_value
        if peak_value >= threshold_value
            % if threshold higher than peak  
            % -> find location where data sink below threshold
            threshold_index = find_first_index_where_data_reach_threshold...
                (data_current,threshold_value,'smaller');
        else % find when data rise above threshold value
            threshold_index = find_first_index_where_data_reach_threshold...
                (data_current, threshold_value,'larger');
        end

        % calculate fpd_start_value and t_dep, 
        % these will be updated later if interpolation needed 
        fpd_end_index = threshold_index + start_index-1;
        fpd_end_value = data_current(threshold_index);
        fpd_start_index = DataPeaks_summary.precise_fpd_start(file_ind, col_ind);
        fp_duration = (fpd_end_index-fpd_start_index)/fs;
        
        % check if change between two indexes around threshold value is
        % relative large compared to difference between threshold and peak
        % if change is equal or more than ratio_threshold (default: 0.1%),
        % interpolate more points
        change_between_threshold_and_peak = ...
            abs(diff([peak_value,threshold_value]));
        change_around_threshold = 0; % if data never on both side of the threshold
        if threshold_index > 1 % if threshold location was found
            change_around_threshold = ...
                abs(diff(data_current(threshold_index-1:threshold_index)));
        end
        % ratio between change in around threshold and the full change 
        ratio_percent = change_around_threshold ...
            / change_between_threshold_and_peak *100;       
        % if ratio_percent > ratio_threshold, interpolation is needed
        if ratio_percent >  ratio_threshold
            % interpolate more points around threshold
            dat = data_current(threshold_index-1:threshold_index);
            interpolation_gain_org = interpolation_gain;
            while ratio_percent >= ratio_threshold
                % interpolate more points around threshold
                xq = 1:1/interpolation_gain:length(dat);
                data_new = interp1(1:length(dat),dat,xq,'pchip')';
                if peak_value > threshold_value
                    % values reducing
                    threshold_index_new = find_first_index_where_data_reach_threshold...
                        (data_new,threshold_value,'smaller');
                else
                    % find when data rises above threshold value
                    threshold_index_new = find_first_index_where_data_reach_threshold...
                        (data_new, threshold_value,'larger');
                end
                % calculate change around this new index
                if threshold_index_new > 1 % if threshold location was found
                    change_around_threshold = ...
                        abs(diff(data_new(threshold_index_new-1:threshold_index_new)));
                else
                    change_around_threshold = 0;
                end
               % calculate new ratio
                ratio_percent = change_around_threshold ...
                    / change_between_threshold_and_peak * 100;
                if ratio_percent >=  ratio_threshold % update gain if needed
                    interpolation_gain = interpolation_gain * 100;
                end
            end
            % update values based on interpolated data
            % fpd end_value from interpolated data
            % but original threshold_index used for DataPeaks_summary.fpd_end_index
% %             fpd_start_value = data_new(threshold_index_new);
% %             % calculate t_dep
% %             peak_start_index = threshold_index + (threshold_index_new-1)/interpolation_gain;
% %             t_dep = abs(peak_start_index-peak_end_index)/fs;

            fpd_end_value = data_new(threshold_index_new);
            fpd_end_index = threshold_index - 1 + (threshold_index_new-1)/interpolation_gain;
            fp_duration = (fpd_end_index-fpd_start_index)/fs;
            interpolation_gain = interpolation_gain_org;
        end
        % update DataPeaks_summary
        try
            DataPeaks_summary.fpd_end_index(file_ind, col_ind) = fpd_end_index;
            DataPeaks_summary.fpd_end_value(file_ind, col_ind) = fpd_end_value;
            DataPeaks_summary.fpd(file_ind, col_ind) = fp_duration;
            DataPeaks_summary.precise_fpd_end(file_ind,col_ind) = fpd_end_index;
        catch
            DataPeaks_summary.fpd_end_index(file_ind, col_ind) = NaN;
            DataPeaks_summary.fpd_end_value(file_ind, col_ind) = NaN;
            DataPeaks_summary.fpd(file_index, col_ind) = NaN;
            DataPeaks_summary.precise_fpd_end(file_ind,col_ind) = NaN;
        end
         clear start_index
    end % for col_ind
   
end % for file_ind 
disp('DataPeaks_summary fp end_index and fpd calculated.')
remove_other_variables_than_needed    
   
