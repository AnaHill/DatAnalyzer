function Data = remove_data_from_Data_variable(...
    file_indexes, column_indexes, remove_whole_file, Data)
% function Data = remove_data_from_Data_variable(...
%     file_indexes, column_indexes, Data)
max_inputs = 4;
narginchk(2,max_inputs)
nargoutchk(0,1)

% default: not remove_whole_file
if nargin < max_inputs-1 || isempty(remove_whole_file)
    remove_whole_file = 'no';
end

if nargin < max_inputs || isempty(Data)
    try
        Data = evalin('base', 'Data');
    catch
        error('No proper Data given or found.')
    end
end


% removing data
try
    if strcmp(remove_whole_file,'yes')
        for file_ind = file_indexes
            Data{file_ind} = [];
        end
        % https://se.mathworks.com/matlabcentral/answers/27042-how-to-remove-empty-cell-array-contents
        Data = Data(~cellfun('isempty',Data));
    end
    for f_ind = file_indexesremove_whole_file
    
    end
catch
   error('Check file and column indexes that should be removed.') 
end


% update file index in each Data{}
for ind = 1:length(Data)
   Data{ind,1}.file_index =  ind;
end



end