% remove_offset_from_single_data_and_update_Data
% called from remove_offset.m

% offset = median --> better than mean? update 2021/09
offset_dat = median(dat(bs:be,1));
% remove offset
dat_offset_removed = dat-offset_dat;
% update data
data{file_index,1}.data(:,col) = dat_offset_removed;
data{file_index,1}.removed_offset(col,1) = offset_dat;
str_offset = sprintf('%0.3g',offset_dat);
disp(['Removed offset from File#',num2str(file_index),' - datacol#',...
        num2str(col),': ',str_offset])


