function h5file_info = get_h5info(TargetFile_or_DataInfo, file_index)
% get_h5info gets info about .h5 file 
    % recording info InfoChannel information
    % data size
    % duration
    % framerate based on duration and data length
% Some examples %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% h5file_info = get_h5info
    % tries to load TargetFile variable from the workspace
    % then, tries to load .h5 file given in TargetFile
    % e.g. if TargetFile is created before function call:
    % file_index=randi(129,1); 
    % TargetFile = [DataInfo.folder_raw_files, DataInfo.file_names{file_index}];
    % h5file_info = get_h5info
% h5file_info = get_h5info('Full_File_location); 
    % reads .h5 file given from input information
% h5file_info = get_h5info(DataInfo,7); 
    % reads 7th file listed in DataInfo.file_names
    % basically, TargetFile = [DataInfo.folder_raw_files, DataInfo.file_names{7}];
% h5file_info = get_h5info([],2);
    % tries to get DataInfo variable from the workspace
    % then, tries to get information from the second .h5 file listed in DataInfo.file_names
    % basically TargetFile = [DataInfo.folder_raw_files, DataInfo.file_names{2}];

narginchk(0,2)
nargoutchk(0,1)

%%% Checking inputs
if nargin < 1 
    try 
        TargetFile = evalin('base', 'TargetFile');
        h5file_info.infochannel = h5read(TargetFile,'/Data/Recording_0/AnalogStream/Stream_0/InfoChannel');
        TargetFile_or_DataInfo = TargetFile;
    catch
        error(['No TargetFile variable found on workspace, ',...
            'provide either TargetFilename or file index when calling function'])
    end
end
% if TargetFilename is given but no file_index --> h5read directly to TargetFilename
if nargin < 2 || isempty(file_index)
    try
        TargetFile = TargetFile_or_DataInfo;
        h5file_info.infochannel = h5read(TargetFile,'/Data/Recording_0/AnalogStream/Stream_0/InfoChannel');
    catch
       error('Only one input given in the function call: given .h5 file not found') 
    end
end
% if only file_index is given --> trying to load DataInfo from workspace
if isempty(TargetFile_or_DataInfo) && ~isempty(file_index)
    try 
        DataInfo = evalin('base', 'DataInfo');
        TargetFile = [DataInfo.folder_raw_files, DataInfo.file_names{file_index}];
        h5file_info.infochannel = h5read(TargetFile,'/Data/Recording_0/AnalogStream/Stream_0/InfoChannel');
    catch
       error('No TargetFile given, and DataInfo not found on workspace or problems loading .h5 file')
    end
end
% assuming first that TargetFile_or_DataInfo == DataInfo
% if not working, assuming that TargetFile_or_DataInfo == TargetFile
% prints error if even that does not work
if nargin == 2  && ~isempty(TargetFile_or_DataInfo)  && ~isempty(file_index)
    try  % first, tries TargetFile_or_DataInfo == DataInfo
        DataInfo = TargetFile_or_DataInfo;
        TargetFile = [DataInfo.folder_raw_files, DataInfo.file_names{file_index}];
        h5file_info.infochannel = h5read(TargetFile,'/Data/Recording_0/AnalogStream/Stream_0/InfoChannel');
    catch
        try % secondly, tries TargetFile_or_DataInfo == TargetFile
            TargetFile = TargetFile_or_DataInfo;
            h5file_info.infochannel = h5read(TargetFile,'/Data/Recording_0/AnalogStream/Stream_0/InfoChannel');
        catch
            error('No TargetFile given, and DataInfo not found on workspace or problems loading .h5 file')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get duration, data size and framerate
% get duration
try
    % directly duration in sec in duration field
    h5file_info.duration = double(h5readatt(...
        TargetFile,'/Data/Recording_0/', 'Duration'))*10^-6;
catch
    error('reading file not working properly!')
end

% get data size
% see: https://se.mathworks.com/help/matlab/import_export/importing-hierarchical-data-format-hdf5-files.html
some_info = h5info(TargetFile);
h5file_info.datasize = some_info.Groups(1).Groups(1).Groups(1).Groups(1).Datasets(1).Dataspace.Size;
% get framerate
h5file_info.framerate = max(h5file_info.datasize)/h5file_info.duration;
% if framerate > 1, round framerate, as sometimes some round error
if h5file_info.framerate > 1
    h5file_info.framerate = round(h5file_info.framerate,4);
end
end