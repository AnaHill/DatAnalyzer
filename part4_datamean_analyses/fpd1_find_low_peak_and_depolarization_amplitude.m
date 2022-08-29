function DataPeaks_summary = fpd1_find_low_peak_and_depolarization_amplitude(...
    start_index_to_find_peak, end_index_to_find_peak, DataInfo, DataPeaks_mean)
% fpd calculation #1
% finds DataPeaks_summary.peaks first peaks and calculate depolarization amplitudes
% outcomes
    % DataPeaks_summary.depolarization_amplitude
    % DataPeaks_summary.peaks table including columns 
        % {'file_index','firstp_loc','firstp_val'}   
start_index_to_find_peak, end_index_to_find_peak, max_or_min_value
narginchk(0,4)
nargoutchk(0,1)
% default: whole data
if nargin < 1 || isempty(start_index_to_find_peak)
    start_index_to_find_peak = 1;
end
if nargin < 2 || isempty(end_index_to_find_peak)
    end_index_to_find_peak = nan;
end
if nargin < 3 || isempty(DataInfo)
    
end

% finding minimum for low peak and fpd start
max_or_min_value = 'min'; 


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
    [peak_values, peak_location_indexes] = find_max_or_min(data,[],[],...
        max_or_min_value); 
    % calculate baseline for depolarization amplitude
    datapoints_for_baseline = round(fs/4*abs(DataPeaks.time_range_from_peak(1)));
    baseline_values = median(DataPeaks_mean{file_ind, 1}.data...
            (1:datapoints_for_baseline,:)); % mean or median?   
    % depolarisation amplitude: baseline-peak
    DataPeaks_summary.depolarization_amplitude(file_ind,:) = ...
        peak_values - baseline_values;    
    % update DataPeaks_summary.peaks tables
    for col_ind = 1:length(DataInfo.datacol_numbers)
        peaks_summary = [file_ind peak_location_indexes(col_ind) ...
            peak_values(col_ind)];
        DataPeaks_summary.peaks{1,col_ind} = ...
            [DataPeaks_summary.peaks{1,col_ind}; ...
            array2table(peaks_summary, 'VariableNames',...
             {'file_index','firstp_loc','firstp_val'})];     
    end

end % for file_ind_end
disp('DataPeaks_summary.peaks first peak and depolarization amplitude calculated.')
% remove_other_variables_than_needed

end