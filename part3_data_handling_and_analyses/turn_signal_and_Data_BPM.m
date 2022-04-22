function [Data,Data_BPM, DataInfo] = turn_signal_and_Data_BPM(Data,Data_BPM, file_index,datacolumns)
% function [Data,Data_BPM, DataInfo] = turn_signal_upside_down(Data,index,datacolumns);
% turns data found in Data{index,1}.data(:,datacolumns) => data = -data
narginchk(0,4)
nargoutchk(0,3)

if nargin < 1 || isempty(Data)
    Data = evalin('base','Data');
end
if nargin < 2 || isempty(Data_BPM)
    Data_BPM = evalin('base','Data_BPM');
end

if nargin < 3 || isempty(file_index)
    file_index = [];
    disp('no file index given -> doing nothing.')
    return
end
file_index = unique(sort(file_index));
if nargin < 4 || isempty(datacolumns)
    datacolumns = 1:min(size(Data{file_index,1}.data));
end

datacolumns = unique(sort(datacolumns));

try
   DataInfo = evalin('base','DataInfo');
catch
   warning('No DataInfo found!') 
end


try
    for pp = 1:length(file_index)
        ind = file_index(pp);
        for kk = 1:length(datacolumns)
           col = datacolumns(kk);
           Data{ind,1}.data(:,col) = -Data{ind,1}.data(:,col);
           try 
               temp = Data_BPM{ind,1}.peak_values_high{col,1};
               Data_BPM{ind,1}.peak_values_high{col,1} = ...
                   Data_BPM{ind,1}.peak_values_low{col,1} * -1;
               Data_BPM{ind,1}.peak_values_low{col,1} = temp * -1;
               
               temp = Data_BPM{ind,1}.peak_locations_high{col,1};
               Data_BPM{ind,1}.peak_locations_high{col,1} = ...
                   Data_BPM{ind,1}.peak_locations_low{col,1};
               Data_BPM{ind,1}.peak_locations_low{col,1} = temp;
               try
                   temp = Data_BPM{ind,1}.peak_widths_high{col,1};
                   Data_BPM{ind,1}.peak_widths_high{col,1} = ...
                       Data_BPM{ind,1}.peak_widths_low{col,1};
                   Data_BPM{ind,1}.peak_widths_low{col,1} = temp;
               catch
                   disp('Data_BPM has no peak widths')
               end
               % turn signal_types
               %TODO: muillakin käännettävillä
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
           catch
               disp('Data_BPM peak signals not found!')
           end
        end
    end
catch
    error('no prober data found')    
end
end