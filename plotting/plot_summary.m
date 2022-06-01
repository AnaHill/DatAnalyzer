function hfig = plot_summary(normalizing, fpd_correction, time_unit, hfig,...
    DataInfo, Data_BPM_summary, DataPeaks_summary, Data_o2)
% PLOT_SUMMARY plots summary of the BPM analysis
% plot_summary % default plot with absolute values and 
    % - fpd-correction: Izumi-Nakaseko FPDc
    % - time_unit = 'datetime';
    % - to new, full screen size, figure
% plot_summary(1) % normalized values
% plot_summary([],[],[],hfig) % if plotting to certain figure given in input
% fpd_correction: Following FPDc equations
    % 1) 'Izumi-Nakaseko' (default): FPDc=FPD/(60/BPM)^{0.22}
    % 2) 'Bazett': FPDc=FPD/(60/BPM)^{1/2}
    % 3) 'Fridericia': FPDc=FPD/(60/BPM)^{1/3}
    % 4) 'none' (or any other than above): Pure FPD, no corrected FPD
% time_unit   
    % 'datetime' (default)
    % 'hours'
    % 'seconds'
    % 'file_index'
% required files
    % choose_timep_unit.m
        % [timep, xlabel_text] = choose_timep_unit(timep_unit,DataInfo)
    % which_fpd_correction.m
        % [data_out, tittext] = which_fpd_correction(data_in, fpd_correction, Data_BPM_summary)
    % plot_hypoxia_line
        % plot_hypoxia_line(timep, dat, DataInfo)    
%% TODO:
% see script open('.\plotting\Summarize_plot_DataPeaks_summary.m')
    % 1) user could choose index(es) to be normalized
    % 2) If want to limit y-axis to certain range, could give them in input
    % ylimits = [0 2.5];
    % ylimits_o2 = [0 1.1];
    % for pp = 1:how_many_different_data
    % 	subplot(how_many_different_data,1,pp)
    %     try
    %         Data_o2.data(Data_o2.measurement_time.datafile_index)
    %         yyaxis left
    %         ylim([ylimits])
    %         yyaxis right
    %         ylim([ylimits_o2])
    %     catch
    %         ylim([ylimits])
    %     end
    % end
%% checking inputs and 
narginchk(0,8)
nargoutchk(0,1)
% set defaults
if nargin < 1 || isempty(normalizing)
    normalizing = 0;
end
if any(normalizing ~= 1)
    normalizing = 0;
end

if nargin < 2 || isempty(fpd_correction)
    fpd_correction = 'Izumi-Nakaseko';
end

if nargin < 3 || isempty(time_unit)
    time_unit = 'datetime';  
end

if nargin < 4 || isempty(hfig)
    % hfig = evalin('base', 'hfig'); % does this needed?!
    disp('Create new full size figure.')
    fig_full % creates hfig
end

%% read data and info if not given
if nargin < 5 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end

if nargin < 6 || isempty(Data_BPM_summary)
    try
        Data_BPM_summary = evalin('base', 'Data_BPM_summary');
    catch
        error('No proper Data_BPM_summary')
    end
end

if nargin < 7 || isempty(DataPeaks_summary)
    try
        DataPeaks_summary = evalin('base', 'DataPeaks_summary');
    catch
        error('No proper DataPeaks_summary')
    end
end

if nargin < 8 || isempty(Data_o2)
    try
        Data_o2 = evalin('base', 'Data_o2');
    catch
        disp('No O2 info (Data_o2), found')
    end
end

%%
% get time units
[timep, xlabel_text] = choose_timep_unit(time_unit,DataInfo);

% get normalizing index(es) if used
% TODO: user could choose index(es) to be normalized
if normalizing == 1
    % choosing index(es) which values are used for normalizing values
    try % finding hypoxia starting time index
        ind_hyp = DataInfo.hypoxia.start_time_index;
        if ind_hyp >= 3
            norm_index = ind_hyp-3:ind_hyp-1;
        elseif ind_hyp >= 1
            norm_index = ind_hyp-1;
        else
            norm_index =ind_hyp;
        end
    catch % no hypoxia index: taking first index as normalizing value
        norm_index = 1;
    end    
end

%% Plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(hfig)% fig_full    
sgtitle([DataInfo.experiment_name,10, DataInfo.measurement_name],...
    'interpreter','none')
%% if absolute values plotted
if normalizing == 0
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
    [dat, tittext] = which_fpd_correction(dat,fpd_correction);

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
            disp('No O2 data to plot.')
        end

        axis tight
    end
end
%% if normalized values plotted
if normalizing == 1
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
        tittext = 'Absolute amplitude (norm)';
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
    [dat, titletext_fpdctype] = which_fpd_correction(dat, fpd_correction);
%     tittext = ['Normalized signal duration fpd(c) based on ',titletext_fpdctype];
    tittext = ['FPDc (norm)',titletext_fpdctype];

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
end

end