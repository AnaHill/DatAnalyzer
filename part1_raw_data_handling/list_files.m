function [folder_of_files, filename_list, file_type, measurement_type] = ...
    list_files(file_type,folder_to_start)
% updated 26.3.2021
% GET_FILES read & list folder of files
% Choose folder and read certain files (e.g. *.avi)
% in: 
    % file_type (e.g. '.h5')
    % folder_to_start (current folder is used if not give)
% out:
    % folder_of_files (char)
    % filename_list{} (cell column)
    % file_type (char)
    % measurement_type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
narginchk(0,2)
nargoutchk(2,4)
% Ask if file type not given
if nargin < 1 || isempty(file_type)% exist('file_type', 'var')
    clear file_type
end
% Check if folder_to_read defined, if not use pwd
if nargin < 2
    folder_to_start =  pwd;
end

file_types = {'.h5';'.abf';'.csv';'.txt';'.atf';'.mat';'.avi';'.tif'};
measurement_types = {'MEA';'MEA';'CA';'CA';'AP';'MATLAB';'Video';'Image_tiff'};
prompt_text = {'Select a file type.';'.h5 and .abf= MEA files';...
    '.csv and .txt = raw and converted Calcium imaging files';...
    '.atf = Patch clamp AP files';...
    '.mat = Matlab files previously created';'.avi = video files';...
    '.tif = .tif images'};

% Check which filetype is looked for
% if file_type exist, choosing measurement type automatically
if exist('file_type', 'var')
    indx = find(contains(file_types,file_type));
    if ~isempty(indx)
        indx = indx(1); % if multiple, choosing the first one
        disp(['Selected file type: ', file_types{indx}]);
    else % no file_type
        warning('Inputted file_type not found, asking file_type again!')
        clear file_type
    end
    
end
if ~exist('file_type', 'var')
%     d = dir;
%     file_types = {'.h5';'.abf';'.csv';'.txt';'.mat';'.avi'};
    [indx,tf] = listdlg('PromptString',prompt_text,...
        'SelectionMode','single','Name','Data Type Selection',...
        'ListSize',[600,300],'ListString',file_types);
    if isempty(indx)
        indx = 1; 
        disp(['No file type selected -> Choosing first data type on the list']);
    end
    file_type = file_types{indx};
    disp(['Selected file type: ', file_types{indx}]);
end
measurement_type = measurement_types{indx};
disp(['Selected measurement type: ', measurement_type]);
% Choose folder
if strcmp(file_type, '.avi')
    folder_of_files = [uigetdir(folder_to_start,'Choose a Directory of Videos'),'\'];
else
    folder_of_files = [uigetdir(folder_to_start,'Choose data directory'),'\'];
end
% print folder path
disp(['Folder: ',folder_of_files])
listdir = dir(folder_of_files);

% Get files from folder
filename_list=[];
for ii = 1 : length(listdir)
    [~,name, ext] = fileparts(listdir(ii).name);
    if strcmp(ext, file_type)
        filename_list{end+1,1} = fullfile(listdir(ii).name);
    end
end
if isempty(filename_list)
    error('No data found! Stopped!')
else
    disp(['%%%%%%%%%%%%%%%',10,'Amount of files found: ',...
        num2str(length(filename_list)),10, 'Listing data:'])
    for ii = 1 : length(filename_list)
        if strcmp(file_type, '.avi')
            fprintf('Video#%d) %s\n',ii, filename_list{ii})
        else
            fprintf('Data#%d) %s\n',ii, filename_list{ii})
        end
    end
end

end