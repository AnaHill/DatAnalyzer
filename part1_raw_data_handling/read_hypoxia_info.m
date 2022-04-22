function experiment_info =  read_hypoxia_info(dataset_name, time_data,time_difference)
% function experiment_info =  read_hypoxia_info(dataset_name, time_data,time_difference)
%  experiment_info =  read_hypoxia_info(dataset_name, time_data,time_difference)
% experiment_info =  read_hypoxia_info(choice_dataset,DataInfo.measurement_time.time_sec);
narginchk(2,3)
nargoutchk(0,1)
if nargin < 3
    time_difference = 30*60;
end
if strcmp(dataset_name,'Martta')
	disp('Long Ischemia data (M.H.)')
    hypox_hours = 24;
    % Protocol
        % baseline yleensä 24h (vaihtelee)
        % hypoxia 24 h (alkukohta yleensä se kun 
        % baseline up to 24 h
    % hypoxia point when time between two points = 30 min
    experiment_info.hypoxia.start_time_index = find_experimental_point...
    (time_data,time_difference);
    % find the first part, where time between two experimental time points is
    % time_difference (default: 30 min)
    % now assuming, that if it is close enough, eps_ value --> 
    % function [measurement_point] = find_experimental_point(time_data,time_difference)
        % default time_difference = 30*60; % 30 minutes
    experiment_info.hypoxia.start_time_sec = time_data...
        (experiment_info.hypoxia.start_time_index);
    % hypoxia kept 24 hours
    experiment_info.hypoxia.end_time_sec = experiment_info.hypoxia.start_time_sec ...
        + hypox_hours*60*60;
    disp(['Hypoxia times are (h): '])
    disp(['Start: ',num2str(round(experiment_info.hypoxia.start_time_sec/3600))])
    disp(['End: ',num2str(round(experiment_info.hypoxia.end_time_sec/3600))])  
 
elseif strcmp(dataset_name,'demo3')
    disp('Demo3 data')
    baseline_hours = 13;
    hypox_hours = 8;
    %     **MEAsurement protocol** using automatic valves
    %     - i)  13 h baseline (10% O2)
    %     - ii) 8 h hypoxia (1% O2)
    %     - iii) > 8 h baseline (10% O2)
    disp('In Demo3, first 13 h baseline (10% O2), then 8 h hypoxia (1% O2)')
    warning('Precise times should be checked!')
    experiment_info.hypoxia.start_time_index = find(time_data/3600 > baseline_hours,1);
    experiment_info.hypoxia.start_time_sec = time_data...
        (experiment_info.hypoxia.start_time_index);
    warning('TODO: tarkista, että oikein demo3:ssa oikeasti 13h baseline aika')
    experiment_info.hypoxia.start_time_sec = baseline_hours*3600;
    % hypoxia kept 24 hours
    experiment_info.hypoxia.end_time_sec = experiment_info.hypoxia.start_time_sec ...
        + hypox_hours*60*60;
    experiment_info.hypoxia.end_time_index = find(...
        time_data >= experiment_info.hypoxia.end_time_sec,1);

    disp(['Hypoxia times are (h): '])
    disp(['Start: ',num2str(round(experiment_info.hypoxia.start_time_sec/3600))])
    disp(['End: ',num2str(round(experiment_info.hypoxia.end_time_sec/3600))])  
else % ask what to find 
    warning('empty info'), experiment_info = [];
    warning('TODO: Should ask what to do next')
    return
end

end