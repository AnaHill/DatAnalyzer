function [folder_of_files, filename_list,file_numbers_to_analyze] = ...
    get_files(file_type,folder_to_start)
% function [folder_of_files, filename_list,file_numbers_to_analyze] = get_files(file_type,folder_to_start)
%GET_FILES get files
%% Choose folder and read files (e.g. *.avi)
% in: 
    % folder_to_read (default if not chosen: pwd, current folder is used)
    % file_type (default: '.avi')
% out:
    % folder_of_files (char)
    % filename_list{} (cell column)
    % file_numbers_to_analyze (column, numbers)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5    

% Check if folder_to_read defined, if not use pwd
% ise_folder = evalin( 'base', 'exist(''folder_to_read'',''var'') == 1' );
% if ~ise_folder % 
if nargin < 2
    folder_to_start =  pwd;
end

% Check which filetype is looked for
% ise_filetype = evalin( 'base', 'exist(''file_type'',''var'') == 1' );
% ise_filetype = evalin( 'caller', 'exist(''file_type'',''var'') == 1' );
% if ~ise_filetype % if not defined, ask file_type
if ~exist('file_type', 'var')
    d = dir;
    fn = {'.avi';'.txt';'.csv';'.h5';'.mat'};
    [indx,tf] = listdlg('PromptString',{'Select a file type.',...
        },'SelectionMode','single','ListString',fn);
    if isempty(indx)
        file_type = fn{1}; %'.avi';
        disp(['No file type selected -> Choosing default file type: ', fn{1}]);
    else
        file_type = fn{indx};
        disp(['Selected file type: ', fn{indx}]);
    end
end

% Read and print folder
if strcmp(file_type, '.avi')
    folder_of_files = [uigetdir(folder_to_start,'Choose a Directory of Videos'),'\'];
else
    folder_of_files = [uigetdir(folder_to_start,'Choose data directory'),'\'];
end
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
    error('No data found! Stopped!'), %    return
end

disp([10,'%%%%%%%%%%%%%%%',10,'List of data found:'])
for ii = 1 : length(filename_list)
    if strcmp(file_type, '.avi')
        fprintf('Video#%d) %s\n',ii, filename_list{ii})   
    else
        fprintf('Data#%d) %s\n',ii, filename_list{ii})   
    end
end

% Want to analyze all data or certain only
file_numbers_to_analyze = [];
choice_fileNumbers= questdlg('Choose all data or only some for analysis?',...
    'Data Number Question', 'All','Choose','All');
switch choice_fileNumbers
  case 'Choose'
     [indx,tf] = listdlg('PromptString',{'Select file(s).'},...
         'ListString',filename_list,'ListSize',[300 600]);
     if isempty(indx)
         file_numbers_to_analyze = 1:length(filename_list);
         disp('Nothing selected, choosing all data files.')
     else
         file_numbers_to_analyze = indx;
     end
  case 'All'
      file_numbers_to_analyze = 1:length(filename_list);
end
file_numbers_to_analyze = file_numbers_to_analyze';

end