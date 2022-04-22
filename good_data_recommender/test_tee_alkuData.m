%% Testing Propose good data (e.g. electrodes where berating)
clear all, tmp = matlab.desktop.editor.getActive; 
cd(fileparts(tmp.Filename)); clear tmp
fold = 'C:\Local\maki9\Data\MATLAB\data_analyysi\data_analysis_files\';
%% Get DataInfo from previously done 
% MIKA_DATA = 'testi1'; lataa_data_alkutiedot
% clearvars -except IndeksiTAULUKKO fs DataInfo
%% Create DataInfo using get_h5info.m
% data_folder = 'C:\Local\maki9\Programs\OneDrive - TUNI.fi\Akuuttihypoksia\Antille H5-tiedostoja\';
% exp_name = 'Acute_12619LMNA'; meas_name = 'MEA2A'; meas_date = '2021_12_26';
data_folder = 'C:\Local\maki9\Programs\OneDrive - TUNI.fi\Akuuttihypoksia\H5-Tiedostoja\';
exp_name = 'Acute_A4LMNA_HEB'; meas_name = 'MEA1B'; meas_date = '2022_01_07';
filetype = '.h5'; set_initial_names; % exp_name, meas_name, meas_date, filetype, mea_layout_name
info_temp = {exp_name; meas_name; meas_date};

% read and list files in folder: list_files(file_type, folder_to_start)
[folder_of_files, filename_list] = list_files('.h5',data_folder); 

% choose files for next phase
% [file_numbers_to_analyze] = choose_files(filename_list);
file_numbers_to_analyze = [1:length(filename_list)]'; % taking all files

DataInfo = set_experimental_names(folder_of_files,info_temp);
DataInfo.file_type = filetype; DataInfo.measurement_type = 'MEA';
DataInfo.folder_raw_files = folder_of_files;
DataInfo.files_amount = length(file_numbers_to_analyze);
DataInfo.file_names = filename_list(file_numbers_to_analyze);
clear exp_name meas_name meas_date info_temp folder_of_files file_numbers_to_analyze
clear filename_list filetype data_folder fold
% Reading MEA layout 
[DataInfo.electrode_layout] = read_MEA_electrode_layout();
clear mea_layout_name
% taking all electrodes
DataInfo.datacol_numbers = [1:height(DataInfo.electrode_layout)]';
DataInfo.MEA_columns = DataInfo.datacol_numbers;
DataInfo.MEA_electrode_numbers = find_MEA_electrode_number_from_datacol_index(DataInfo.datacol_numbers);
clear folderi fs mea_layout_name
%% create DataInfo.framerate
    % i) fs_creation=from each .h5 file separately 
    % ii) assuming same fs in all assuming same fs in all: 
create_fs_to_DataInfo


