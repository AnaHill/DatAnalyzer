function times_sec = convert_indexes_to_sec(indexes,fs,starting_time)
% function times_sec = convert_indexes_to_sec(indexes,fs,starting_time)
% if indexes is matrix, concerning max(size(indexes))
% Examples
% times_sec = convert_indexes_to_sec(Data_BPM{1, 1}.peak_locations{1})
% 
% Example2: Set values for function input
% file_index = 5; column_index = 2; fs = DataInfo.framerate(file_index);
% indexes = Data_BPM{file_index, 1}.peak_locations{column_index};
% starting_time = DataInfo.measurement_time.time_sec(file_index);
% times_sec = convert_indexes_to_sec(indexes, fs,starting_time);


narginchk(1,3)
nargoutchk(0,1)
% if indexes is empty(e.g. no peaks found), set times_sec = empty and return
if isempty(indexes)
    times_sec = [];
    disp('Empty indexes given! Returning empty times_sec.')
    return
    
end

% if fs not give, try to set from DataInfo.framerate(1), otherwise set fs=1
if nargin < 2 || isempty(fs)
    try
        DataInfo = evalin('base','DataInfo');
        fs = DataInfo.framerate(1);
        disp(['Assuming frame rate DataInfo.framerate(1), set '])
        disp(['fs = ',num2str(fs)]);
    catch % set fs = 1 if not found fs = DataInfo.framerate(1)
        % warning('No DataInfo')
        fs = 1;
        disp(['fs not given, set fs = ',num2str(fs)]);
    end
end
% default assuming t = 0 at index 1
if nargin < 3 || isempty(starting_time)
    starting_time = 0;
end

% check and edit inputs if they are longer 
if length(fs) > 2
    fs = fs(1);
    disp('Choosing first given fs value.')
end
if fs <= 0
   error('Incorrect fs given, should be > 0!') 
end
if length(starting_time)> 2
    starting_time = starting_time(1);
    disp('Choosing first given starting_time value.')
end 

% convert indexes to seconds based on fs
times_sec = (indexes-1)/fs+starting_time';



end
