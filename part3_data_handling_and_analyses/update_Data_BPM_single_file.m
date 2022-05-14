function Data_BPM = update_Data_BPM_single_file(filenums, datacols, ...
    using_high_peaks,DataInfo, Data_BPM)
% function Data_BPM = update_Data_BPM_single_file(filenums, datacols, ...
% using_high_peaks,DataInfo, Data_BPM)
% function Data_BPM = update_Data_BPM_single_file(filenums, datacols, 0)

narginchk(2,5)
nargoutchk(0,1)

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

if nargin < 4 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end

if nargin < 5 || isempty(Data_BPM)
    try
        Data_BPM = evalin('base','Data_BPM');
    catch
        error('No proper Data_BPM')
    end
end


%% Update some DataInfo if not exist
DataInfo = update_DataInfo(DataInfo);

%% Update Data_BPM
% howmanydatacolumns = length(datacols);
using_high_peaks_count = 0;
name_files_for_high_peak_index = {};

% for ii = 1:length(filenums)
% file_index = filenums(ii);
for file_index = filenums
    if ~isfield(Data_BPM{file_index,1},'file_index')
        Data_BPM{file_index,1}.file_index = file_index;
    end
    try
        fs = DataInfo.framerate(file_index,1);
    catch % old data where framerate only one file
        fs = DataInfo.framerate(1);
    end
    % for pp = 1:howmanydatacolumns
    for datacol_index = datacols
        try
            % low peaks
            pks = Data_BPM{file_index,1}.peak_locations_low{datacol_index};
            peak_times=(pks-1)/fs;
            dist_ms = diff(peak_times) * 1e3;
            dist_avg_ms = [mean(dist_ms) std(dist_ms)];
            BPM_avg = 1/(dist_avg_ms(1)/1000) * 60;
            % updating Data_BPM -> low
            Data_BPM{file_index,1}.Amount_of_peaks_low(datacol_index,1) = length(pks);
            Data_BPM{file_index,1}.peak_distances_in_ms_low{datacol_index,1} = dist_ms;
            Data_BPM{file_index,1}.peak_avg_distance_in_ms_low(datacol_index,:) = dist_avg_ms;
            Data_BPM{file_index,1}.BPM_avg_low(datacol_index,1) = BPM_avg;
        catch
%             disp('no low peaks')
        end
            
            
        try 
            % high peaks
            pks = Data_BPM{file_index,1}.peak_locations_high{datacol_index};
            peak_times = (pks-1)/fs;
            dist_ms = diff(peak_times) * 1e3;
            dist_avg_ms = [mean(dist_ms) std(dist_ms)];
            BPM_avg = 1/(dist_avg_ms(1)/1000) * 60;
            % updating Data_BPM -> high
            Data_BPM{file_index,1}.Amount_of_peaks_high(datacol_index,1) = length(pks);
            Data_BPM{file_index,1}.peak_distances_in_ms_high{datacol_index,1} = dist_ms;
            Data_BPM{file_index,1}.peak_avg_distance_in_ms_high(datacol_index,:) = dist_avg_ms;
            Data_BPM{file_index,1}.BPM_avg_high(datacol_index,1) = BPM_avg;
        catch
%             disp('no high peaks')
        end
        
        %%% Checking if low or high peak is used to "define" BPM etc
        try 
            % Default: basic beating rate from "low" peaks
%             Data_BPM{file_index,1}.peak_locations{datacol_index,1} = Data_BPM{file_index,1}.peak_locations_low{datacol_index,1};
%             Data_BPM{file_index,1}.peak_values{datacol_index,1} = Data_BPM{file_index,1}.peak_values_low{datacol_index,1};       
%             Data_BPM{file_index,1}.Amount_of_peaks(datacol_index,1) = Data_BPM{file_index,1}.Amount_of_peaks_low(datacol_index,1);
%             Data_BPM{file_index,1}.BPM_avg(datacol_index,1) = Data_BPM{file_index,1}.BPM_avg_low(datacol_index,1);
%             Data_BPM{file_index,1}.peak_avg_distance_in_ms(datacol_index,:) = ...
%                 Data_BPM{file_index,1}.peak_avg_distance_in_ms_low(datacol_index,:);
%             Data_BPM{file_index,1}.peak_distances_in_ms{datacol_index,1} = Data_BPM{file_index,1}.peak_distances_in_ms_low{datacol_index,1};
%             try 
%                 Data_BPM{file_index,1}.peak_widths{datacol_index,1} = Data_BPM{file_index,1}.peak_widths_low{datacol_index,1};              
%             catch
% %                 disp('No low peak widths available')
%             end
            Data_BPM = update_Data_BPM_peaks_with_low_or_high_peaks(file_index,datacol_index, 'low', Data_BPM);
            % function Data_BPM = update_Data_BPM_peaks_with_low_or_high_peaks(file_index, ...
            %     datacolumn_index, low_or_high_peaks, Data_BPM)   
        catch
