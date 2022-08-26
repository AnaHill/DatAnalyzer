% fpd2: finds depolarization start and calculates depolarization times
% outcomes
    % DataPeaks_summary.fpd_start_index
    % DataPeaks_summary.fpd_start_value
    % DataPeaks_summary.depolarization_time     
    
% if these are empty, using DataPeaks_summary.peaks.firstp_loc for the peak
start_index = []; 
end_index = []; 

filter_options = {'lowpass_iir','rlowess'}; % filtterit
used_filter = filter_options{1}; 
fs_low_freq = 1500; % lowpass frequency level
filter_parameters = [fs_low_freq, 0.95];

if ~exist('start_index_to_find_peak','var') || isempty(start_index)
    start_index = 1;
end
if ~exist('end_index','var') || isempty(end_index)
    end_index = nan; % default: löydetty DataPeaks_summary.peaks.firstp_loc
end

% max_or_min_value = 'max'; % finding maximum or minimum

if ~exist('threshold_level_from_baseline','var') 
    threshold_level_from_baseline = 0.1; % using default = 10%
end
% if 0.1% or more change around threshold, interpolate more points
if ~exist('ratio_threshold','var') || isempty(ratio_threshold)
    ratio_threshold = 0.1;
end
if ~exist('interpolation_gain','var') || isempty(interpolation_gain)
    interpolation_gain = 100;
end
if ~exist('filter_parameters','var') 
    filter_parameters = [];    % using default filter parameters
end

for file_ind = 1:length(DataPeaks_mean)
    disp(['Finding fpd start and depolarization time, file#',...
        num2str(file_ind),'/',num2str(length(DataPeaks_mean))])
    for col_ind = 1:length(DataInfo.datacol_numbers)
        try 
            fs = DataInfo.framerate(file_ind, col_ind);
        catch
            fs = DataInfo.framerate(file_ind); % each datacolumn has same fs
        end
        % start from zero first index if not given
        if ~exist('start_index_to_find_peak','var') || isempty(start_index) ...
                || isnan(start_index)
            start_index = 1;
        end
        % get end index from firstp_loc in DataPeaks_summary.peaks
        end_index = DataPeaks_summary.peaks{1,col_ind}.firstp_loc(file_ind);
        data = DataPeaks_mean{file_ind, 1}.data(start_index:end_index,col_ind);
        % filtering
        data_filtered = filter_data(data, fs, used_filter, filter_parameters,[],'no');
        
        data_current = data_filtered;
        % calculate baseline for depolarization amplitude using median (or mean?) 
        datapoints_for_baseline = round...
            (fs/4*abs(DataPeaks.time_range_from_peak(1)));
        baseline_value = median(data_current(1:datapoints_for_baseline));
        
        % calculate threshold value which used to find fpd start
        peak_value = data(end_index-start_index+1);
        threshold_value = calculate_threshold_value(peak_value, ...
            baseline_value, threshold_level_from_baseline);
        
        % find location where data reach threshold_value
        if peak_value < threshold_value
            % if threshold higher than peak  
            % -> find location where data sink below threshold
            threshold_index = find_first_index_where_data_reach_threshold...
                (data_current,threshold_value,'smaller');
        else
            % find when data rise above threshold value
            threshold_index = find_first_index_where_data_reach_threshold...
                (data_current, threshold_value,'larger');
        end
        
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
        
        % calculate fpd_start_value and t_dep, 
        % these will be updated later if interpolation needed 
        fpd_start_value = data_current(threshold_index);
        peak_end_index = DataPeaks_summary.peaks{1,col_ind}.firstp_loc(file_ind);
        % depolarization_time: fpd start to low peak
        t_dep = abs(threshold_index-peak_end_index)/fs;
        
        % if ratio_percent > ratio_threshold, interpolation is needed
        if ratio_percent >  ratio_threshold
            % interpolate more points around threshold
            dat = data_current(threshold_index-1:threshold_index);
            interpolation_gain_org = interpolation_gain;
            while ratio_percent >= ratio_threshold
                % interpolate more points around threshold
                xq = 1:1/interpolation_gain:length(dat);
                data_new = interp1(1:length(dat),dat,xq,'pchip')';
                if peak_value < threshold_value
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
            % fpd start value from interpolated data
            % but original threshold_index used for DataPeaks_summary.fpd_start_index
            fpd_start_value = data_new(threshold_index_new);
            % calculate t_dep
            peak_start_index = threshold_index - 1 + (threshold_index_new-1)/interpolation_gain;
            t_dep = abs(peak_start_index-peak_end_index)/fs;
        end
        interpolation_gain = interpolation_gain_org; % set original for the next round
        % Update DataPeaks_summary fpd and depolarization
        try
            DataPeaks_summary.fpd_start_index(file_ind, col_ind) = threshold_index;
            DataPeaks_summary.fpd_start_value(file_ind, col_ind) = fpd_start_value;
            DataPeaks_summary.depolarization_time(file_ind,col_ind) = t_dep;
            DataPeaks_summary.precise_fpd_start(file_ind,col_ind) = peak_start_index;
        catch
            DataPeaks_summary.fpd_start_index(file_ind, col_ind) = NaN;
            DataPeaks_summary.fpd_start_value(file_ind, col_ind) = NaN;
            DataPeaks_summary.depolarization_time(file_ind,col_ind) = NaN;
            DataPeaks_summary.precise_fpd_start(file_ind,col_ind) = NaN;
        end
        
            
    end % for col_ind
    
end % for file_ind_end
disp('DataPeaks_summary.fpd_start and depolarization time calculated.')
remove_other_variables_than_needed