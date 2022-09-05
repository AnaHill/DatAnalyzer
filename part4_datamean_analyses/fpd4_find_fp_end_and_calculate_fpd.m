function DataPeaks_summary = fpd4_find_fp_end_and_calculate_fpd(...
    starting_index, end_index, ...
    used_filter, filter_parameters,...
    threshold_level_from_baseline, acceptable_threshold_change_ratio,...
    DataInfo, DataPeaks_mean, DataPeaks_summary)
% fpd calculation #4
% finds signal end and calculates fpd
% default: second (flat) peak used for initial starting point to define signal end
% outcomes 
    % DataPeaks_summary.fpd_end_index
    % DataPeaks_summary.fpd_end_value
    % DataPeaks_summary.precise_fpd_end_index
    % DataPeaks_summary.fpd
% Examples
% with defaults: DataPeaks_summary = fpd4_find_fp_end_and_calculate_fpd;
max_inputs = 9;    
narginchk(0,max_inputs)
nargoutchk(0,1)


% default: if these are empty, finding fpd end between
% DataPeaks_summary.peaks.flatp_loc and signal end
if nargin < 1 || isempty(starting_index)
    % when nan, starting from DataPeaks_summary.peaks.flatp_loc
    starting_index = nan; 
end
if nargin < 2 || isempty(end_index) 
    end_index = nan; 
end

if ~isnan(all(starting_index)) && length(starting_index) > 1
   starting_index = starting_index(1);
   disp(['Set starting index to first starting_index(1) = ', num2str(starting_index)])
end
% filter; default is lowpass IIR filter at 200Hz with Steepness 0.95
if nargin < 3 || isempty(used_filter) 
    used_filter = 'lowpass_iir'; % default filter for fp-start
end
if nargin < 4 || isempty(filter_parameters)
    fs_low_freq = 200; % lowpass frequency level, typically used for fp-end
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

for file_ind = 1:length(DataPeaks_mean)
    disp(['Finding fp end and calculate fp-signal time (=fpd), file#',...
        num2str(file_ind),'/',num2str(length(DataPeaks_mean))])
    for col_ind = 1:length(DataInfo.datacol_numbers)
        %%
        try
            fs = DataInfo.framerate(file_ind, col_ind);
        catch
            fs = DataInfo.framerate(file_ind); % each datacolumn has same fs
        end
        if isnan(starting_index)
            % starting from DataPeaks_summary.peaks{col_ind}.flatp_loc 
            start_index = DataPeaks_summary.peaks{col_ind}.flatp_loc(file_ind);
            % disp(['Set start_index to flatpeak index: ',num2str(start_index)])
        else
            start_index = starting_index;
        end
        
        if isnan(end_index)
            % if ending index is not given, take end of data
            try
                data = DataPeaks_mean{file_ind, 1}.data(start_index:end,col_ind);
                end_index = length(data)+start_index-1;
            catch
               data = NaN; 
            end            
        else
            try
                data = DataPeaks_mean{file_ind, 1}.data(start_index:end_index,col_ind);
            catch
                data = NaN;
            end
        end
        if all(isnan(data))
            DataPeaks_summary.fpd_end_index(file_ind, col_ind) = NaN;
            DataPeaks_summary.fpd_end_value(file_ind, col_ind) = NaN;
            DataPeaks_summary.fpd(file_ind, col_ind) = NaN;
            DataPeaks_summary.precise_fpd_end_index(file_ind,col_ind) = NaN;
            continue
        end
        % now data is only from start_index to end, 
        % i.e. data(1) = DataPeaks_mean{file_ind, 1}.data(start_index)
        % filter_data(data, fs, filter_type, filter_parameters, plot_result,print_filter)
        data_filtered = filter_data(data, fs, used_filter, filter_parameters,'no','no');  
        data_current = data_filtered;
        
        % calculate baseline
        datapoints_for_baseline = round(fs/4*abs(...
            DataPeaks_mean{file_ind, 1}.time_range_from_peak(1)));
