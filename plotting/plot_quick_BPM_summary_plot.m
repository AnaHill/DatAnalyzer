function plot_quick_BPM_summary_plot(bpm_or_amplitude,DataInfo, Data_BPM_summary, time_unit) 
% function plot_quick_BPM_summary_plot(bpm_or_amplitude,DataInfo, Data_BPM_summary, time_unit) 
% fig_full, plot_quick_BPM_summary_plot() % plots bmp
% fig_full, plot_quick_BPM_summary_plot('amp')
% fig_half, plot_quick_BPM_summary_plot('amp')
narginchk(0,4)
nargoutchk(0,0)

if nargin < 1 || isempty(bpm_or_amplitude)
    bpm_or_amplitude = 'bpm';
end

if nargin < 2 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end

if nargin < 3 || isempty(Data_BPM_summary)
    try
        Data_BPM_summary = evalin('base', 'Data_BPM_summary');
    catch
        error('No proper Data_BPM_summary')
    end
end

if nargin < 4 || isempty(time_unit)
    time_unit = 'datetime';
end

%%%
switch bpm_or_amplitude
    case 'bpm'
        data_to_plot = Data_BPM_summary.BPM_avg;
        ylabel_text = 'Peak rate (BPM)';
    otherwise
        data_to_plot = Data_BPM_summary.Amplitude_avg*1e3;
        ylabel_text = 'Amplitude (mV)';
end

legs = {};
for col_index = 1:length(DataInfo.datacol_numbers)
    try
        legs{end+1,1} = ['MEA ele#',...
            num2str(DataInfo.MEA_electrode_numbers(col_index))];
    catch
        legs{end+1,1} = ['Datacolumn#',num2str(col_index)];
    end
end
dataplots = [];
if strcmp(time_unit,'datetime')
    time_vector=DataInfo.measurement_time.datetime;
elseif strcmp(time_unit,'duration')
    time_vector=DataInfo.measurement_time.duration;
    % TODO: muut
end
dataplots = plot(time_vector, data_to_plot,'marker','*');
title([DataInfo.experiment_name,' - ',DataInfo.measurement_name],'interpreter','none')
ylabel(ylabel_text)
try
    legend(dataplots,legs, 'interpreter','none','location','best')
catch
    legend('interpreter','none','location','best')
end

try
    hs=DataInfo.hypoxia.start_time_index;
    he=DataInfo.hypoxia.end_time_index;
    hold all,
    plot([time_vector(hs) time_vector(hs)],...
        [min(data_to_plot(:)) max(data_to_plot(:))] ,'--','color',[.4 .4 .4])
    plot([time_vector(he) time_vector(he)],...
        [min(data_to_plot(:)) max(data_to_plot(:))] ,'--','color',[.4 .4 .4])
catch
    disp('No hypoxia info in DataInfo.hypoxia')
end
axis tight
end