% Reading MEA layout 
if exist('mea_layout_name','var')
    [DataInfo.electrode_layout] = read_MEA_electrode_layout(mea_layout_name); 
else % assuming default
    [DataInfo.electrode_layout] = read_MEA_electrode_layout();
end
clear mea_layout_name
% function [electrode_layout] = read_MEA_electrode_layout(mea_layout_name)
% default: mea_layout_name = 'MEA_64_electrode_layout.txt'; 

% MANUAL CHOOSING SOME
if exist('manually_chosen_mea_electrodes','var')
    if ~isempty(manually_chosen_mea_electrodes)
        disp('Overwriting: choosing following electrodes')
        DataInfo.MEA_electrode_numbers = manually_chosen_mea_electrodes;
    end
	clear manually_chosen_mea_electrodes
end

if ~isfield(DataInfo,'MEA_electrode_numbers')
    % finding index for the previously chosen electrodes
    DataInfo.MEA_electrode_numbers = read_wanted_electrodes_of_measurement...
        (DataInfo.experiment_name, DataInfo.measurement_name,...
        DataInfo.electrode_layout);
end

% finding MEA columns of the wanted electrodes
DataInfo.MEA_columns = find_MEA_electrode_index...
    (DataInfo.MEA_electrode_numbers, DataInfo.electrode_layout);

% DataInfo.datacol_numbers = DataInfo.MEA_columns; % yleinen, muissakin kuin MEA

% read raw MEA .h5 data -> Output Data and DataInfo
% datetime from file name, default: 'yyyy-MM-dd''T''HH-mm-ss'
% check convert_end_string_in_filename_to_datetime
get_Data_and_DataInfo_from_MEA_in_loop
% ask and save chosen data to single .mat files
save_each_data_in_Data_to_single_mat_files(Data,DataInfo)
