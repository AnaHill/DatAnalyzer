function DataInfo = set_hypoxia_info_to_DataInfo_with_datetime(DataInfo, ...
    hypoxia_start_datetime, hypoxia_end_datetime)
% function DataInfo = set_hypoxia_info_to_DataInfo_with_datetime(DataInfo,...
% hypoxia_start_datetime, hypoxia_end_datetime)
% hypoxia_start_datetime = hypoxia start datetime
% hypoxia_end_datetime = hypoxia end datetime
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

if ~isfield(DataInfo.measurement_time,'time_sec')
    error('No DataInfo.measurement_time.time_sec found!')
end

if nargin < 2 || isempty(hypoxia_start_datetime)
    disp('Setting hypoxia start to first datetime')
	hypoxia_start_datetime = DataInfo.measurement_time.datetime(1); % datetime in first index
end
if nargin < 3 || isempty(hypoxia_end_datetime)
    disp('Setting hypoxia end to last datetime')
	hypoxia_end_datetime = DataInfo.measurement_time.datetime(end); % datetime in last index
end

% get file indexes that are last indexes before given datetime(s)
if ~isempty(find(DataInfo.measurement_time.datetime <= hypoxia_start_datetime,1,'last'))
    DataInfo.hypoxia.start_time_index = ...
        find(DataInfo.measurement_time.datetime <= hypoxia_start_datetime,1,'last');
else % setting to first index even hypoxia would have started earlier
    DataInfo.hypoxia.start_time_index = 1;
end
DataInfo.hypoxia.end_time_index = find(DataInfo.measurement_time.datetime <= ...
    hypoxia_end_datetime,1,'last');
% calculate times based on datetimes
% hypoxia_start_datetime = DataInfo.measurement_time.datetime(2);
% hypoxia_end_datetime = DataInfo.measurement_time.datetime(end-1);
DataInfo.hypoxia.start_time_sec = ...
    seconds(hypoxia_start_datetime - DataInfo.measurement_time.datetime(1));
DataInfo.hypoxia.end_time_sec = ...
    seconds(hypoxia_end_datetime - DataInfo.measurement_time.datetime(1));

% Update hypoxia names
% DataInfo = set_hypoxia_time_names_based_on_datetime(DataInfo,...
%     hypoxia_start_datetime, hypoxia_end_datetime);
% update 2022/08
DataInfo = create_hypoxia_time_names(DataInfo);

end