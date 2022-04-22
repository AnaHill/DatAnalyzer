function [index_point,time_value, data_value] = find_peak_start_or_end(data, peak_index, ... % compulsory
    time_range, index_range, trigger_level, baseline_level,... 
    triggergain_for_data, triggergain_for_data_derivative, ...
    window_mavg, fs, interpolation_rate)
% function [index_point,time_value, data_value] = find_peak_start_or_end(data, peak_index, ... % compulsory
%     time_range, index_range, trigger_level, baseline_level,... 
%     triggergain_for_data, triggergain_for_data_derivative, ...
%     window_mavg, fs, interpolation_rate)
narginchk(2,11)
nargoutchk(0,3)
% disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
% disp('%%%%%%%')
if min(size(data)) > 1
    [rows, cols] = size(data);
    if cols < rows
        disp('Data has more than one data set (columns), taking only the first column')
        data = data(:,1);
    elseif cols > rows
        disp('Data has more than one data set (rows), taking only the first row')
        data = data(1,:);
    else % square matrix, same number of  rows and cols, e.g. 4x4
        disp(['Square matrix ', num2str(rows),' x ', num2str(rows)])
        disp('Taking only the first column')
        data = data(:,1);
    end
end
% make sure data is in column vector
data = data(:);

% check peak_index
if length(peak_index) > 1
    warning('Peak index should be only one number, taking the first index')
    peak_index = peak_index(1);
end
if peak_index < 1
    error('Peak index should be positive integrer')
end
if peak_index > length(data)
    error('Peak index out of data, check.')
end

if nargin < 10 || isempty(fs)
    try
        fs = evalin('base','DataInfo.framerate(1)');
        % disp('fs not given, set from DataInfo.framerate(1)')
    catch
        error('No fs found')
    end    
end

time = 0:1/fs:(length(data)-1)/fs;

% setting time range
if nargin < 3 || isempty(time_range)
    % setting time range from half way between zero and peak_index time to peak_index
    if nargin < 4 || isempty(index_range)
        time_range = sort(unique([(peak_index-1)/fs/2 (peak_index-1)/fs]));
        disp(['Setting time_range between peak_index and halfway to start time'])
    else
        disp(['Setting time_range based on given index_range'])
        time_range = time(index_range);
    end
end
time_range = sort(unique(time_range));
if length(time_range) ~= 2
    if length(time_range) == 1
        % if only one value for time_range is given
        time_range = sort(unique([(peak_index-1)/fs time_range]));
    end
    if length(time_range) > 2
        time_range = sort(unique([min(time_range) max(time_range)]));
    end
    if length(time_range) == 1
       error('No prober time range!') 
    end
end
% disp(['Setting time_range to: ',num2str(time_range)])

% setting index_range
if nargin < 4 || isempty(index_range)
    try
        index_range =round(time_range*fs+1);    
        disp(['Setting index_range based on time range'])
    catch
       error('no time nor index range available') 
    end
end
index_range = round(sort(unique(index_range)));
if length(index_range) ~= 2
    if length(index_range) == 1
        index_range = sort(unique([peak_index index_range]));
    end
    if length(index_range) > 2
        index_range = sort(unique([min(index_range) max(index_range)]));
    end
    if length(index_range) == 1
       error('No prober index range!') 
    end
end
try 
    data_to_check = data(index_range(1):index_range(2));
catch
    try
        index_range(2) = length(data);
        data_to_check = data(index_range(1):index_range(2));
        disp('End of index range incorrect, setting end index to length of data')
    catch
        error('Incorrect index_range, check.')
    end
end
disp(['Setting index_range to: ',num2str(index_range)])

% check if (fixed) trigger_level is given; if not, trigger level will be 
% estimated using calculation based on peak amplitude and triggergain_data and triggergain_derivative 
if nargin < 5 || isempty(trigger_level)
    using_fixed_trigger_level = 0;
    trigger_level = 0; % will be calculated later
% 	disp(['Not using fixed trigger level to define point.'])
%     disp(['Instead, finding trigger level based on peak amplitude, '...
%         'baseline level and trigger_gains'])
else
    using_fixed_trigger_level = 1;
    % disp(['Using fixed trigger level to define point: ',num2str(trigger_level)])
end
if length(trigger_level) > 1
    warning('trigger_level should be only one number, taking the first index')
    trigger_level = trigger_level(1);
end

if nargin < 6 || isempty(baseline_level)
    baseline_level = mean(data(1:round(peak_index/2)));
    if  using_fixed_trigger_level == 0
        disp('Baseline level not given, defining it as mean from begin to halfway to peak index:')
        disp([num2str(baseline_level)])
    end
end
if length(baseline_level) > 1
    warning('baseline_level should be only one number, taking the first index')
    baseline_level = baseline_level(1);
    disp(['Baseline level: ',num2str(baseline_level)])
end

% default values used for trigger level calculating: 0.1=10%
if nargin < 7 || isempty(triggergain_for_data)
    triggergain_for_data = 0.1; % 0.1 = 10% increase from baseline
    if  using_fixed_trigger_level == 0
        disp('Using default triggergain_for_data')
    end
end
if nargin < 8 || isempty(triggergain_for_data_derivative)
    triggergain_for_data_derivative = 0.1; % 0.1 = 10% increase from baseline
    if using_fixed_trigger_level == 0
        disp('Using default triggergain_for_data_derivative')
    end
