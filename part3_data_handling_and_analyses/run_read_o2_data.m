Data_o2 = read_o2_data_to_DataInfo();
% function DataO2 = read_o2_data_to_DataInfo(min_time_deleted_from_begin, exp_name, meas_name)
% määritellään Data_o2.measurement_time:n duration ja .meas_time_sec
% suhteessa DataInfo.measurement_time.datetime(1) indeksiin    
datetime_diff = Data_o2.measurement_time.datetime(1)-DataInfo.measurement_time.datetime(1);
Data_o2.measurement_time.duration = Data_o2.measurement_time.duration+datetime_diff;
sec_diff = datenum(datetime_diff)* 24*60*60;
Data_o2.measurement_time.time_sec = Data_o2.measurement_time.time_sec+sec_diff;

%%% find O2 times that are 
filenumber = 1:DataInfo.files_amount; %length(Data_BPM);
for pp = 1:length(filenumber)
    te =  filenumber(pp);
    nametemp1=DataInfo.hypoxia.names{te,1};
    date_mea = DataInfo.measurement_time.datetime(te);
	Data_o2.measurement_time.datafile_index(pp,1) = find(Data_o2.measurement_time.datetime >= date_mea,1);
end


remove_other_variables_than_needed