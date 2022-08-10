function DataInfo = create_hypoxia_time_names(DataInfo)
% function DataInfo = create_hypoxia_time_names(DataInfo)
% set hypoxia names to DataInfo.hypoxia.names based on given 
% DataInfo.hypoxia.start_time_sec and DataInfo.hypoxia.end_time_sec
% if these are not found, check hypoxia.start_time_index and .end_time_index
% from DataInfo.measurement_time.time_sec

narginchk(1,1)
nargoutchk(0,1)

% check DataInfo.hypoxia
try
    hy = DataInfo.hypoxia;
catch
    warning('No hypoxia defined in DataInfo.hypoxia, returning without update!')
    returning
end

% time vector in hours
experiment_time_in_h =  DataInfo.measurement_time.time_sec/3600;% in h

%% if DataInfo.hypoxia.start_time_sec available


hypox_indexes = hy.start_time_index:hy.end_time_index-1;
if hy.start_time_index > 1
    baseline_indexes = 1:hy.start_time_index-1;
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
if hy.end_time_index < DataInfo.files_amount
    reoxy_indexes = hy.end_time_index:DataInfo.files_amount;
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

disp('DataInfo.hypoxia.names created for Demo3 data')

%%
DataInfo.hypoxia.names = time_names;
disp('Created following hypoxia names')
DataInfo.hypoxia.names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end