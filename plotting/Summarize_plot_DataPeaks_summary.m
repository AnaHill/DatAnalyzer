% Plot summary of the results: BPM, amplitude, and signal duration (FPD or FPDc)
    % Parameters: 1) spike amplitude (AMP), (2) field potential duration (FPD), and (3) beat period (BP).
    % REF [Hayes et al., Sci. Rep., 9(1):11893, 2019.]
    % To account for rate dependent effects, FPD was are also reported as beat rate-corrected (FPDc) using the Fridericia correction

%%%%% some info
% Possible FPDc equations, see 
    % 1) (default) Izumi-Nakeseko: FPDc=FPD/(60/BPM)^{0.22}
    % 2) Bazetts: FPDc=FPD/(60/BPM)^{1/2}
    % 3) Fridericia: FPDc=FPD/(60/BPM)^{1/3}
    % 4) Pure FPD
% plotting single results, see
    % open('.\DataPeaks_summary_yksittaisten_plottaus.m')
% Versions
    % 2022/01: Created separate functions (m-files) for following functions
        % function [dat, tittext] = which_fpd_correction(fpd_correction,dat, Data_BPM_summary)
        % function plot_hypoxia_line(timep, dat, DataInfo)
        % function [timep, xlabel_text] = choose_timep_unit(timep_unit,DataInfo)
%% Summarize:  BPM, amplitude, signal duration
fpd_correction = 'Izumi-Nakeseko';
% fpd_correction = 'Bazett';
% fpd_correction = 'Fridericia';
fpd_correction = 'none'; % if not corrected FPD, just pure FPD plotted

timep_unit = 'datetime';  
timep_unit = 'hours';  
timep_unit = 'file_index';  
unit = '';

[timep, xlabel_text] = choose_timep_unit(timep_unit,DataInfo);
fig_full    
sgtitle([DataInfo.experiment_name,10, DataInfo.measurement_name],'interpreter','none')

try
    how_many_different_data = 3;
    subplot(how_many_different_data,1,1)
    dat = Data_BPM_summary.BPM_avg;
    tittext = 'Beating rate (BPM)';
    plot(timep, dat,'.-'), ylabel(tittext), title(tittext)
    plot_hypoxia_line(timep, dat, DataInfo)
    
    subplot(how_many_different_data,1,2)
    dat = abs(DataPeaks_summary.depolarization_amplitude)*1e3; 
    tittext = 'Amplitude (mV)';
    plot(timep, dat,'.-'), ylabel(tittext), title(tittext)
    plot_hypoxia_line(timep, dat, DataInfo)
    
catch % no amplitude
    how_many_different_data = 2;
    subplot(how_many_different_data,1,1)
    dat = Data_BPM_summary.BPM_avg;
    tittext = 'Beating rate (BPM)';
    plot(timep, dat,'.-'), ylabel(tittext), title(tittext)
    plot_hypoxia_line(timep, dat, DataInfo) 
end

subplot(how_many_different_data,1,how_many_different_data)

% calculate FPDc (or FPD)
dat =  DataPeaks_summary.fpd; 
[dat, tittext] = which_fpd_correction(fpd_correction, dat);

plot(timep, dat,'.-'), ylabel(tittext), title(tittext)
plot_hypoxia_line(timep, dat, DataInfo)

for pp = 1:how_many_different_data
    subplot(how_many_different_data,1,pp)
    xlabel([xlabel_text])
    try
        Data_o2.data(Data_o2.measurement_time.datafile_index);
        yyaxis right
        plot(timep,Data_o2.data(Data_o2.measurement_time.datafile_index),'--')
        ylabel('pO2 (kPa)') 
    catch
    end

    axis tight
end



%% Summarize, normalized: BPM, amplitude, signal duration
% fpd_correction = 'Izumi-Nakeseko';
% fpd_correction = 'Bazett';
% fpd_correction = 'Fridericia';
% fpd_correction = 'none'; % for just FPD 

% unit = '';
% timep_unit = 'datetime';  
% timep_unit = 'hours';  
% timep_unit = 'file_index';  

% choosing index(es) which values are used for normalizing values
try % finding hypoxia starting time index
    ind_hyp = DataInfo.hypoxia.start_time_index;
    if ind_hyp >=3
        norm_index = ind_hyp-3:ind_hyp-1;
    elseif ind_hyp >=1
        norm_index = ind_hyp-1;
    else
        norm_index =ind_hyp;
    end
catch % no hypoxia index: taking first index as normalizing value
    norm_index = 1;
end

[timep, xlabel_text] = choose_timep_unit(timep_unit,DataInfo);
fig_full, 
sgtitle([DataInfo.experiment_name,10, DataInfo.measurement_name],'interpreter','none')
try
    how_many_different_data = 3;
    subplot(how_many_different_data,1,1)
    dat = Data_BPM_summary.BPM_avg;
    dat = dat ./ mean(dat(norm_index,:));
    tittext = 'Beating rate (norm)';
    plot(timep, dat), ylabel(tittext), title(tittext)
    plot_hypoxia_line(timep, dat, DataInfo)

    subplot(how_many_different_data,1,2)
    dat = abs(DataPeaks_summary.depolarization_amplitude);
    tittext = 'Normalized absolute amplitude (norm)';
    dat = dat ./ mean(dat(norm_index,:));
    plot(timep, dat), ylabel(tittext), title(tittext)
    plot_hypoxia_line(timep, dat, DataInfo)
    ylim([0 Inf])

catch % no amplitude
    how_many_different_data = 2;
    subplot(how_many_different_data,1,1)
    dat = Data_BPM_summary.BPM_avg;
    dat = dat ./ mean(dat(norm_index,:));
    tittext = 'Beating rate (norm)';
    plot(timep, dat), ylabel(tittext), title(tittext)
    plot_hypoxia_line(timep, dat, DataInfo)
    ylim([0 Inf])
end

subplot(how_many_different_data,1,how_many_different_data)
% calculate FPDc (or FPD)
dat =  DataPeaks_summary.fpd; 
[dat, titletext_fpdctype] = which_fpd_correction(fpd_correction, dat);
tittext = ['Normalized signal duration fpd(c) based on ',titletext_fpdctype];
% normalizing
dat = dat./ mean(dat(norm_index,:));
plot(timep, dat,'.-'), ylabel(tittext), title(tittext)
plot_hypoxia_line(timep, dat, DataInfo)
ylim([0 Inf])

for pp = 1:how_many_different_data
    subplot(how_many_different_data,1,pp)
    xlabel([xlabel_text])
    try
        Data_o2.data(Data_o2.measurement_time.datafile_index)
        yyaxis right
        dat = Data_o2.data(Data_o2.measurement_time.datafile_index);
        dat = dat ./ mean(dat(norm_index,:));
        plot(timep,dat,'--')
        ylabel('O2 (norm)')
    catch
    end
    axis tight
end
%% If want to limit y-axis to certain range, use this cell
ylimits = [0 2.5];
ylimits = [.7 1.1];
ylimits = [.65 1.25];

ylimits_o2 = [0 1.1];

for pp = 1:how_many_different_data
	subplot(how_many_different_data,1,pp)
    try
        Data_o2.data(Data_o2.measurement_time.datafile_index)
        yyaxis left
        ylim([ylimits])
        yyaxis right
        ylim([ylimits_o2])
    catch
        ylim([ylimits])
    end
end
