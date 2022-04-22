function [Data_BPM] = find_peaks_in_loop(Data, DataInfo, Rule, ...
    filenumbers, datacolumns, data_multiply) % TODO: gmin arvot
% find_peaks_in_loop(Data, DataInfo)
% FIND_PEAKS_IN_LOOP find peaks 
% Rule should have
    % .FrameRate
    % .MaxBPM
    % .MinPeakValue
    % TODO: katso miten kalsiumkuvantamisdatan kanssa menee
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
narginchk(2,6) 
nargoutchk(0,1)

% set defaults if not all function inputs are given
if nargin < 3 || isempty(Rule)
    disp('Check if DataInfo has rules, ask to used them or not')
    use_datainfo_rule = 0;
    if isfield(DataInfo, 'Rule')
        disp('TODO: ask if using rules found in DataInfo')
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
%% TODO: find peaks_in loop
disp(['Finding peaks from Data: ',DataInfo.experiment_name,...
    '_',DataInfo.measurement_name,10, ...
    'Number of data/electrodes: ',num2str(length(datacolumns))])
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
Data_peaks = [];
tic_whole_find_peak_loop = tic;
for pp = 1:length(filenumbers)
    % index = 1;
    index = filenumbers(pp);
    tic_round = tic;  
    % if data_multiply == -1 -> raw_data*-1 --> finding low peaks
    raw_data = Data{index,1}.data * data_multiply;
    % figure, plot(raw_data)
    disp(['Checking file #',num2str(index),'/',num2str(length(filenumbers))])
    for kk = 1:length(datacolumns)
        col = datacolumns(kk); 
        dataToCheck = raw_data(:,col);
        % negative values set to zero for peak finding
        dataToCheck(dataToCheck < 0) = 0;
%         [pks, locs, w] = findpeaks();%TODO: jos findpeaks käyttäisi
        % last input parameter false -> not include endpoints peaks
        % no interpolation used
        sele = [];
        threshold = min_peak_value;
        [locs, pks] = peakfinder(dataToCheck, sele, threshold, [], false);
        % function [loc, mag]= ...
        % peakfinder(x0, sel, thresh, extrema, includeEndpoints, interpolate)
        
        if data_multiply > 0 % high peaks
            Data_BPM{pp,1}.peak_values_high{kk,1} = pks; 
            Data_BPM{pp,1}.peak_locations_high{kk,1} = locs;
%             Data_BPM{index,1}.peak_widths_high = w;
        else % datamultiply negativie -> low peaks
            Data_BPM{pp,1}.peak_values_low{kk,1} = pks; 
            Data_BPM{pp,1}.peak_locations_low{kk,1} = locs;
        end
        
        %% TEE
% % %         dat = Data{kk,1}.data(:,pp);
% % % %         gmin_abs_high = peaks_to_change(kk,3);
% % % %         gmin_abs_low = peaks_to_change(kk,4);
% % %         [Data_peaks_high_and_low] = find_peaks_low_and_high(dat,Rule,DataInfo,...
% % %             gmin_abs_high,gmin_abs_low,min_peak_width);
% % function [Data_peaks] = find_peaks_low_and_high(ChannelData,Rule,info,gmin_abs_high, gmin_abs_low, min_peak_width)
% % %         Data_peaks{kk,1}.peak_locations_high{pp,1} = Data_peaks_high_and_low.peak_locations_high;
% % %         Data_peaks{kk,1}.peak_locations_low{pp,1} = Data_peaks_high_and_low.peak_locations_low;
% % %         clear Data_peaks_high_and_low dat 
    end
    %% TODO: päivitä
    try
%         disp(['High / Low Peaks found: ', num2str(length(peak_values_high)),...
%     ' / ', num2str(length(peak_values_low))])
    

        disp(['peak find: File#',num2str(index),'/',...
            num2str((DataInfo.files_amount)),...
            ', time: ',num2str(round(toc(tic_round),1)),'s'])
        disp(['File #',num2str(kk),'/',num2str(length(Data)),...
        ' checked, round time (s): ',num2str(round((toc(tic_file_round))))])
    	total_time = total_time + tic_file_round;
        
    catch
        disp(['MEA data read: File#',num2str(index),'/',...
            num2str((DataInfo.files_amount))])
    end

    %%% ending statement
    if index == DataInfo.files_amount
        try %%TODO:
            disp(['All files #',num2str(length(Data)),'/',num2str(length(Data)),...
            ' checked, total time (min): ',num2str(round(total_time/60))])

        disp(['Peaks find from ',num2str(DataInfo.files_amount),...
            ' files, total time: ',num2str(round(toc(tic_whole_find_peak_loop),0)),'s'])
    % % %     for kk = 1: length(Data_peaks)
    % % %         DatBPM{kk,1}.experiment_name = DataInfo.experiment_name;
    % % %         DatBPM{kk,1}.measurement_name = DataInfo.measurement_name;
    % % %         DatBPM{kk,1}.measurement_time = Data{kk,1}.measurement_time;
    % % %         DatBPM{kk,1}.filename = Data{kk,1}.filename;
    % % %         DatBPM{kk,1}.Peak_rules = Rule;
    % % %         DatBPM{kk,1}.peak_locations_high =  Data_peaks{kk,1}.peak_locations_high;
    % % %         DatBPM{kk,1}.peak_locations_low =  Data_peaks{kk,1}.peak_locations_low;
    % % %     end


        catch
            disp('ending')
        end
    end
    
    
    

end