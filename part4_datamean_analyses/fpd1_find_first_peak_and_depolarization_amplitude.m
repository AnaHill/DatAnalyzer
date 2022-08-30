function DataPeaks_summary = fpd1_find_first_peak_and_depolarization_amplitude(...
    start_index_to_find_peak, end_index_to_find_peak, max_or_min_for_peak_value, ...
    DataInfo, DataPeaks_mean)
% function DataPeaks_summary = fpd1_find_first_peak_and_depolarization_amplitude(...
%     start_index_to_find_peak, end_index_to_find_peak, max_or_min_for_peak_value, ...
%     DataInfo, DataPeaks_mean)
% fpd calculation #1
% finds DataPeaks_summary.peaks first peaks and calculate depolarization amplitudes
% outcomes
    % DataPeaks_summary.depolarization_amplitude
    % DataPeaks_summary.peaks table including columns 
% Example: when DataPeaks_mean created, just run
% DataPeaks_summary = fpd1_find_first_peak_and_depolarization_amplitude;
max_inputs = 5;    
narginchk(0,max_inputs)
nargoutchk(0,1)
% default: whole data
if nargin < 1 || isempty(start_index_to_find_peak)
    start_index_to_find_peak = 1;
end
if nargin < 2 || isempty(end_index_to_find_peak)
    end_index_to_find_peak = nan;
end
% default: for first peak, finding minimum 
if nargin < 3 || isempty(max_or_min_for_peak_value)
    max_or_min_for_peak_value = 'min'; 
end
if nargin < max_inputs-1 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
        disp('DataInfo read from workspace.')
    catch
        error('No proper DataInfo!')
    end
end
if nargin < max_inputs || isempty(DataPeaks_mean)
    try
        DataPeaks_mean = evalin('base', 'DataPeaks_mean');
        disp('DataPeaks_mean read from workspace.')
    catch
        error('No proper DataPeaks_mean!')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    % find peak
    [peak_values, peak_location_indexes] = find_max_or_min(data,[],[],...
        max_or_min_for_peak_value); 
    % calculate baseline for depolarization amplitude
    % datapoints_for_baseline = round(fs/4*abs(DataPeaks.time_range_from_peak(1)));
    % update: now DataPeaks_mean{file_index} includes .time_range_from_peak
    datapoints_for_baseline = round(fs/4*abs(...
        DataPeaks_mean{file_ind, 1}.time_range_from_peak(1)));
    baseline_values = median(DataPeaks_mean{file_ind, 1}.data...
            (1:datapoints_for_baseline,:)); 
    % depolarisation amplitude: baseline - peak values
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

end 
disp('DataPeaks_summary.peaks first peak and depolarization amplitude calculated.')

end