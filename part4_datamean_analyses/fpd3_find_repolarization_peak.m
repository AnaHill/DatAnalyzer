% fpd3: finds repolization flat peak location with optional time window
% outcomes
    % DataPeaks_summary.peaks table including columns 
        % {'file_index','flatp_loc','flatp_val'}   
        
% if these are empty, using DataPeaks_summary.peaks.firstp_loc for the starting point
start_index = []; 
end_index = []; 

filter_options = {'lowpass_iir','rlowess'}; % filtterit
used_filter = filter_options{1}; 
% fs_low_freq = 1500; % lowpass frequency level
% filter_parameters = [fs_low_freq, 0.95];

if ~exist('filter_parameters','var') 
    filter_parameters = [];    % using default filter parameters
end

if ~exist('start_index','var') || isempty(start_index)
    start_index = nan; % default: using DataPeaks_summary.peaks.firstp_loc
end

if ~exist('end_index','var') || isempty(end_index)
    end_index = nan; % default: end of the signal
end



max_or_min_value = 'max'; % finding maximum or minimum

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

if ~exist('interpolation_gain','var') || isempty(interpolation_gain)
    max_or_min_value = 'max'; % default; finding maximum 
end
if ~exist('location_window_start_and_end_indexes','var') || ...
        isempty(location_window_start_and_end_indexes)
    % if nan, finding peak from whole data 
    location_window_start_and_end_indexes = nan; 
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
        % starting from DataPeaks_summary.peaks{col_ind}.firstp_loc if not given
        if ~exist('start_index','var') || isempty(start_index) ...
                || isnan(start_index)
            start_index = DataPeaks_summary.peaks{col_ind}.firstp_loc(file_ind);
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
       
    end    
    
end
% remove_other_variables_than_needed
