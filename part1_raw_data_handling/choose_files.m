function [file_numbers_to_analyze] = choose_files(filename_list)
%CHOOSE_FILES choose files from the list
%   [file_numbers_to_analyze] = choose_files(filename_list)
% file_numbers_to_analyze includes indexes of chosen files found in the folder
narginchk(1,1)
nargoutchk(0,1)
file_numbers_to_analyze = [];
% Want to analyze all data or certain only
choice_fileNumbers= questdlg('Choose all data or only some for analysis?',...
    'Data Number Question', 'All','Choose','All');
switch choice_fileNumbers
  case 'Choose'
     [indx,tf] = listdlg('PromptString',{'Select file(s).'},...
         'ListString',filename_list,'ListSize',[600 600]); % [300 600]
     if isempty(indx)
         file_numbers_to_analyze = 1:length(filename_list);
         disp('Nothing selected, choosing all data files.')
     else
         file_numbers_to_analyze = indx;
         disp(['Chosen ',num2str(length(indx)), ' / ', ...
             num2str(length(filename_list)),' data found in the folder.'])
     end
  case 'All'
      file_numbers_to_analyze = 1:length(filename_list);
      disp(['All data files (#',num2str(length(filename_list)), ') selected.'])
end
file_numbers_to_analyze = file_numbers_to_analyze';
end