function [DataInfo] = set_signal_type(DataInfo,file_index,datacolumns,signal_type)
% function [DataInfo] = set_signal_type(DataInfo,file_index,datacolumns,signal_type)
% DataInfo=set_signal_type(DataInfo,1,[2,4]); % set to default:normal_mea
% DataInfo = set_signal_type(DataInfo,1,[3],'low_mea'); % low_mea signal
% DataInfo = set_signal_type(DataInfo,1,[1],'none'); % no beats/peaks

narginchk(0,4)
nargoutchk(0,1)
% defaults
if nargin < 1 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error(['No DataInfo found!'])
    end
end
if nargin < 2 || isempty(file_index)
    file_index = 1:DataInfo.files_amount;
end
if nargin < 3 || isempty(datacolumns)
    datacolumns = 1:length(DataInfo.datacol_numbers);
end
% setting default based on DataInfo.measurement_type if not given
if nargin < 4 || isempty(signal_type)
    if isfield(DataInfo, 'measurement_type')
        if strcmp(DataInfo.measurement_type,'MEA')
            signal_type = 'normal_mea';
            disp(['Setting signal type to normal mea'])
        elseif strcmp(DataInfo.measurement_type,'CA')
            signal_type = 'normal_ca';
            disp(['Setting signal type to normal ca'])
        elseif strcmp(DataInfo.measurement_type,'AP')
            signal_type = 'normal_ap';
            disp(['Setting signal type to normal ap'])
        elseif strcmp(DataInfo.measurement_type,'Video')
            signal_type = 'normal_video';
            disp(['Setting signal type to normal video'])
        elseif strcmp(DataInfo.measurement_type,'MATLAB')
            signal_type = 'normal';
            disp(['Setting signal type to normal (from .mat file)'])
        else
            signal_type = 'normal';
            disp(['Setting signal type to normal (unknown file type)'])
        end
    else % no measurement_type
        file_types = {'.h5';'.abf';'.csv';'.txt';'.atf';'.mat';'.avi'};
        measurement_types = {'MEA';'MEA';'CA';'CA';'AP';'MATLAB';'Video'};
        prompt_text = {'Select a file type.';'.h5 and .abf= MEA files';...
            '.csv and .txt = raw and converted Calcium imaging files';...
            '.atf = Patch clamp AP files';...
            '.mat = Matlab files previously created';'.avi = video files'};        
        [indx,tf] = listdlg('PromptString',prompt_text,...
            'SelectionMode','single','Name','Data Type Selection',...
            'ListSize',[600,300],'ListString',file_types);
        if isempty(indx)
            indx = 1;
            disp(['No file type selected -> Choosing first data type on the list']);
        end
        file_type = file_types{indx};
        disp(['Selected file type: ', file_types{indx}]);
        measurement_type = measurement_types{indx};
        disp(['Selected measurement type: ', measurement_type]);
        DataInfo.measurement_type = measurement_type;
        if strcmp(DataInfo.measurement_type,'MEA')
            signal_type = 'normal_mea';
            disp(['Setting signal type to normal mea'])
        elseif strcmp(DataInfo.measurement_type,'CA')
            signal_type = 'normal_ca';
            disp(['Setting signal type to normal ca'])
        elseif strcmp(DataInfo.measurement_type,'AP')
            signal_type = 'normal_ap';
            disp(['Setting signal type to normal ap'])
        elseif strcmp(DataInfo.measurement_type,'Video')
            signal_type = 'normal_video';
            disp(['Setting signal type to normal video'])
        elseif strcmp(DataInfo.measurement_type,'MATLAB')
            signal_type = 'normal';
            disp(['Setting signal type to normal (from .mat file)'])
        else
            signal_type = 'normal';
            disp(['Setting signal type to normal (unknown file type)'])
        end
    end
        
end

file_index = unique(sort(file_index));
datacolumns = unique(sort(datacolumns));
disp(['%%%%%%%%%%%%%'])
disp(['Setting signal type to ',signal_type, 10, 'in the following data:'])
disp(['Datafiles: ',num2str(file_index)])
disp(['Datacolumns: ',num2str(datacolumns)])
disp(['%%%%%%%%%%%%%'])
for pp = 1:length(file_index)
    ind = file_index(pp);
    for kk = 1:length(datacolumns)
       col = datacolumns(kk);
       % set signal type to normal, fix if needed
       DataInfo.signal_types{ind,col}=signal_type;
    end
end
end