% finds low peak location and its amplitude (depolarization amplitude)
% gain_for_time_range = 1.5;
time_to_find = [0 abs(DataPeaks.time_range_from_peak(1)*gain_for_time_range)];
%% Low peak find rules
minimiarvot=zeros(DataInfo.files_amount,length(DataInfo.datacol_numbers));
for col_index=1:length(DataInfo.datacol_numbers)
    PeakFindRules{1,col_index} = DataInfo.Rule;
end
for file_index = 1:DataInfo.files_amount
    fs = DataInfo.framerate(file_index);
    time = 0:1/fs:(length(DataPeaks_mean{file_index, 1}.data)-1)/fs;
    index_to_time_to_find = find(time >= max(time_to_find),1,'first');
    % minimum of data from first index to time_to_find index only
    minimiarvot(file_index,:) = min(DataPeaks_mean{file_index, 1}.data...
        (1:index_to_time_to_find,:));
end

minimirajat = (max(minimiarvot,[],1));
for col_index=1:length(DataInfo.datacol_numbers)
    PeakFindRules{1,col_index}.MinPeakValue = abs(minimirajat(col_index))*.9;
end
%% Find low peaks
files_total = 1:DataInfo.files_amount;
datacols_total = DataInfo.datacol_numbers;
DataPeaks_summary = [];
DataPeaks_summary.peaks = [];
DataPeaks_summary.depolarization_amplitude = [];
for col_index = 1:length(datacols_total)
    PeakFindRule = PeakFindRules{1,col_index};
    peaks_summary = [];
    disp(['Datacolumn#',num2str(col_index),'/', num2str(length(datacols_total))])
    disp(['Rules to find peak'])
    for kk = 1:length(files_total)
        file_index = files_total(kk);
        fs = DataInfo.framerate(file_index);
        time = 0:1/fs:(length(DataPeaks_mean{file_index, 1}.data)-1)/fs;
        peaks_ = find_peaks_in_loop_from_time_range(...
            DataPeaks_mean, DataInfo, PeakFindRule, file_index,col_index,-1,time_to_find);
        peaks_{1, 1}.firstp_loc = peaks_{1, 1}.peak_locations_low{1};
        peaks_{1, 1}.firstp_val = peaks_{1, 1}.peak_values_low{1};
        temp{file_index, col_index} = peaks_{1,1};
        clear peaks_
        fpl =  temp{file_index, col_index}.firstp_loc;
        fpv = temp{file_index, col_index}.firstp_val;
        try
            fpl = fpl(1); fpv = fpv(1); 
        catch
            fpl = NaN; fpv = NaN;
        end
        peaks_summary(end+1,:) = [file_index fpl fpv];
        DataPeaks_summary.depolarization_amplitude(file_index, col_index)= fpv;
    end
    DataPeaks_summary.peaks{1,col_index} = array2table(peaks_summary, 'VariableNames',...
        {'file_index','firstp_loc','firstp_val'});          
end