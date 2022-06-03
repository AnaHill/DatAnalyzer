function datarows_total = set_datarows(how_many_seconds_used, part_of_full_data)
% set which part of data is used for recommender
    % how_many_seconds_used = 0; to use whole length
    % how_many_seconds_used = 5; to use 5 sec length
    % part_of_full_data: partial amount of full data length (0 < X <= 1 , e.g. 0.5)
narginchk(0,2)
nargoutchk(0,1)

% default values
% setting how_many_seconds_used  to zero --> all rows are included
if nargin < 1
    how_many_seconds_used = 0;
end

if nargin < 2
    part_of_full_data = 0;
end

if nargin == 2
    part_of_full_data = 0;
    disp('both inputs given, using only first one')
end


if part_of_full_data == 0
    if how_many_seconds_used == 0 % || strcmp(how_many_datarows, 'inf')
        datarows_total= 'inf'; 
    else
        DataInfo = evalin('base','DataInfo');
        create_fs_variable % create fs
        datarows_total= fs*how_many_seconds_used; % seconds x fs = X sec length
    end

else % if partial data used
    try
        whole_datasize = max(evalin('base','h5file_info.datasize'));
    catch
        DataInfo = evalin('base','DataInfo');
        h5file_info = get_h5info(DataInfo,1);
        whole_datasize = max('h5file_info.datasize');
    end
    if part_of_full_data > 1
        part_of_full_data = 1;
    end
    datarows_total= round(whole_datasize*part_of_full_data);
end