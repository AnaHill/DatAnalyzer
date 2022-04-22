function [time_in_datetime, date_name_temp] = convert_begin_string_in_filename_to_datetime(filename,...
    str_to_find, before_str_date_format, after_str_date_format, str_index)


%%%%%%%%
narginchk(1,5)
nargoutchk(0,2)
% default values
if nargin < 2 || isempty(str_to_find)
    str_to_find = '_';
end
if nargin < 3 || isempty(before_str_date_format)
    before_str_date_format = ['yyyyMMdd']; 
end
if nargin < 4 || isempty(after_str_date_format)
%     after_str_date_format = ['HH-mm-ss']; 
    after_str_date_format = []; 
end    
if nargin < 5 || isempty(str_index)
    % Find FIRST appearance of str_to_find (assuming datetime before str_to_find)
    str_index_is_last = 0; 
end

index_str_in_filename = strfind(filename, str_to_find);

if length(index_str_in_filename) > 1 % if multiple locations, 
    if str_index_is_last == 0 % only the FIRST index is taken
        index_str_in_filename = index_str_in_filename(1);
    else % taking index given in function call
        index_str_in_filename = index_str_in_filename(str_index);
    end
end
ind=index_str_in_filename;
str_len = length(str_to_find);
% now assuming time format in name is in format 'yyyyMMdd''str_to_find'''
% e.g. 'yyyyMMdd'_''
date_name_temp =  filename(ind-length(before_str_date_format):...
    ind+length(after_str_date_format)+str_len-1);
% time_in_datetime = datetime(date_name_temp,'InputFormat',['yyyy-MM-dd''',str_to_find,'''HH-mm-ss']);
time_in_datetime = datetime(date_name_temp,'InputFormat',...
    [before_str_date_format,'''',str_to_find,'''',after_str_date_format]);

date_name_temp = date_name_temp(1:end-1);
if strcmp(before_str_date_format, 'yyyyMMdd')
    date_name_temp = [date_name_temp(1:4),'_',...
        date_name_temp(5:6),'_',date_name_temp(7:end)];
end

end