function [Data,Data_BPM, DataInfo] = turn_signal_and_Data_BPM(file_indexes, ...
    datacolumns, Data, DataInfo, Data_BPM)
% function [Data,Data_BPM, DataInfo] = turn_signal_and_Data_BPM(file_indexes, ...
%     datacolumns, Data, DataInfo, Data_BPM)
% turns data found in Data{index,1}.data(:,datacolumns) => data = - data
% same with found peaks if any available in Data_BPM
narginchk(1,5)
nargoutchk(0,3)

if isempty(file_indexes)
    warning('no file indexes given -> doing nothing.')
    return
end
file_indexes = unique(sort(file_indexes));

if nargin < 2 || isempty(datacolumns)
    datacolumns = 1:min(size(Data{file_indexes,1}.data));
end
datacolumns = unique(sort(datacolumns));

if nargin < 3 || isempty(Data)
    try
        Data = evalin('base', 'Data');
        disp('Data read from workspace.')
    catch
        error('No proper Data')
    end
end

if nargin < 4 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
        disp('DataInfo read from workspace.')
    catch
        warning('No DataInfo found!') 
    end
end

if nargin < 5 || isempty(Data_BPM)
    try
        Data_BPM = evalin('base', 'Data_BPM');
        disp('Data_BPM read from workspace.')
    catch
        warning('No Data_BPM found!') 
    end
end

%%
try % test first if Data is available with given file_indexes & datacolumns
    for pp = 1:length(file_indexes)
        for kk = 1:length(datacolumns)
            Data{file_indexes(pp),1}.data(:,datacolumns(kk));
        end
    end
catch
    warning('No prober data found in')
    disp(['File#',num2str(file_indexes(pp)),', col#',num2str(datacolumns(kk))])
    disp('Returning')
    return
end
    
    
for pp = 1:length(file_indexes)
    ind = file_indexes(pp);
    for kk = 1:length(datacolumns)
       col = datacolumns(kk);
       Data{ind,1}.data(:,col) = - Data{ind,1}.data(:,col);
       try % check found high peaks
           temp_high = Data_BPM{ind,1}.peak_values_high{col,1};
           temp_high_loc = Data_BPM{ind,1}.peak_locations_high{col,1};
           try
               temp_high_width = Data_BPM{ind,1}.peak_widths_high{col,1};
           catch
               disp(['No high peak widths in file#',num2str(ind),', col#',num2str(col)])
           end
           is_high_peaks = 'yes';
       catch
           disp(['No high peaks in file#',num2str(ind),', col#',num2str(col)])
           is_high_peaks = 'no';
       end
       try % check found low peaks
           temp_low = Data_BPM{ind,1}.peak_values_low{col,1};
           temp_low_loc = Data_BPM{ind,1}.peak_locations_low{col,1};
           try
               temp_low_width = Data_BPM{ind,1}.peak_widths_low{col,1};
           catch
               disp(['No low peak widths in file#',num2str(ind),', col#',num2str(col)])
           end
           is_low_peaks = 'yes';
       catch
           disp(['No low peaks in file#',num2str(ind),', col#',num2str(col)])
           is_low_peaks = 'no';
       end
       % setting high peaks to low if found
       if strcmp(is_high_peaks,'yes')
           Data_BPM{ind,1}.peak_values_low{col,1} = temp_high * -1;
           Data_BPM{ind,1}.peak_locations_low{col,1} = temp_high_loc;
           try % if low peaks found, set high peak to them (*-1)
               Data_BPM{ind,1}.peak_values_high{col,1} = temp_low * -1;
               Data_BPM{ind,1}.peak_locations_high{col,1} = temp_low_loc;               
           catch
               Data_BPM{ind,1}.peak_values_high{col,1} = [];
               Data_BPM{ind,1}.peak_locations_high{col,1} = [];
           end
           try
               Data_BPM{ind,1}.peak_widths_low{col,1} = temp_high_width;
               try
                   Data_BPM{ind,1}.peak_widths_high{col,1} = temp_low_width;
               catch
                   Data_BPM{ind,1}.peak_widths_high{col,1} = [];
               end
           catch
           end
       end       
       % setting low peaks to high if found
       if strcmp(is_low_peaks,'yes')
           Data_BPM{ind,1}.peak_values_high{col,1} = temp_low * -1;
           Data_BPM{ind,1}.peak_locations_high{col,1} = temp_low_loc;
           try % if high peaks found, set low peak to them (*-1)
               Data_BPM{ind,1}.peak_values_low{col,1} = temp_high * -1;
               Data_BPM{ind,1}.peak_locations_low{col,1} = temp_high_loc;               
           catch
               Data_BPM{ind,1}.peak_values_low{col,1} = [];
               Data_BPM{ind,1}.peak_locations_low{col,1} = [];
           end           
           try
               Data_BPM{ind,1}.peak_widths_high{col,1} = temp_low_width;
               try
                   Data_BPM{ind,1}.peak_widths_low{col,1} = temp_high_width;
               catch
                   Data_BPM{ind,1}.peak_widths_low{col,1} = [];
               end
           catch
           end
       end        
       
       % turn signal_types TODO: other signal types
       try
           if strcmp(DataInfo.signal_types{ind,col},'low_mea')
               DataInfo.signal_types{ind,col} = 'high_mea';
               disp('Low mea type turned to high mea type')
           elseif strcmp(DataInfo.signal_types{ind,col},'high_mea')
               DataInfo.signal_types{ind,col} = 'low_mea';
               disp('High mea type turned to low mea type')
           else
               disp('Not changing signal type')
           end
       catch
           
       end
       clear col temp_high temp_high_loc temp_high_width ...
               temp_low temp_low_loc temp_low_width is_high_peaks is_low_peaks
    end % end kk = 1:length(datacolumns)
end
if ~exist('Data_BPM','var')
    warning('No Data_BPM found --> returning empty Data_BPM')
    Data_BPM = [];
end

end