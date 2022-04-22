%% loads multiple "raw" .mat files to single Data structure
% DataInfo required
tic
loadpath = [DataInfo.savefolder,'data02_intermediate\'];
clear Data, Data{DataInfo.files_amount,1} = [];
for file_index=1:DataInfo.files_amount
    Data{file_index,1} = load([loadpath, DataInfo.matfilenames{file_index,1}]);
    Data{file_index,1}.data = double(Data{file_index,1}.data)/DataInfo.conversion_factor_double_to_int; 
    disp(['Read file#',num2str(file_index)])
end
toc 
