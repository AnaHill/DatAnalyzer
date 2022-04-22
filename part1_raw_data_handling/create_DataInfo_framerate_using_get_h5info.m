% tstart = tic;
for file_index = 1:DataInfo.files_amount
    % tic
    h5file_info = get_h5info([], file_index); 
    DataInfo.framerate(file_index,1) = h5file_info.framerate;
    % toc
end
% toc(tstart) 