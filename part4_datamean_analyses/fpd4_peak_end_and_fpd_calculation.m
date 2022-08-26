% fpd4: finds signal end and calculates fpd
% second (flat) peak used for initial starting point to define signal end
% outcomes 
    % DataPeaks_summary.fpd_end_index =[];
    % DataPeaks_summary.fpd_end_value = [];
    % DataPeaks_summary.fpd = [];

% if these are empty, finding fpd end between
% DataPeaks_summary.peaks.flatp_loc and signal end
% start_index = []; 
% end_index = []; 
if ~exist('start_index','var') || isempty(start_index)
    start_index = nan; % default: using DataPeaks_summary.peaks.flatp_loc
end
if ~exist('end_index','var') || isempty(end_index)
    end_index = nan; % default: end of the signal
end

filter_options = {'lowpass_iir','rlowess'}; 
used_filter = filter_options{1}; 
if ~exist('filter_parameters','var') 
    filter_parameters = []; % using default filter parameters 
end    

if ~exist('threshold_level_from_baseline','var') 
    threshold_level_from_baseline = []; % using default = 10%
end
% if 0.1% or more change around threshold, interpolate more points
if ~exist('ratio_threshold','var') || isempty(ratio_threshold)
    ratio_threshold = 0.1;
end
if ~exist('interpolation_gain','var') || isempty(interpolation_gain)
    interpolation_gain = 100;
end

for file_ind = 1:length(DataPeaks_mean)
    disp(['Finding fpd end and calcaute total fpd time, file#',...
        num2str(file_ind),'/',num2str(length(DataPeaks_mean))])
    for col_ind = 1:length(DataInfo.datacol_numbers)
        try
            fs = DataInfo.framerate(file_ind, col_ind);
        catch
            fs = DataInfo.framerate(file_ind); % each datacolumn has same fs
        end
        % starting from DataPeaks_summary.peaks{col_ind}.flatp_loc if not given
        if ~exist('start_index','var') || isempty(start_index) ...
                || isnan(start_index)
            start_index = DataPeaks_summary.peaks{col_ind}.flatp_loc(file_ind);
        end
        % if no ending given, take end of data
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
        % fig_full, plot(data,'.-'), hold all, plot(data_filtered,'--'), plot(peak_location,peak_value,'ro','markersize', 30)
        data_current = data_filtered;
        % calculate baseline 
        datapoints_for_baseline = round...
            (fs/4*abs(DataPeaks.time_range_from_peak(1)));
        baseline_value = median(DataPeaks_mean{file_ind, 1}.data...
            (1:datapoints_for_baseline,col_ind));
        
        % calculate threshold value which used to find fpd end
        peak_value = DataPeaks_summary.peaks{col_ind}.flatp_val(file_ind);
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
        
        
        
        
        
        
        % find peak (maximum or minimum)
        [peak_value, peak_location] = find_max_or_min...
            (data_filtered, start_index_for_search, ...
            location_window_start_and_end_indexes, max_or_min_value);
        % fig_full, plot(data,'.-'), hold all, plot(data_filtered,'--'), plot(peak_location,peak_value,'ro','markersize', 30)
        flatp_loc = peak_location + start_index-1;
        DataPeaks_summary.peaks{1,col_ind}.flatp_loc(file_ind) = ...
            flatp_loc;
        DataPeaks_summary.peaks{1,col_ind}.flatp_val(file_ind) = ...
            peak_value;
        
        % update DataPeaks_summary
        try
            DataPeaks_summary.fpd_end_index(file_ind, col_ind) = fpd_end_index;
            DataPeaks_summary.fpd_end_value(file_ind, col_ind) = fpd_end_value;
            % TODO: päivitä oikeaksi mistä piikki alkaa
            DataPeaks_summary.fpd(file_ind, col_ind) = (fpd_end_index-fpd_start_index)/fs;
        catch
            DataPeaks_summary.fpd_end_index(file_ind, col_ind) = NaN;
            DataPeaks_summary.fpd_end_value(file_ind, col_ind) = NaN;
            DataPeaks_summary.fpd(file_index, col_ind) = NaN;
        end
        
    
         clear start_index
    end % for col_ind
   
