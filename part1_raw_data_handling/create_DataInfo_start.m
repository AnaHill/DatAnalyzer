% list_files(file_type, folder_to_start)
if exist('file_type','var')
    [folder_of_files, filename_list,file_type, measurement_type] = list_files(file_type); 
else
    [folder_of_files, filename_list,file_type, measurement_type] = list_files(); 
end
% choose files for next phase
[file_numbers_to_analyze] = choose_files(filename_list);

% set experimental and measurement names and date
info_temp = {exp_name; meas_name; meas_date};
% below will create info.experiment_name, measurement_name, measurement_date
DataInfo = set_experimental_names(folder_of_files,info_temp);
DataInfo.folder_raw_files = folder_of_files;
% 26.3.2021: adding these two, list_files.m updated
DataInfo.file_type = file_type;
DataInfo.measurement_type = measurement_type;

DataInfo.files_amount = length(file_numbers_to_analyze); % TODO: tarkista
DataInfo.file_names = filename_list(file_numbers_to_analyze);
saving_name = [DataInfo.experiment_name,'_',DataInfo.measurement_name];
DataInfo.saving_name = matlab.lang.makeValidName(saving_name,'Prefix','Data_');
clear exp_name meas_name meas_date info_temp folder_of_files file_numbers_to_analyze
clear  file_type measurement_type saving_name
% clear filename_list