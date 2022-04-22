function [rawmeadata, framerate] = read_raw_mea_file(info, index)
%READ_RAW_MEA_FILE Reads single mea (.h5) file fully to rawmeadata
% 2022/02 edition: decreased used variables
narginchk(2,2)
nargoutchk(0,2)

rawmeadata = [];
TargetFile = [info.folder_raw_files, info.file_names{index}];
try
    % directly duration in sec in duration field
    rawmeadata.duration = double(h5readatt(...
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
    rawmeadata.duration = double(h5readatt(TargetFile,...
        '/Data/Recording_0/', 'Duration'))*10^-6;

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
    
    
end
% full recording array (not converted to Volts)
rawmeadata.MCSFile = h5read(TargetFile,'/Data/Recording_0/AnalogStream/Stream_0/ChannelData');
% recording info
rawmeadata.info = h5read(TargetFile,'/Data/Recording_0/AnalogStream/Stream_0/InfoChannel');
% framerate
rawmeadata.framerate = double(length(rawmeadata.MCSFile(:,1))/rawmeadata.duration);

% if framerate is wanted to own variable
if nargout > 1
    framerate = rawmeadata.framerate;
end

end



