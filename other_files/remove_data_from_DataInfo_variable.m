function DataInfo = remove_data_from_DataInfo_variable(...
    file_indexes, column_indexes, remove_whole_file, DataInfo)
% function DataInfo = remove_data_from_DataInfo_variable(...
%     file_indexes, column_indexes, remove_whole_file, DataInfo)
% removes certain info from DataInfo variable
% Examples:
% remove fully certain files from data
    % file_ind_to_remove = [1,5,10]; 
    % DataInfo = remove_data_from_DataInfo_variable(file_ind_to_remove,1,'yes')
% remove last datacolumn from each Data{}.data variable
    % assumes, that each has same amount of datacolumns!
    % col_ind = length(DataInfo.datacol_numbers);
    % col_ind = length(Data{1}.data(1,:)); % if DataInfo not updated
    % file_ind = 1:DataInfo.files_amount;
    % file_ind = 1:length(Data); % if DataInfo not updated
    % DataInfo = remove_data_from_DataInfo_variable(file_ind,col_ind);

% Testing: 
% remove files
% DataInfo = DataInfo2;DataInfo = remove_data_from_DataInfo_variable([1,3,47],1,'yes')
% remove columns
% DataInfo = DataInfo2;DataInfo = remove_data_from_DataInfo_variable([1:47],[11])


% check function call
max_inputs = 4;
narginchk(2,max_inputs)
nargoutchk(1,1)

% default: not remove_whole_file
if nargin < max_inputs - 1 || isempty(remove_whole_file)
    remove_whole_file = 'no';
end
% get data from workspace if not given
if nargin < max_inputs || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo given or found from workspace.')
    end
end

file_indexes = sort(unique(file_indexes));
column_indexes = sort(unique(column_indexes));
if strcmp(remove_whole_file,'yes') || ...
        isequal(column_indexes,1:length(DataInfo.datacol_numbers))
    disp(['Fully remove data from these file indexes: ', num2str(file_indexes)])
    % disp('Set column indexes to every column')
    column_indexes = 1:length(DataInfo.datacol_numbers);
    remove_whole_file = 'yes';
else
    disp(['Removing following data from DataInfo variable'])
    disp(['File indexes: ', num2str(file_indexes)])
    disp(['Data column indexes: ', num2str(column_indexes)])
end
% check file_indexes; should not be below one or larger than amount of cells in Data
    % some give file_indexes are not correct if size of 
    % combined intersection is smaller than file_indexes
if length(intersect(file_indexes,1:DataInfo.files_amount)) < length(file_indexes)
    error('Check file indexes!')
end
% check datacolumn indexes; should not be below one
if any(column_indexes < 1) 
    error('Check column indexes!')
end
% if all file_indexes are chosen, certain data column indexes are fully removed
if isequal(file_indexes,1:DataInfo.files_amount)
    disp(['Removing following datacolumn indexes from everywhere: ',num2str(column_indexes)])
    remove_whole_datacolumn = 'yes';
else
    remove_whole_datacolumn = 'no';
end
%% Updating DataInfo
% if whole datacolumn is removed
if strcmp(remove_whole_datacolumn,'yes')
%     DataInfo.signal_types
    DataInfo.datacol_numbers(column_indexes) = [];
    % updating DataInfo.datacol_names after DataInfo.datacol_numbers
    DataInfo = rmfield(DataInfo,'datacol_names');
    for pp=1:length(DataInfo.datacol_numbers)
        try
            DataInfo.datacol_names{pp,1} = ['MEAele',...
                num2str(DataInfo.MEA_electrode_numbers(pp))];                
        catch
            DataInfo.datacol_names{pp,1} = ['DataCol',...
                num2str(DataInfo.datacol_numbers(pp))];                
        end
    end
    try
        DataInfo.MEA_electrode_numbers(column_indexes) = [];
        DataInfo.MEA_columns(column_indexes) = [];
    catch
        %disp('No MEA data')
    end
    DataInfo.signal_types(:,column_indexes) = [];
end

% if whole file is removed, update following
if strcmp(remove_whole_file,'yes')
    DataInfo.framerate(file_indexes) = [];
    DataInfo.file_names(file_indexes) = [];
    DataInfo.signal_types(file_indexes,:) = [];
end

DataInfo.files_amount = length(DataInfo.file_names);


%% if not removing full row or column
if strcmp(remove_whole_file,'no') && strcmp(remove_whole_datacolumn,'no')
    for pp = column_indexes
        for kk = file_indexes
            DataInfo.signal_types(file_indexes,:) = [];
        end
    end
end

%% if removing full file(s)
if strcmp(remove_whole_file,'yes')
    if isfield(DataInfo, 'hypoxia') 
        % take original hypoxia times to calculate later new times and indexes
        hps_datetime = DataInfo.measurement_time.datetime(1) + ...
            seconds(DataInfo.hypoxia.start_time_sec);
        hpe_datetime = DataInfo.measurement_time.datetime(1) + ...
            seconds(DataInfo.hypoxia.end_time_sec);
    end
    DataInfo = rmfield(DataInfo,'measurement_time');
    for index = 1:DataInfo.files_amount
        datetime  = convert_end_string_in_filename_to_datetime...
            (DataInfo.file_names{index});
        if index == 1
            meas_duration =  datetime - datetime;
        else
            meas_duration = datetime - DataInfo.measurement_time.datetime(1,1);
        end
        meas_time = datenum(meas_duration)* 24*60*60;
        % calculate measurement duration and time in sec from the beging
        DataInfo.measurement_time.datetime(index,1) = datetime;
        DataInfo.measurement_time.duration(index,1) = meas_duration;
        DataInfo.measurement_time.time_sec(index,1) = meas_time;
    end
    % after DataInfo.measurement_time.time_sec is created, update field .names
    DataInfo = create_time_names_for_DataInfo(DataInfo);
    % .measurement.time.names = adding "measurement name" for legend purposes
    
    % Update DataInfo.hypoxia if exist: only when full file(s) is/are removed
    if isfield(DataInfo, 'hypoxia')
        new_datetime = DataInfo.measurement_time.datetime;
        DataInfo.hypoxia.start_time_sec = seconds(hps_datetime - new_datetime(1));
        DataInfo.hypoxia.start_time_index = find(new_datetime >= hps_datetime,1);
        DataInfo.hypoxia.end_time_sec = seconds(hpe_datetime - new_datetime(1)); 
        DataInfo.hypoxia.end_time_index = find(new_datetime < hpe_datetime,1,'last');
        % Update hypoxia names
        DataInfo = create_hypoxia_time_names(DataInfo);
        disp('DataInfo.hypoxia updated.')
    end
    
end

disp('DataInfo variable updated')

end