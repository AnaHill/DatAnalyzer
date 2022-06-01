%% Create DataPeaks & DataPeaks_mean, Analyze DataPeaks_mean tp get 
% creates new DataPeaks based on trimmed Data_BPM location
trim_found_peak_value_and_location % TODO: ottaa nyt alapiikeista vain
%% Check proper time window (backward and forward time from peak)
% create_DataPeaks_and_mean % using [t_back t_forw] sis‰lt‰‰
t_back = -.15; t_forw = 1;  

switch DataInfo.measurement_name
    case 'demo3_3'
        t_back = -.1; t_forw = .95; 
    case 'demo3_13'
        t_back = -.1; t_forw = 1.2; 
        
end
if strcmp(DataInfo.experiment_name,'Acute_hypoxia_HEB04602wt_p42_090321_MACS290321')
    if strcmp(DataInfo.measurement_name, 'MEA21001b') || ...
            strcmp(DataInfo.measurement_name, 'MEA21002a') % || ...
%             strcmp(DataInfo.measurement_name, 'MEA21002b')
        t_back = -0.25; % t_back - 0.1 % -.05; % t_forw = 1;  
        t_forw = 1.05;  
    end
elseif strcmp(DataInfo.experiment_name,'Acute_hypoxia_HEB04602WT_p42_090321_MACS_290321')
    if strcmp(DataInfo.measurement_name, 'MEA21002b')
         t_back = -0.25;
         t_forw = 0.95;
    end
elseif strcmp(DataInfo.experiment_name,'Acute_hypoxia_MEA2A_12619LMNA_29112021_p41_25102021_baseline') || ...
    strcmp(DataInfo.experiment_name,'Acute_hypoxia_MEA2A_12619LMNA_29112021_p41_25102021_hypoxia') || ...
    strcmp(DataInfo.experiment_name,'Acute_hypoxia_MEA2A_12619LMNA_29112021_p41_25102021_reoxygenation')
    t_back = -0.05;
    t_forw = 0.6+t_back;
% elseif strcmp(DataInfo.experiment_name,'Acute_hypoxia_MEA2A_12619LMNA_29112021_p41_25102021_hypoxia')
%     t_back = -0.05;
%     t_forw = 0.6+t_back;
end
check_peak_forms([t_back t_forw], [],[],1); % % mean plot included
% check_peak_forms([t_back t_forw],20,[],1); % % mean plot included
%% Luodaan DataPeaks ja sitten DataPeaks_mean
% t_back = -.05; t_forw = 0.6;  
% DataPeaks = get_peak_signals([],[],[],[t_back t_forw]);
DataPeaks = get_peak_signals([t_back t_forw]);
DataPeaks_mean = get_peak_signal_average(DataPeaks);
remove_offset_from_DataPeaks
remove_other_variables_than_needed,
save_data_files(DataInfo.savefolder,1,1);
%% Create DataPeaks_summary: find peaks from DataPeaks_mean data and calculate fpd
% old open('C:\Local\maki9\Data\MATLAB\data_analyysi\data_analysis_files\TEST_define_fpd.m')
% 1) Find low peak
    gain_for_time_range = 1.5; % set time range from the first p
fpd_find_low_peak; % find low peaks
% 2) find fpd start 
    fpd_threshold_percent = 0.1; % threshold from baseline where FPD starts
    low_freq = 1500;% low pass filter start freq [Hz], org 150 Hz
fpd_fpstart_and_depolarization_time;
% 3) find signal end and flat peak
    low_freq = 2500; % 150, 25, 2500 low pass filter start freq [Hz]
    fpd_threshold_percent = 0.1; % threshold from baseline where FPD ends
    plotting_results = 0; % plot or not results
fpd_find_flatpeak_and_signal_end

%% 
save_data_files(DataInfo.savefolder);
save_data_files(DataInfo.savefolder,1,1); % DataPeaks_mean and DataPeaks
% remove_other_variables_than_needed
%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot certain DataPeaks_summary data toge
open('.\plotting\Plotting_Certain_DataPeaks_mean_and_summary_data')
% PLOT avg value etc
open('.\plotting\Keskiarvojenpiirtelya.m')
%% Summarize (plots)
open('.\plotting\Summarize_plot_DataPeaks_summary.m')
% open('.\plotting\Plot_multiple_DataPeaks_summary_plots.m')
