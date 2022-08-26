% fpd1: calculates DataPeaks_summary.peaks first peaks and depolarization amplitudes
% outcomes
    % DataPeaks_summary.depolarization_amplitude
    % DataPeaks_summary.peaks table including columns 
        % {'file_index','firstp_loc','firstp_val'}   
    
if ~exist('start_index_to_find_peak','var') || isempty(start_index_to_find_peak)
    start_index_to_find_peak = 1;
end
if ~exist('end_index_to_find_peak','var') || isempty(end_index_to_find_peak)
    end_index_to_find_peak = nan;
end
if ~exist('threshold_level_from_baseline','var') 
    threshold_level_from_baseline = [];    % default = 10%
end

max_or_min_value = 'min'; % finding minimum for low peak and fpd start         
DataPeaks_summary = [];
DataPeaks_summary.peaks = [];
for col_ind = 1:length(DataInfo.datacol_numbers)
    DataPeaks_summary.peaks{1,col_ind} = [];
end
DataPeaks_summary.depolarization_amplitude = [];

for file_ind = 1:length(DataPeaks_mean)
    if isempty(end_index_to_find_peak) || isnan(end_index_to_find_peak)
        data = DataPeaks_mean{file_ind, 1}.data...
            (start_index_to_find_peak:end,:);
    else
        data = DataPeaks_mean{file_ind, 1}.data...
            (start_index_to_find_peak:end_index_to_find_peak,:);       
    end
    fs = DataInfo.framerate(file_ind);
    % get max (or min if chosen)
    [peak_values, peak_location_indexes] = find_max_or_min(data,[],[],'min'); 
    % calculate baseline for depolarization amplitude
    datapoints_for_baseline = round(fs/4*abs(DataPeaks.time_range_from_peak(1)));
    baseline_values = median(DataPeaks_mean{file_ind, 1}.data...
            (1:datapoints_for_baseline,:)); % mean or median?    
    for col_ind = 1:length(DataInfo.datacol_numbers)
        peaks_summary = [file_ind peak_location_indexes(col_ind) ...
            peak_values(col_ind)];
        DataPeaks_summary.peaks{1,col_ind} = ...
            [DataPeaks_summary.peaks{1,col_ind}; ...
            array2table(peaks_summary, 'VariableNames',...
             {'file_index','firstp_loc','firstp_val'})];     
    end
    % depolarisation amplitude: baseline-peak
    DataPeaks_summary.depolarization_amplitude(file_ind,:) = ...
        peak_values - baseline_values;
end % for file_ind_end
disp('DataPeaks_summary.peaks first peak and depolarization amplitude calculated.')
remove_other_variables_than_needed