%         baseline_value = median(data_current(1:datapoints_for_baseline));
        baseline_value = median(DataPeaks_mean{file_ind, 1}.data...
            (1:datapoints_for_baseline,col_ind));
        
        % calculate threshold value which used to find fpd start
        peak_value = data(1);
        threshold_value = calculate_threshold_value(peak_value, ...
            baseline_value, threshold_level_from_baseline);
        % find location where data reach threshold_value
        if peak_value > threshold_value
            % if peak_value is larger than threshold 
            
            % check if threshold_value is reached, if not, estimate 
            % new baseline value by the end of the signal & estimate new
            % threshold value
            if min(data_current) > threshold_value
                baseline_value = median(DataPeaks_mean{file_ind, 1}.data...
                    (end-datapoints_for_baseline+1:end,col_ind));
                threshold_value = calculate_threshold_value(peak_value, ...
                    baseline_value, threshold_level_from_baseline);
            end
            
            % -> find location where data sink below threshold
            threshold_index = find_first_index_where_data_reach_threshold...
                (data_current, threshold_value,' smaller');
        else
            % find when data rise above threshold value
            % check if threshold_value is reached, if not, estimate 
            % new baseline value by the end of the signal & estimate new
            % threshold value
            if max(data_current) < threshold_value
                baseline_value = median(data_current...
                    (end-datapoints_for_baseline+1:end,1));
                threshold_value = calculate_threshold_value(peak_value, ...
                    baseline_value, threshold_level_from_baseline);
            end
            
            
            
            threshold_index = find_first_index_where_data_reach_threshold...
                (data_current, threshold_value,'larger');
        end
        % calculate fpd_end_value and fpd, 
        % these will be updated later if interpolation needed 
        fpd_end_index = threshold_index + start_index-1;
        fpd_end_value = data_current(threshold_index);
        fpd_start_index = DataPeaks_summary.precise_fpd_start_index(file_ind, col_ind);
        fp_duration = (fpd_end_index-fpd_start_index)/fs;
        
        % check if change between two indexes around threshold value is
        % relative large compared to difference between threshold and peak
        % if change is equal or more than acceptable_threshold_change_ratio (default: 0.1%),
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
        % if ratio_percent > acceptable_threshold_change_ratio, interpolation is needed
        if ratio_change_around_threshold >  acceptable_threshold_change_ratio
            % interpolate more points around threshold
            dat = data_current(threshold_index-1:threshold_index);
            interpolation_gain_org = interpolation_gain;
            while ratio_change_around_threshold >= acceptable_threshold_change_ratio
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
                ratio_change_around_threshold = change_around_threshold ...
                    / change_between_threshold_and_peak;
                if ratio_change_around_threshold >=  acceptable_threshold_change_ratio % update gain if needed
                    interpolation_gain = interpolation_gain * 100;
                end
            end
            % update values based on interpolated data
            % fpd end_value from interpolated data
            % but original threshold_index used for DataPeaks_summary.fpd_end_index
            fpd_end_value = data_new(threshold_index_new);
            fpd_end_index = threshold_index + start_index-1;
            fpd_end_index = fpd_end_index - 1 + (threshold_index_new-1)/interpolation_gain;
            fp_duration = (fpd_end_index-fpd_start_index)/fs;
            % set original interpolation_gain for the next round
            interpolation_gain = interpolation_gain_org;
        end
        

        
        % update DataPeaks_summary
        try
            % fpd_end_index = threshold_index + start_index-1;
            DataPeaks_summary.fpd_end_index(file_ind, col_ind) = threshold_index + start_index-1;
            DataPeaks_summary.fpd_end_value(file_ind, col_ind) = fpd_end_value;
            DataPeaks_summary.fpd(file_ind, col_ind) = fp_duration;
            DataPeaks_summary.precise_fpd_end_index(file_ind,col_ind) = fpd_end_index;
        catch
            DataPeaks_summary.fpd_end_index(file_ind, col_ind) = NaN;
            DataPeaks_summary.fpd_end_value(file_ind, col_ind) = NaN;
            DataPeaks_summary.fpd(file_ind, col_ind) = NaN;
            DataPeaks_summary.precise_fpd_end_index(file_ind,col_ind) = NaN;
        end
    end % for col_ind
   
end % for file_ind 
disp('DataPeaks_summary fp end_index and fpd calculated.')
end   
