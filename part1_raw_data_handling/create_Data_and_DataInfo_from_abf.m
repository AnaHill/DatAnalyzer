function [Data, DataInfo] = create_Data_and_DataInfo_from_abf....
    (raw_data,info_abf,file_index, datacolumns)
% create_Data_and_DataInfo_from_abf
    % data and file_index
    % DataInfo.framete now each separately, so pointing fs=DataInfo.framerate(index,1);
%%%%%%%%%%%%%%%%%%
% Data
    % Includes only data and file_index
% following not included in Data anymore --> reading from DataInfo
    % framerate
    % filename
    % measurement_time
    % measurement_name
    % experiment_name
    % framerate
    % MEA_electrode_numbers
    % MEA_columns
narginchk(2,4)
nargoutchk(0,2)

if nargin < 3 || isempty(file_index)
    file_index = 1;
end
if nargin < 4 || isempty(datacolumns)
    datacolumns = 1:min(size(raw_data));
end

if length(file_index) > 1
    file_index = file_index(1);
    disp('Only first value in file_index used')
end

try
   Data = evalin('base','Data');
catch
    Data = [];
end
try
   DataInfo = evalin('base','DataInfo');
catch
    DataInfo = [];
end

% info_abf has info read from abfload
DataInfo.file_type = '.abf';
DataInfo.measurement_type = 'MEA';
DataInfo.datacol_numbers = datacolumns;


DataInfo.framerate(file_index,1) = info_abf.dataPtsPerChan / ...
    (max(info_abf.recTime)-min(info_abf.recTime));

try 
    datetime = DataInfo.measurement_time.datetime(file_index,1);
catch
    file_name = DataInfo.file_names{file_index,1}; 
    [datetime] = convert_begin_string_in_filename_to_datetime(file_name);
end
if file_index == 1
   meas_duration =  datetime - datetime;
else
   meas_duration = datetime - DataInfo.measurement_time.datetime(1,1);
end
meas_time = datenum(meas_duration)* 24*60*60;
% DataInfo.folder_raw_files = 
 % calculate measurement duration and time in sec from the beging
DataInfo.measurement_time.datetime(file_index,1) = datetime;
DataInfo.measurement_time.duration(file_index,1) = meas_duration;
DataInfo.measurement_time.time_sec(file_index,1) = meas_time;

%% TODO TARKISTA ALLA OLEVAT
%% Creating Data from raw_data
% including only following in Data
Data{file_index,1}.data = raw_data(:,datacolumns);
Data{file_index,1}.file_index = file_index; 
disp(['MEA data (.abf) read: File#',num2str(file_index),'/',...
    num2str((DataInfo.files_amount))])
% try
%     disp(['MEA data (.abf) read: File#',num2str(file_index),'/',...
%         num2str((DataInfo.files_amount)),...
%         ', time: ',num2str(round(toc(tic_mea_read_this_round),1)),'s'])
% catch
%     disp(['MEA data (.abf) read: File#',num2str(file_index),'/',...
%         num2str((DataInfo.files_amount))])
% end

%%% ending statement
if file_index == DataInfo.files_amount
    try 
        tic_whole_read_mea_files = evalin('base','tic_whole_read_mea_files');
        disp(['MEA data read ',num2str(DataInfo.files_amount),...
            ' files, total time: ',num2str(round(toc(tic_whole_read_mea_files),0)),'s'])
    catch
       disp('ending')
    end
%     try
%     disp(['MEA data read ',num2str(DataInfo.files_amount),...
%         ' files, total time: ',num2str(round(toc(tic_whole_read_mea_files),0)),'s'])
%     catch
%         disp('ending')
%     end
end
 