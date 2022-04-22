function [Data_BPM] = set_main_peaks(Data_BPM,file_index,...
    datacolumns, high_peaks_are_main, signal_type)
% function [Data_BPM] = set_main_peaks(Data_BPM,file_index,datacolumns, high_peaks_are_main, signal_type)
% default: set high peaks as main peaks locations
% Data_BPM = set_main_peaks(Data_BPM,1,[2,4]); 
% Data_BPM = set_main_peaks(Data_BPM,1,[3],0,'low_main_peak'); % low main peaks
narginchk(2,5)
nargoutchk(0,1)
% all data columns (e.g. electrodes)
if nargin < 3 || isempty(datacolumns)
   try
       datacolumns =  1:length(Data_BPM{file_index(1),1}.peak_values_high);
   catch
       try
           datacolumns =  1:length(Data_BPM{file_index(1),1}.peak_values_low);
       catch
           error('no prober peak information found')
       end
   end
           
end
 
% default: set high peaks as main peaks locations
if nargin < 4 || isempty(high_peaks_are_main)
    high_peaks_are_main = 1; 
end
if high_peaks_are_main > 1
    high_peaks_are_main = 1;
    disp(['Setting high peaks to main peaks'])
end
if high_peaks_are_main < 1 % set low peaks as main peaks
    high_peaks_are_main = 0;
    disp(['Setting low peaks to main peaks'])
    signal_type = 'low_main_peak';
end
% default: 
if nargin < 5 || isempty(signal_type)
    signal_type = 'normal_mea';
    disp(['Setting signal type to normal'])
end

for pp = 1:length(file_index)
    ind = file_index(pp);
    for kk = 1:length(datacolumns)
       col = datacolumns(kk);
       % set signal type to normal, fix if needed
       Data_BPM{ind,1}.signal_type{col,1}=signal_type;
       switch high_peaks_are_main 
           % set low peaks as main peaks
           case 0 
               Data_BPM{ind,1}.mainpeak_values{col,1} = ...
                   Data_BPM{ind,1}.peak_values_low{col};
               Data_BPM{ind,1}.mainpeak_locations{col,1} = ...
                   Data_BPM{ind,1}.peak_locations_low{col};
               % Data_BPM{ind,1}.peak_widths_low{col,1};
           % set high peaks as main peaks
           case 1 
               Data_BPM{ind,1}.mainpeak_values{col,1} = ...
                   Data_BPM{ind,1}.peak_values_high{col};
               Data_BPM{ind,1}.mainpeak_locations{col,1} = ...
                   Data_BPM{ind,1}.peak_locations_high{col};
               % Data_BPM{ind,1}.peak_widths_high{col,1};
       end
    end
end
end