 function [DataInfo] = correct_hypoxia_times(DataInfo,...
    correct_hypoxia_datetime_to_start, hypoxia_duration_in_seconds)
% [DataInfo] = correct_hypoxia_times(DataInfo,...
%     correct_hypoxia_datetime_to_start, hypoxia_duration_in_seconds)
% default: [DataInfo] = correct_hypoxia_times(DataInfo)
    % correct_hypoxia_datetime_to_start =  datetime('25-Sep-2019 11:55:00'); 
    % hypoxia_duration_in_seconds = 60*60*24; % 24h default time
narginchk(1,3)
nargoutchk(0,1)

if nargin < 2 || isempty(correct_hypoxia_datetime_to_start)
    % oletus liittyy MEA250919 
    % siin‰ -> hypoksia alkoi klo 11:55 j‰lkeen (25-09-2019)index
    % v‰h‰n alle sen aikaa etsit‰‰n
    correct_hypoxia_datetime_to_start = datetime('25-Sep-2019 11:55:00'); 
end
if nargin < 3 || isempty(hypoxia_duration_in_seconds)
    hypoxia_duration_in_seconds = 60*60*24; % 24h = 86400 sec default time
    
end


% etsit‰‰n uusi hypoksian aloitusaika
DataInfo.hypoxia.start_time_index = ...
    find(DataInfo.measurement_time.datetime >= ...
    correct_hypoxia_datetime_to_start,1); 

indh = DataInfo.hypoxia.start_time_index;
DataInfo.hypoxia.start_time_sec = ...
DataInfo.measurement_time.time_sec(indh);
DataInfo.hypoxia.end_time_sec = ...
DataInfo.hypoxia.start_time_sec+hypoxia_duration_in_seconds;  
end

