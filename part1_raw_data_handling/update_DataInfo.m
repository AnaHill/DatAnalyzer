function DataInfo = update_DataInfo(DataInfo)
%% Update DataInfo: update_DataInfo.m
% .file_names = file names 
% .datacol_numbers  = datacolumn number, for MEA from raw data datacolumn numbers taken
% .datacol_names = naming thse datacolumns
% .measurement.time.names = adding "measurement name" for legend purposes
narginchk(0,1)
nargoutchk(0,1)
disp('Updating DataInfo if missing struct fields')
if nargin < 1 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end


% file names if only .file_names_mat exist
try
    DataInfo.file_names;
    disp('DataInfo.file_names ok')
catch
    file_numbers_to_analyze = 1:DataInfo.files_amount;
    DataInfo.file_names = DataInfo.file_names_mat(file_numbers_to_analyze);
    disp('DataInfo.file_names updated')
end

% datacol_numbers
try
    DataInfo.datacol_numbers;
    disp('DataInfo.datacol_numbers ok')
catch
    disp('Creating DataInfo.datacol_numbers')
    try
        DataInfo.datacol_numbers = DataInfo.MEA_columns;
    catch
        try
            Data = evalin('base', 'Data');
        catch
            error('No proper Data')
        end
        DataInfo.datacol_numbers = 1:length(Data{1,1}.data(1,:));
    end
    DataInfo.datacol_numbers
    disp('DataInfo.datacol_numbers updated')
end

% datacol_names
try
    DataInfo.datacol_names;
    disp('DataInfo.datacol_names ok')
catch
    disp('Creating DataInfo.datacol_names')
    for pp=1:length(DataInfo.datacol_numbers)
        try
            DataInfo.datacol_names{pp,1} = ['MEAele',...
                num2str(DataInfo.MEA_electrode_numbers(pp))];                
        catch
            DataInfo.datacol_names{pp,1} = ['DataCol',...
                num2str(DataInfo.datacol_numbers(pp))];                
        end
    end
    DataInfo.datacol_names
    disp('DataInfo.datacol_names updated.')
end

% add "measurement name" to DataInfo.measurement.time for the legends
try
    DataInfo.measurement_time.names;
    disp('DataInfo.measurement_time.names ok')
catch
    disp('Creating "measurement name" to DataInfo.measurement.time for the legends')
    DataInfo = create_time_names_for_DataInfo(DataInfo);
	disp('DataInfo.measurement_time.names updated')

end



