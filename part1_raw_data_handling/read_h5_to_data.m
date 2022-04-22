function [data, h5info,framerate] = read_h5_to_data(info, index, ... % compulsory
    how_many_datarows, how_many_datacolumns,start_indexes)
%READ_h5_FILE_TO_data Reads single mea (.h5) file to data variable
% reads
    % duration, converts its to seconds
    % channeldata
    % info
    % converts channeldata to double(data) format using conversions from info

% TODO:
    % reading better columns/rows
    
narginchk(2,5)
nargoutchk(0,3)

% default: all data rows included
if nargin < 3 || isempty(how_many_datarows)
    how_many_datarows = 0; % using whole length
end    

% all datacolumns
if nargin < 4 || isempty(how_many_datacolumns)
    how_many_datacolumns = length(info.datacol_numbers);
end    
    
% default: starting from [1 1]
if nargin < 5 || isempty(start_indexes)
    start_indexes = [1 1];
end
if length(start_indexes) == 1
    start_indexes = [start_indexes start_indexes];
end
if length(start_indexes) > 2
    start_indexes = [min(start_indexes) max(start_indexes)];
end

% count_amount = [DataInfo.framerate(1)*5, 60]; 
% start_ind=[1 1];file_ind = 5; 
% rawmeadata.MCSFile = h5read([DataInfo.folder_raw_files, DataInfo.file_names{file_ind}],...
%     '/Data/Recording_0/AnalogStream/Stream_0/ChannelData',start_ind,count_amount);
TargetFile = [info.folder_raw_files, info.file_names{index}];
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
% h5disp(TargetFile,'/Data/Recording_0/AnalogStream/Stream_0/ChannelDataTimeStamps');
% Attributes:
    % 'Column-0':  'FirstTimeStamp'
    % 'Column-1':  'FirstIndex'
    % 'Column-2':  'LastIndex'
index_length = h5read(TargetFile,...
    '/Data/Recording_0/AnalogStream/Stream_0/ChannelDataTimeStamps');
index_length = index_length(end)-index_length(end-1)+1;
h5info.framerate = double(index_length)/h5info.duration;


if any(how_many_datarows == 0) % using whole length
    % full recording array: each row 
    % values are not converted to Volts
    disp('reading full .h5 data')
    MCSFile = h5read(TargetFile,...
        '/Data/Recording_0/AnalogStream/Stream_0/ChannelData',start_indexes,...
        [inf,how_many_datacolumns]);
else
	disp(['Reading .h5 data - number of rows:',num2str(how_many_datarows),...
        ' & columns:',num2str(how_many_datacolumns)])
    MCSFile = h5read(TargetFile,...
        '/Data/Recording_0/AnalogStream/Stream_0/ChannelData',start_indexes,...
        [how_many_datarows,how_many_datacolumns]);
    
end 


% convert raw data to data
% cols = 1:min(size(rawmeadata.MCSFile));
cols = [start_indexes(2):start_indexes(2)+how_many_datacolumns-1];
% data = double(rawmeadata.MCSFile(:,cols) - ...
data = double(MCSFile(:,:) - ...
    h5info.ADZero(cols)') .* ...
    (double(h5info.ConversionFactor(cols)) .* ...
    10.^double(h5info.Exponent(cols)))';

% if framerate is wanted to own variable
if nargout > 2
    framerate = h5info.framerate;
end

end
