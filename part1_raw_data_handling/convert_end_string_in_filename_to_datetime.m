function [time_in_datetime] = convert_end_string_in_filename_to_datetime(filename,...
    str_to_find, before_str_date_format, after_str_date_format, str_index)
% function [time_in_datetime] = convert_end_string_in_filename_to_datetime...
%     (filename, str_to_find, before_str_date_format, after_str_date_format,str_index)
%CONVERT_END_STRING_IN_FILENAME_TO_DATETIME returns datetime taken from filename
% assumes, that filename includes datetime in the end of filename
% first finds str_to_find, char(s) before and after date format

% default format, if not given in function input, is 'yyyy-MM-dd''T''HH-mm-ss'
%     str_to_find = 'T';
%     before_str_date = ['yyyy-MM-dd']; 
%     after_str_date_format = ['HH-mm-ss']; 
%     str_index index if if str_to_find that is used: last appeareance

% Examples
% Default values working: 'Exp_11311_EURCCS_p32_180820_mea21001a2020-09-15T09-33-28.h5'
    % filename = 'Exp_11311_EURCCS_p32_180820_mea21001a2020-09-15T09-33-28.h5'
    % time_in_datetime = convert_end_string_in_filename_to_datetime(filename)
% Using other format
    % filename='20190904_144713_File.mat';
    % index_that_wanted = 1;  
    % time_in_datetime = convert_end_string_in_filename_to_datetime(filename,'_','yyyyMMdd','HHmmss',index_that_wanted);
    
%%%%%%%%
narginchk(1,5)
nargoutchk(0,1)
% default values
if nargin < 2 || isempty(str_to_find)
    str_to_find = 'T';
end
if nargin < 3 || isempty(before_str_date_format)
    before_str_date_format = ['yyyy-MM-dd']; 
end
if nargin < 4 || isempty(after_str_date_format)
    after_str_date_format = ['HH-mm-ss']; 
end    
if nargin < 5 || isempty(str_index)
    % if empty / not given
    % Find LAST appearance of str_to_find (assuming datetime in the end of filename)
    str_index_is_last = 1; 
end

if ~exist('str_index_is_last','var')
    str_index_is_last = 0;
end


index_str_in_filename = strfind(filename, str_to_find);

if length(index_str_in_filename) > 1 % if multiple locations, 
    if str_index_is_last == 1 % only last index is taken
        index_str_in_filename = index_str_in_filename(end);
    else % taking index given in function call
        index_str_in_filename = index_str_in_filename(str_index);
    end
end
ind=index_str_in_filename;
str_len = length(str_to_find);
% now assuming time format in name is in format 'yyyy-MM-dd''str_to_find''HH-mm-ss' 
% e.g. 'yyyy-MM-dd''T''HH-mm-ss'
date_name_temp =  filename(ind-length(before_str_date_format):ind+length(after_str_date_format)+str_len-1);
% time_in_datetime = datetime(date_name_temp,'InputFormat',['yyyy-MM-dd''',str_to_find,'''HH-mm-ss']);
time_in_datetime = datetime(date_name_temp,'InputFormat',...
    [before_str_date_format,'''',str_to_find,'''',after_str_date_format]);


end