%% Trim signal --> onko juuri tarpeen
datacolumns=1:length(DataInfo.datacol_numbers);
filenumbers = 1:DataInfo.files_amount; %length(DataInfo.datacol_numbers);
for file_ind = filenumbers
    for col_ind = datacolumns
        % get mean data
        % filenumbers=1; datacolumns=1; file_ind = filenumbers;col_ind = datacolumns;
         % data = DataPeaks_mean{file_ind,1}.data(:,col_ind); % figure, plot(data)
         fs = DataInfo.framerate(file_ind);
         % figure, plot(DataPeaks.data{file_ind,col_ind}), hold all, plot(data,'color','k','linewidth',3)
         for peak_locs=1:length(Data_BPM{file_ind, 1}.peak_locations_low{col_ind})
             peak_point = Data_BPM{file_ind, 1}.peak_locations_low{col_ind}(peak_locs);
             peak_value = Data_BPM{file_ind, 1}.peak_values_low{col_ind}(peak_locs);
             value_index = round([-fs fs]/100)+peak_point;
             values = Data{file_ind}.data(value_index(1):value_index(2),col_ind);
             values_mean=movmean(values,10);
%              figure, plot(values,'--'), hold all, plot(values_mean)
            [M,I] = min(values_mean); % [Morg,Iorg] = min(values)
            new_peak_point = value_index(1)+I-1;
            new_peak_value = M;
            % new_peak_value/peak_value * 100
            Data_BPM{file_ind, 1}.peak_locations_low{col_ind}(peak_locs) = ...
                new_peak_point;
            Data_BPM{file_ind, 1}.peak_values_low{col_ind}(peak_locs) = M;
         end
         % fin
    end
    Data_BPM{file_ind, 1}.peak_locations = Data_BPM{file_ind, 1}.peak_locations_low;
    Data_BPM{file_ind, 1}.peak_values = Data_BPM{file_ind, 1}.peak_values_low;
end
