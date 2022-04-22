% if date in other format, assing here
% convert_end_string_in_filename_to_datetime...
  % (filename, str_to_find, before_str_date_format, after_str_date_format)
Data = []; 
% DataInfo = info_dataset;
clear info_dataset % remove
tic_whole_read_mea_files = tic;
for index = 1:DataInfo.files_amount
    % index = 1;
    tic_mea_read_this_round = tic;
    % datetime from current filename 
    datetime  = convert_end_string_in_filename_to_datetime(DataInfo.file_names{index});
    rawmeadata = read_raw_mea_file(DataInfo, index); % read full single .h5 file 
    chosen_mea_data = read_chosen_mea_electrode_data(DataInfo, rawmeadata);
    % updates values to Data and DataInfo
    create_Data_and_DataInfo_from_mea_data
    clear datetime rawmeadata chosen_mea_data meas_duration meas_time
end
clear tic_mea_read_this_round tic_whole_read_mea_files index
