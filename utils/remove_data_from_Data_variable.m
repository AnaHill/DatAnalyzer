function Data = remove_data_from_Data_variable(...
    file_indexes, column_indexes, remove_whole_file, Data)
% function Data = remove_data_from_Data_variable(...
%     file_indexes, column_indexes, Data)
% removes certain data from Data variable
% Examples:
% remove fully certain files from data
    % file_ind_to_remove = [1,5,10]; 
    % Data = remove_data_from_Data_variable(file_ind_to_remove,1,'yes')
% remove last datacolumn from each Data{}.data variable
    % assumes, that each has same amount of datacolumns!
    % col_ind = length(DataInfo.datacol_numbers);
    % col_ind = length(Data{1}.data(1,:)); % if DataInfo not updated
    % file_ind = 1:DataInfo.files_amount;
    % file_ind = 1:length(Data); % if DataInfo not updated
    % Data = remove_data_from_Data_variable(file_ind,col_ind);

% check function call
max_inputs = 4;
narginchk(2,max_inputs)
nargoutchk(1,1)

% default: not remove_whole_file
if nargin < max_inputs-1 || isempty(remove_whole_file)
    remove_whole_file = 'no';
end
% get data from workspace if not given
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
    % remove empty cells in Data, see
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