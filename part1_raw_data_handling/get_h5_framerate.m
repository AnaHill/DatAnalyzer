function [framerate] = get_h5_framerate(DataInfo, index)
% get_h5_framerate get framerate of current .h5 file
% calculates fs based on duration and length    
narginchk(2,2)
nargoutchk(0,1)

TargetFile = [DataInfo.folder_raw_files, DataInfo.file_names{index}];
% recording info
h5info = h5read(TargetFile,'/Data/Recording_0/AnalogStream/Stream_0/InfoChannel');
try
    % directly duration in sec in duration field
    h5info.duration = double(h5readatt(...
        TargetFile,'/Data/Recording_0/', 'Duration'))*10^-6;
catch
    warning('reading file not working properly!')
    warning('estimating records times from prev data')
    % taking prev data unless first value, then taking next
    if index > 1
        TargetFile = [info.folder_raw_files, info.file_names{index-1}];
    else % taking next if index == 1 && file_names_length > 1
        try 
            TargetFile = [info.folder_raw_files, info.file_names{index+1}];
        catch
            error('no other data found!')
        end
    end
    h5info.duration = double(h5readatt(TargetFile,...
        '/Data/Recording_0/', 'Duration'))*10^-6;
end
% framerate
index_length = h5read(TargetFile,...
    '/Data/Recording_0/AnalogStream/Stream_0/ChannelDataTimeStamps');
index_length = index_length(end)-index_length(end-1)+1;
framerate = double(index_length)/h5info.duration;


end