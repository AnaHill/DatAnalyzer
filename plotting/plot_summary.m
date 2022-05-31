function hfig = plot_summary(normalized, fpd_correction, time_unit)
narginchk(0,2)
nargoutchk(0,1)

if nargin < 1 || isempty(normalized)
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

% get variables
try
    DataInfo = evalin('base', 'DataInfo');
catch
    error('No DataInfo found!')
end
try
    Data_BPM_summary = evalin('base', 'Data_BPM_summary');
catch
    error('No Data_BPM_summary found!')
end
try
    DataPeaks_summary = evalin('base', 'DataPeaks_summary');
catch
    error('No DataPeaks_summary found!')
end

try
    Data_o2 = evalin('base', 'Data_o2');
catch
    disp('No O2 info, Data_o2, found')
end

[timep, xlabel_text] = choose_timep_unit(time_unit,DataInfo);


%%% TODO: user could choose index(es) to be normalized
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

%%%%% plotting
fig_full    
sgtitle([DataInfo.experiment_name,10, DataInfo.measurement_name],'interpreter','none')
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
            disp('No O2 data to plot.')
        end

        axis tight
    end
end
%% if normalized values
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
end




end