function plot_files_with_irregular_beating(irregular_file_indexes,...
    irregular_datacolumn_indexes, DataInfo, Data, Data_BPM, Data_BPM_summary)
narginchk(1,6)
nargoutchk(0,0)

plot_all_index = 'Yes';
max_figure_limit = 5; % ask if more than X figures would be plotted
if length(irregular_file_indexes) > max_figure_limit
    plot_all_index = questdlg(['Are you sure you want to plot all ',...
        num2str(length(irregular_file_indexes)),' figures?'],...
        'Plotting all', 'Yes','No','No');
end
% returning if chosen not to plot all
if strcmp(plot_all_index,'No')
    disp(['Not plotting ', num2str(length(irregular_file_indexes)),...
        ' figures, returning'])
    return
end

%% plotting
if ~exist('DataInfo','var') || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo.')
    end
end
irreg_beat_limit = DataInfo.irregular_beating_limit;
if ~exist('Data','var') || isempty(Data)
    try
        Data = evalin('base', 'Data');
    catch
        error('No proper Data.')
    end
end
if ~exist('Data_BPM','var') || isempty(Data_BPM)
    try
        Data_BPM = evalin('base', 'Data_BPM');
    catch
        error('No proper Data_BPM')
    end
end
if ~exist('Data_BPM_summary','var') || isempty(Data_BPM_summary)
    try
        Data_BPM_summary = evalin('base', 'Data_BPM_summary');
    catch
        error('No proper Data_BPM_summary')
    end
end


col = 1:length(DataInfo.datacol_numbers);
for kk = 1:length(irregular_file_indexes)
    ind_file = irregular_file_indexes(kk);
    fig_full
    subplot(311)
    plotDatainfig(Data,Data_BPM, ind_file,col,1)
    experiment_title_text = create_experiment_info_text(ind_file, DataInfo);
    sgtitle(experiment_title_text,'interpreter','none','fontsize',12, 'fontweight', 'bold')
    subplot(312)
    try
        for pp = 1:length(irregular_datacolumn_indexes{kk})
            temp_pd = Data_BPM_summary.peak_distances{ind_file,...
                irregular_datacolumn_indexes{kk}(pp)};
            temp_pd_avg = mean(temp_pd);
            temp_pd_high_level = temp_pd_avg*(1+irreg_beat_limit);
            temp_pd_low_level = temp_pd_avg*(1-irreg_beat_limit);
            plot(temp_pd)
            title_text = ['Average peak distance: ', num2str(round(temp_pd_avg,0)),' ms'];
            title_text = [title_text, 10, 'Irregularity level: ',...
                num2str(irreg_beat_limit*100),'% => ',num2str(round(temp_pd_avg ...
                * (1-irreg_beat_limit),0)),'...', num2str(round(temp_pd_avg ...
                * (1+irreg_beat_limit),0)),' ms'];% 1+irreg_beat_limit]];
            title(title_text)
            ylabel('Peak distance (from start peak to next) (ms)')
            xlabel('Peak index (= start peak)')
            hold all
            line([1,length(temp_pd)],[temp_pd_avg temp_pd_avg],...
                'LineStyle',':','color', 'k')
            line([1,length(temp_pd)],[temp_pd_low_level temp_pd_low_level],...
                'LineStyle','--','color', [0.4 0.4 0.4])
            line([1,length(temp_pd)],[temp_pd_high_level temp_pd_high_level],...
                'LineStyle','--','color', [0.4 0.4 0.4])
            axis tight
        end
    catch
        
    end
    subplot(313)
    histogram(Data_BPM_summary.peak_distances{ind_file,...
        irregular_datacolumn_indexes{kk}(pp)})
    ylabel('Count')
    xlabel('Peak distance (ms)')
    axis tight
end