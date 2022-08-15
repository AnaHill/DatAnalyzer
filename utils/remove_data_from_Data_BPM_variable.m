function Data_BPM = remove_data_from_Data_BPM_variable(...
    file_indexes, column_indexes, remove_whole_file, Data_BPM)
% function Data_BPM = remove_data_from_Data_BPM_variable(...
%     file_indexes, column_indexes, remove_whole_file, Data_BPM)
% removes certain info from Data_BPM variable
% Examples:
% remove fully certain files from data
    % file_ind_to_remove = [1,5,10]; 
    % Data_BPM = remove_data_from_Data_BPM_variable(file_ind_to_remove,1,'yes')
% remove last datacolumn from each Data{}.data variable
    % assumes, that each has same amount of datacolumns!
    % col_ind = length(Data_BPM.datacol_numbers);
    % col_ind = length(Data{1}.data(1,:)); % if Data_BPM not updated
    % file_ind = 1:Data_BPM.files_amount;
    % file_ind = 1:length(Data); % if Data_BPM not updated
    % Data_BPM = remove_data_from_Data_BPM_variable(file_ind,col_ind);

% Testing: 
% remove files
% Data_BPM = Data_BPM2;Data_BPM = remove_data_from_Data_BPM_variable([1,3,47],1,'yes')
% remove columns
% Data_BPM = Data_BPM2;Data_BPM = remove_data_from_Data_BPM_variable([1:47],[11])


% check function call
max_inputs = 4;
narginchk(2,max_inputs)
nargoutchk(1,1)

% default: not remove_whole_file
if nargin < max_inputs - 1 || isempty(remove_whole_file)
    remove_whole_file = 'no';
end
% % % get DataInfo from workspace if not given
% % if nargin < max_inputs - 1 || isempty(DataInfo)
% %     try
% %         DataInfo = evalin('base', 'DataInfo');
% %     catch
% %         error('No proper DataInfo given or found from workspace.')
% %     end
% % end
% get Data_BPM from workspace if not given
if nargin < max_inputs || isempty(Data_BPM)
    try
        Data_BPM = evalin('base', 'Data_BPM');
    catch
        error('No proper Data_BPM given or found from workspace.')
    end
end

file_indexes = sort(unique(file_indexes));
column_indexes = sort(unique(column_indexes));
if strcmp(remove_whole_file,'yes') || ...
        isequal(column_indexes,1:length(Data_BPM{1, 1}.Amount_of_peaks))
    disp(['Fully remove data from these file indexes: ', num2str(file_indexes)])
    % disp('Set column indexes to every column')
    column_indexes = 1:length(Data_BPM{1, 1}.Amount_of_peaks);
    remove_whole_file = 'yes';
else
    disp(['Removing following data from Data_BPM variable'])
    disp(['File indexes: ', num2str(file_indexes)])
    disp(['Data column indexes: ', num2str(column_indexes)])
end
% check file_indexes; should not be below one or larger than amount of cells in Data
    % some give file_indexes are not correct if size of 
    % combined intersection is smaller than file_indexes
if length(intersect(file_indexes,1:length(Data_BPM))) < length(file_indexes)
    error('Check file indexes!')
end
% check datacolumn indexes; should not be below one
if any(column_indexes < 1) 
    error('Check column indexes!')
end
% if all file_indexes are chosen, certain data column indexes are fully removed
if isequal(file_indexes,1:length(Data_BPM))
    disp(['Removing following datacolumn indexes from everywhere: ',...
        num2str(column_indexes)])
    remove_whole_datacolumn = 'yes';
else
    remove_whole_datacolumn = 'no';
end
%% Updating Data_BPM
% removing data
try
    for file_ind = file_indexes
        if strcmp(remove_whole_file,'yes')  
            % if deleting every column, empty whole cell
            Data_BPM{file_ind} = [];
        else % remove chosen datacolumns
            
            % low peaks
            if isfield(Data_BPM{file_ind,1},'peak_values_low')
                Data_BPM{file_ind,1}.peak_values_low(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'peak_locations_low')
                Data_BPM{file_ind,1}.peak_locations_low(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'peak_widths_low')
                Data_BPM{file_ind,1}.peak_widths_low(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'Amount_of_peaks_low')
                Data_BPM{file_ind,1}.Amount_of_peaks_low(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'BPM_avg_low')
                Data_BPM{file_ind,1}.BPM_avg_low(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'peak_distances_in_ms_low')
                Data_BPM{file_ind,1}.peak_distances_in_ms_low(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'peak_avg_distance_in_ms_low')
                Data_BPM{file_ind,1}.peak_avg_distance_in_ms_low(column_indexes,:) = [];
            end
            
            % high peaks
            if isfield(Data_BPM{file_ind,1},'peak_values_high')
                Data_BPM{file_ind,1}.peak_values_high(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'peak_locations_high')
                Data_BPM{file_ind,1}.peak_locations_high(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'peak_widths_high')
                Data_BPM{file_ind,1}.peak_widths_high(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'Amount_of_peaks_high')
                Data_BPM{file_ind,1}.Amount_of_peaks_high(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'BPM_avg_high')
                Data_BPM{file_ind,1}.BPM_avg_high(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'peak_distances_in_ms_high')
                Data_BPM{file_ind,1}.peak_distances_in_ms_high(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'peak_avg_distance_in_ms_high')
                Data_BPM{file_ind,1}.peak_avg_distance_in_ms_high(column_indexes,:) = [];
            end            
            
            % chosen
            if isfield(Data_BPM{file_ind,1},'peak_values')
                Data_BPM{file_ind,1}.peak_values(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'peak_locations')
                Data_BPM{file_ind,1}.peak_locations(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'peak_widths')
                Data_BPM{file_ind,1}.peak_widths(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'Amount_of_peaks')
                Data_BPM{file_ind,1}.Amount_of_peaks(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'BPM_avg')
                Data_BPM{file_ind,1}.BPM_avg(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'peak_distances_in_ms')
                Data_BPM{file_ind,1}.peak_distances_in_ms(column_indexes) = [];
            end
            if isfield(Data_BPM{file_ind,1},'peak_avg_distance_in_ms')
                Data_BPM{file_ind,1}.peak_avg_distance_in_ms(column_indexes,:) = [];
            end

            
        end
    end
    % remove empty cells in Data_BPM, see
    % https://se.mathworks.com/matlabcentral/answers/27042-how-to-remove-empty-cell-array-contents
    Data_BPM = Data_BPM(~cellfun('isempty',Data_BPM));
catch
   error('Check file and column indexes that should be removed.') 
end

%% TODO:
% if whole datacolumn is removed
if strcmp(remove_whole_datacolumn,'yes')

end
% open('C:\Local\maki9\Data\MATLAB\data_analyysi\data_analysis_files\Explore_and_TEMP\Delete_certain_datacolumns_from_Data_and_DataInfo.m')

% for file_index = 1:DataInfo.files_amount
% end
%% TODO: tarvitaanko if not removing full row or column
if strcmp(remove_whole_file,'no') && strcmp(remove_whole_datacolumn,'no')
    for pp = column_indexes
        for kk = file_indexes
            Data_BPM.signal_types(file_indexes,:) = [];
        end
    end
end


%% update file index in each cell in Data_BPM
for ind = 1:length(Data_BPM)
   Data_BPM{ind,1}.file_index =  ind;
end

end


