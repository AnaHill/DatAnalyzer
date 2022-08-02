function slice_and_plot_datapeak_signals(time_range_from_peak, ...
    file_indexes_to_analyze, datacolumns, plot_average, ...
    Data, DataInfo, Data_BPM)
% function slice_and_plot_datapeak_signals(time_range_from_peak, file_indexes_to_analyze, datacolumns, ...
%     plot_average, Data, DataInfo, Data_BPM)
% plot randomly one file and all datacolumns
    % slice_and_plot_datapeak_signals
% previous with mean line
    % slice_and_plot_datapeak_signals([],[],[],1)
% plot certain file and datacolumns, include mean line
    % slice_and_plot_datapeak_signals([],3,[2,3],1)
narginchk(0,7)
nargoutchk(0,0)
% default time: 0.2 sec backwards, 1.4 sec forward
if nargin < 1 || isempty(time_range_from_peak) 
    time_range_from_peak = [-.2 1.4]; 
	disp(['Using default time range from the peak: ',...
        num2str(time_range_from_peak)]) 
end

if nargin < 5 || isempty(Data) 
    try
        Data = evalin('base','Data');
    catch
        error('No Data')
    end
end

if nargin < 6 || isempty(DataInfo) 
    try
        DataInfo = evalin('base','DataInfo');
    catch
        error('No DataInfo')
    end
end

if nargin < 7 || isempty(Data_BPM) 
    try
        Data_BPM = evalin('base','Data_BPM');
    catch
        error('No Data_BPM')
    end
end

% default: plot randomly one file
if nargin < 2 || isempty(file_indexes_to_analyze) 
    file_indexes_to_analyze = randi([1 DataInfo.files_amount],1);
    disp(['Choosing randomly file index#',num2str(file_indexes_to_analyze)]) 
end

% default: all datacolumns plotted
if nargin < 3 || isempty(datacolumns) 
    datacolumns = 1:length(DataInfo.datacol_numbers);
    disp(['Choosing all data columns# ',num2str(datacolumns)]) 
end

% default: average line not plotted
if nargin < 4 || isempty(plot_average) 
    plot_average = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file_indexes_to_analyze = sort(unique(file_indexes_to_analyze));

if length(file_indexes_to_analyze) > 10
    amount_figs = length(file_indexes_to_analyze);
    answer = questdlg(['Are you sure you want to plot all ',...
        num2str(amount_figs),' figs?'],'Plotting all', 'Yes','No','No'); 
    if strcmp(answer,'No')
        disp(['Chosen not to plot ',num2str(amount_figs), ' figures, returning'])
        return
    end
end

%%% fig parameters
[fig_parameters] = cal_subfig_parameters(datacolumns);
sub_fig_rows=fig_parameters(1);
sub_fig_cols=fig_parameters(2);
new_fig_number  = fig_parameters(3);
hfigs = cell(length(file_indexes_to_analyze),1);
for kk = 1:length(file_indexes_to_analyze)
    fig_full
    hfigs{kk,1} = hfig;
    num=1;
    plot_mean = [];
    leg_mean = {};
    % get_file_parameters % creates file_index, fs, time, and empty DataPeak
    file_index = file_indexes_to_analyze(kk);
    fs = DataInfo.framerate(file_index);
    index_from_peak = time_range_from_peak*fs;
    time = 0:1/fs:(abs(diff(index_from_peak)))/fs;
    DataPeak = cell(1,length(datacolumns));
    % slice data and plot
    for pp = 1:length(datacolumns)
        col = datacolumns(pp);
        slice_peak_data % slices data to DataPeak  
        % plot all data columns to same figure to different subfigs
        subplot(sub_fig_rows,sub_fig_cols,num)
        try
            plot(time, DataPeak{1,col});
            axis tight
            xlabel('Time (sec)')
            ylabel('Measurement (V)')
            if plot_average ~= 0
                mean_data(:,1) = mean(DataPeak{1,col},2);
                hold all,
                plot_mean(end+1) = plot(time, mean_data(:,1),':',...
                    'linewidth',3,'color','k');%[.7 .7 .7]);
                leg_mean{end+1} = ['Average from ','\bf',...
                    num2str(min(size(DataPeak{col}))),'\rm',' signals'];
            end
        catch
            disp('no peaks')
        end
        num=num+1;
        subfig_title_text = create_datacolumn_text(col, DataInfo);
        % function [datacolumn_info_text] = create_datacolumn_text(datacolumn_ind,DataInfo)
        title(subfig_title_text)
        grid
    end
    if plot_average ~= 0
        legend(plot_mean, leg_mean{:})
        plot_mean = {};
        leg_mean = {};
    end
    experiment_title_text = create_experiment_info_text(file_index,DataInfo);
    sgtitle(experiment_title_text,'interpreter','none','fontsize',12,...
        'fontweight', 'bold')
end
% presenting first figure on screen
for fig_index = length(hfigs):-1:1
    figure(hfigs{fig_index,1}); 
end


end