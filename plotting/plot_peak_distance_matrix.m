function plot_peak_distance_matrix(y_unit, time_unit, ...
    normalizing_y_indexes, hfig, ...
    datacolumn_indexes, Data_BPM_summary, DataInfo)
% function plot_peak_distance_matrix(y_unit, time_unit, ...
%     normalizing_y_indexes, hfig, ...
%     datacolumn_indexes, Data_BPM_summary, DataInfo)
% possible y_unit: 
    % BPM, frequency, peak_distance_in_milliseconds, peak_distance_in_seconds
% possible time_unit: 
    % duration, datetime, hours, seconds

% Examples
% normalizing_y_indexes = DataInfo.hypoxia.start_time_index;
% norm_indexes = 1;
% norm_index = plot_peak_distance_matrix('peak_distance_in_millisecond','datetime',norm_indexes, [],1)



%% TODO: voisiko poistaa tietyn alun halutessaan, jolloin plot siirtyisi siihen?!?
% apua: \KEHITYS\plottaa_juokseva_bpm\plot_with_meas_running_time.m
%% check input values
max_inputs = 7;
narginchk(0,max_inputs)
nargoutchk(0,1)

if nargin < max_inputs || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end
% If Data_BPM_summary not given, trying to read Data_BPM_summary
if nargin < max_inputs-1 || isempty(Data_BPM_summary)
    try
        Data_BPM_summary = evalin('base','Data_BPM_summary');
    catch 
        error('No proper Data_BPM_summary found!')
    end
end

% default: plot every data column indexes
if nargin < max_inputs-2 || isempty(datacolumn_indexes)
    datacolumn_indexes = 1:length(DataInfo.datacol_numbers);
end

% default y-value: BPM (beats-per-minute)
if nargin < 1 || isempty(time_unit)
     y_unit = 'BPM';  
end

% default time unit: seconds
if nargin < 2 || isempty(time_unit)
     time_unit = 'seconds';  
end

% default: not normalizing values --> normalizing_y_indexes = []
if nargin < 3 || isempty(normalizing_y_indexes)
    normalizing_y_indexes = [];
end

% empty normaling if any index is 0 or below
if ~isempty(normalizing_y_indexes)
    if any(normalizing_y_indexes <= 0)
        normalizing_y_indexes = [];
    end
end


%% Plot: default plot in new figure
if nargin < 4 || isempty(hfig)
    disp('Create new full size figure.')
    fig_full   
end
figure(hfig)
hold all
sgtitle([DataInfo.experiment_name,10, DataInfo.measurement_name],...
    'interpreter','none')
for kk = 1:length(datacolumn_indexes)
    if kk == 1
        % x-axis
        [timep, xlabel_text] = convert_seconds_to_different_time_units(...
            time_unit, Data_BPM_summary.peak_distance_with_running_index{kk}(:,1),...
            DataInfo.measurement_time.datetime(1));
        % y-axis
        [data_converted, ylabel_text] = ...
            create_data_and_ylabel_text_for_peak_analysis_plot(...
            Data_BPM_summary.peak_distance_with_running_index{kk}(:,2),...
            y_unit, normalizing_y_indexes);

    else % no label text after first rounf
        [timep, ~] = convert_seconds_to_different_time_units(...
            time_unit, Data_BPM_summary.peak_distance_with_running_index{kk}(:,1),...
            DataInfo.measurement_time.datetime(1));
        [data_converted, ~] = ...
            create_data_and_ylabel_text_for_peak_analysis_plot(...
            Data_BPM_summary.peak_distance_with_running_index{kk}(:,2),...
            y_unit, normalizing_y_indexes);
    end        
   
    % plot(timep, data_converted,'o'), 
    plot(timep, data_converted,'.-'), 

    
end
ylabel(ylabel_text), % title(tittext)
xlabel(xlabel_text)
% for hypoxia line, use
[time_o2, ~] = choose_timep_unit(time_unit,DataInfo);
plot_hypoxia_line(time_o2, data_converted, DataInfo)

    
end
