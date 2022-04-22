function [Data_BPM] = delete_all_peaks(Data_BPM,index,datacolumns,delete_high_and_low)
% function [Data_BPM] = delete_all_peaks(Data_BPM, index, datacolumns, delete_high_and_low)   
%% TODO: luo turhaan Data_BPM{ind,1}.peak_values_high yms jos niitä ei ole kun poistaa

% delete_all_peaks delete all found peaks from single 
% delete_high_and_low: 
    % 1 -> delete high peaks (default)
    % 0 (or anything below 1) -> delete low peaks
    % 2 (or anything > 1) -> delete high and low peaks
% examples
    % delete all peaks: [Data_BPM] = delete_all_peaks(Data_BPM,1,[],2)

narginchk(2,4)
nargoutchk(0,1)

% all data columns (e.g. electrodes)
if nargin < 3 || isempty(datacolumns)
   try
       datacolumns =  1:length(Data_BPM{index(1),1}.peak_values_high);
   catch
       try
           datacolumns =  1:length(Data_BPM{index(1),1}.peak_values_low);
       catch
           error('no prober peak information found')
       end
   end
           
end
if nargin < 4 || isempty(delete_high_and_low)
    delete_high_and_low = 1; % deleting only high peaks (default)
end

if delete_high_and_low > 1
    delete_high_and_low = 2;
end
if delete_high_and_low < 1
    delete_high_and_low = 0;
end

for pp = 1:length(index)
    ind = index(pp);
    for kk = 1:length(datacolumns)
       col = datacolumns(kk);
       switch delete_high_and_low 
           case 0 % delete low peaks
               Data_BPM{ind,1}.peak_values_low{col} = [];
               Data_BPM{ind,1}.peak_locations_low{col} = [];
               Data_BPM{ind,1}.peak_widths_low{col} = [];
               Data_BPM{ind, 1}.Amount_of_peaks_low(col) = 0;
               try 
                   Data_BPM{ind,1}.antipeak_locations{col} = [];
                   Data_BPM{ind,1}.antipeak_values{col} = [];
               catch                   
               end
               try
                   Data_BPM{ind,1}.peak_avg_distance_in_ms_low(col,:) = NaN;
                   Data_BPM{ind,1}.peak_distances_in_ms_low{col} = [];
                   Data_BPM{ind, 1}.BPM_avg_low(col) = NaN;
                   
               catch                   
               end
           case 1 % delete high peaks
               Data_BPM{ind,1}.peak_values_high{col} = [];
               Data_BPM{ind,1}.peak_locations_high{col} = [];
               Data_BPM{ind,1}.peak_widths_high{col} = [];
               Data_BPM{ind, 1}.Amount_of_peaks_high(col) = 0;
               try 
                   Data_BPM{ind,1}.mainpeak_locations{col} = [];
                   Data_BPM{ind,1}.mainpeak_values{col} = [];

               catch                   
               end
               try
                   Data_BPM{ind,1}.peak_avg_distance_in_ms_high(col,:) = NaN;
                   Data_BPM{ind,1}.peak_distances_in_ms_high{col} = [];
                   Data_BPM{ind, 1}.BPM_avg_high(col) = NaN;
                   
               catch                   
               end               
           case 2 % delete high and low
               Data_BPM{ind,1}.peak_values_high{col} = [];
               Data_BPM{ind,1}.peak_locations_high{col} = [];
               Data_BPM{ind,1}.peak_widths_high{col} = [];
               Data_BPM{ind, 1}.Amount_of_peaks_high(col) = 0;
              
               Data_BPM{ind,1}.peak_values_low{col} = [];
               Data_BPM{ind,1}.peak_locations_low{col} = [];
               Data_BPM{ind,1}.peak_widths_low{col} = [];
               Data_BPM{ind, 1}.Amount_of_peaks_low(col) = 0;
               
                try 
                   Data_BPM{ind,1}.antipeak_locations{col} = [];
                   Data_BPM{ind,1}.antipeak_values{col} = [];

               catch                   
               end
               try 
                   Data_BPM{ind,1}.mainpeak_locations{col} = [];
                   Data_BPM{ind,1}.mainpeak_values{col} = [];

               catch                   
               end               
               try 
                   Data_BPM{ind,1}.flatpeak_locations{col} = [];
                   Data_BPM{ind,1}.flatpeak_values{col} = [];

               catch                   
               end 
               try
                   Data_BPM{ind,1}.peak_avg_distance_in_ms_high(col,:) = NaN;
                   Data_BPM{ind,1}.peak_distances_in_ms_high{col} = [];
                   Data_BPM{ind, 1}.BPM_avg_high(col) = NaN;
                   
               catch
               end
               try
                   Data_BPM{ind,1}.peak_avg_distance_in_ms_low(col,:) = NaN;
                   Data_BPM{ind,1}.peak_distances_in_ms_low{col} = [];
                   Data_BPM{ind, 1}.BPM_avg_low(col) = NaN;
                   
               catch
               end
       end
% % %        % update
% % %        try
% % %             Data_BPM = update_Data_BPM;
% % %         catch
% % %             Data_BPM = update_Data_BPM(DataInfo, Data_BPM, 0); % jos vain alapiikit
% % %         end
    end
end
    
end
