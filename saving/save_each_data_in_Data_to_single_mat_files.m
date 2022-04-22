function [] = save_each_data_in_Data_to_single_mat_files(Data, DataInfo)
% Want to save each data in Data to .mat files 
narginchk(2,2)
nargoutchk(0,0)
choice_saving = questdlg('Want to save each data to single .mat files?',...
    'Saving single .mat files', 'Yes','No','No');


switch choice_saving
    case 'No'
        disp('No saving')
    case 'Yes'
        saving_folder = choose_saving_folder();
        saving_name = ['DataInfo_',DataInfo.experiment_name,'_',DataInfo.measurement_name];
        saving_name = matlab.lang.makeValidName(saving_name,'Prefix','Data_');
        % saving DataInfo
        DataInfo.folder_mat_files = saving_folder;

        % saving Data
        disp('Saving each data file')
        for kk = 1:length(Data)
            try % old where filename included in Data
                saving_name = matlab.lang.makeValidName...
                    (DataInfo.file_names{kk,1},'Prefix','data_');
            catch % where filename only in DataInfo
                saving_name = matlab.lang.makeValidName...
                    (DataInfo.file_names{kk,1},'Prefix','data_');
            end
            data = Data{kk,1};
            sdata = {'data'};
            save([saving_folder,saving_name],sdata{:})
            disp(['File ',num2str(kk),'/',num2str(length(Data)),': ',...
                saving_name , ' saved'])
        end 
        disp([num2str(length(Data)),' file(s) saved to: ',10, saving_folder])
        
        sdata={'DataInfo'};
        save([saving_folder,saving_name],sdata{:})
        disp([saving_name, ' saved'])
end

