try
    if all(DataInfo.framerate == DataInfo.framerate(1))
        fs = DataInfo.framerate(1);
        disp(['Every data has same fs = ',num2str(fs), ' Hz'])
    end
catch
    try
        fs = evalin('base','h5file_info.framerate');
        disp(['fs from h5file_info.framerate, fs = ',num2str(fs), ' Hz'])
    catch
        file_ind_to_get_fs = 1;
        h5file_info = get_h5info(DataInfo,file_ind_to_get_fs);
        fs = h5file_info.framerate;
        disp(['fs from first file, fs = ',num2str(fs), ' Hz'])
        clear file_ind_to_get_fs
    end
end