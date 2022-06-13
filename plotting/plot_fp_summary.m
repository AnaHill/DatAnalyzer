function hfig = plot_fp_summary(normalizing, fpd_correction, time_unit, hfig,...
    DataInfo, DataPeaks_summary, Data_o2, norm_indexes)
% function hfig = plot_fp_summary(normalizing, fpd_correction, time_unit, hfig,...
%     DataInfo,  DataPeaks_summary, Data_o2, norm_indexes)
% PLOT_FP_SUMMARY plots summary of the FP values: 
    % depolarization time tdep, depolarization amplitude, and FPD
% plot_summary % default plot with absolute values and 
    % - fpd-correction: Izumi-Nakaseko FPDc
    % - time_unit = 'datetime';
    % - to new, full screen size, figure
% plot_fp_summary(1) % normalized values
% plot_fp_summary([],[],[],hfig) % if plotting to certain figure given in input
% if want to limit y-axes, call limit_y_axes after this, e.g.
    % plot_fp_summary;pause(0.2); ylimits=[0 Inf];ylimits_o2=[0 Inf]; limit_y_axes(ylimits, ylimits_o2)

% Normalized plot, normalization based on file indexes 3-5
    % plot_fp_summary(1, [], [], [], [], [], [], 3:5);
    
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
    % limit_y_axes
        % limit_y_axes(ylimits, ylimits_o2)
    
%% checking inputs and set defaults
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

if nargin < 6 || isempty(DataPeaks_summary)
    try
        DataPeaks_summary = evalin('base', 'DataPeaks_summary');
    catch
        error('No proper DataPeaks_summary')
    end
end

if nargin < 7 || isempty(Data_o2)
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
if normalizing == 1
    % choosing index(es) which values are used for normalizing values
    if ~exist('norm_indexes','var') % if not given in function call 
        % first try to finding hypoxia starting time index
        try 
            ind_hyp = DataInfo.hypoxia.start_time_index;
            if ind_hyp >= 3
                norm_indexes = ind_hyp-3:ind_hyp-1;
            elseif ind_hyp >= 1
                norm_indexes = ind_hyp-1;
            else
                norm_indexes =ind_hyp;
            end
        catch % no hypoxia index: taking first index as normalizing value
            norm_indexes = 1;
        end    
    end
end

%% Plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(hfig)% fig_full    
sgtitle([DataInfo.experiment_name,' - ',DataInfo.measurement_name],...
    'interpreter','none')
% legend
legs = {};
for col_index = 1:length(DataInfo.datacol_numbers)
    try
        legs{end+1,1} = ['MEA ele#',num2str(DataInfo.MEA_electrode_numbers(col_index))];
    catch
        legs{end+1,1} = ['Datacolumn#',num2str(col_index)];
    end
end
dataplots = [];
%% if absolute values are plotted
if normalizing == 0
    try
        how_many_different_data = 3;
        subplot(how_many_different_data,1,1)
        dat =  DataPeaks_summary.depolarization_time*1e3;
        tittext = 'Depolarization time';
        ylabel_text = 't_{dep} (ms)';
        dataplots = plot(timep, dat,'.-'); 
        ylabel(ylabel_text), title(tittext)
        plot_hypoxia_line(timep, dat, DataInfo)        
        subplot(how_many_different_data,1,2)
        dat = abs(DataPeaks_summary.depolarization_amplitude)*1e3; 
        ylabel_text = 'A (mV)';
        tittext = 'Depolarization Amplitude (absolute)';
        plot(timep, dat,'.-'), ylabel(ylabel_text), title(tittext)
        plot_hypoxia_line(timep, dat, DataInfo)
        
        subplot(how_many_different_data,1,1) % for legend back to first subplot
    catch % 
        error('Missing fp parameters!')
    end
    legend(dataplots,legs, 'interpreter','none','location','best')

    subplot(how_many_different_data,1,how_many_different_data)
    % calculate FPDc (or FPD)
    dat =  DataPeaks_summary.fpd; 
    [dat, tittext] = which_fpd_correction(dat,fpd_correction);
    if strcmp(tittext,'Pure FPD, not BPM corrected FPDc') % if not FPDc, just FPD
        ylabel_text = 'FPD';
    else
        ylabel_text = ['FPDc'];
    end
    dat = dat*1e3; ylabel_text = [ylabel_text,' (ms)'];% set FPD in ms
    plot(timep, dat,'.-'), ylabel(ylabel_text), title(tittext)
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
%% if normalized values are plotted
% now median values used for normalization, e.g.
% instead of dat = dat ./ mean(dat([norm_indexes],:),1);
% --> dat = dat ./ median(dat([norm_indexes],:),1);

if normalizing == 1
    try
        how_many_different_data = 3;
        subplot(how_many_different_data,1,1)
        tittext = ['Normalized depolarization time, normalization from median of file(s) #',...
            num2str(norm_indexes)];
        dat =  DataPeaks_summary.depolarization_time*1e3;
        dat = dat ./ median(dat([norm_indexes],:),1);
        ylabel_text = 'Normalized t_{dep}';
        dataplots = plot(timep, dat); ylabel(ylabel_text), title(tittext)
        plot_hypoxia_line(timep, dat, DataInfo)
        
        subplot(how_many_different_data,1,2)
        dat = abs(DataPeaks_summary.depolarization_amplitude);
        dat = dat ./ median(dat([norm_indexes],:),1);
        tittext = 'Normalized Absolute amplitude';
        ylabel_text = 'A (norm)';
        plot(timep, dat), ylabel(ylabel_text), title(tittext)
        plot_hypoxia_line(timep, dat, DataInfo)
        ylim([0 Inf])
        
        subplot(how_many_different_data,1,1) % for legend back to first subplot
    catch % 
        error('Missing fp parameters!')
    end
    legend(dataplots,legs, 'interpreter','none','location','best')

    subplot(how_many_different_data,1,how_many_different_data)
    % calculate FPDc (or FPD)
    dat =  DataPeaks_summary.fpd;
    [dat, titletext_fpdctype] = which_fpd_correction(dat, fpd_correction);
    if strcmp(titletext_fpdctype,'Pure FPD, not BPM corrected FPDc') % if not FPDc, just FPD
        ylabel_text = 'FPD (norm)';
    else
        ylabel_text = ['FPDc (norm)'];
    end
    titletext_fpdctype = ['Normalized ',titletext_fpdctype];
    % normalizing
    dat = dat ./ median(dat([norm_indexes],:),1);
    plot(timep, dat,'.-'), ylabel(ylabel_text), title(titletext_fpdctype)
    plot_hypoxia_line(timep, dat, DataInfo)
    ylim([0 Inf])
    
    for pp = 1:how_many_different_data
        subplot(how_many_different_data,1,pp)
        xlabel([xlabel_text])
        try
            Data_o2.data(Data_o2.measurement_time.datafile_index)
            yyaxis right
            dat = Data_o2.data(Data_o2.measurement_time.datafile_index);
            dat = dat ./ mean(dat([norm_indexes],:),1);
            plot(timep,dat,'--')
            ylabel('O2 (norm)')
        catch
        end
        axis tight
    end
end
zoom on
end