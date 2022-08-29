function [] = plot_signal_average(plot_confidence_level, confidence_level, ...
    file_index_to_analyze, datacolumns, plot_all_files_to_same, DataPeaks_mean)
% function [] = plot_signal_average(plot_confidence_level,confidence_level, ...
%     file_index_to_analyze, datacolumns, plot_all_files_to_same, DataPeaks_mean)
% plot_all_files_to_same: set 1 or 'yes' if all are plotted to same figure
% Examples
% plot randomly one file, all datacolumns, separate subplots: plot_signal_average,
% above with 95% confidence level: plot_signal_average(1)
% above with fileindex#3: plot_signal_average(1,[],3)
% fileindexes #3&4 to same fig: plot_signal_average(0,[],[3,4],[],'yes')
% For plotting confidence level, see 
    % https://se.mathworks.com/matlabcentral/answers/414039-plot-confidence-interval-of-a-signal?s_tid=answers_rc1-2_p2_MLT
    % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ‘x’
    % yCI95 = bsxfun(@times, ySEM', CI95(:));
    % x_plott = [1:size(dat,1) fliplr(1:size(dat,1))];
    % y_plott = [(yCI95(2,:)+a1') fliplr(yCI95(1,:)+a1')];
% and plotting confidence with fill
    % https://se.mathworks.com/matlabcentral/answers/425206-plot-of-confidence-interval-with-fill

max_inputs = 6;    
narginchk(0,6)
nargoutchk(0,0)
%%%%%%%%%%%
if nargin < max_inputs || isempty(DataPeaks_mean) 
    try
        DataPeaks_mean = evalin('base','DataPeaks_mean');
    catch
        error('No DataPeaks_mean found')
    end
end
try
    DataInfo = evalin('base','DataInfo');
catch
    error('No DataInfo')
end
%%%% defaults
% default: not plotting confidence level
if nargin < 1 || isempty(plot_confidence_level) 
    plot_confidence_level = 0;
end

% Default: 95% condifence level calculated with 1.96*SD (normal distribution)
if nargin < 2 || isempty(confidence_level) 
    confidence_level = 1.96;
end

% default: random plot if file_index_to_analyze not given
if nargin < 3 || isempty(file_index_to_analyze) 
    file_index_to_analyze = randi([1 length(DataPeaks_mean)],1);
    disp(['Plotting randomly file#',num2str(file_index_to_analyze)])
else
    file_index_to_analyze = unique(sort(file_index_to_analyze));
    disp(['Plotting file(s)# ',num2str(file_index_to_analyze)])
end
if length(file_index_to_analyze) > 15
    amount_figs = length(file_index_to_analyze);
    answer = questdlg(['Are you sure you want to plot all ',...
        num2str(amount_figs),' figs?'],'Plotting all', 'Yes','No','No');
    switch answer
        case 'Yes'
            disp(['Plotting ',num2str(amount_figs),' figs, might take for a while.'])
        otherwise
            disp('Chosen not to plot data as so many chosen, returning')
            return
    end
end
% default: all datacolumns plotted
if nargin < 4 || isempty(datacolumns) 
    datacolumns = 1:length(DataInfo.datacol_numbers);
end

% default: not plotting all files to same
if nargin < 5 || isempty(plot_all_files_to_same)
    plot_all_files_to_same = 0;
end
% if plot_all_files_to_same is anything else than 1 or 'yes', do not plot to same
if ~(any(plot_all_files_to_same == 1) || strcmp(plot_all_files_to_same,'yes'))
    plot_all_files_to_same = 0;
else
    plot_all_files_to_same = 1;
end

%%% fig parameters
[fig_parameters] = cal_subfig_parameters(datacolumns);
sub_fig_rows=fig_parameters(1);
sub_fig_cols=fig_parameters(2);
new_fig_number  = fig_parameters(3);
hfigs = cell(length(file_index_to_analyze),1);

framerates = DataInfo.framerate;

% plot only one fig
if plot_all_files_to_same ~= 0
    fig_full
    hfigs{1,1} = hfig; hold on
    legs_file = [];
end

for kk = 1:length(file_index_to_analyze)
    file_index = file_index_to_analyze(kk);
    fs = framerates(file_index);
    dat_length = length(DataPeaks_mean{file_index, 1}.data(:,1));
    time = 0:1/fs:(dat_length-1)/fs;
    num=1;
    plot_mean = [];
    leg_mean = {};
    if plot_all_files_to_same == 0
        fig_full
        hfigs{kk,1} = hfig;
        hold on,
    end
    dat = DataPeaks_mean{file_index, 1};
	for pp = 1:length(datacolumns)
        col = datacolumns(pp);
        % plot all data columns to same figure to different subfigs
        subplot(sub_fig_rows,sub_fig_cols,num)
        if plot_all_files_to_same == 0
            plot_mean = plot(time, dat.data(:,col),'k','linewidth',3);
        else
            plot_mean = plot(time, dat.data(:,col),'linewidth',1); hold on
        end
        
        % plotting confidence level; see link provided at start
        if  plot_confidence_level ~= 0
            hold on,
            N = dat.N(1,col);
            x_plott = [time fliplr(time)];
            yMean = dat.data(:,col);
            ySD = dat.data_std(:,col);
            CI95 = dat.CI95(:,col);
            try
                ySEM = dat.ySEM(:,col);
                yCI95 = bsxfun(@times, ySEM', CI95(:));
            catch
            end
            if confidence_level == 99 % plotting 99% condifence level 
                try
                    CI99 = dat.CI99(:,col);
                    yCI99 = bsxfun(@times, ySEM', CI99(:));            
                    y_plott = [(yCI99(2,:)+yMean') fliplr(yCI99(1,:)+yMean')];
                    disp('Plotting 99% confidence level')
                catch
                    disp('No 99% confidence level available, plotting 95%')
                    y_plott = [(yCI95(2,:)+yMean') fliplr(yCI95(1,:)+yMean')];
                end
            elseif confidence_level == 95 % plotting 95% condifence level 
                disp('Plotting 95% confidence level')
                y_plott = [(yCI95(2,:)+yMean') fliplr(yCI95(1,:)+yMean')];
            elseif confidence_level == 1.96
                disp('Plotting 95% confidence level with 1.96 x SD (normally distributed)')
                gain_sd = 1.96;
                y_plott = [yMean+ySD*gain_sd;flipud(yMean-ySD*gain_sd)];
                           
            end
            % Plot 95% or 99% Confidence Intervals Of All Experiments
            plot_fill = fill(x_plott, y_plott, 1,'facecolor', [.4 .4 .4],...
                'edgecolor', 'none', 'facealpha', 0.4);
        end
        subfig_title_text = create_datacolumn_text(col,DataInfo);
        title(subfig_title_text)
        axis tight
        xlabel('Time (sec)')
        ylabel('Measurement (V)')
        num=num+1;
    end
    experiment_title_text = create_experiment_info_text(file_index,DataInfo);
    if plot_all_files_to_same == 0
        sgtitle(experiment_title_text,'interpreter','none',...
            'fontsize',12, 'fontweight', 'bold')  
    else
        try
            legs_file{end+1,1} = ['File#',num2str(file_index),' ',...
                DataInfo.hypoxia.names{file_index}];
        catch
            legs_file{end+1,1} = ['File#',num2str(file_index),' ',...
                DataInfo.measurement_time.names{file_index}];            
        end
        % legs_file{end+1,1} = experiment_title_text;
    end
end
% presenting first above
if plot_all_files_to_same == 0
    for fig_index = length(hfigs):-1:1
        figure(hfigs{fig_index,1}); 
    end
else
   legend(legs_file,'interpreter','none', 'fontsize',10,'location','best')
end

end
