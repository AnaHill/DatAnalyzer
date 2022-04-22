% create_Data_and_DataInfo_from_mea_data
% Data
    % Includes only data and file_index
% update 2021/04:
    % name changed: 
        % from create_Data_and_DataInfo --> create_Data_and_DataInfo_from_mea_data
    % DataInfo.framete now each separately, so pointing fs=DataInfo.framerate(index,1);
%%%%%%%%%%%%%%%%%%
    
if index == 1
   meas_duration =  datetime - datetime;
else
   meas_duration = datetime - DataInfo.measurement_time.datetime(1,1);
end
meas_time = datenum(meas_duration)* 24*60*60;

% update 2021/04: DataInfo.framerate has each own fs
DataInfo.framerate(index,1) = rawmeadata.framerate; 
% calculate measurement duration and time in sec from the beging
DataInfo.measurement_time.datetime(index,1) = datetime;
DataInfo.measurement_time.duration(index,1) = meas_duration;
DataInfo.measurement_time.time_sec(index,1) = meas_time;

% including only following in Data
Data{index,1}.data = chosen_mea_data;
Data{index,1}.file_index = index;


try
    disp(['MEA data read: File#',num2str(index),'/',...
        num2str((DataInfo.files_amount)),...
        ', time: ',num2str(round(toc(tic_mea_read_this_round),1)),'s'])
catch
    disp(['MEA data read: File#',num2str(index),'/',...
        num2str((DataInfo.files_amount))])
end

%%% ending statement
if index == DataInfo.files_amount
    try
    disp(['MEA data read ',num2str(DataInfo.files_amount),...
        ' files, total time: ',num2str(round(toc(tic_whole_read_mea_files),0)),'s'])
    catch
        disp('ending')
    end
end
  