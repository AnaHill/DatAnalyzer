%% Template for data analysis: MEA data
% Saving data Examples
% save_data_files(savefolder) % not saving DataPeaks_mean, DataPeaks nor Data
% save_data_files(savefolder,1) % saves DataPeaks_mean
% save_data_files(savefolder,1,1) % saves also DataPeaks
% save_data_files(savefolder,1,1,1) % saves also Data
% save_data_files(savefolder,[],[],1) % saves only Data without DataPeaks and DataPeaks_mean
% Main parts
    % 1. Get data
    % 2. Find peaks
    % 3. Analyze peaks
    % 4. Summarize and analyze
clear, close all,  clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Get data: Option 1 manually chosen electrodes
manually_chosen_mea_electrodes = [71, 84];
[Data, DataInfo] = load_raw_mea_data_to_Data_and_DataInfo([], [], [], [], [], 1, manually_chosen_mea_electrodes);
% [Data, DataInfo] = load_raw_mea_data_to_Data_and_DataInfo(...
% exp_name, meas_name, meas_date, file_type, mea_layout_name, clear_workspace, manually_chosen_mea_electrodes)
[DataInfo.Rule] = set_default_filetype_rules_for_peak_finding;
save_data_files([],[],[],1) % remove_other_variables_than_needed
%% 1. Get data: Option 2 
filetype = '.h5';
% mea_layout_name = 'MEA_64_electrode_layout.txt'; % default

% manually_chosen_mea_electrodes = [13, 16, 24, 33, 68]; 
exp_name = 'MEA2020_03_02';
meas_name = 'MEA21001b'; 
meas_date = '2020_03_02';
set_initial_names; % exp_name, meas_name, meas_date, filetype, mea_layout_name

% read and list files in folder: list_files(file_type, folder_to_start)
[folder_of_files, filename_list] = list_files(filetype); 
% choose files for next phase
[file_numbers_to_analyze] = choose_files(filename_list);

% set experimental and measurement names and date
info_temp = {exp_name; meas_name; meas_date};
% below will create info.experiment_name, measurement_name, measurement_date
DataInfo = set_experimental_names(folder_of_files,info_temp);
DataInfo.folder_raw_files = folder_of_files;
DataInfo.files_amount = length(file_numbers_to_analyze); % TODO: tarkista
DataInfo.file_names = filename_list(file_numbers_to_analyze);
clear exp_name meas_name meas_date info_temp folder_of_files file_numbers_to_analyze
clear filename_list filetype 
 % if MEA .h5 data
 if strcmp(DataInfo.file_names{1}(end-2:end),'.h5')
    % open('read_mea_data_MAIN')
   read_mea_data_MAIN
end
save_data_files([],[],[],1)
% remove_other_variables_than_needed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2) Findpeaks from raw data: Data and DataInfo are needed, use APP
run('C:\Local\maki9\Data\MATLAB\data_analyysi\data_analysis_files\APP\Analysis_environment.mlapp')
%% UPDATE Data_BPM after peaks are correct --> calculate peak distance, BPM etc
try
    Data_BPM = update_Data_BPM;
catch
    Data_BPM = update_Data_BPM(DataInfo, Data_BPM, 0); % jos vain alapiikit
end

%% Set hypoxia (if exist)
% set d1 just before hypoxia starts
% d2 value just larger than time when hypoxia ends
if strcmp(DataInfo.experiment_name,'Acute_hypoxia_HEB04602wt_p42_090321_MACS290321') ...
        || strcmp(DataInfo.experiment_name,'Acute_hypoxia_HEB04602WT_p42_090321_MACS_290321') 
    d1 = '2021-04-06 7:32'; d2 = '2021-04-06 10:29'; 
    meas_hypox_start = datetime(d1,'InputFormat','yyyy-MM-dd HH:mm');
    meas_hypox_end =  datetime(d2,'InputFormat','yyyy-MM-dd HH:mm');
elseif strcmp(DataInfo.experiment_name,'Acute_hypoxia_HEB04602WT_p37_070621_MACS_280621')
    d1 = '06-Jul-2021 06:29'; d2 = '06-Jul-2021 09:30'; % treox=0h at 9:29 
    meas_hypox_start = datetime(d1,'InputFormat','dd-MM-yyyy HH:mm');
    meas_hypox_end =  datetime(d2,'InputFormat','dd-MM-yyyy HH:mm');
else
    error('No hypoxia time found!')
end
hps=find(DataInfo.measurement_time.datetime > meas_hypox_start,1);
hpe=find(DataInfo.measurement_time.datetime < meas_hypox_end,1,'last');
DataInfo = run_hypoxia_info_to_DataInfo(DataInfo, hps, hpe);
try
    Data_BPM = update_Data_BPM;
catch
    Data_BPM = update_Data_BPM(DataInfo, Data_BPM, 0); % jos vain alapiikit
end
% update datainfo
DataInfo = update_DataInfo(DataInfo);
% check edges
[DataInfo, Data_BPM] = run_check_edges(Data, DataInfo, Data_BPM);
% update datainfo
DataInfo = update_DataInfo(DataInfo);
%% set proper MEA signal type
signal_type = 'low_mea';
[DataInfo] = set_signal_type(DataInfo,[],[],signal_type);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3) Create Data_BPM_summary 
Data_BPM_summary = create_BPM_summary;
%% Check irregularity
DataInfo.irregular_beating_limit = 0.2;
if  ~isfield(DataInfo, 'irregular_beating_limit')
    DataInfo.irregular_beating_limit = 0.1; % default: .1 = 10%
end
Data_BPM_summary.irregular_beating_table = index_irregular_beating...
    (DataInfo, Data_BPM_summary, DataInfo.irregular_beating_limit);
sort(unique(Data_BPM_summary.irregular_beating_table.File_index ))
check_and_plot_irregular_data
%% plot same data
time=DataInfo.measurement_time.datetime;
data = Data_BPM_summary.Amplitude_avg;
data = Data_BPM_summary.BPM_avg;
hs=DataInfo.hypoxia.start_time_index; 
he=DataInfo.hypoxia.end_time_index;
fig_full, plot(time, data)
hold all, plot([time(hs) time(hs)],[min(data(:)) max(data(:))] ,'--','color',[.4 .4 .4])
plot([time(he) time(he)],[min(data(:)) max(data(:))] ,'--','color',[.4 .4 .4])
title([DataInfo.experiment_name,' - ',DataInfo.measurement_name],'interpreter','none')
%% 4) ANALYZING MEAN SIGNALS from peaks
open('C:\Local\maki9\Data\MATLAB\data_analyysi\data_analysis_files\Analyze_BPM_fp_values.m')