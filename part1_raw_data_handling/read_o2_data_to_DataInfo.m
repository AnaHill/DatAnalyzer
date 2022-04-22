function DataO2 = read_o2_data_to_DataInfo(min_time_deleted_from_begin, exp_name, meas_name)
% function DataO2 = read_o2_data_to_DataInfo(min_time_deleted_from_begin, exp_name, meas_name)
% Add Ksv phi0 and phiC parameters if available
    % min_time_deleted_from_begin minimum time in sec that is deleted
    % exp_name, meas_name are experiment and measurement names
    % if these are not given, tries to load DataInfo from workspace and
        % exp_name = DataInfo.experiment_name;
        % meas_name = DataInfo.measurement_name;
    
narginchk(0,3)
nargoutchk(0,1)
if nargin < 1 || isempty(min_time_deleted_from_begin)
    min_time_deleted_from_begin = 0;
end
if nargin < 2 || isempty(exp_name)
    try
        DataInfo = evalin('base','DataInfo');
        exp_name = DataInfo.experiment_name;
    catch
        error('No experiment name found!')
    end
        
end
if nargin < 3 || isempty(meas_name)
    try 
        if ~exist('DataInfo','var')
            DataInfo = evalin('base','DataInfo');
        end
        meas_name = DataInfo.measurement_name;
    catch
       error('No measurement name found') 
    end
end

if strcmp(exp_name,'demo3')
    if strcmp(meas_name,'demo3_14')
        Ksv = 0.201; phi0 = 29.55; phiC = 0.0; % demo 3.14
    elseif strcmp(meas_name,'demo3_13')
        Ksv = 0.185; phi0 = 31.3; phiC = 6.0; 
    elseif strcmp(meas_name,'demo3_3')
        Ksv = 0.195; phi0 = 31.0; phiC = 0.0;
    end
end

% If Ksv and other parameters not found, ask
if ~exist('Ksv','var')
    prompt = {'Ksv','phi0','phiC'};
    dlgtitle = 'Set O2 parameters';
    definputs = [{'0.185'};{'31.3'}; {'6.0'}];
    opts.Interpreter = 'none';
    output_names = inputdlg(prompt,dlgtitle,[1 100],definputs,opts);
    kk = 1; Ksv = str2double(output_names{kk,1}); kk=kk+1;
    phi0= str2double(output_names{kk,1}); kk=kk+1;
    phiC= str2double(output_names{kk,1});
end
disp([10,'O2 parameters for experiment: ', exp_name,' - ', meas_name])
o2param_table = array2table([Ksv phi0 phiC],'Variablenames',{'Ksv','phi0','phiC'});
disp(o2param_table)


%% Choosing and reading o2 datafolder
try
    if ~exist('DataInfo','var')
        DataInfo = evalin('base','DataInfo');
    end
    folder_to_read =  DataInfo.folder_raw_files;
catch
	folder_to_read = pwd;
end

