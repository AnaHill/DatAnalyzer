function plot_summary_of_irregular_data(irregu_file_index,irregu_col_index,...
    DataInfo, Data_BPM_summary, Data_o2)
% function plot_summary_of_irregular_data(irregu_file_index,irregu_col_index,...
%     DataInfo, Data_BPM_summary, Data_o2)
narginchk(0,5)

if nargin < 3 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end
if nargin < 4 || isempty(Data_BPM_summary)
    try
        Data_BPM_summary = evalin('base','Data_BPM_summary');
    catch
        error('No proper Data_BPM_summary')
    end
end

filenumber = 1:DataInfo.files_amount; %length(Data_BPM);
col = 1:length(DataInfo.datacol_numbers);
fig_full
subplot(211)
errorbar(ones(1,length(col)) .* [1:DataInfo.files_amount]', Data_BPM_summary.peak_distances_avg(:,col),...
    Data_BPM_summary.peak_distances_std(:,col))
hold all 
if exist('irregu_file_index','var')
    for pp = 1:length(irregu_file_index)
        plot(irregu_file_index(pp), Data_BPM_summary.peak_distances_avg...
        (irregu_file_index(pp),irregu_col_index{pp,1}(:)),'r*','Markersize',10), 
    end
end
axis tight
sgtitle([DataInfo.experiment_name,': ',DataInfo.measurement_name,10,...
    'Irregularity check when level is set to: ',...
    num2str(DataInfo.irregular_beating_limit*100),'% of average'],'interpreter', 'none')
ylabel('Average Peak distance (ms)')
xlabel('File index')
try
    Data_o2.data(Data_o2.measurement_time.datafile_index);
    yyaxis right
    plot(filenumber,Data_o2.data(Data_o2.measurement_time.datafile_index))
    ylabel('pO2 (kPa)')
    axis tight
catch
    disp('no o2 data available to plot')
end
subplot(212)
errorbar(ones(1,length(col)) .* DataInfo.measurement_time.time_sec/3600 , ...
    Data_BPM_summary.peak_distances_avg(:,col),...
    Data_BPM_summary.peak_distances_std(:,col))
hold all 
if exist('irregu_file_index','var')
    for pp = 1:length(irregu_file_index)
        plot(DataInfo.measurement_time.time_sec(irregu_file_index(pp))/3600, ...
            Data_BPM_summary.peak_distances_avg...
            (irregu_file_index(pp),irregu_col_index{pp,1}(:)),'r*','Markersize',10)
    end
end
axis tight
ylabel('Average Peak distance (ms)')
xlabel('Experiment time (hour)')
try
    Data_o2.data(Data_o2.measurement_time.datafile_index);
    yyaxis right
    plot(DataInfo.measurement_time.time_sec/3600, ...
        Data_o2.data(Data_o2.measurement_time.datafile_index))
    ylabel('pO2 (kPa)')
    axis tight
catch
    disp('no o2 data available to plot')
end