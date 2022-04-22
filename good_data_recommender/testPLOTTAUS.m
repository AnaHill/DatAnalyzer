% Eri plottauksia
[hat2,post2] = plot_data_to_subplots(data,parhaat(1:montako,1), fs, 1);

%% manuaalinen valinta raakdatoina
% tic
valitut=4:2:10 % 3% 1:3
for pp=valitut
    clear data
    file_index = pp;
    % file_index = randi(DataInfo.files_amount,1);
    disp(['file_index: ',num2str(file_index)])
    [data h5info] = read_h5_to_data(DataInfo, file_index);
    % [hat,post] = plot_data_to_subplots(data,[], fs, 1);
    [hatgrid,postgrid] = plot_data_to_subplots_with_layout...
        (data,DataInfo.MEA_electrode_numbers, fs, [],[], 1);
    filename_text = ['File #',num2str(file_index),'/',...
        num2str(DataInfo.files_amount),...
        ': ', DataInfo.file_names{file_index}(1:end-3)];
    sgtitle_text = [DataInfo.experiment_name,' - ', ...
        DataInfo.measurement_name,10,filename_text];
    sgtitle(sgtitle_text,'interpreter','none')
end
% toc


%% noin 10 välein mittaukset
for pp=unique([1:10:DataInfo.files_amount DataInfo.files_amount])
    clear data
    file_index = pp;
    % file_index = randi(DataInfo.files_amount,1);
    disp(['file_index: ',num2str(file_index)])
    [data h5info] = read_h5_to_data(DataInfo, file_index);
    % [hat,post] = plot_data_to_subplots(data,[], fs, 1);
    [hatgrid,postgrid] = plot_data_to_subplots_with_layout(data,DataInfo.MEA_electrode_numbers, fs, [],[], 1);
    filename_text = ['File #',num2str(file_index),'/',num2str(DataInfo.files_amount),...
        ': ', DataInfo.file_names{file_index}(1:end-3)];
    sgtitle_text = [DataInfo.experiment_name,' - ', DataInfo.measurement_name,10,filename_text];
    sgtitle(sgtitle_text,'interpreter','none')
end

%% PLOTTAILUT, katso
% open('C:\Local\maki9\Data\MATLAB\data_analyysi\data_analysis_files\KEHITYS\HyvanDatanSuosittelija\TESTAILU_lopullisetElektrodiEhdotukset.m')
%%% read_h5_to_data testailu
file_index = randi(DataInfo.files_amount,1)
% how_many_datacolumns = randi(length(DataInfo.datacol_numbers),1)
% how_many_datarows = 25e3*randi(60,1);
file_index = 24
how_many_datacolumns  = 60
how_many_datarows = 25e3*15;
[data, h5info,framerate] = read_h5_to_data(DataInfo, file_index, ... 
    how_many_datarows, how_many_datacolumns);
%%%%%%%%%%%%%%%
file_index = randi(DataInfo.files_amount,1)
how_many_datacolumns  = 60;
how_many_datarows = 25e3*4;

[data] = read_h5_to_data(DataInfo, file_index, how_many_datarows);

%%%%%%%%%
[hatgrid,postgrid] = plot_data_to_subplots_with_layout(data,DataInfo.MEA_electrode_numbers, fs, [],[], 1);
[hat,post] = plot_data_to_subplots(data,[] ,fs); 
