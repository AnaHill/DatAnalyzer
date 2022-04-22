%%%%%% file parameters
file_index = file_index_to_analyze(kk);
fs = DataInfo.framerate(file_index);
index_from_peak = time_range_from_peak*fs;
time = 0:1/fs:(abs(diff(index_from_peak)))/fs;
DataPeak = cell(1,length(datacolumns));