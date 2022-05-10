function DataInfo = set_hypoxia_time_names_based_on_datetime(DataInfo,...
    hypoxia_start_datetime, hypoxia_end_datetime)
% function DataInfo = set_hypoxia_time_names_based_on_datetime(DataInfo,hypoxia_start_datetime, hypoxia_end_datetime)
% set hypoxia names to DataInfo.hypoxia.names

narginchk(0,3)
nargoutchk(0,1)
if nargin < 1 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
        disp('DataInfo read from workspace.')
    catch
        error('No proper DataInfo')
    end
end
% check DataInfo.hypoxia
try
    hy = DataInfo.hypoxia;
catch
    error('No DataInfo.hypoxia defined!')
end
try 
    experiment_time_in_h = DataInfo.measurement_time.time_sec/3600;
catch
    error('No DataInfo.measurement_time.time_sec defined!')
end
if nargin < 2 || isempty(hypoxia_start_datetime)
    disp(['Hypoxia start not given in datetime',10,'Setting from DataInfo.hypoxia.start_time_index'])
	hypoxia_start_datetime = DataInfo.measurement_time.datetime(DataInfo.hypoxia.start_time_index); 
end
if nargin < 3 || isempty(hypoxia_end_datetime)
    disp(['Hypoxia end not given in datetime',10,'Setting from DataInfo.hypoxia.end_time_index'])
    hypoxia_end_datetime = DataInfo.measurement_time.datetime(DataInfo.hypoxia.end_time_index);
end
%% 
% hypox_indexes = hy.start_time_index:hy.end_time_index-1;   
ind_hypox_start = find(DataInfo.measurement_time.datetime >= hypoxia_start_datetime,1,'first');
ind_hypox_end = find(DataInfo.measurement_time.datetime <= hypoxia_end_datetime,1,'last');
hypox_indexes = [ind_hypox_start:ind_hypox_end];
if ind_hypox_start > 1
    baseline_indexes = 1:ind_hypox_start-1;
else
    baseline_indexes = 0; % no baseline
end
time_vector_in_h = experiment_time_in_h - hy.start_time_sec/3600;
time_names = {zeros(DataInfo.files_amount,1)};
if any(baseline_indexes ~= 0)
    for pp = baseline_indexes
        time_names{pp,1} = ['BL: before hypoxia t = ',...
            num2str(round(time_vector_in_h(pp,1),1)),'h'];            
    end
end
for pp = hypox_indexes
    time_names{pp,1} = ['Hypoxia t = ',...
        num2str(round(time_vector_in_h(pp,1),1)),'h'];
end


% Reoxy
if ind_hypox_end < DataInfo.files_amount
    reoxy_indexes = ind_hypox_end+1:DataInfo.files_amount;
    time_vector_in_h_for_reoxy = experiment_time_in_h - hy.end_time_sec/3600;
else
    reoxy_indexes = 0; % no reoxynation
    time_vector_in_h_for_reoxy = 0;
end

if any(reoxy_indexes ~= 0)
    for pp = reoxy_indexes
        time_names{pp,1} = ['Reoxygenation t = ',...
            num2str(round(time_vector_in_h_for_reoxy(pp,1),1)),'h'];
    end
end    

disp('DataInfo.hypoxia.names created')

%%
DataInfo.hypoxia.names = time_names;
disp('Created following hypoxia names')
DataInfo.hypoxia.names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end