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
        error('No proper Data given or found from workspace.')
    end
end

file_indexes = sort(unique(file_indexes));
column_indexes = sort(unique(column_indexes));
disp(['Removing following data from Data variable'])
disp(['File indexes: ', num2str(file_indexes)])
disp(['Data column indexes: ', num2str(column_indexes)])

% check file_indexes; should not be below one or larger than amount of cells in Data
if any(file_indexes < 1) || any(file_indexes > length(Data))
    error('Check file indexes!')
end
if any(column_indexes < 1) 
    error('Check column indexes!')
end
% removing data
try
    for file_ind = file_indexes
        if strcmp(remove_whole_file,'yes') || ...
                isequal(column_indexes,1:length(Data{file_ind}.data(1,:)))  
            % if deleting every column, empty whole cell
            Data{file_ind} = [];
        else % remove chose datacolumns
            Data{file_ind}.data(:,column_indexes) = [];
        end
    end
    % remove empty cells in Data
    % https://se.mathworks.com/matlabcentral/answers/27042-how-to-remove-empty-cell-array-contents
    Data = Data(~cellfun('isempty',Data));
catch
   error('Check file and column indexes that should be removed.') 
end


% update file index in each cell in Data
for ind = 1:length(Data)
   Data{ind,1}.file_index =  ind;
end

disp(['Data variable updated'])

end