data_folder = [uigetdir(folder_to_read,'Choose O2 data directory (.mat files)'),'\'];
disp(['Folder: ',data_folder])
listdir = dir(data_folder);
filenameO2=cell(length(listdir)-2,1); % decresing two because of . and .. in dir
% filenameO2=cell(length(listdir),1);
index = 1;
for ii = 1 : length(listdir)
    [~,~, ext] = fileparts(listdir(ii).name);
    if strcmp(ext, '.mat')
        filenameO2{index,1} = fullfile(listdir(ii).name);
        index = index + 1;
    end
end
if isempty(filenameO2)
    warning('No data found!')
    return
end
disp([10,'%%%%%%%%%%%%%%%',10,'List of data found:'])
for ii = 1 : length(filenameO2)
    fprintf('Data#%d) %s\n',ii, filenameO2{ii})   
end
%% Get O2 time vector from file names and measurement
% DataO2_Time.filename = {};
filenames = {};
FullData=[];
MeanData=[];
Phase=[];
Mag=[];
FullStartCal=[];
FullStopCal=[];

aof= length(filenameO2); % amount_of_files 
ftd = 100; % how often disp is printed; after every ftd'th file
% possible problems indexed
index_problems = [];
disp([10,'Reading O2 files',10])
for pp = 1:aof
    try % part of data not valid
        temp = load([data_folder, filenameO2{pp}]);
        tn=filenameO2(pp);
        tn{1}=tn{1}(1:end-4-5);
        try
            date_t=datetime(tn,'InputFormat','yyyyMMdd_HHmmss');
        catch % if e.g. end ss = 60 (should not be)
            if str2num(tn{1}(end-1:end)) == 60
                date_t=datetime(tn{1}(1:end-2),'InputFormat','yyyyMMdd_HHmm');
                date_t = date_t+seconds(60); % add one minute
            else
                warning(['Processing file #',num2str(pp),': some problem'])
                warning('Unknown error!')% error('Unknown error!')
                return
            end
        end
    
        filenames{end+1,1} = filenameO2(pp);
        if pp == 1
            DataO2_Time.datetime = date_t;
        else
            DataO2_Time.datetime(end+1,1) = date_t;
        end
        % data
        phi(pp,1) = mean(angle(temp.Measurement(3:end)-temp.StopCal)/pi*180); 
        amp(pp,1) = mean(abs(temp.Measurement(3:end)-temp.StopCal)); 
        try
            FullData=[FullData; temp.Measurement];
        catch
            disp(['Processing file #',num2str(pp),' -> Size not same than previous data'])
            tMle = length(temp.Measurement);
            fdle = length(FullData(end,:));
            if tMle > fdle
                 FullData=[FullData; temp.Measurement(1:fdle)];
            else
                mv = fdle-tMle; % number of missing values;
                extra_data_points = 1:floor(tMle/mv):tMle;
                temp.Measurement = [temp.Measurement ...
                    temp.Measurement(extra_data_points)];
                disp(['File #',num2str(pp),': added extra points that length is same than previous data!'])
                clear mv

            end
            clear tMl fdl 
        end
        MeanData=[MeanData; mean(temp.Measurement)];
        FullStartCal=[FullStartCal;temp.StartCal];
        FullStopCal=[FullStopCal;temp.StopCal];    
    %     disp('file processed.')
        if mod(pp,ftd) == 0 || pp == aof
            disp(['Processing file #',num2str(pp),' / ',num2str(aof),' ... processed'])
        end
    catch
       warning(['PROBLEM while processing file #',num2str(pp),' -> skipping'])
       index_problems = [index_problems pp]; 
    end
end

%%
disp(['All files (#',num2str(length(filenameO2)),') processed'])
if ~isempty(index_problems)
    index_problems = sort(unique(index_problems));
    if length(index_problems) > 1 
        warning(['Problems while reading following files (n = ',...
            num2str(length(index_problems)),')'])
    else % one problem
        warning(['Problem while reading following file'])
    end
    disp(num2str(index_problems))
else
    disp('No problems detected file reading O2 files.')
end
Phase=phi;
Mag=amp;
pO2=SternVolmerC(Ksv,phi0,-Phase,phiC);
% function [ pO2 ] = SternVolmerC(Ksv,phi0,phi,phiC)

DataO2_Time.duration = (DataO2_Time.datetime - DataO2_Time.datetime(1));
DataO2_Time.time_sec = datenum(DataO2_Time.duration) * 24*60*60; % in sec

%% deleting non-usefull data from the begin
if min_time_deleted_from_begin > 0
    disp(['Removing those data points at the beging that are before measurement time (in sec): ',...
        num2str(min_time_deleted_from_begin)])
    first_index = find(DataO2_Time.time_sec >=min_time_deleted_from_begin,1);
    t_temp.datetime = DataO2_Time.datetime(first_index:end);
    t_temp.duration = t_temp.datetime - t_temp.datetime(1);
    t_temp.time_sec = datenum(t_temp.duration) * 24*60*60; % in sec
    DataO2.measurement_time = t_temp;
else
    first_index = 1;
    DataO2.measurement_time = DataO2_Time;
end
DataO2.data = pO2(first_index:end);
DataO2.filename = filenames(first_index:end,1);
DataO2.Ksv = Ksv;
DataO2.phi0 = phi0;
DataO2.phiC = phiC;
disp('O2 reading completed')
end
