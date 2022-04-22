function [Data, DataInfo] = load_raw_mea_data_to_Data_and_DataInfo(...
    exp_name, meas_name, meas_date, file_type, mea_layout_name, clear_workspace, manually_chosen_mea_electrodes)
% function [Data, DataInfo] = load_raw_mea_data_to_Data_and_DataInfo(exp_name, meas_name, meas_date, file_type, mea_layout_name, clear_workspace, manually_chosen_mea_electrodes)
narginchk(0,7)
nargoutchk(0,2)

if nargin < 1 || isempty(exp_name)
    exp_name = 'Exp_11311_EURCCS_p32_180820';
end
if nargin < 2 || isempty(meas_name)
    meas_name = 'mea21001a';
end
if nargin < 3 || isempty(meas_date)
    meas_date = '2020_09_15';    
end
if nargin < 4 || isempty(file_type)
    file_type = '.h5';
end
if nargin < 5 || isempty(mea_layout_name)
    mea_layout_name = 'MEA_64_electrode_layout.txt';
end
if nargin < 6 || isempty(clear_workspace) || ~strcmp(clear_workspace,'No')
    choice_clearall = questdlg('Clear all variables?','Clear all', 'Yes','No','Yes');
else
    choice_clearall = 'No';
end
if strcmp(choice_clearall,'Yes')
    evalin('base', 'clear all')
end

if nargin < 7 || isempty(manually_chosen_mea_electrodes)
    manually_chosen_mea_electrodes = [];
end


%%
% Initial values
set_initial_names; 
% Get data read and list files in folder
create_DataInfo_start
if strcmp(DataInfo.file_type,'.h5')
    create_Data_from_h5files % Reading raw MEA data (.h5 files)
end
% Update DataInfo
update_DataInfo_datacol_and_time_names
DataInfo = set_signal_type(DataInfo);

%% Checking data
choice_plotting = questdlg('Want to plot every 10th data?',...
    'Plotting', 'Yes','No','Yes');
if strcmp(choice_plotting,'Yes')
    plot_chosen_data_files(Data,DataInfo) % all data, every 10th default
end

% Analysis_environment % --> APP sopivat plottaukset
%% Save raw data (Data) and current info (DataInfo)
choice_saving = questdlg('Want to save Data and DataInfo to single .mat files?',...
    'Saving', 'Yes','No','Yes');
if strcmp(choice_saving,'Yes')
    try 
        save_Data_and_DataInfo(Data, DataInfo) % martalle
    catch
        save_data_files
    end
end
clear choice_saving