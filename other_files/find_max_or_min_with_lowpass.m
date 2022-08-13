function [values,location_indexes, datafil] = find_max_or_min_with_lowpass(data, start_index, ...
    location_window_start_and_end_indexes, max_or_min_value,low_pass_filter_freq, fs)
% function [values,location_indexes] = find_max_or_min_with_lowpass(data, start_index, ...
%     location_window_start_and_end_indexes, max_or_min_value,low_pass_filter_freq, fs)
% Example: data = DataPeaks_mean{1, 1}.data(:,1); [value, location] = find_max_or_min_with_lowpass(data)
narginchk(1,6)
nargoutchk(0,3)
% assumes that each column in data is separate
% low pass filter: default frequency is 200
%% TODO: mieti parempia/useampia filtteröintejä

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
    disp('Given more than two values: take min and maximum values from location_window_start_and_end_indexes')
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
end
if ~strcmp(max_or_min_value,'max') && ~strcmp(max_or_min_value,'min')
   disp('Incorrect max_or_min given. Set to max, i.e. finding positive peak')
   max_or_min_value = 'max';
end

% default low pass filter start frequency: 200 Hz
if nargin < 5 || isempty(low_pass_filter_freq)
    low_pass_filter_freq = 200; %1500;
end
if length(low_pass_filter_freq) > 1
    disp('Given more than 1 values: take minimum of low_pass_filter_freq')
    low_pass_filter_freq = [min(low_pass_filter_freq(:))];
end
disp(['Using low pass filter with frequency: ',num2str(low_pass_filter_freq)])

% fs: 1 Hz if not given
if nargin < 6 || isempty(fs)
    warning('No fs found, set fs = 1')
    fs = 1;
%     try
%         fs = evalin('base','DataInfo.framerate(1)');
%         disp('fs read from DataInfo.framerate(1)')
%     catch
%        warning('No fs found, set fs = 1')
%        fs = 1;
%     end
end
if length(fs) > 1
    disp('Given more than one fs value: take minimum of fs')
    fs = [min(fs(:))];
end

% filtering and finding max/min
% TODO: eri filteröintivaihtoehtoja paremmin
window_indexes = [min(location_window_start_and_end_indexes):...
    max(location_window_start_and_end_indexes)];
datafil = lowpass(data(window_indexes,:),...
    low_pass_filter_freq,fs, 'ImpulseResponse','iir','Steepness',0.95);
% fig_full, plot(data(window_indexes,:),'.'), hold all, plot(datafil)
if strcmp(max_or_min_value,'max')
    [values,location_indexes] = max(datafil); 
else
    [values,location_indexes] = min(datafil); 
end
% plot(location_indexes,values,'ro','markersize',10)
location_indexes = location_indexes + window_indexes(1) - 1;    
% plot(location_indexes-start_index + 1,values,'ro','markersize',10)
end