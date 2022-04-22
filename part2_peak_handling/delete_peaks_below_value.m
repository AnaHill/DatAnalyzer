function [Data_BPM] = delete_peaks_below_value(Data_BPM,file_index,datacolumns,min_level,high_or_low_peaks)
% [Data_BPM] = delete_peaks_below_value(Data_BPM,file_index,datacolumns,min_level,high_or_low_peaks)
% delete low or high peaks below certain (absolut!) value
    % deleting low peaks (default)
    % deleting high peaks
        
narginchk(3,5)
nargoutchk(1,1)
% set default limit if not given
if nargin < 4 || isempty(min_level)
    min_level = 1.4e-5;
    disp
end

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

if min_level < 5e-4
    disp(['Deleting peaks that are below (abs value) ', num2str(min_level*1e5),'e-5'])
else
    disp(['Deleting peaks that are below (abs value) ', num2str(min_level)])
end

for pp = 1:length(file_index)
    ind = file_index(pp);
    for kk = 1:length(datacolumns)
       col = datacolumns(kk);
       switch high_or_low_peaks 
           case 0 % delete low peak(s) larger than value (negative)
               dat = abs(Data_BPM{ind,1}.peak_values_low{col});
           case 1    
               dat = abs(Data_BPM{ind,1}.peak_values_high{col});
       end
       index_to_delete = find(dat < min_level);
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
           if min_level < 5e-4
               disp(['No peaks below (abs value) ',...
                   num2str(min_level*1e5), 'e-5 to delete.'])
           else
               disp(['No peaks below (abs value) ',...
                   num2str(min_level),' to delete.'])
           end
       end
    end
end
    
end