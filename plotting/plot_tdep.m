function hfig = plot_tdep(normalizing, time_unit, hfig,...
    DataInfo, DataPeaks_summary, Data_o2, norm_indexes)
% function hfig = plot_tdep(normalizing, time_unit, hfig,...
%     DataInfo, DataPeaks_summary, Data_o2, norm_indexes)
% PLOT_TDEP plots summary of depolarization times
% plot_tdep % default plot with absolute tdepolarization values in ms and 
    % - time_unit = 'datetime';
    % - to new, full screen size, figure
% plot_tdep(1) % normalized values
% plot_tdep([],[],hfig) % if plotting to certain figure given in input
% if want to limit y-axes, call limit_y_axes after this, e.g.
    % plot_tdep;pause(0.2); ylimits=[0 Inf];ylimits_o2=[0 Inf]; limit_y_axes(ylimits, ylimits_o2)
% Normalized plot, normalization based on file indexes 3-5
    % plot_tdep(1, [], [], [],[], [], 3:5);
% time_unit   
    % 'datetime' (default)
    % 'hours'
    % 'seconds'
    % 'file_index'
% required files
    % choose_timep_unit.m
        % [timep, xlabel_text] = choose_timep_unit(timep_unit,DataInfo)
    % plot_hypoxia_line
        % plot_hypoxia_line(timep, dat, DataInfo)    
    % limit_y_axes
        % limit_y_axes(ylimits, ylimits_o2)
%% checking inputs and set defaults
narginchk(0,7)
nargoutchk(0,1)
% set defaults
if nargin < 1 || isempty(normalizing)
    normalizing = 0;
end
if any(normalizing ~= 1)
    normalizing = 0;
end

if nargin < 2 || isempty(time_unit)
    time_unit = 'datetime';  
end

if nargin < 3 || isempty(hfig)
    disp('Create new full size figure.')
    fig_full % creates hfig
end

%% read data and info if not given
if nargin < 4 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end

if nargin < 5 || isempty(DataPeaks_summary)
    try
        DataPeaks_summary = evalin('base', 'DataPeaks_summary');
    catch
        error('No proper DataPeaks_summary')
    end
end

if nargin < 6 || isempty(Data_o2)
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
        dat =  DataPeaks_summary.depolarization_time*1e3;
        ylabel_text = 't_{dep} (ms)';
        dataplots = plot(timep, dat,'.-'); 
        ylabel(ylabel_text)
        plot_hypoxia_line(timep, dat, DataInfo)        
    catch 
    end

    try
        Data_o2.data(Data_o2.measurement_time.datafile_index);
        yyaxis right
        plot(timep,Data_o2.data(Data_o2.measurement_time.datafile_index),'--')
        ylabel('pO2 (kPa)')
    catch
        disp('No O2 data to plot.')
    end
    
    title([DataInfo.experiment_name,' - ', DataInfo.measurement_name,...
    ': Depolarization time'],'interpreter','none')
end
%% if normalized values are plotted
% now median values used for normalization, e.g.
% instead of dat = dat ./ mean(dat([norm_indexes],:),1);
% --> dat = dat ./ median(dat([norm_indexes],:),1);

if normalizing == 1
    try
        dat =  DataPeaks_summary.depolarization_time*1e3;
        dat = dat ./ median(dat([norm_indexes],:),1);
        ylabel_text = 'Normalized t_{dep}';
        dataplots = plot(timep, dat,'.-'); 
        ylabel(ylabel_text)
        plot_hypoxia_line(timep, dat, DataInfo)  
        ylim([0 Inf])
    catch 
    end

    try
        Data_o2.data(Data_o2.measurement_time.datafile_index);
        dat = Data_o2.data(Data_o2.measurement_time.datafile_index);
        dat = dat ./ mean(dat([norm_indexes],:),1);
        plot(timep,dat,'--')
        ylabel('O2 (norm)')
    catch
        disp('No O2 data to plot.')
    end     
    title([DataInfo.experiment_name,' - ', DataInfo.measurement_name,': ',...
        'Normalized depolarization time, normalized from median of file(s) #',...
        num2str(norm_indexes)],'interpreter','none')
end

%% General for both plots
legend(dataplots,legs, 'interpreter','none','location','best')
xlabel([xlabel_text])
axis tight, zoom on

end