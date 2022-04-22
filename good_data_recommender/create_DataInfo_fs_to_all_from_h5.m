tic
for file_index = 1:DataInfo.files_amount
%     file_index = 1; 
    h5file_info = get_h5info([], file_index);  
    DataInfo.framerate(file_index,1)=h5file_info.framerate;
    clear h5file_info.framerate
    disp(['file_index: ',num2str(file_index)])
end
toc