end % for file_ind 
disp('DataPeaks_summary fp end_index and fpd calculated.')
remove_other_variables_than_needed    
   
%% poista
for pp=1
    if isempty(end_index_to_find_peak) || isnan(end_index_to_find_peak)
        data = DataPeaks_mean{file_ind, 1}.data...
            (start_index_to_find_peak:end,:);
    else
        data = DataPeaks_mean{file_ind, 1}.data...
            (start_index_to_find_peak:end_index_to_find_peak,:);       
    end
    % filter data
    % data_filtered on nyt lähtien indeksistä start_index_to_find_peak
    data_filtered = filter_data(data, fs, used_filter, [], 'no');
    % get max (or min if chosen)
    [peak_values, loc_index] = find_max_or_min...
        (data_filtered,[],[],max_or_min_value); 
    peak_location_indexes = loc_index + start_index_to_find_peak-1;
    
    % find flatpeak end
    % calculate threshold value which used to find flatpeak end
    datapoints_for_baseline = round(fs/4*abs(DataPeaks.time_range_from_peak(1)));
    baseline_values = median(DataPeaks_mean{file_ind, 1}.data...
        (1:datapoints_for_baseline,:)); % mean or median?    
    threshold_values = calculate_threshold_value(peak_values, ...
        baseline_values, threshold_level_from_baseline);
%     TESTAILUJA_piirtoja
    
    % DataPeaks_summary.fpd_end_value(file_ind, col_ind) = peak_end_value;
    
    %%%%% päivitä muuttujat, TODO: tee oma funktio
    for col_ind = 1:length(DataInfo.datacol_numbers) 
        % check if peak value is positive (negative) if maximum (minimum) value is found
            % Tarvitaanko: check if value is above (below) threshold
        peak_info = find_peak_info(peak_values(col_ind), max_or_min_value);
        if contains(peak_info,'Unexpected')
            DataPeaks_summary.peaks{1,col_ind}.flatp_loc(file_ind) = NaN;
            DataPeaks_summary.peaks{1,col_ind}.flatp_val(file_ind) = NaN;
            DataPeaks_summary.fpd_end_index(file_ind, col_ind) = NaN;
            DataPeaks_summary.fpd_end_value(file_ind, col_ind) = NaN;
            DataPeaks_summary.fpd(file_index, col_ind) = NaN;    
        else % mikäli ns hyväksyttävä piikki löydetty
            DataPeaks_summary.peaks{1,col_ind}.flatp_loc(file_ind) = ...
                peak_location_indexes(col_ind);
            DataPeaks_summary.peaks{1,col_ind}.flatp_val(file_ind) = ...
                peak_values(col_ind);
            % etsi flatpeak_end
            dat = data_filtered(loc_index(col_ind):end,col_ind);
            % peak_location_indexes = loc_index + start_index_to_find_peak-1;
            if peak_values(col_ind) > threshold_values(col_ind)
                % if peak higher than threshold --> find location where data reachs t 
                threshold_index = find(dat <= threshold_values(col_ind),1,'first');
            else % find when data rises above threshold value
                threshold_index = find(dat >= threshold_values(col_ind),1,'first');
            end
            fpd_end_index = threshold_index + loc_index(col_ind)-1 + start_index_to_find_peak-1;
            fpd_end_value = dat(threshold_index);
            
            try 
                DataPeaks_summary.fpd_end_index(file_ind, col_ind) = fpd_end_index;
                DataPeaks_summary.fpd_end_value(file_ind, col_ind) = fpd_end_value;
                % TODO: päivitä oikeaksi mistä piikki alkaa
                DataPeaks_summary.fpd(file_ind, col_ind) = (fpd_end_index-fpd_start_index)/fs;
            catch
                DataPeaks_summary.fpd_end_index(file_ind, col_ind) = NaN;
                DataPeaks_summary.fpd_end_value(file_ind, col_ind) = NaN;
                DataPeaks_summary.fpd(file_index, col_ind) = NaN;
            end
        end
        

    end
end
