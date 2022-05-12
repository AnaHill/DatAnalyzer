function plot_quick_BPM_summary_plot(bpm_or_amplitude,DataInfo, Data_BPM_summary) 
% function plot_quick_BPM_summary_plot(bpm_or_amplitude,DataInfo, Data_BPM_summary) 
% fig_full, plot_quick_BPM_summary_plot() % plots bmp
% fig_full, plot_quick_BPM_summary_plot('amp')
% fig_half, plot_quick_BPM_summary_plot('amp')
narginchk(0,3)
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

switch bpm_or_amplitude
    case 'bpm'
        data_to_plot = Data_BPM_summary.BPM_avg;
        ylabel_text = 'Peak rate (BPM)';
    otherwise
        data_to_plot = Data_BPM_summary.Amplitude_avg*1e3;
        ylabel_text = 'Amplitude (mV)';
end

datetime=DataInfo.measurement_time.datetime;
plot(datetime, data_to_plot,'marker','*')
title([DataInfo.experiment_name,' - ',DataInfo.measurement_name],'interpreter','none')
ylabel(ylabel_text)
try
    hs=DataInfo.hypoxia.start_time_index;
    he=DataInfo.hypoxia.end_time_index;
    hold all,
    plot([datetime(hs) datetime(hs)],[min(data_to_plot(:)) max(data_to_plot(:))] ,'--','color',[.4 .4 .4])
    plot([datetime(he) datetime(he)],[min(data_to_plot(:)) max(data_to_plot(:))] ,'--','color',[.4 .4 .4])
catch
    disp('No hypoxia info in DataInfo.hypoxia')
end

end