%% Find fpd start from low peaks and calculate depolarization time
% fpd_threshold_percent = 0.1; % threshold from baseline where FPD starts
% low_freq = 150;% low pass filter start freq [Hz]
% low_freq = 1500;
DataPeaks_summary.fpd_start_index = [];
DataPeaks_summary.fpd_start_value = [];
DataPeaks_summary.depolarization_time=[];

for file_index = 1:DataInfo.files_amount
    disp(['Finding fpd start from file#', num2str([file_index]),', ',num2str(length(DataInfo.datacol_numbers)), ' datacolumns'])
    for col_index = 1:length(DataInfo.datacol_numbers)
        % löydetty alapiikki on nyt DataPeaks_summary.peaks{1,col_index}.firstp_loc(file_index)
        % get baseline
        fs = DataInfo.framerate(file_index);
        data = DataPeaks_mean{file_index, 1}.data(:,col_index);
        time = 0:1/fs:(length(data)-1)/fs;
        if all(isnan(data)) % if all nan
            warning(['No DataPeaks_mean in file & datacol #', num2str([file_index, col_index])])
        else
%             disp(['Analyzing file & datacol #', num2str([file_index, col_index])])
            datapoints_for_baseline = round(fs/4*abs(DataPeaks.time_range_from_peak(1)));
            baseline = median(data(1:datapoints_for_baseline,:)); % mean or median?
            peak_amp =  DataPeaks_summary.depolarization_amplitude(file_index, col_index);
            Amp = peak_amp-baseline;
            threshold_value = baseline + fpd_threshold_percent*Amp;
            % peak start: backwards from peak: data_from_firstpeak to start
            first_peak_index = DataPeaks_summary.peaks{col_index}.firstp_loc(file_index);
            datafil = lowpass(data,low_freq,fs,'ImpulseResponse','iir','Steepness',0.95);
            % making backwards
            datafildrop = datafil(first_peak_index:-1:1); % backwards
            ind = find(datafildrop >= threshold_value,1,'first'); 
            peak_start_value = datafildrop(ind);
            peak_start_index = first_peak_index-ind+1; % as ind is steps to backwards
            depolarisation_end_peak_index = DataPeaks_summary.peaks{col_index}.firstp_loc(file_index);
            tdep = (depolarisation_end_peak_index-peak_start_index)/fs;
        end
       
        try
            DataPeaks_summary.fpd_start_index(file_index, col_index) = peak_start_index;
            DataPeaks_summary.fpd_start_value(file_index, col_index) = peak_start_value;
        catch
            DataPeaks_summary.fpd_start_index(file_index, col_index) = NaN;
            DataPeaks_summary.fpd_start_value(file_index, col_index) = NaN;
        end

        try
            DataPeaks_summary.depolarization_time(file_index, col_index) = tdep;
        catch
            DataPeaks_summary.depolarization_time(file_index, col_index) = NaN;
        end

        clear peak_end_index Amp tdep peak_start_index
    end
end

% figure, plot(DataPeaks_summary.depolarization_time*1e3)
% col_index = 1; file_index = 1; data = DataPeaks_mean{file_index}.data(:,col_index);
% fpd_start_ind = DataPeaks_summary.fpd_start_index(file_index, col_index)
% fig_full, plot(data), hold all
% plot(fpd_start_ind, data(fpd_start_ind),'o')
% plot(DataPeaks_summary.peaks{1,col_index}.firstp_loc(file_index),...
%     DataPeaks_summary.peaks{1,col_index}.firstp_val(file_index),'x')
% plot(flat_peak_index, val, 'sq')