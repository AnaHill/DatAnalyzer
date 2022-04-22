function [DataPeaks] = get_peak_signals(Data, DataInfo, Data_BPM,...
    time_range_from_peak, file_index_to_analyze, datacolumns)
% just get each peak signals
narginchk(0,6)
nargoutchk(0,1)

if nargin < 1 || isempty(Data) 
    try
        Data = evalin('base','Data');
    catch
        error('No Data')
    end
end

if nargin < 2 || isempty(DataInfo) 
    try
        DataInfo = evalin('base','DataInfo');
    catch
        error('No DataInfo')
    end
end

if nargin < 3 || isempty(Data_BPM) 
    try
        Data_BPM = evalin('base','Data_BPM');
    catch
        error('No Data_BPM')
    end
end
% default time: 0.2 sec backwards, 1.5 sec forward
if nargin < 4 || isempty(time_range_from_peak) 
    time_range_from_peak = [-.2 1.4]; 
    disp(['Default time range from each peak used: ', num2str(time_range_from_peak)])
else
    disp(['Using time range from each peak: ', num2str(time_range_from_peak)])
end
% default: every file is analyzed
if nargin < 5 || isempty(file_index_to_analyze) 
    file_index_to_analyze = 1:DataInfo.files_amount;
end

% default: all datacolumns plotted
if nargin < 6 || isempty(datacolumns) 
    datacolumns = 1:length(DataInfo.datacol_numbers);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file_index_to_analyze = unique(sort([file_index_to_analyze])); 

DataPeaks = [];
DataPeaks.data = {};
DataPeaks.file_index = [];
for kk = 1:length(file_index_to_analyze)
    % creates file_index, fs, time, and empty DataPeak
    get_file_parameters
    % slice data
    try
        for pp = 1:length(datacolumns)
            slice_peak_data % slices Data.data to DataPeak
        end
    catch
       disp('error'), kk, pp 
    end
    % add DataPeak to PeakSignals
    DataPeaks.data(end+1,:) = DataPeak;
    DataPeaks.file_index(end+1,1) = file_index;
    DataPeaks.time_range_from_peak = time_range_from_peak;
end


end