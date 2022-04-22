function [savefolder] = save_data_files(savefolder, saving_DataPeaks_mean, saving_DataPeaks,...
    saving_raw_data, DataInfo, Data_BPM, Data_BPM_summary, Data_o2,...
    DataPeaks_summary, savename_end)
% function save_data_files(savefolder, saving_DataPeaks_mean, saving_DataPeaks,...
%     saving_raw_data, DataInfo, Data_BPM, Data_BPM_summary, Data_o2,...
%     DataPeaks_summary, savename_end)
% save_data_files saves important data
% Examples
% save_data_files(savefolder) % not saving DataPeaks_mean, DataPeaks nor Data
% save_data_files(savefolder,1) % saves DataPeaks_mean
% save_data_files(savefolder,1,1) % saves also DataPeaks
% save_data_files(savefolder,1,1,1) % saves also Data
% save_data_files(savefolder,[],[],1) % saves only Data without DataPeaks and DataPeaks_mean
% save_data_files(DataInfo.savefolder)

narginchk(0,10)
nargoutchk(0,1)
disp(['%%%%%%%%%%%%%%%%%%%%%%',10,'Saving data'])

if nargin < 1 || isempty(savefolder)
    text='Choose saving location';
    try
        savefolder = uigetdir([evalin('base','DataInfo.savefolder')],text);
    catch
%         savefolder = uigetdir([pwd],'Choose saving location');
        savefolder = uigetdir([pwd],text);
    end
end
if nargin < 2 || isempty(saving_DataPeaks_mean)
    saving_DataPeaks_mean = 0; % not saving DataPeaks_mean (might take quite long time)
end
if nargin < 3 || isempty(saving_DataPeaks)
    saving_DataPeaks = 0; % not saving DataPeaks (takes quite long time)
end
if nargin < 4 || isempty(saving_raw_data)
    saving_raw_data = 0; % not saving data (takes even longer time)
end


names = {};
names{end+1,1} = 'DataInfo';
if nargin < 5 || isempty(DataInfo) 
    try
        DataInfo = evalin('base',names{end,1});
    catch
        disp(['No ',names{end,1}])
        names(end) = [];
    end
end

names{end+1,1} = 'Data_BPM';
if nargin < 6 || isempty(Data_BPM) 
    try
        Data_BPM = evalin('base',names{end,1});
    catch
        disp(['No ',names{end,1}])
        names(end) = [];
    end
end

names{end+1,1} = 'Data_BPM_summary';
if nargin < 7 || isempty(Data_BPM_summary) 
    try
        Data_BPM_summary = evalin('base',names{end,1});
    catch
        disp(['No ',names{end,1}])
        names(end) = [];
    end
end

names{end+1,1} = 'Data_o2';
if nargin < 8 || isempty(Data_o2) 
    try
        Data_o2 = evalin('base',names{end,1});
    catch
        disp(['No ',names{end,1}])
        names(end) = [];
    end
end

names{end+1,1} = 'DataPeaks_summary';
if nargin < 9 || isempty(DataPeaks_summary) 
    try
        DataPeaks_summary = evalin('base',names{end,1});
    catch
        disp(['No ',names{end,1}])
        names(end) = [];
    end
end

if nargin < 10 || isempty(savename_end) 
    try
        savename_end = ['_',DataInfo.experiment_name,'_',DataInfo.measurement_name];
    catch
        warning('No DataInfo exp and meas information found!') 
        disp('Setting generic suffix to savefile: exp_meas_name')
        savename_end = 'exp_meas_name';
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~strcmp(savefolder(end),'\')
    savefolder = [savefolder,'\'];
end

% If saving also DataPeaks_mean
if saving_DataPeaks_mean ~= 0
        names{end+1,1} = 'DataPeaks_mean'; 
    try
        DataPeaks_mean = evalin('base',names{end,1});
    catch
        disp(['No ',names{end,1}])
        names(end) = [];
    end
else
    disp(['DataPeaks_mean not saved.']) 
end


% If saving also DataPeaks
if saving_DataPeaks ~= 0  
    names{end+1,1} = 'DataPeaks'; 
    try
        DataPeaks = evalin('base',names{end,1});
    catch
        disp(['No ',names{end,1}])
        names(end) = [];
    end
else
    disp(['DataPeaks not saved.']) 
end

% If saving also Data
if saving_raw_data ~= 0
    answer = questdlg('Do you really want to save Data, it might take for a while?', ...
        'Saving Data', ...
        'Yes.','No.','Yes.');
    % Handle response
    switch answer
        case 'No.'
            disp(['Raw data not saved.'])
            saving_raw_data = 0;
        otherwise     
            names{end+1,1} = 'Data';  % names = [names,'Data'];
            try
                Data = evalin('base',names{end,1});
            catch
                disp(['No ',names{end,1}])
                names(end) = [];
            end
            
    end
else
    disp(['Raw data not saved.']) 
end
if exist('DataInfo','var')
    DataInfo.savefolder = savefolder;
    assignin('base','DataInfo',DataInfo)
end
%% saving 
disp(['Saving folder: ', savefolder])
disp(['Save info: ',savename_end])
fprintf('Saving variables:   ')
fprintf('%s    ', names{:}), fprintf('\n')
for kk = 1:length(names)
    nam = names{kk,1};
    fprintf(['Saving ',nam])
    try
        if strcmp(nam, 'DataPeaks') || strcmp(nam, 'Data') || ...
                strcmp(nam, 'DataPeaks_mean')
            fprintf(' this might take for a while')
            save([savefolder,nam,savename_end] ,nam,'-v7.3')
        else
            save([savefolder,nam,savename_end] ,nam)
        end
        disp('...saved')
    catch
        warning(['...not found to save!'])
%         warning([10, nam,' not found to save'])
    end
end
disp([10,' '])
end
