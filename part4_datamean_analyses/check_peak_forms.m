function check_peak_forms(Data, DataInfo, Data_BPM,...
    time_range_from_peak, every_nth_data, datacolumns, plot_average)
% function check_peak_forms(Data, DataInfo, Data_BPM,...
%     time_range_from_peak, every_nth_data, datacolumns, plot_average)
narginchk(0,7)
nargoutchk(0,0)

if nargin < 1 || isempty(Data) 
    try
        Data = evalin('base','Data');
    catch
        error('No Data')
    end
end

if nargin < 2 || isempty(DataInfo) 
    try
        DataInfo = evalin('base','DataInfo');
    catch
        error('No DataInfo')
    end
end

if nargin < 3 || isempty(Data_BPM) 
    try
        Data_BPM = evalin('base','Data_BPM');
    catch
        error('No Data_BPM')
    end
end
% default time: 0.2 sec backwards, 1.5 sec forward
if nargin < 4 || isempty(time_range_from_peak) 
    time_range_from_peak = [-.2 1.4]; 
end
% default: every 10th data is plotted
if nargin < 5 || isempty(every_nth_data) 
    every_nth_data = 10;
end

if every_nth_data < 1
    every_nth_data = 1;
elseif every_nth_data > DataInfo.files_amount
    every_nth_data = DataInfo.files_amount;
end

% default: all datacolumns plotted
if nargin < 6 || isempty(datacolumns) 
    datacolumns = 1:length(DataInfo.datacol_numbers);
end
% default: not calculate average
if nargin < 7 || isempty(plot_average) 
    plot_average = 0;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check how many plots are drawn
file_index_to_analyze = unique([1:every_nth_data:...
    DataInfo.files_amount,DataInfo.files_amount]);

if length(file_index_to_analyze) > 15
    amount_figs = length(file_index_to_analyze);
    answer = questdlg(['Are you sure you want to plot all ',...
        num2str(amount_figs),' figs?'],'Plotting all', 'Yes','No','No'); 
    switch answer
        case 'Yes'
            plot_all_index = 1;
        otherwise
            disp('Chosen not to plot data as so many chosen, returning')
            return
    end
end

%%% fig parameters
[fig_parameters] = cal_subfig_parameters(datacolumns);
sub_fig_rows=fig_parameters(1);
sub_fig_cols=fig_parameters(2);
new_fig_number  = fig_parameters(3);
hfigs = cell(length(file_index_to_analyze),1);
for kk = 1:length(file_index_to_analyze)
    fig_full
    hfigs{kk,1} = hfig;
    num=1;
    plot_mean = [];
    leg_mean = {};
    get_file_parameters % creates file_index, fs, time, and empty DataPeak
    % slice data and plot
    for pp = 1:length(datacolumns)
        slice_peak_data % slices data to DataPeak     
        % plot all data columns to same figure to different subfigs
        subplot(sub_fig_rows,sub_fig_cols,num)
        try
            plot(time, DataPeak{1,pp});
            axis tight
            xlabel('Time (sec)')
            ylabel('Measurement (V)')
            if plot_average ~= 0
                mean_data(:,1) = mean(DataPeak{1,pp},2);
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
        % % function [datacolumn_info_text] = create_datacolumn_text(datacolumn_ind,DataInfo)
        title(subfig_title_text)
        grid
    end
    if plot_average ~= 0
        legend(plot_mean, leg_mean{:})
        plot_mean = {};
        leg_mean = {};
    end
    % experiment_title_text = create_experiment_info_text(file_index, Data,DataInfo);
    experiment_title_text = create_experiment_info_text(file_index,DataInfo);
    sgtitle(experiment_title_text,'interpreter','none','fontsize',12, 'fontweight', 'bold')
end
% presenting first above
for fig_index = length(hfigs):-1:1
    figure(hfigs{fig_index,1}); 
end


end