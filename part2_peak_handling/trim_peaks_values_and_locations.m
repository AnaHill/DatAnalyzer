function Data_BPM = trim_peaks_values_and_locations(filenumbers, datacolumns,...
    DataInfo, Data, Data_BPM)
% function Data_BPM = trim_peaks_values_and_locations(filenumbers, datacolumns, ...
% DataInfo, Data, Data_BPM)
%%% TODO: now only low peaks!

narginchk(0,5)
nargoutchk(0,1)

if nargin < 3 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end
if nargin < 1 || isempty(filenumbers)
    filenumbers = 1:DataInfo.files_amount; 
end
if nargin < 2 || isempty(datacolumns)
    datacolumns = 1:length(DataInfo.datacol_numbers);
end

if nargin < 4 || isempty(Data)
    try
        Data = evalin('base', 'Data');
    catch
        error('No proper Data')
    end    
end


if nargin < 5 || isempty(Data_BPM)
    try
        Data_BPM = evalin('base', 'Data_BPM');
    catch
        error('No proper Data_BPM')
    end    
end

if nargout < 1 || isempty(Data_BPM)
    warning('Data_BPM not updated!')
end

for file_ind = filenumbers
    for col_ind = datacolumns
         fs = DataInfo.framerate(file_ind);
         for peak_locs=1:length(Data_BPM{file_ind, 1}.peak_locations_low{col_ind})
             peak_point = Data_BPM{file_ind, 1}.peak_locations_low{col_ind}(peak_locs);
             peak_value = Data_BPM{file_ind, 1}.peak_values_low{col_ind}(peak_locs);
             value_index = round([-fs fs]/100)+peak_point;
             values = Data{file_ind}.data(value_index(1):value_index(2),col_ind);
             values_mean=movmean(values,10);
             [M,I] = min(values_mean); % [Morg,Iorg] = min(values)
             new_peak_point = value_index(1)+I-1;
             new_peak_value = M;
             Data_BPM{file_ind, 1}.peak_locations_low{col_ind}(peak_locs) = ...
                 new_peak_point;
             Data_BPM{file_ind, 1}.peak_values_low{col_ind}(peak_locs) = M;
         end
    end
    Data_BPM{file_ind, 1}.peak_locations = Data_BPM{file_ind, 1}.peak_locations_low;
    Data_BPM{file_ind, 1}.peak_values = Data_BPM{file_ind, 1}.peak_values_low;
end