%             disp('no low peaks')
        end
        % checking if high peaks should be used
        % using_high_peaks: > 0 always using high peaks, 0=always low peaks, -1=check which one
        if using_high_peaks < 0 % check
            use_high_peaks = should_high_peak_data_be_used(Data_BPM{file_index,1},datacol_index);
            % function [use_high_peaks] = should_high_peak_data_be_used(data,elcol,high_peaks_ratio_to_low_peaks)
            % high_peaks_ratio_to_low_peaks is optional, default = 0.8
        end
        name_file = DataInfo.file_names{file_index,1}(1:end-3);
        try
            datacol_name = ['Ele#',...
                num2str(DataInfo.MEA_electrode_numbers(datacol_index))];
        catch
            datacol_name = ['Data col#',...
                num2str(DataInfo.datacol_numbers(datacol_index))];
        end
        time_exp_name = DataInfo.measurement_time.names{file_index};
        % TODO: tarvitaanko alla olevaa, ei tuo juuri hyötyä
%         disp([name_file,' -> ', time_exp_name,' - ',datacol_name]);
        if use_high_peaks == 1
            name_files_for_high_peak_index{end+1,1} = ...
                [name_file,' -> ', time_exp_name,10,datacol_name];
            name_files_for_high_peak_index{end,2} = [file_index];
            disp('Current Data_BPM values changed to data from high peaks')
%             Data_BPM{file_index,1}.peak_locations{datacol_index,1} = Data_BPM{file_index,1}.peak_locations_high{datacol_index,1};   
%             Data_BPM{file_index,1}.peak_values{datacol_index,1} = Data_BPM{file_index,1}.peak_values_high{datacol_index,1};
%             Data_BPM{file_index,1}.Amount_of_peaks(datacol_index,1) = Data_BPM{file_index,1}.Amount_of_peaks_high(datacol_index,1);
%             Data_BPM{file_index,1}.BPM_avg(datacol_index,1) = Data_BPM{file_index,1}.BPM_avg_high(datacol_index,1);
%             Data_BPM{file_index,1}.peak_avg_distance_in_ms(datacol_index,:) = ...
%                 Data_BPM{file_index,1}.peak_avg_distance_in_ms_high(datacol_index,:);
%             Data_BPM{file_index,1}.peak_distances_in_ms{datacol_index,1} = ...
%                 Data_BPM{file_index,1}.peak_distances_in_ms_high{datacol_index,1};  
%             try 
%                 Data_BPM{file_index,1}.peak_widths{datacol_index,1} = Data_BPM{file_index,1}.peak_widths_high{datacol_index,1};              
%             catch
% %                 disp('No high peak widths available')
%             end
            Data_BPM = update_Data_BPM_peaks_with_low_or_high_peaks(file_index,datacol_index, 'high', Data_BPM);
            % function Data_BPM = update_Data_BPM_peaks_with_low_or_high_peaks(file_index, ...
            %     datacolumn_index, low_or_high_peaks, Data_BPM)

            try
                name_files_for_high_peak_index{end,3}  = ...
                    num2str(DataInfo.MEA_electrode_numbers(datacol_index));                
            catch
                name_files_for_high_peak_index{end,3} = ...
                    DataInfo.datacol_numbers(datacol_index);
            end   
        
            using_high_peaks_count = using_high_peaks_count + 1;
        end
        try
%             disp(['Using high peaks to count average values: ',...
%                 num2str(using_high_peaks_count), '/',num2str(DataInfo.files_amount...
%                 *howmanydatacolumns) , ' times',10,'%%%%%%%%%%%',10]);
        catch
            
        end
    end
end
