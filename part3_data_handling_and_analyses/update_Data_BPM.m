function Data_BPM = update_Data_BPM(DataInfo, Data_BPM, using_high_peaks)
% function Data_BPM = update_Data_BPM(DataInfo, Data_BPM, using_high_peaks)
% function Data_BPM = update_Data_BPM(DataInfo, Data_BPM, 0)

narginchk(0,3)
nargoutchk(0,1)

if nargin < 1 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end

if nargin < 2 || isempty(Data_BPM)
    try
        Data_BPM = evalin('base','Data_BPM');
    catch
        error('No proper Data_BPM')
    end
end

% default: using_high_peaks = -1 --> check which if low or high peaks are used
% to define parameters in Data_BPM
if nargin < 3 || isempty(using_high_peaks)
    using_high_peaks = -1;
else % if given something > 0, always using high peaks, and if < 0, low peaks
    % if given using_high_peaks == 0
    if using_high_peaks > 0
        using_high_peaks = 1; % always high peaks used
    elseif using_high_peaks < 0
        using_high_peaks = 0; % always low peaks used
    end
end

if using_high_peaks > 0 % always high
    use_high_peaks = 1;
elseif using_high_peaks == 0 % always low
    use_high_peaks = 0;
end

%% Update some DataInfo if not exist
DataInfo = update_DataInfo(DataInfo);
%% Update Data_BPM
try
    howmanydatacolumns = length(DataInfo.datacol_numbers);
catch
    Data = evalin('base','Data');
    howmanydatacolumns = length(Data{1,1}.data(1,:));
end
name_files_for_high_peak_index = {};

using_high_peaks_count = 0;
for kk = 1:length(Data_BPM)
    Data_BPM{kk,1}.file_index = kk;
    try
        fs = DataInfo.framerate(kk,1);
    catch % old data where framerate only one file
        fs = DataInfo.framerate(1);
    end
    for pp = 1:howmanydatacolumns
        try
            % low peaks
            pks = Data_BPM{kk,1}.peak_locations_low{pp};
            peak_times=(pks-1)/fs;
            dist_ms = diff(peak_times) * 1e3;
            dist_avg_ms = [mean(dist_ms) std(dist_ms)];
            BPM_avg = 1/(dist_avg_ms(1)/1000) * 60;
            % updating Data_BPM -> low
            Data_BPM{kk,1}.Amount_of_peaks_low(pp,1) = length(pks);
            Data_BPM{kk,1}.peak_distances_in_ms_low{pp,1} = dist_ms;
            Data_BPM{kk,1}.peak_avg_distance_in_ms_low(pp,:) = dist_avg_ms;
            Data_BPM{kk,1}.BPM_avg_low(pp,1) = BPM_avg;
        catch
            disp('no low peaks')
        end
            
            
        try 
            % high peaks
            pks = Data_BPM{kk,1}.peak_locations_high{pp};
            peak_times = (pks-1)/fs;
            dist_ms = diff(peak_times) * 1e3;
            dist_avg_ms = [mean(dist_ms) std(dist_ms)];
            BPM_avg = 1/(dist_avg_ms(1)/1000) * 60;
            % updating Data_BPM -> high
            Data_BPM{kk,1}.Amount_of_peaks_high(pp,1) = length(pks);
            Data_BPM{kk,1}.peak_distances_in_ms_high{pp,1} = dist_ms;
            Data_BPM{kk,1}.peak_avg_distance_in_ms_high(pp,:) = dist_avg_ms;
            Data_BPM{kk,1}.BPM_avg_high(pp,1) = BPM_avg;
        catch
            disp('no high peaks')
        end
        
        %%% Checking if low or high peak is used to "define" BPM etc
        try 
            % Default: basic beating rate from "low" peaks
            Data_BPM = update_Data_BPM_peaks_with_low_or_high_peaks(kk,pp, 'low', Data_BPM);
            % update_Data_BPM_peaks_with_low_or_high_peaks(file_index, datacolumn_index, low_or_high_peaks, Data_BPM)
        catch
            disp('no low peaks')
        end
        % checking if high peaks should be used
        % using_high_peaks > 0 always using high peaks, 0=always low peaks, -1=check which one
        if using_high_peaks < 0 % if below 0, check which one used
            use_high_peaks = should_high_peak_data_be_used(Data_BPM{kk,1},pp);
            % function [use_high_peaks] = should_high_peak_data_be_used(data,elcol,high_peaks_ratio_to_low_peaks)
            % high_peaks_ratio_to_low_peaks is optional, default = 0.8
        end
        name_file = DataInfo.file_names{kk,1}(1:end-3);
        try
            datacol_name = ['Ele#',...
                num2str(DataInfo.MEA_electrode_numbers(pp))];
        catch
            datacol_name = ['Data col#',...
                num2str(DataInfo.datacol_numbers(pp))];
        end
        time_exp_name = DataInfo.measurement_time.names{kk};
        disp([name_file,' -> ', time_exp_name,' - ',datacol_name]);
        if use_high_peaks == 1
            name_files_for_high_peak_index{end+1,1} = ...
                [name_file,' -> ', time_exp_name,10,datacol_name];
            name_files_for_high_peak_index{end,2} = [kk];
            disp('Current Data_BPM values changed to data from high peaks')
            Data_BPM = update_Data_BPM_peaks_with_low_or_high_peaks(kk,pp, 'high', Data_BPM);
            % update_Data_BPM_peaks_with_low_or_high_peaks(file_index, datacolumn_index, low_or_high_peaks, Data_BPM)
            try
                name_files_for_high_peak_index{end,3}  = ...
                    num2str(DataInfo.MEA_electrode_numbers(pp));                
            catch
                name_files_for_high_peak_index{end,3} = ...
                    DataInfo.datacol_numbers(pp);
            end   
        
            using_high_peaks_count = using_high_peaks_count + 1;
        end
        try
            disp(['Using high peaks to count average values: ',...
                num2str(using_high_peaks_count), '/',num2str(DataInfo.files_amount...
                *howmanydatacolumns) , ' times',10,'%%%%%%%%%%%',10]);
        catch
            
        end
    end
end
