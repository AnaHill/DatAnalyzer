function DataPeaks_summary = fpd2_find_fp_start_and_depolarization_time(...
    start_index, end_index, ...
    used_filter, filter_parameters,...
    threshold_level_from_baseline, acceptable_threshold_change_ratio,...
    DataInfo, DataPeaks_mean, DataPeaks_summary)
% fpd calculation #2
% finds depolarization signal start and calculates depolarization times
% outcomes
    % DataPeaks_summary.fpd_start_index
    % DataPeaks_summary.fpd_start_value
    % DataPeaks_summary.depolarization_time  
    % DataPeaks_summary.precise_fpd_start_index
% Examples
% with defaults: DataPeaks_summary = fpd2_find_fp_start_and_depolarization_time;
max_inputs = 9;    
narginchk(0,max_inputs)
nargoutchk(0,1)
% if start and end indexes are not given, finding 
% fp start from the begin to DataPeaks_summary.peaks.firstp_loc 
% start from zero first index if not given
if nargin < 1 || isempty(start_index) || isnan(start_index)
    start_index = 1;
end
% default: using DataPeaks_summary.peaks.firstp_loc --> end_index set to nan
if nargin < 2 || isempty(end_index) 
    end_index = nan; 
end
% filter; default is lowpass IIR filter at 1500Hz with Steepness 0.95
if nargin < 3 || isempty(used_filter) 
    used_filter = 'lowpass_iir'; % default filter for fp-start
end
if nargin < 4 || isempty(filter_parameters)
    fs_low_freq = 1500; % lowpass frequency level, typically used for fp-start
    filter_parameters = [fs_low_freq, 0.95];
end
if length(filter_parameters) == 1
    filter_parameters(2) = 0.95; % default iir steepness, see filter_data function
end
if nargin < 5 || isempty(threshold_level_from_baseline)
    % using default 10% to mark as threshold
   threshold_level_from_baseline = 0.1; % equals 10%
end

if nargin < 6 || isempty(acceptable_threshold_change_ratio)
    % using default 0.10% as acceptable level when fp-start it estimated 
   acceptable_threshold_change_ratio = 0.001; % equals 0.10%
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

% if interpolation is needed, in how many subindexes or orignal index interval is divided into
interpolation_gain = 100; 

%% 
for file_ind = 1:length(DataPeaks_mean)
    disp(['Finding fpd start and depolarization time, file#',...
        num2str(file_ind),'/',num2str(length(DataPeaks_mean))])
    for col_ind = 1:length(DataInfo.datacol_numbers)
        try 
            fs = DataInfo.framerate(file_ind, col_ind);
        catch
            fs = DataInfo.framerate(file_ind); % each datacolumn has same fs
        end

        if isnan(end_index) 
            % get index from firstp_loc in DataPeaks_summary.peaks if not given
            end_index = DataPeaks_summary.peaks{1,col_ind}.firstp_loc(file_ind);
        end
        data = DataPeaks_mean{file_ind, 1}.data(start_index:end_index,col_ind);
        % filtering
        % filter_data(data, fs, filter_type, filter_parameters, plot_result,print_filter)
        data_filtered = filter_data(data, fs, used_filter, filter_parameters,'no','no');   
        data_current = data_filtered;
        
        % calculate baseline for depolarization amplitude using median (or mean?) 
        datapoints_for_baseline = round(fs/4*abs(...
            DataPeaks_mean{file_ind, 1}.time_range_from_peak(1)));
        baseline_value = median(data_current(1:datapoints_for_baseline));
        
        % calculate threshold value which used to find fpd start
        peak_index = end_index-start_index+1;
        peak_value = data(peak_index);
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
        ratio_change_around_threshold = change_around_threshold ...
            / change_between_threshold_and_peak;
        
        % calculate fpd_start_value and t_dep, 
        % these will be updated later if interpolation needed 
        peak_start_index = threshold_index + start_index-1;
        fpd_start_value = data_current(threshold_index);
        % depolarization_time: fpd start to low peak
        t_dep = abs(threshold_index-peak_index)/fs;
        
        % if ratio_percent > ratio_threshold, interpolation is needed
        if ratio_change_around_threshold >  acceptable_threshold_change_ratio
            % interpolate more points around threshold
            dat = data_current(threshold_index-1:threshold_index);
            interpolation_gain_org = interpolation_gain;
            while ratio_change_around_threshold  >= acceptable_threshold_change_ratio
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
                ratio_change_around_threshold = change_around_threshold ...
                    / change_between_threshold_and_peak;
                if ratio_change_around_threshold  >= acceptable_threshold_change_ratio
                    % multiple gain if needed by 100x
                    interpolation_gain = interpolation_gain * 100;
                end
            end
            % update values based on interpolated data
            % fpd start value from interpolated data
            % but original threshold_index used for DataPeaks_summary.fpd_start_index
            fpd_start_value = data_new(threshold_index_new);
            peak_start_index = threshold_index - 1 + ...
                (threshold_index_new-1)/interpolation_gain;
            % calculate t_dep based on interpolated index
            t_dep = abs(peak_start_index-peak_index)/fs;
        end

        % Update DataPeaks_summary fpd and depolarization
        try
            DataPeaks_summary.fpd_start_index(file_ind, col_ind) = threshold_index + start_index-1;
            DataPeaks_summary.fpd_start_value(file_ind, col_ind) = fpd_start_value;
            DataPeaks_summary.depolarization_time(file_ind,col_ind) = t_dep;
            DataPeaks_summary.precise_fpd_start_index(file_ind,col_ind) = peak_start_index;
        catch
            DataPeaks_summary.fpd_start_index(file_ind, col_ind) = NaN;
            DataPeaks_summary.fpd_start_value(file_ind, col_ind) = NaN;
            DataPeaks_summary.depolarization_time(file_ind,col_ind) = NaN;
            DataPeaks_summary.precise_fpd_start_index(file_ind,col_ind) = NaN;
        end
        
            
    end
    
end

disp('DataPeaks_summary.fpd_start and depolarization time calculated.')

end