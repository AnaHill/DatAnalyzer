function [Data_BPM] = delete_peaks_with_peaknumber(Data_BPM,file_index,...
    datacolumns,peak_numbers_to_delete,high_or_low_peaks)
% [Data_BPM] = delete_peaks_with_peaknumber(Data_BPM,file_index,datacolumns,peak_numbers_to_delete,high_or_low_peaks)
% default: high_or_low_peaks = 0 --> deleting low peaks
% TESTAILU -> katso \TODO_pohjat\TEST_eri_fuktioita.m

narginchk(4,5)
nargoutchk(1,1)
% deleting low peaks (default)
if nargin < 5 || isempty(high_or_low_peaks)
    high_or_low_peaks = 0; 
end

if high_or_low_peaks > 1
    high_or_low_peaks = 1;
end
if high_or_low_peaks < 1
    high_or_low_peaks = 0;
end 

pdel = peak_numbers_to_delete; % shorter term
for pp = 1:length(file_index)
    ind = file_index(pp);
    for kk = 1:length(datacolumns)
       col = datacolumns(kk);
       switch high_or_low_peaks 
           case 0 % delete low peak(s)
               try
                   Data_BPM{ind,1}.peak_values_low{col,1}(pdel) = [];
                   if ~isempty(pdel)
                        disp_text = 'Low peak(s) deleted, peak(s) # ';
                   else
                        disp_text = 'No low peaks to delete. ';
                   end
               catch
                   warning('No chosen low peak values found')
                   disp_text = 'Can not find following low peaks to delete: # ';
               end
               try
                   Data_BPM{ind,1}.peak_locations_low{col,1}(pdel) = [];
               catch
                   warning('No chosen low peak locations found')
               end
               try
                   Data_BPM{ind,1}.peak_widths_low{col,1}(pdel) = [];
               catch
                   warning('no peak_widths_low found')
               end

           case 1 % delete high peaks
               try 
                   Data_BPM{ind,1}.peak_values_high{col,1}(pdel) = [];
                   if ~isempty(pdel)
                       disp_text = 'High peak(s) deleted, peak(s) # ';
                   else
                       disp_text = 'No high peaks to delete.';
                   end
               catch
                   warning('No chosen high peak values found')
                   disp_text = 'Can not find following high peaks to delete: # ';
                   
               end
               try
                   Data_BPM{ind,1}.peak_locations_high{col,1}(pdel) = [];
               catch
                   warning('No chosen high peak locations found')
               end
               try
                   Data_BPM{ind,1}.peak_widths_high{col,1}(pdel) = [];
               catch
                   warning('no peak_widths_high found')
               end               

       end
       try
           disp(['File#', num2str(ind),', datacolumn#',num2str(col),': ', disp_text,num2str(pdel)]) % if pdel = row vector
       catch
           disp(['File#', num2str(ind),', datacolumn#',num2str(col),': ', disp_text,num2str(pdel')]) % if column
       end
       
       
       
    end
end
    
end
