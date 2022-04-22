function [Data_BPM] = modify_individual_peak...
    (Data, DataInfo, Data_BPM, file_index, datacolumn, ...
    peak_type, peak_number, new_time, samples_to_estimate_peak_value)
% [Data_BPM] = modify_individual_peak...
%     (Data, DataInfo, Data_BPM, file_index, datacolumn, ...
%     peak_type, peak_number, new_time, samples_to_estimate_peak_value)

narginchk(8,9)
nargoutchk(0,1)

% default: average of 100 samples from both size of the location
% TODO: olisiko parempi
if nargin < 9 || isempty(samples_to_estimate_peak_value)
    samples_to_estimate_peak_value = [-100 100]; % to both size
end

if length(samples_to_estimate_peak_value) ~= 2
   if length(samples_to_estimate_peak_value) == 1
      samples_to_estimate_peak_value(end+1) = 0;
   end
   samples_to_estimate_peak_value = [ ...
          min(samples_to_estimate_peak_value) max(samples_to_estimate_peak_value)];   
end
if length(file_index) > 1
    file_index = file_index(1);
    disp('Looking for only first file_index(1)')
end
if length(datacolumn) > 1
    datacolumn = datacolumn(1);
    disp('Looking for only first datacolumn(1)')
end

if length(new_time) > 1
   new_time = [min(new_time) max(new_time)];
   disp('Setting new time between min and max from given values:')
   disp(new_time)
end
col = datacolumn;

try
    if strcmp(peak_type,'hp') % first peak
        peak_location_index = ...
            Data_BPM{file_index(1),1}.mainpeak_locations{col,1}(peak_number);
    elseif strcmp(peak_type,'ap') % second peak
        peak_location_index = ...
            Data_BPM{file_index(1),1}.antipeak_locations{col,1}(peak_number);

    elseif strcmp(peak_type,'fp') % third peak
        peak_location_index = ...
            Data_BPM{file_index(1),1}.flatpeak_locations{col,1}(peak_number);   
    else
       error('not proper peak_type') 
    end
catch
    peak_location_index = [];
    disp('no peak found')
end

try
    fs = DataInfo.framerate(file_index,1);
catch % old data where framerate only one file
    fs = DataInfo.framerate(1);
end
ts = 1/fs;
time_vector = 0:ts:(length(Data{file_index(1),1}.data(:,col))-1)*ts; 
if ~isempty(peak_location_index )
    time_peak = ts*(peak_location_index-1);
end
% finding new index and value
time_to_find = mean(new_time);
index_new = find(time_vector >= time_to_find,1);

% value: if new_time is vector, then average from values between that.
% otherwise, value from index_new given average_size
if length(new_time) == 2
    index1 = find(time_vector >= new_time(1),1);
    index2 = find(time_vector >= new_time(2),1);
else % from samples_to_estimate_peak_value
    index1 = index_new+samples_to_estimate_peak_value(1);
    index2 = index_new+samples_to_estimate_peak_value(2);
end

value_new = mean(Data{file_index(1),1}.data(index1:index2,col));



% changing
if strcmp(peak_type,'hp') % first peak
    Data_BPM{file_index(1),1}.mainpeak_locations{col,1}(peak_number) = ...
        index_new;
    Data_BPM{file_index(1),1}.mainpeak_values{col,1}(peak_number) = ...
        value_new;
elseif strcmp(peak_type,'ap') % second peak
    Data_BPM{file_index(1),1}.antipeak_locations{col,1}(peak_number) = ...
        index_new;
    Data_BPM{file_index(1),1}.antipeak_values{col,1}(peak_number) = ...
        value_new;
elseif strcmp(peak_type,'fp') % third peak
    Data_BPM{file_index(1),1}.flatpeak_locations{col,1}(peak_number) = ...
        index_new;
    Data_BPM{file_index(1),1}.flatpeak_values{col,1}(peak_number) = ...
        value_new;
else
   error('New index not found') 
end
disp([peak_type,'#',num2str(peak_number),' changed.'])
disp(['Location (time, sec): ', num2str(time_vector(index_new))])
disp(['Value : ', num2str(value_new)])