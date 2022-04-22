function [Data_BPM] = delete_peaks_with_time(Data_BPM, file_index,...
    datacolumns,time_range,high_or_low_peaks)
% [Data_BPM] = delete_peaks_with_time(Data_BPM, file_index,datacolumns,time_range,high_or_low_peaks)
% if length(time_range ) = 1 -> deleting only the first peak after this time
% Examples
    % deleting low peaks (default)
        % fil = 1; col = 2; time_range = [0.8 1.8]; 
        % temp = delete_peaks_with_time(Data_BPM, fil,col, time_range )
        % PLOT_DataWithPeaks(Data, temp,fil,col,1);
    % deleting high peaks
        % temp = delete_peaks_with_time(temp, fil,col, time_range,1);
        % PLOT_DataWithPeaks(Data, temp,fil,col,1);
    % deleting only one peak after time given
        % time_range2=50; % only one peak, next after this time
        % temp = delete_peaks_with_time(temp, fil,col, time_range2);
        % PLOT_DataWithPeaks(Data, temp,fil,col,1);

narginchk(4,5)
nargoutchk(0,1)
% deleting low peaks (default)
if nargin < 5 || isempty(high_or_low_peaks)
    disp('default: deleting low peak(s)')
    high_or_low_peaks = 0; 
end
if high_or_low_peaks > 1
    high_or_low_peaks = 1;
    disp('deleting high peak(s)')
end
if high_or_low_peaks < 1
    high_or_low_peaks = 0;
    disp('deleting low peak(s)')
end
% update 2021/04: DataInfo.fra,e
% fs = DataInfo.framerate; % now fs in Data
try
    DataInfo = evalin('base','DataInfo');
catch
    error('No DataInfo')
end
% Data = evalin('base','Data');
if isempty(datacolumns)
    datacolumns = 1:length(DataInfo.datacol_numbers);
end
% set time range to min and max values given
if length(time_range) > 1
    time_range = [min(time_range) max(time_range)];
    deleting_info_text = ['Deleting peaks found between t = ',...
               num2str(time_range(1)),'-',num2str(time_range(2)),' sec'];
else
    deleting_info_text = ['Deleting first peak found after t=',...
               num2str(time_range(1)),' sec'];
end
disp(' ')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
switch high_or_low_peaks
    case 0 % low peaks
        del_info_start = ['LOW peaks: '];
        disp(['Deleting low peaks'])
    case 1 % high
        del_info_start = ['HIGH peaks: '];
        disp(['Deleting high peaks'])
end
disp(['File#',num2str(file_index)])
disp(['Datacolumns#',num2str(datacolumns)]);

for pp = 1:length(file_index)
    ind = file_index(pp);
    try
        fs = DataInfo.framerate(ind,1);
    catch % old data where framerate only one file
        fs = DataInfo.framerate(1);
    end    
    
    for kk = 1:length(datacolumns)
       col = datacolumns(kk);
       data_text = ['File#',num2str(ind),', col#',num2str(col),', '];
       switch high_or_low_peaks 
           case 0 % low peaks
               dat = (Data_BPM{ind,1}.peak_locations_low{col})/fs;
           case 1 % high peaks   
               dat = (Data_BPM{ind,1}.peak_locations_high{col})/fs;
       end
       switch length(time_range)
           % if time_range length = 1 --> only one peak deleted
            case 1 % only first peak after time
               index_to_delete = find(dat > time_range,1);
           case 2 % find peaks that are between time range
               index_to_delete = ...
                   find(dat > time_range(1) & dat < time_range(2));
                
       end
       if ~isempty(index_to_delete)
           index_to_delete = reshape(index_to_delete,1,[]);
           disp(deleting_info_text)
           switch high_or_low_peaks 
               case 0 % low peaks
                   Data_BPM{ind,1}.peak_values_low{col}(index_to_delete) = [];
                   Data_BPM{ind,1}.peak_locations_low{col}(index_to_delete) = [];
                   Data_BPM{ind,1}.peak_widths_low{col}(index_to_delete) = [];
                   disp([data_text,'LOW peak(s) deleted: peak(s)#',...
                       10,num2str(index_to_delete)])
               case 1 % delete high peaks
                   Data_BPM{ind,1}.peak_values_high{col}(index_to_delete) = [];
                   Data_BPM{ind,1}.peak_locations_high{col}(index_to_delete) = [];
                   Data_BPM{ind,1}.peak_widths_high{col}(index_to_delete) = [];
                   disp([data_text,'HIGH peak(s) deleted: peak(s)#',...
                       10,num2str(index_to_delete)])
           end
       else
           if length(time_range) > 1
               disp([data_text, del_info_start, 'No peaks found between t=',...
                   num2str(time_range(1)),'-',num2str(time_range(2)),' sec'])
           else
               disp([data_text, del_info_start,...
                   'No peaks found after t=',num2str(time_range(1)),' sec'])
           end
   
       end
    end
end
disp(' ')    
end