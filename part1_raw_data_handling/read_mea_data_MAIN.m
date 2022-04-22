%% Reading raw MEA data (.h5 files)
% Reading MEA layout 
[DataInfo.electrode_layout] = read_MEA_electrode_layout();
% function [electrode_layout] = read_MEA_electrode_layout(mea_layout_name)
clear mea_layout_name
% finding index for the previously chosen electrodes 
DataInfo.MEA_electrode_numbers = read_wanted_electrodes_of_measurement...
    (DataInfo.experiment_name, DataInfo.measurement_name,...
    DataInfo.electrode_layout);

% finding MEA columns of the wanted electrodes
DataInfo.MEA_columns = find_MEA_electrode_index...
    (DataInfo.MEA_electrode_numbers, DataInfo.electrode_layout);

% read raw MEA .h5 data -> Output Data and DataInfo
% datetime from file name, default: 'yyyy-MM-dd''T''HH-mm-ss'
% check info 
get_Data_and_DataInfo_from_MEA_in_loop

% ask and save chosen data to single .mat files
save_each_data_in_Data_to_single_mat_files(Data,DataInfo)
