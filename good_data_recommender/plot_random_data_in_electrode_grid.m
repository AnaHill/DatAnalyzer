file_index = randi(DataInfo.files_amount,1); 
disp(['file_index: ',num2str(file_index)])
[data h5info] = read_h5_to_data(DataInfo, file_index);
[hatgrid,postgrid] = plot_data_to_subplots_with_layout(data,...
    DataInfo.MEA_electrode_numbers, h5info.framerate, [],[], 1);
filename_text = ['File #',num2str(file_index),'/',num2str(DataInfo.files_amount),...
    ': ', DataInfo.file_names{file_index}(1:end-3)];
sgtitle_text = [DataInfo.experiment_name,' - ', DataInfo.measurement_name,10,filename_text];
sgtitle(sgtitle_text,'interpreter','none')