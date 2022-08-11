function DataInfo = create_hypoxia_time_names(DataInfo)
% function DataInfo = create_hypoxia_time_names(DataInfo)
% set hypoxia names to DataInfo.hypoxia.names based on given
% DataInfo.hypoxia.start_time_sec and DataInfo.hypoxia.end_time_sec
% if these are not found, check hypoxia.start_time_index and .end_time_index
% from DataInfo.measurement_time.time_sec
% update also 
%     DataInfo.hypoxia.start_time_index = last_before_hypox_index+1;
%     DataInfo.hypoxia.end_time_index = last_hypox_index;


narginchk(1,1)
nargoutchk(0,1)

% check DataInfo.hypoxia
try
    hy = DataInfo.hypoxia;
catch
    warning('No hypoxia defined in DataInfo.hypoxia, returning without update!')
    return
end

experiment_time = DataInfo.measurement_time.time_sec; 
time_names = [];
%% if DataInfo.hypoxia.start_time_sec available
% hypoxia start and end in sec
hs_sec = []; he_sec = [];
times_in_sec_before_hypoxia = [];
times_in_sec_during_hypoxia  = [];
times_in_sec_after_hypoxia  = [];
last_before_hypox_index = [];
last_hypox_index = [];
if isfield(hy, 'start_time_sec')
    hs_sec = hy.start_time_sec;
end
if isfield(hy, 'end_time_sec')
    he_sec = hy.end_time_sec;
end

% if no hypoxia start and end times given, check if start and end indexes given
if isempty(hs_sec) || isempty(he_sec)
    if isfield(hy, 'start_time_index')
        hs_sec = experiment_time(hy.start_time_index);
    end
    if isfield(hy, 'end_time_index')
        he_sec = experiment_time(hy.end_time_index);
    end
end

% before hypoxia
if ~isempty(hs_sec)
    last_before_hypox_index = find(experiment_time < hs_sec,1,'last');
    if ~isempty(last_before_hypox_index)
        times_in_sec_before_hypoxia = experiment_time...
            (1:last_before_hypox_index) - hs_sec;
    end
end
% if all times are "before hypoxia" -->
if ~isempty(last_before_hypox_index)
    if last_before_hypox_index == length(experiment_time)
        % set any hypoxia end time to zero
        he_sec = [];
    end
end

% during hypoxia
if ~isempty(he_sec)
    last_hypox_index = find(experiment_time <= he_sec,1,'last');
    if ~isempty(last_hypox_index)
        if isempty(last_before_hypox_index)
            last_before_hypox_index = 0;
        end
        times_in_sec_during_hypoxia = experiment_time...
            (last_before_hypox_index+1:last_hypox_index) - hs_sec;
    end
end

% after hypoxia
if isempty(last_hypox_index)
    % if no hypoxia end found --> no after hypoxia names/indexes
    last_hypox_index = length(experiment_time);
end

% if last hypoxia index is less than last measurement time
% set end indexes to time after hypoxia
if last_hypox_index < length(experiment_time)
    times_in_sec_after_hypoxia = experiment_time...
        (last_hypox_index+1:end) - he_sec;
end

% set names
if ~isempty(times_in_sec_before_hypoxia)
    for kk = 1:length(times_in_sec_before_hypoxia) 
        time_names{end+1,1} = ['BL before hypoxia t = ',...
            num2str(round(times_in_sec_before_hypoxia(kk,1)/3600,1)),'h'];
    end 
end

if ~isempty(times_in_sec_during_hypoxia)
    for kk = 1:length(times_in_sec_during_hypoxia) 
        time_names{end+1,1} = ['Hypoxia running t = ',...
            num2str(round(times_in_sec_during_hypoxia(kk,1)/3600,1)),'h'];
    end 
end

if ~isempty(times_in_sec_after_hypoxia)
    for kk = 1:length(times_in_sec_after_hypoxia) 
        time_names{end+1,1} = ['After hypoxia (reoxygenation) t = ',...
            num2str(round(times_in_sec_after_hypoxia(kk,1)/3600,1)),'h'];
    end 
end

% Update DataInfo.hypoxia indexes
% if times during hypoxia found, updated start and end time indexes
if ~isempty(times_in_sec_during_hypoxia)
    DataInfo.hypoxia.start_time_index = last_before_hypox_index+1;
    DataInfo.hypoxia.end_time_index = last_hypox_index;
else
    % no time during hypoxia found -->
    DataInfo.hypoxia.start_time_index = nan;
    DataInfo.hypoxia.end_time_index = nan;
end
if ~isempty(time_names)
    DataInfo.hypoxia.names = time_names;
    disp('Created following DataInfo.hypoxia.names')
    DataInfo.hypoxia.names
else % if time_names was not created during function call, set all to 
    for kk = 1:length(experiment_time) 
        time_names{end+1,1} = ['No hypoxia info available'];
    end
    DataInfo.hypoxia.names = time_names;
    warning('No names could be created, setting all DataInfo.hypoxia.names to:')
    DataInfo.hypoxia.names(1)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end