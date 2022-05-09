function DataInfo = create_time_names_for_DataInfo(DataInfo)
% function DataInfo = create_time_names_for_DataInfo(DataInfo)

% time in in hour, rounded from start
times = round(DataInfo.measurement_time.time_sec/3600,2);

% updapting time_names
time_names = {};
for pp = 1:length(times)
    time_names{end+1,1} = ['t = ',num2str(round(times(pp,1),1)),'h'];
end
DataInfo.measurement_time.names = time_names;
end
  