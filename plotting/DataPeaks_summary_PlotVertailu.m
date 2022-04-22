%% Summarize normalized:  BPM, amplitude, signal duration
fpd_correction = 'Izumi-Nakeseko';
% fpd_correction = 'Bazett';
% fpd_correction = 'Fridericia';
if ~exist('chosen_datacolumns','var')
    chosen_datacolumns=1:length(DataInfo.datacol_numbers);
end
timep_unit = 'datetime';  
timep_unit = 'hours';  
% timep_unit = 'file_index';  

try
    ind_hyp = DataInfo.hypoxia.start_time_index;
    if ind_hyp >=3
        norm_index = ind_hyp-3:ind_hyp-1;
    elseif ind_hyp >=1
        norm_index = ind_hyp-1;
    else
        norm_index =ind_hyp;
    end
catch
    norm_index = 1;
end

unit = '';
[timep, xlabel_text] = choose_timep_unit(timep_unit,DataInfo);

try
    how_many_different_data = 3;
    subplot(how_many_different_data,1,1), hold all
    dat = Data_BPM_summary.BPM_avg; tittext = 'Beating rate (BPM)';
    dat = dat ./ mean(dat(norm_index,:)); tittext = 'Beating rate (norm)';
    dat = dat(:,chosen_datacolumns);
    plot(timep, dat), ylabel(tittext), title(tittext)
    plot_hypoxia_line(timep, dat, DataInfo)

    subplot(how_many_different_data,1,2), hold all
    dat = DataPeaks_summary.first_peak_amplitude_abs;
    dat = dat ./ mean(dat(norm_index,:));
    dat = dat(:,chosen_datacolumns);
    tittext = 'Normalized absolute amplitude (norm)';
    plot(timep, dat), ylabel(tittext), title(tittext)
    plot_hypoxia_line(timep, dat, DataInfo)
catch % no amplitude
    how_many_different_data = 2;
    subplot(how_many_different_data,1,1), hold all
    dat = Data_BPM_summary.BPM_avg; tittext = 'Beating rate (BPM)';
    dat = dat ./ mean(dat(norm_index,:)); tittext = 'Beating rate (norm)';
    dat = dat(:,chosen_datacolumns);
    plot(timep, dat), ylabel(tittext), title(tittext)
    plot_hypoxia_line(timep, dat, DataInfo) 
end
subplot(how_many_different_data,1,how_many_different_data), hold all
[dat, tittext] = which_fpd_correction(fpd_correction, dat);
tittext = ['NORMALIZED: ',tittext];
dat = dat ./ mean(dat(norm_index,:));
dat = dat(:,chosen_datacolumns);

plot(timep, dat), ylabel(tittext), title(tittext)
plot_hypoxia_line(timep, dat, DataInfo)

for pp = 1:how_many_different_data
    subplot(how_many_different_data,1,pp)
    xlabel([xlabel_text])
    try
        Data_o2.data(Data_o2.measurement_time.datafile_index);
        yyaxis right
        plot(timep,Data_o2.data(Data_o2.measurement_time.datafile_index),'--')
        ylabel('O2 (kPa)') %         ylabel('O2 (%)')
    catch
    end

    axis tight
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS
function [dat, tittext] = which_fpd_correction(fpd_correction,dat, Data_BPM_summary)
    % function [dat, tittext] = which_fpd_correction(fpd_correction)
    narginchk(0,3)
    nargoutchk(0,2)

    if nargin < 1 || isempty(fpd_correction)
        fpd_correction = 'Izumi-Nakeseko';
    end
    if nargin < 3 || isempty(Data_BPM_summary)
        Data_BPM_summary = evalin('base','Data_BPM_summary');
    end
    switch fpd_correction
        case 'Izumi-Nakeseko'
            dat = dat./(Data_BPM_summary.BPM_avg/60).^0.22; % \cite{Hyyppa2018}: Izumi-Nakeseko 2017
            tittext = ['BMP corrected signal duration',10,'FPDc=FPD/(60/BPM)^{0.22} (ms)'];
            disp('Choosing Izumi-Nakaseko: FPDc=FPD/(60/BPM)^{0.22}')
        case 'Bazett'
            dat = dat./sqrt(Data_BPM_summary.BPM_avg/60);
            tittext = ['BMP corrected signal duration',10,'Bazetts FPDc=FPD/(60/BPM)^{1/2} (ms)'];
            disp('Choosing Bazetts: FPDc=FPD/(60/BPM)^{1/2}')
        case 'Friodericia'
            dat = dat./(Data_BPM_summary.BPM_avg/60).^(1/3);
            tittext = ['BMP corrected signal duration',10,'Fridericia FPDc=FPD/(60/BPM)^{1/3} (ms)'];
            disp('Choosing Bazetts: FPDc=FPD/(60/BPM)^{1/3}')
        otherwise
            disp('No proper input, choosing Izumi-Nakaseko: FPDc=FPD/(60/BPM)^{0.22}')
            dat = dat./(Data_BPM_summary.BPM_avg/60).^0.22; % \cite{Hyyppa2018}: Izumi-Nakeseko 2017
            tittext = ['BMP corrected signal duration',10,'FPDc=FPD/(60/BPM)^{0.22}'];
    end

end
function plot_hypoxia_line(timep, dat, DataInfo)
try
    hyp_start = DataInfo.hypoxia.start_time_index;
    hyp_end = DataInfo.hypoxia.end_time_index;
    line([timep(hyp_start) timep(hyp_start)], [min(dat(:)) max(dat(:))],...
        'color', [.4 .4 .4],'linestyle','--')
    line([timep(hyp_end) timep(hyp_end)], [min(dat(:)) max(dat(:))],...
        'color', [.4 .4 .4],'linestyle','--')
catch
    disp('no hypoxia information')
end
end
%%%%%%%%%%%%%%%%%
function [timep, xlabel_text] = choose_timep_unit(timep_unit,DataInfo)
switch timep_unit
    case 'datetime'
        timep = DataInfo.measurement_time.datetime;
        xlabel_text = '';
    case 'hours'
        timep = DataInfo.measurement_time.time_sec/3600;
        xlabel_text = 'Time (h)';
        
    case 'file_index'
        timep = 1:DataInfo.files_amount;
        xlabel_text = 'File#';
    otherwise
        error('check time')
end
end
