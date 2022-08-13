function [values,location_indexes] = find_max_or_min(data, start_index, ...
    location_window_start_and_end_indexes, max_or_min_value)
% function [values,location_indexes, datafil] = find_max_or_min(data, start_index, ...
%     location_window_start_and_end_indexes, max_or_min_value)
% Finds max or min value without filtering data
% Example: data = DataPeaks_mean{1, 1}.data(:,1); [value, location] = find_max_or_min(data)
narginchk(1,4)
nargoutchk(0,2)
% assumes that each column in data is separate
%% defaults and checks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if data is column-wise
datasize=size(data);
if datasize(1) < datasize(2)
    disp('Transponse row vectors to columns: data = data')
    data = data';
    datasize = size(data);
end

% start_index: use full data if start index not specified
if nargin < 2 || isempty(start_index)
    start_index = 1;
end
if length(start_index) > 1
    start_index = start_index(1);
end
if start_index < 1 || start_index > length(data)
   error('Check start index, should be between 1 and length(data)!') 
end

% location_window_start_and_end_indexes: default: set to start_index to end
if nargin < 3 || isempty(location_window_start_and_end_indexes)
    location_window_start_and_end_indexes = [start_index length(data)];
end
if length(location_window_start_and_end_indexes) > 2
    disp(['Given more than two values: take min and maximum ',...
        'values from location_window_start_and_end_indexes'])
    location_window_start_and_end_indexes = ...
        [min(location_window_start_and_end_indexes) ...
        max(location_window_start_and_end_indexes)];
end
if length(location_window_start_and_end_indexes) == 1
    disp('Set location_window end index to end of data')
    location_window_start_and_end_indexes = sort(...
        [location_window_start_and_end_indexes length(data)]);
end
if	any(location_window_start_and_end_indexes > length(data))
   disp(['location_window_start_and_end_indexes larger than end of data --> ',...
   'Set to end of data'])
   location_window_start_and_end_indexes = [min(location_window_start_and_end_indexes) length(data)];
end
if any(location_window_start_and_end_indexes) < 1
   error('location_window_start_and_end_indexes, should be between 1 or larger!') 
end

% find max value, i.e. finding positive peak if max_or_min not given
if nargin < 4 || isempty(max_or_min_value)
    max_or_min_value = 'max';
    disp('Finding maximum value')
end
if ~strcmp(max_or_min_value,'max') && ~strcmp(max_or_min_value,'min')
   disp('Incorrect max_or_min given. Set to max, i.e. finding positive peak')
   max_or_min_value = 'max';
end

window_indexes = [min(location_window_start_and_end_indexes):...
    max(location_window_start_and_end_indexes)];
if strcmp(max_or_min_value,'max')
    [values,location_indexes] = max(data(window_indexes,:)); 
else
    [values,location_indexes] = min(data(window_indexes,:)); 
end
location_indexes = location_indexes + window_indexes(1) - 1;    
end