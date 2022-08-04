function Data_BPM_summary = include_peak_distance_matrix_to_Data_BPM_summary(...
    file_indexes, datacolumn_indexes, Data_BPM, Data_BPM_summary, DataInfo)
% function Data_BPM_summary = include_peak_distance_matrix_to_Data_BPM_summary(...
%     file_indexes, datacolumn_indexes, Data_BPM, Data_BPM_summary, DataInfo)



%% check input values
max_inputs = 5;
narginchk(0,max_inputs)
nargoutchk(0,1)

if nargin < max_inputs || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end

% default: all file_indexes 
if nargin < 1 || isempty(file_indexes)
    file_indexes = 1:DataInfo.files_amount;
end
% default: all column indexes
if nargin < 2 || isempty(datacolumn_indexes)
    datacolumn_indexes = 1:length(DataInfo.datacol_numbers);
end

% default: if Data_BPM not given, trying to read Data_BPM 
if nargin < 3 || isempty(Data_BPM)
    try
        Data_BPM = evalin('base','Data_BPM');
    catch 
        error('No proper Data_BPM found!')
    end
end

% default: if Data_BPM_summary not given, trying to read Data_BPM 
if nargin < 4 || isempty(Data_BPM_summary)
    try
        Data_BPM_summary = evalin('base','Data_BPM_summary');
    catch
        try % create Data_BPM_summary
            Data_BPM_summary = create_BPM_summary;
        catch
            error('No proper Data_BPM_summary found or could not be created!')
        end
    end
end
% create matrix
matrix_of_values = []; 

for kk = datacolumn_indexes
    times_and_values = [];
    for pp = file_indexes
        peak_indexes = Data_BPM{pp, 1}.peak_locations{kk};
        fs = DataInfo.framerate(pp);
        starting_time = DataInfo.measurement_time.time_sec(pp);
        peak_times_sec = convert_indexes_to_sec(peak_indexes,fs,starting_time);
        % now, delete first time points, as values are calculated between 
        % distances of two peaks --> first value is between time indexes 2 and 1
        % First value = peak distance at time point 2
        peak_times_sec = peak_times_sec(2:end);
        values = Data_BPM{pp, 1}.peak_distances_in_ms{kk}*1e-3; % in sec
        times_and_values = [times_and_values; [peak_times_sec values]];
    end
    matrix_of_values{end+1} = times_and_values;
end

% Update Data_BPM_summary with field peak_distance_with_running_index
disp('Add matrix Data_BPM_summary.peak_distance_with_running_index');
Data_BPM_summary.peak_distance_with_running_index = matrix_of_values;
end