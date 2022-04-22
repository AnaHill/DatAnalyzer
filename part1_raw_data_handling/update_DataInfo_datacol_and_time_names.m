%% Update DataInfo: update_DataInfo_datacol_and_time_names.m
% .datacol_numbers  = datacolumn number, for MEA from raw data datacolumn numbers taken
% .datacol_names = naming thse datacolumns
% .measurement.time.names = adding "measurement name" for legend purposes
    
% datacol_numbers
try
    DataInfo.datacol_numbers
catch
    disp('Creating DataInfo.datacol_numbers')
    try
        DataInfo.datacol_numbers = DataInfo.MEA_columns;
    catch
        DataInfo.datacol_numbers = 1:length(Data{1,1}.data(1,:));
    end
    DataInfo.datacol_numbers
end

% datacol_names
try
    DataInfo.datacol_names
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
end

% add "measurement name" to DataInfo.measurement.time for the legends
try
    DataInfo.measurement_time.names;
catch
    disp('Creating "measurement name" to DataInfo.measurement.time for the legends')
    DataInfo = create_time_names_for_DataInfo(DataInfo);
end
