%% Saving Large Data omiin .mat tiedostoihin int32 muodosssa
% kansioon 'data02_intermediate\'
% KÄYDÄÄN koko data setin maksimiarvo lävitse!!!
%% proper conversion factor
tic
bitlimit=2^15-1; % for int16 data type
bitlimit=2^31-1; % for int32 data type
DataInfo.conversion_factor_double_to_int = 1e8;
fg = DataInfo.conversion_factor_double_to_int;

filenum = 1;
% % KÄYDÄÄN koko data setin maksimiarvo lävitse!!!
tic
max_converted_data_value = 0;
min_non_zero_converted_value = 100;
for filenum = 1:DataInfo.files_amount
    % max_converted_data_value = max(max(abs(Data{filenum,1}.data(:))))*fg;
    max_converted_data_value = max([max_converted_data_value 
        max(max(abs(Data{filenum,1}.data(:))))*fg;]);
    
    dat_abs = abs(Data{filenum,1}.data(:));
%     min_non_zero_converted_value = min(dat_abs(dat_abs > 0))*fg;
    
    min_non_zero_converted_value = min([min_non_zero_converted_value
        min(dat_abs(dat_abs > 0))*fg]);
end
toc

% toimiiokohan
while min_non_zero_converted_value < 1
    fg = fg*10;
    min_non_zero_converted_value = max(max(abs(Data{filenum,1}.data(:))))*fg;
end

% jos datalle ei sovi kyseinen 
while max_converted_data_value/bitlimit < 0.1
    fg = fg*10; 
%     max_converted_data_value = max(max(abs(Data{filenum,1}.data(:))))*fg;
    max_converted_data_value = max_converted_data_value*10;
end

while max_converted_data_value > bitlimit
    fg = fg*0.1; 
%     max_converted_data_value = max(max(abs(Data{filenum,1}.data(:))))*fg;
    max_converted_data_value = max_converted_data_value*0.1;
end
toc
DataInfo.conversion_factor_double_to_int = fg;
DataInfo.conversion_factor_double_to_int 
%% save
% N = matlab.lang.makeValidName(S)
% DataInfo.conversion_factor_double_to_int = 1e8;
% bitlimit=2^15-1; % for int16 data type
% bitlimit=2^31-1; % for int32 data type
file_num_digits = numel(num2str(DataInfo.files_amount));
savemat_name = ['data%0',num2str(file_num_digits),'d.mat'];
savepath = [DataInfo.savefolder,'data02_intermediate\'];
% % if bitlimit < 32767*2 % int16
% % 	savepath = [DataInfo.savefolder,'matint16\'];
% % end
tic
for fil_index=1:DataInfo.files_amount
    if bitlimit < 32767*2 % int16
        data = int16(Data{fil_index,1}.data*1e8);
    elseif bitlimit > 1e9 % int32
        data = int32(Data{fil_index,1}.data*DataInfo.conversion_factor_double_to_int);
    end
    file_index = fil_index;
    % savname = DataInfo.file_names{fil_index};
    savename = sprintf(savemat_name, file_index);
    save([savepath,savename], 'data','file_index','-v7.3')
    disp(['data#',num2str(fil_index),'/', num2str(DataInfo.files_amount),' saved.'])
end
toc    

Files = dir(fullfile(savepath, '*.mat'));
DataInfo.folder_matfiles=[Files(1).folder,'\'];
for pp = 1:length(Files)
    DataInfo.matfilenames{pp,1} = Files(pp).name;
end
remove_other_variables_than_needed
save_data_files(DataInfo.savefolder)
%% loading data to Data
open('C:\Local\maki9\Data\MATLAB\data_analyysi\data_analysis_files\other_files\load_mat_files_to_Data.m')
% loadpath = [DataInfo.savefolder,'data02_intermediate\'];
% Data{DataInfo.files_amount,1} = [];
% tic
% for file_index=1:DataInfo.files_amount
%     Data{file_index,1} = load([loadpath, DataInfo.matfilenames{file_index,1}]);
%     Data{file_index,1}.data = double(Data{file_index,1}.data)/DataInfo.conversion_factor_double_to_int; 
% end
% toc 


%% POSITA 
% % % % remove_other_variables_than_needed
% % % file_index = 2
% % % tic
% % % Data_{1,1} = load([DataInfo.folder_matfiles DataInfo.matfilenames{file_index,1}])
% % % toc
% % % Data_{1,1}.data = double(Data_{1,1}.data)/DataInfo.conversion_factor_double_to_int;
% % % toc
% % % % fig_full, plot(Data{file_index}.data), hold all,plot(Data_{1}.data,'--'),
% % % % fig_full, plot(Data{file_index}.data-Data_{1}.data)
% % % col = 1
% % % % fig_full, plot(Data{file_index}.data(:,col)-Data_{1}.data(:,col))
% % % fig_full, plot(Data{file_index}.data(:,col),'.'), hold all, plot(Data_{1}.data(:,col))
% % % % xlim([5.04 5.044]*1e5)
% % % ero = Data{file_index}.data(:,col)-Data_{1}.data(:,col);
% % % ero_pros = ero ./ (Data{file_index}.data(:,col)) * 100;
% % % fig_full, 
% % % subplot(211)
% % % plot(ero_pros), title(['INT32: Max/Mean ero %: ',num2str([nanmax(abs(ero_pros)) nanmean(abs(ero_pros))])])
% % % % ero(1) , Data{file_index}.data(1,col)
% % % % ero(1)/Data{file_index}.data(1,col)*100
% % % % xlim([5.04 5.044]*1e5)
% % % Data_int16{1,1} = load('C:\Local\maki9\Data\celldata\acute_hypoxia\Acute_hypoxia_HEB04602wt_p42_090321_MACS290321_MEA21001a\data02_intermediate\matint16\data002.mat');
% % % Data_int16{1,1}.data = double(Data_int16{1,1}.data)/1e8;
% % % 
% % % eroint16 = Data{file_index}.data(:,col)-Data_int16{1}.data(:,col);
% % % ero_prosint16 = eroint16 ./ (Data{file_index}.data(:,col)) * 100;
% % % subplot(212) %fig_full, 
% % % plot(ero_prosint16), title(['INT16: Max/Mean ero %: ',num2str([nanmax(abs(ero_prosint16)) nanmean(abs(ero_prosint16))])])
% % % % fig_full, plot(ero_prosint16), title(['INT16: Max/Mean ero %: ',num2str([max(ero_prosint16) mean(ero_prosint16)])])
% % % 
% % % fig_full, plot(Data{file_index}.data(:,col),'.'), hold all, plot(Data_int16{1}.data(:,col))
% % % % xlim([5.04 5.044]*1e5)
% % % 
% % % %% save double
% % % file_num_digits = numel(num2str(DataInfo.files_amount));
% % % savemat_name = ['data%0',num2str(file_num_digits),'d.mat'];
% % % savepath = [DataInfo.savefolder,'matdoub\'];
% % % tic
% % % for fil_index=1:DataInfo.files_amount
% % %     data = (Data{fil_index,1}.data);
% % %     file_index = fil_index;
% % %     % savname = DataInfo.file_names{fil_index};
% % %     savename = sprintf(savemat_name, file_index);
% % %     save([savepath,savename], 'data','file_index','-v7.3')
% % % end
% % % toc  