end
% default value for moving window size = 10, set 1 if not wanted
if nargin < 9 || isempty(window_mavg)
    % moving window size
    window_mavg = 10;
    % disp(['Using default window_mavg moving mean window size: ',num2str(window_mavg)])
else
    window_mavg = window_mavg(1);
    %disp(['Using moving mean window size window_mavg =  ',num2str(window_mavg)])
    
end

% default resample gain
if nargin < 11 || isempty(interpolation_rate)
    interpolation_rate = 100;
    disp(['Using default resampling rate for data: ',num2str(interpolation_rate)])
else
    interpolation_rate = interpolation_rate(1);
    disp(['Using resampling rate for data interpolation_rate =  ',num2str(interpolation_rate)])  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if using_fixed_trigger_level == 1
    disp(['Using fixed trigger level to detect point: ',num2str(trigger_level)])
else % not using fixed level
    disp(['trigger level is calculated using the following parameters for trigger gains'])
    disp(['triggergain_for_data = ',num2str(triggergain_for_data)])
    disp(['triggergain_for_data_derivative = ',num2str(triggergain_for_data_derivative)])
end
disp(['Moving average window size window_mavg = ',num2str(window_mavg)])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check data, if data(peak_index) is negative, assuming low peak --> inverting data
if data(peak_index) < 0
    data = -data;
    data_to_check = -data_to_check;
    disp('Negative peak: inverting data = -data')
end
%%% averaging and interpolating data for finding start or end point
datavg = movmean(data_to_check,window_mavg);

% interpolate more points for better time indicator
used_data = interp(datavg,interpolation_rate);
fs_interp = fs*interpolation_rate;
time_used_data(:,1) = 0:1/fs_interp:(length(used_data)-1)/fs_interp;

% Finding index 
    % A) using fixed trigger level -> finding where data first time exceeds thus
    % B) comparing data and derivate, choosing latter

if using_fixed_trigger_level == 1
    % using fixed_trigger_level for data; where data is first time exceeding level
    % finding first
    if max(index_range) <= peak_index
        % if left side of the peak --> finding first exceeding trigger level
        ind = find(used_data >= trigger_level,1,'first');
    elseif max(index_range) > peak_index
        % if right side of the peak --> finding first BELOW value
        ind = find(used_data <= trigger_level,1,'first');
    else
        error('index_range not proper, check')
    end
    % fig_full, plot(used_data,'.-'), hold all, plot(ind, used_data(ind),'ro')
    
else
    % if not using fixed_trigger level for data, then defining levels for data and derivative
    % trigger level based on peak amplitude, baseline and gains 
    % default level = baseline + peak_amplitude*0.1, 10% change from baseline
    
    % finding trigger level for data (y)
    peak_value = data(peak_index);
    amplitude = peak_value-baseline_level;
    trigger_level = baseline_level + amplitude*triggergain_for_data;
    
    % finding trigger level for d(data) (diff(y))
    % max derivative is typically not in peak point but earlier
    ddata = diff(used_data); 
    used_datad = movmean(ddata,window_mavg*100);
    peak_value = max(used_datad); 
    baseline_for_derivative  = mean(mink(used_datad, ceil(length(used_datad)/100/2)));
    amplitude_derivative = peak_value - baseline_for_derivative;
    
    trigger_level_derivative = baseline_for_derivative + ...
        amplitude_derivative*triggergain_for_data_derivative;
    
    % Now first find where data exceeds trigger_level for the first time
    % then, where derivate exceeds trigger_level_derivative for the first time
    % choosing that which index is larger
    if max(index_range) <= peak_index
        % if left side of the peak --> finding first exceeding trigger level% if left side of the peak --> finding first exceeding trigger level
        ind_data = find(used_data >= trigger_level,1,'first');
        ind_data_derivative = find(used_datad >= trigger_level_derivative,1,'first');
        ind_data_derivative = ind_data_derivative+1;
    
    elseif max(index_range) > peak_index
        % if right side of the peak --> finding first BELOW value
        ind_data = find(used_data <= trigger_level,1,'first');
        ind_data_derivative = find(used_datad <= trigger_level_derivative,1,'first');
        ind_data_derivative = ind_data_derivative+1;
    else
        error('index_range not proper, check')
    end

    % choosing that one which is larger
    ind = max([ind_data, ind_data_derivative]);
end

% find index and time value from original data set
t0 = time(index_range(1));
t_addition = time_used_data(ind);
% fig_full, plot(time_used_data, used_data,'.-'), grid on, hold all, plot(time_used_data(ind), used_data(ind),'ro')

%%% function outputs
time_value = t0+t_addition;
index_point = find(time >= time_value,1,'first');
data_value = used_data(ind);
% pause(0.01),clc
end
%%
% fig_full, 
% plot(time-t0, data,'--','color',[.7 .7 .7]),
% grid on, hold all
% plot(time_used_data, used_data,'.-'), plot(time_used_data(ind), used_data(ind),'ro')
% line([time_used_data(1) time_used_data(end)],[data_value data_value],'linestyle','--','color',[.4 .4 .4])
% plot(time(index_point)-t0, data(index_point),'rx')
