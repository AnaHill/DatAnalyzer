function [DataPeaks] = get_peak_signals(time_range_from_peak, file_indexes, datacolumns,...
    Data, DataInfo, Data_BPM)
% DataPeaks = get_peak_signals(time_range_from_peak, file_indexes, datacolumns,Data, DataInfo, Data_BPM)
% Slice and get get each peak signals
narginchk(0,6)
nargoutchk(0,1)

% default time: 0.2 sec backwards, 1.4 sec forward
if nargin < 1 || isempty(time_range_from_peak) 
    time_range_from_peak = [-.2 1.4]; 
    disp(['Default time range from each peak used: ', num2str(time_range_from_peak)])
else
    disp(['Using time range from each peak: ', num2str(time_range_from_peak)])
end

if nargin < 4 || isempty(Data) 
    try
        Data = evalin('base','Data');
    catch
        error('No Data')
    end
end

if nargin < 5 || isempty(DataInfo) 
    try
        DataInfo = evalin('base','DataInfo');
    catch
        error('No DataInfo')
    end
end

if nargin < 6 || isempty(Data_BPM) 
    try
        Data_BPM = evalin('base','Data_BPM');
    catch
        error('No Data_BPM')
    end
end

% default: every file is analyzed
if nargin < 2 || isempty(file_indexes) 
    file_indexes = 1:DataInfo.files_amount;
end

% default: all datacolumns plotted
if nargin < 3 || isempty(datacolumns) 
    datacolumns = 1:length(DataInfo.datacol_numbers);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file_indexes = unique(sort([file_indexes])); 

DataPeaks = [];
DataPeaks.data = {};
DataPeaks.file_index = [];
for kk = 1:length(file_indexes)
    % creates file_index, fs, time, and empty DataPeak
    file_index = file_indexes(kk);
    fs = DataInfo.framerate(file_index);
    index_from_peak = time_range_from_peak*fs;
    time = 0:1/fs:(abs(diff(index_from_peak)))/fs;
    DataPeak = cell(1,length(datacolumns));
    % slice data
    try
        for pp = 1:length(datacolumns)
            col = datacolumns(pp);
            slice_peak_data % slices Data.data to DataPeak
        end
    catch
       disp('error'), % kk, pp 
    end
    % add DataPeak to PeakSignals
    DataPeaks.data(end+1,:) = DataPeak;
    DataPeaks.file_index(end+1,1) = file_index;
    DataPeaks.time_range_from_peak = time_range_from_peak;
    clear DataPeak file_index fs index_from_peak time
end


end