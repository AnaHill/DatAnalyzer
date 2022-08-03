% check_and_plot_irregular_data: Data_BPM_summary required
% need to include .irregular_beating_table 
try
    irregu_file_index = unique(Data_BPM_summary.irregular_beating_table.File_index);
    irregu_col_index  = [];
    for pp = 1:length(irregu_file_index)
        col_ind = ...
            find(Data_BPM_summary.irregular_beating_table.File_index ...
            == irregu_file_index(pp));
        irregu_col_index{end+1,1} = sort(unique(Data_BPM_summary. ...
            irregular_beating_table.DataColumn_index(col_ind)));
    end
catch
    irregu_file_index = [];
    irregu_col_index  = [];
end
%%
filenumber = 1:DataInfo.files_amount; %length(Data_BPM);
col = 1:length(DataInfo.datacol_numbers);
fig_full
subplot(211)
errorbar(ones(1,length(col)) .* [1:DataInfo.files_amount]', Data_BPM_summary.peak_distances_avg(:,col),...
    Data_BPM_summary.peak_distances_std(:,col))
hold all 
for pp = 1:length(irregu_file_index)
    plot(irregu_file_index(pp), Data_BPM_summary.peak_distances_avg...
    (irregu_file_index(pp),irregu_col_index{pp,1}(:)),'r*','Markersize',10), 
end

axis tight
sgtitle([DataInfo.measurement_name,10,...
    'Irregularity check when level is set to: ',...
    num2str(DataInfo.irregular_beating_limit*100),'% of average'],'interpreter', 'none')
ylabel('Average Peak distance (ms)')
xlabel('File index')
try
    yyaxis right
    plot(filenumber,Data_o2.data(Data_o2.measurement_time.datafile_index))
    ylabel(['pO2 (kPa)'])
    axis tight
catch
    disp('no o2 data available to plot')
end
subplot(212)
errorbar(ones(1,length(col)) .* DataInfo.measurement_time.time_sec/3600 , ...
    Data_BPM_summary.peak_distances_avg(:,col),...
    Data_BPM_summary.peak_distances_std(:,col))
hold all 
for pp = 1:length(irregu_file_index)
    plot(DataInfo.measurement_time.time_sec(irregu_file_index(pp))/3600, ...
        Data_BPM_summary.peak_distances_avg...
        (irregu_file_index(pp),irregu_col_index{pp,1}(:)),'r*','Markersize',10)
end
% plot(DataInfo.measurement_time.time_sec(irregu_file_index)/3600, ...
%     Data_BPM_summary.peak_distances_avg...
%     (irregu_file_index,col),'r*','Markersize',10)
ylabel('Peak distance (ms)')
axis tight
% sgtitle(DataInfo.measurement_name,'interpreter', 'none')
ylabel('Average Peak distance (ms)')
xlabel('Experiment time (hour)')
try
    yyaxis right
    plot(DataInfo.measurement_time.time_sec/3600, ...
        Data_o2.data(Data_o2.measurement_time.datafile_index))
    ylabel(['pO2 (kPa)'])
    axis tight
catch
    disp('no o2 data available to plot')
end

%%
if length(irregu_file_index) > 10
   am_irreg_file = length(irregu_file_index);
    answer = questdlg(['Are you sure you want to plot all ',...
        num2str(am_irreg_file),' figs?'],'Plotting all', 'Yes','No','No'); 
    switch answer
        case 'Yes'
            plot_all_index = 1;
        otherwise
            plot_all_index = 0;
    end
else
    plot_all_index = 1;
end

if plot_all_index == 1
    irreg_beat_limit = DataInfo.irregular_beating_limit;
    if ~exist('Data','var')
        try
            Data = evalin('base', 'Data');
        catch
            error('No proper Data')
        end
    end
    if ~exist('Data_BPM','var')
        try
            Data_BPM = evalin('base', 'Data_BPM');
        catch
            error('No proper Data_BPM')
        end
    end    
    for kk = 1:length(irregu_file_index)
        ind_file = irregu_file_index(kk);
        fig_full
        subplot(311)
        plotDatainfig(Data,Data_BPM, ind_file,col,1)
        experiment_title_text = create_experiment_info_text(ind_file, DataInfo);
        sgtitle(experiment_title_text,'interpreter','none','fontsize',12, 'fontweight', 'bold')
        subplot(312)
        % modification 2021/08
        try
            for pp = 1:length(irregu_col_index{kk})
                temp_pd = Data_BPM_summary.peak_distances{ind_file,irregu_col_index{kk}(pp)};
        %         temp_pd = Data_BPM_summary.peak_distances{ind_file,1}(:,col);
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
       	histogram(Data_BPM_summary.peak_distances{ind_file,irregu_col_index{kk}(pp)})
        ylabel('Frequency')
        axis tight
    end
else
    disp('Chosen not to plot all data')

end
%% remove_other_variables_than_needed
 