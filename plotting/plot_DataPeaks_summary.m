function plot_DataPeaks_summary(fpd_correction, timep_unit,...
    normalizing_values, DataInfo, Data_BPM_summary, DataPeaks_summary, hfig)
% required files
    % [timep, xlabel_text] = choose_timep_unit(timep_unit,DataInfo)
    % [dat, tittext] = which_fpd_correction(fpd_correction,dat, Data_BPM_summary)
    % plot_hypoxia_line(timep, dat, DataInfo)
narginchk(0,7)

if nargin < 1 || isempty(fpd_correction)
    fpd_correction = 'Izumi-Nakaseko';
    disp('Izumi-Nakaseko equation used for FDP_corrected')
end

if nargin < 2 || isempty(timep_unit)
    timep_unit = 'datetime';  
    disp('datetime chosen for time unit')
end

if nargin < 3 || isempty(normalizing_values)
    normalizing_values = 0;
    % disp('not normalized')
elseif any(normalizing_values) ~= 1
    normalizing_values = 0;
end

if nargin < 4 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end

if nargin < 5 || isempty(Data_BPM_summary)
    try
        Data_BPM_summary = evalin('base', 'Data_BPM_summary');
    catch
        error('No proper Data_BPM_summary')
    end
end

if nargin < 6 || isempty(DataPeaks_summary)
    try
        DataPeaks_summary = evalin('base', 'DataPeaks_summary');
    catch
        error('No proper DataPeaks_summary')
    end
end

if nargin < 7 || isempty(hfig)
    try
        hfig = evalin('base', 'hfig');
    catch
        disp('Create new full size figure.')
        fig_full
    end
end
%%
if normalizing_values == 1
    % choosing index(es) which values are used for normalizing values
    try % finding hypoxia starting time index
        ind_hyp = DataInfo.hypoxia.start_time_index;
        if ind_hyp >= 3
            norm_index = ind_hyp-2:ind_hyp;
        elseif ind_hyp == 2
            norm_index = ind_hyp-1:ind_hyp;
        else
            norm_index =ind_hyp;
        end
    catch % no hypoxia index: taking first index as normalizing value
        norm_index = 1;
    end
end
%%
[timep, xlabel_text] = choose_timep_unit(timep_unit,DataInfo);
figure(hfig)
sgtitle([DataInfo.experiment_name,10, DataInfo.measurement_name],'interpreter','none')

try
    how_many_different_data = 3;
    subplot(how_many_different_data,1,1)
    dat = Data_BPM_summary.BPM_avg;
    tittext = 'Beating rate (BPM)';
    if normalizing_values == 1
        dat = dat ./ median(dat(norm_index,:));
        tittext = 'Beating rate (norm)';
    end
    plot(timep, dat,'.-'), ylabel(tittext), title(tittext)
    plot_hypoxia_line(timep, dat, DataInfo)
    
    subplot(how_many_different_data,1,2)
    dat = abs(DataPeaks_summary.depolarization_amplitude)*1e3; 
	tittext = 'Amplitude (mV)';
    if normalizing_values == 1
        dat = abs(DataPeaks_summary.depolarization_amplitude);
        tittext = 'Normalized absolute amplitude (norm)';
        dat = dat ./ median(dat(norm_index,:));
    end
    plot(timep, dat,'.-'), ylabel(tittext), title(tittext)
    plot_hypoxia_line(timep, dat, DataInfo)
    
catch % no amplitude
    how_many_different_data = 2;
    subplot(how_many_different_data,1,1)
    dat = Data_BPM_summary.BPM_avg;
    tittext = 'Beating rate (BPM)';
    if normalizing_values == 1
        dat = dat ./ median(dat(norm_index,:));
        tittext = 'Beating rate (norm)';
    end
    plot(timep, dat,'.-'), ylabel(tittext), title(tittext)
    plot_hypoxia_line(timep, dat, DataInfo) 
end

subplot(how_many_different_data,1,how_many_different_data)

% calculate FPDc (or FPD)
dat =  DataPeaks_summary.fpd; 
if normalizing_values == 0
    [dat, tittext] = which_fpd_correction(fpd_correction, dat);
    plot(timep, dat,'.-'), ylabel(tittext), title(tittext)
    plot_hypoxia_line(timep, dat, DataInfo)
else % normalizing_values
    [dat, titletext_fpdctype] = which_fpd_correction(fpd_correction, dat);
    tittext = ['Normalized signal duration fpd(c) based on ',titletext_fpdctype];
    dat = dat ./ median(dat(norm_index,:));
    tittext = 'Beating rate (norm)';
    plot(timep, dat,'.-'), ylabel(tittext), title(tittext)
    plot_hypoxia_line(timep, dat, DataInfo)
    ylim([0 Inf])

end

for pp = 1:how_many_different_data
    subplot(how_many_different_data,1,pp)
    xlabel([xlabel_text])
    try
        Data_o2.data(Data_o2.measurement_time.datafile_index);
        yyaxis right
        if normalizing_values == 0
            plot(timep,Data_o2.data(Data_o2.measurement_time.datafile_index),'--')
            ylabel('pO2 (kPa)') 
        else
            dat = Data_o2.data(Data_o2.measurement_time.datafile_index);
            dat = dat ./ median(dat(norm_index,:));
            plot(timep,dat,'--')
            ylabel('O2 (norm)')
        end
    catch
    end
    axis tight
end
%% TODO: impementoi
% loppu: .\plotting\Summarize_plot_DataPeaks_summary.m
%% If want to limit y-axis to certain range, use this cell
% % % ylimits = [0 2.5];
% % % ylimits = [.7 1.1];
% % % ylimits = [.65 1.25];
% % % 
% % % ylimits_o2 = [0 1.1];
% % % 
% % % for pp = 1:how_many_different_data
% % % 	subplot(how_many_different_data,1,pp)
% % %     try
% % %         Data_o2.data(Data_o2.measurement_time.datafile_index)
% % %         yyaxis left
% % %         ylim([ylimits])
% % %         yyaxis right
% % %         ylim([ylimits_o2])
% % %     catch
% % %         ylim([ylimits])
% % %     end
% % % end

end