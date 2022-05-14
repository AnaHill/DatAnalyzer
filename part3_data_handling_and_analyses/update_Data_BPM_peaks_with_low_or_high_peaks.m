function Data_BPM = update_Data_BPM_peaks_with_low_or_high_peaks(file_index, ...
    datacolumn_index, low_or_high_peaks, Data_BPM)
% function Data_BPM = update_Data_BPM_peaks_with_low_or_high_peaks(file_index, ...
%     datacolumn_index, low_or_high_peaks, Data_BPM)

narginchk(2,4)
nargoutchk(0,1)

if length(file_index) ~= 1
   disp('Take first file index')
   file_index = file_index(1);
end

if length(datacolumn_index) ~= 1
   disp('Take first datacolumn index')
   datacolumn_index = datacolumn_index(1);
end

% Default: calculate basic beating rate from "low" peaks
if nargin < 3 || isempty(low_or_high_peaks)
    low_or_high_peaks = 'low';
end

if nargin < 4 || isempty(Data_BPM)
    try
        Data_BPM = evalin('base','Data_BPM');
    catch
        error('No proper Data_BPM')
    end
    
end

% shorter variables for update
kk = file_index;
pp = datacolumn_index;

if strcmp(low_or_high_peaks, 'low')
    Data_BPM{kk,1}.peak_locations{pp,1} = Data_BPM{kk,1}.peak_locations_low{pp,1};
    Data_BPM{kk,1}.peak_values{pp,1} = Data_BPM{kk,1}.peak_values_low{pp,1};       
    Data_BPM{kk,1}.Amount_of_peaks(pp,1) = Data_BPM{kk,1}.Amount_of_peaks_low(pp,1);
    Data_BPM{kk,1}.BPM_avg(pp,1) = Data_BPM{kk,1}.BPM_avg_low(pp,1);
    Data_BPM{kk,1}.peak_avg_distance_in_ms(pp,:) = ...
        Data_BPM{kk,1}.peak_avg_distance_in_ms_low(pp,:);
    Data_BPM{kk,1}.peak_distances_in_ms{pp,1} = Data_BPM{kk,1}.peak_distances_in_ms_low{pp,1};
    try 
        Data_BPM{kk,1}.peak_widths{pp,1} = Data_BPM{kk,1}.peak_widths_low{pp,1};              
    catch
        disp('No low peak widths available')
    end

elseif strcmp(low_or_high_peaks, 'high')% update with high peaks
    Data_BPM{kk,1}.peak_locations{pp,1} = Data_BPM{kk,1}.peak_locations_high{pp,1};   
    Data_BPM{kk,1}.peak_values{pp,1} = Data_BPM{kk,1}.peak_values_high{pp,1};
    Data_BPM{kk,1}.Amount_of_peaks(pp,1) = Data_BPM{kk,1}.Amount_of_peaks_high(pp,1);
    Data_BPM{kk,1}.BPM_avg(pp,1) = Data_BPM{kk,1}.BPM_avg_high(pp,1);
    Data_BPM{kk,1}.peak_avg_distance_in_ms(pp,:) = ...
        Data_BPM{kk,1}.peak_avg_distance_in_ms_high(pp,:);
    Data_BPM{kk,1}.peak_distances_in_ms{pp,1} = ...
        Data_BPM{kk,1}.peak_distances_in_ms_high{pp,1};  
    try 
        Data_BPM{kk,1}.peak_widths{pp,1} = Data_BPM{kk,1}.peak_widths_high{pp,1};              
    catch
        disp('No high peak widths available')
    end
else
    error('Not prober low_or_high_peaks input given!')
end