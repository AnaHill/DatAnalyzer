DataPeaks_mean = remove_offset(DataPeaks_mean);
for file_index = 1:length(DataPeaks_mean)
    for col = 1:length(DataInfo.datacol_numbers)
        offset_ = DataPeaks_mean{file_index, 1}.removed_offset(col,1);
        DataPeaks.data{file_index,col} = DataPeaks.data{file_index,col} - ...
            offset_;
        DataPeaks.removed_offset(file_index,col) =  offset_;
    end
end