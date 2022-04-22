function [Data_BPM] = delete_peaks_above_value(Data_BPM,file_index,datacolumns,max_level,high_or_low_peaks)
% [Data_BPM] = delete_peaks_above_value(Data_BPM,file_index,datacolumns,max_level,high_or_low_peaks)
% delete low or high peaks above certain (absolut!) value

narginchk(4,5)
nargoutchk(1,1)

% default: deleting low peaks
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

if max_level < 1e-3
    disp(['Deleting peaks that are above (abs value) ', num2str(max_level*1e5),'e-5'])
else
    disp(['Deleting peaks that are above (abs value) ', num2str(max_level)])
end



for pp = 1:length(file_index)
    ind = file_index(pp);
    for kk = 1:length(datacolumns)
       col = datacolumns(kk);
       switch high_or_low_peaks 
           case 0 % low peaks
               dat = abs(Data_BPM{ind,1}.peak_values_low{col});
           case 1 % high peaks   
               dat = abs(Data_BPM{ind,1}.peak_values_high{col});
       end
       index_to_delete = find(dat > max_level);
       disp(['File#',num2str(ind),', datacolumn#',num2str(col)])
       if ~isempty(index_to_delete)
           switch high_or_low_peaks 
               case 0 % low peaks
               Data_BPM{ind,1}.peak_values_low{col}(index_to_delete) = [];
               Data_BPM{ind,1}.peak_locations_low{col}(index_to_delete) = [];
               try
                   Data_BPM{ind,1}.peak_widths_low{col}(index_to_delete) = [];
               catch
                   % disp('No low peak widths available')
               end  
               disp(['Low peaks deleted, peak # ',num2str(index_to_delete(:)')])
           case 1 % delete high peaks
               Data_BPM{ind,1}.peak_values_high{col}(index_to_delete) = [];
               Data_BPM{ind,1}.peak_locations_high{col}(index_to_delete) = [];
               try
                   Data_BPM{ind,1}.peak_widths_high{col}(index_to_delete) = [];
               catch
                   % disp('No high peak widths available')
               end
               disp(['High peaks deleted, peak # ',num2str(index_to_delete(:)')])
               
           end
       else
           if max_level < 1e-3
               disp(['No peaks above (abs value) ',...
                   num2str(max_level*1e5), 'e-5 to delete.'])
           else
               disp(['No peaks above (abs value) ',...
                   num2str(max_level),' to delete.'])
           end
       end
    end
end
    
end