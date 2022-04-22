function [Data_BPM] = find_peaks_in_loop_from_time_range(Data, DataInfo, Rule, ...
    filenumbers, datacolumns, data_multiply, time_range) 
% function [Data_BPM] = find_peaks_in_loop(Data, DataInfo, Rule,filenumbers, datacolumns, data_multiply,[time_range])
% find_peaks_in_loop(Data, DataInfo)
% FIND_PEAKS_IN_LOOP find peaks 
% Rule should have
    % .FrameRate
    % .MaxBPM
    % .MinPeakValue
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
narginchk(2,7) 
nargoutchk(0,1)

% set defaults if not all function inputs are given
if nargin < 3 || isempty(Rule)
    disp('Check if DataInfo has rules, ask to used them or not')
    use_datainfo_rule = 0;
    if isfield(DataInfo, 'Rule')
        disp('TODO: ask if using rules found in DataInfo or manually set')
        % if yes
        use_datainfo_rule = 1;    
    end
    if use_datainfo_rule == 1
        Rule = DataInfo.Rule;
    else
        disp('TODO: set rules if not defined')
        disp('TODO: ask if default or user input rules are used')
        % if default chosen
        use_default_rules=1;
        if use_default_rules == 1         % set default values    
            disp('Now default rules')
            DataInfo.Rule = set_default_filetype_rules_for_peak_finding;
            Rule = DataInfo.Rule;
        end
    end
end
  
if nargin < 4 || isempty(filenumbers)
  filenumbers =  [1:DataInfo.files_amount]';
end
if nargin < 5 ||  isempty(datacolumns)
  datacolumns =  1:length(Data{filenumbers(1),1}.data(1,:));
end    
% setting data_multiply, if 1, high peaks are found
% if -1 -> data will be converted (data * -1), and therefore finding low
% peaks
if nargin < 6 || isempty(data_multiply)
  data_multiply =  1; % 1= high peaks
end    

% default: using full data
if nargin < 7 || isempty(time_range)
    find_from_full_data = 1;
else
    find_from_full_data = 0;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    min_peak_distance_in_frames = Rule.FrameRate * 60/Rule.MaxBPM;
    min_peak_value  = Rule.MinPeakValue;
    min_peak_width  = Rule.minimum_peak_width;
catch
    min_peak_distance_in_frames = Rule.MinDist_sec*Rule.FrameRate;
    min_peak_value  = 2.5e-5;
    min_peak_width  = 50;
end
% find peaks_in loop
disp(['Finding peaks from Data: ',DataInfo.experiment_name,...
    '_',DataInfo.measurement_name,10, ...
    'Number of data/electrodes: ',num2str(length(datacolumns))])
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
Data_peaks = [];
total_time = 0;

tic_whole_find_peak_loop = tic;
for pp = 1:length(filenumbers)
    % index = 1;
    index = filenumbers(pp);
    if find_from_full_data ~= 1 % make time vector
        try
            fs = DataInfo.framerate(index,1);
        catch % old data where framerate only one file
            fs = DataInfo.framerate(1);
        end
    end
    tic_round = tic;  
    % if data_multiply == -1 -> raw_data*-1 --> finding low peaks
    raw_data = Data{index,1}.data * data_multiply;
    if find_from_full_data ~= 1 % make time vector
        t_raw = 0:1/fs:(length(raw_data(:,1))-1)/fs;
    end
    % figure, plot(raw_data)
    disp(['Checking, round ',num2str(pp),'/',num2str(length(filenumbers)),...
        ' (= file ',num2str(index),'/', num2str(length(Data)),')'])
    for kk = 1:length(datacolumns)
        col = datacolumns(kk); 
        dataToCheck = raw_data(:,col);
        % if only time_range is used to limit peak values
        if find_from_full_data ~= 1
            ind1 = find(t_raw >= min(time_range),1);
            ind2 = find(t_raw >= max(time_range),1);
            if ~isempty(ind2)
                dataToCheck = dataToCheck(ind1:ind2,1);
            else
                dataToCheck = dataToCheck(ind1:end,1);
            end
            if min_peak_distance_in_frames > length(dataToCheck)
                min_peak_distance_in_frames = length(dataToCheck)-2;
            end
        end    
        % negative values set to zero for peak finding
        dataToCheck(dataToCheck < 0) = 0;
        [pks, locs, w] = findpeaks(dataToCheck,'MinPeakDistance',...
            min_peak_distance_in_frames, 'MinPeakHeight', min_peak_value);%,...
            % 'MinPeakWidth',min_peak_width)
        if find_from_full_data ~= 1 % adding first index if part of data taken
            locs = locs + ind1-1;
        end         
            
            
        if data_multiply > 0 % high peaks
            Data_BPM{pp,1}.peak_values_high{kk,1} = pks; 
            Data_BPM{pp,1}.peak_locations_high{kk,1} = locs;
            Data_BPM{pp,1}.peak_widths_high{kk,1} = w;
            pks_amount(kk,1) = length(Data_BPM{pp,1}.peak_values_high{kk,1});
            % disp(['High Peaks found: ', num2str(length(pks))])
        else % datamultiply negativie -> low peaks
            Data_BPM{pp,1}.peak_values_low{kk,1} = pks* data_multiply; 
            Data_BPM{pp,1}.peak_locations_low{kk,1} = locs;
            Data_BPM{pp,1}.peak_widths_low{kk,1} = w;
            % disp(['Low Peaks found: ', num2str(length(pks))])
            pks_amount(kk,1) = length(Data_BPM{pp,1}.peak_values_low{kk,1});
        end
        
    end
    try
        disp(['CHECKED, round time: ',num2str(round(toc(tic_round),1)),' s'])
    	if data_multiply > 0 % high peaks
            disp(['High Peaks found: ', num2str(pks_amount')])
        else
            disp(['Low Peaks found: ', num2str(pks_amount')])
        end
        total_time = total_time + toc(tic_round);        
    catch
        disp(['Data read: File#',num2str(index),'/',...
            num2str((DataInfo.files_amount))])
    end

    %%% ending statement
    if index == filenumbers(end) % DataInfo.files_amount
        try 
            disp(['CHECKED total ',num2str(length(filenumbers)),...
                ' files',10,'Total time (min): ',...
             num2str(round(toc(tic_whole_find_peak_loop)/60,1)) ])
            disp('%%%%%%%%%%%%%%%%%%%%%%%')
        catch
            disp('EI TOIMI lopetus')
            disp('ending')
        end
    end
 
end