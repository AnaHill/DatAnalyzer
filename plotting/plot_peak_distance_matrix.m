function plot_peak_distance_matrix(y_unit, time_unit, ...
    normalizing_y_indexes, hfig, shift_time_seconds,...
    datacolumn_indexes, Data_BPM_summary, DataInfo)
% function plot_peak_distance_matrix(y_unit, time_unit, ...
%     normalizing_y_indexes, hfig, shift_time_seconds,...
%     datacolumn_indexes, Data_BPM_summary, DataInfo)
% possible y_unit: 
    % BPM, frequency, peak_distance_in_milliseconds, peak_distance_in_seconds
% possible time_unit: 
    % duration, datetime, hours, seconds
% shift_time_seconds: how much time is shifted; if negative, send to backwards
% e.g. useful for plotting purposes
%
% Examples
% col_index=1;plot_peak_distance_matrix([],[],[],[], [], col_index)
% reduce some time
    % tr = DataInfo.measurement_time.time_sec(20); col_index=1;plot_peak_distance_matrix([],[],[],[],-tr, col_index)
    
% col_index=[1,5];plot_peak_distance_matrix([],'datetime',[],[],[], col_index)
% col_index=1;plot_peak_distance_matrix([],[],1,[],[], col_index)%normalized
% normalizing_y_indexes = DataInfo.hypoxia.start_time_index;
% plot_peak_distance_matrix('peak_distance_in_millisecond','datetime',normalizing_y_indexes,[],[], 1)



%% TODO: voisiko poistaa tietyn alun halutessaan, jolloin plot siirtyisi siihen?!?
% apua: \KEHITYS\plottaa_juokseva_bpm\plot_with_meas_running_time.m
%% check input values
max_inputs = 8;
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
if nargin < max_inputs - 1 || isempty(Data_BPM_summary)
    try
        Data_BPM_summary = evalin('base','Data_BPM_summary');
    catch 
        error('No proper Data_BPM_summary found!')
    end
end

% default: plot every data column indexes
if nargin < max_inputs - 2 || isempty(datacolumn_indexes)
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
        disp(['Not proper normalizing indexes given: ', ...
            num2str(normalizing_y_indexes)])
        disp('-> using absolut values, no normalizing')
        normalizing_y_indexes = [];
    end
end
% Plot: default plot in new figure
if nargin < 4 || isempty(hfig)
    disp('Create new full size figure.')
    fig_full
    legs = {};
    dataplots = [];
else
    try
        leg_prev = get(gca,'Legend');
        legs = leg_prev.String;
        dataplots = get(gca,'Children');
    catch
       legs = {}; 
       dataplots = [];
    end
end
% default: not sgifting
if nargin < 5 || isempty(shift_time_seconds)
    shift_time_seconds = 0;
end
shift_time_seconds=shift_time_seconds(1);


%% Calculate and Plot
figure(hfig)
hold all
sgtitle([DataInfo.experiment_name,': ', DataInfo.measurement_name],...
    'interpreter','none')
% legend
% legs = {};
for col_index = datacolumn_indexes
    % legs this way row as above you will get legends as a row when calling 
    % leg_prev = get(gca,'Legend'); legs = leg_prev.String;
    try
        legs{end+1} = ['MEA ele#',...
            num2str(DataInfo.MEA_electrode_numbers(col_index))];
    catch
        legs{end+1} = ['Datacolumn#',num2str(col_index)];
    end
end
% dataplots = [];

% for kk = 1:length(datacolumn_indexes)
for kk = datacolumn_indexes
    % x-axis
    [timep, xlabel_text] = convert_seconds_to_different_time_units(...
        time_unit, Data_BPM_summary.peak_distance_with_running_index{kk}(:,1),...
        shift_time_seconds, DataInfo.measurement_time.datetime(1));
    % y-axis
    [data_converted, ylabel_text] = ...
        create_data_and_ylabel_text_for_peak_analysis_plot(...
        Data_BPM_summary.peak_distance_with_running_index{kk}(:,2),...
        y_unit, normalizing_y_indexes);
    % plot(timep, data_converted,'o'), 
    dataplots(end+1,1) = plot(timep, data_converted,'.-');
    
end
ylabel(ylabel_text), % title(tittext)
xlabel(xlabel_text)
% for hypoxia line, use
[time_o2, ~] = choose_timep_unit(time_unit,DataInfo);
[line_hypox_start, line_hypox_end] = plot_hypoxia_line(time_o2, data_converted, DataInfo);
legend(dataplots,legs, 'interpreter','none','location','best')

try
    Data_o2.data(Data_o2.measurement_time.datafile_index);
    yyaxis right
    plot(time_o2,Data_o2.data(Data_o2.measurement_time.datafile_index),'--')
    ylabel('pO2 (kPa)')
catch
    % disp('No O2 data to plot.')
end
axis tight
if ~isempty(normalizing_y_indexes)
    ylim([0 Inf])
end   
try
    xlim([0 Inf])
catch
    xlim([min(timep) max(timep)])
end
end
