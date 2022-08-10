function [irregular_file_indexes, irregular_datacolumn_indexes] = ...
    check_irregular_data(Data_BPM_summary)
% check irregular_data: Data_BPM_summary required
% need to include .irregular_beating_table 
try
    irregular_file_indexes = unique(...
        Data_BPM_summary.irregular_beating_table.File_index);
    irregular_datacolumn_indexes  = [];
    for pp = 1:length(irregular_file_indexes)
        col_ind = ...
            find(Data_BPM_summary.irregular_beating_table.File_index ...
            == irregular_file_indexes(pp));
        irregular_datacolumn_indexes{end+1,1} = sort(unique(Data_BPM_summary. ...
            irregular_beating_table.DataColumn_index(col_ind)));
    end
catch
    warning('No Data_BPM_summary.irregular_beating_table found!')
    irregular_file_indexes = [];
    irregular_datacolumn_indexes  = [];
end