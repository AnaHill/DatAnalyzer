function [DataPeaks_summary] = fpd_fpstart_and_depolarization_times(fpd_threshold_percent,...
    low_freq, filenumbers, datacolumns, ...
    DataInfo, DataPeaks, DataPeaks_mean, DataPeaks_summary)
% function [DataPeaks_summary] = fpd_fpstart_and_depolarization_times(fpd_threshold_percent,...
%     low_freq, filenumbers, datacolumns, ...
%     DataInfo, DataPeaks, DataPeaks_mean, DataPeaks_summary)
narginchk(0,8)
nargoutchk(0,1)

% default threshold: 0.1
if nargin < 1 || isempty(fpd_threshold_percent)
    fpd_threshold_percent = 0.1;
end

% default low pass filter start freq: 1500 Hz
if nargin < 2 || isempty(fpd_threshold_percent)
    low_freq = 1500;
end


if nargin < 5 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end

if nargin < 4 || isempty(filenumbers)
    filenumbers = 1:DataInfo.files_amount; 
end
if nargin < 4 || isempty(datacolumns)
    datacolumns = 1:length(DataInfo.datacol_numbers);
end

if nargin < 6 || isempty(DataPeaks)
    try
        DataPeaks = evalin('base', 'DataPeaks');
    catch
        error('No proper DataPeaks')
    end    
end


if nargin < 7 || isempty(DataPeaks_mean)
    try
        DataPeaks_mean = evalin('base', 'DataPeaks_mean');
    catch
        error('No proper DataPeaks_mean')
    end    
end

if nargin < 8 || isempty(DataPeaks_summary)
    try
        DataPeaks_summary = evalin('base', 'DataPeaks_summary');
    catch
        error('No proper DataPeaks_summary')
    end    
end

if nargout < 1 % || isempty(DataPeaks_summary)
    warning('DataPeaks_summary will not be updated!')
end
%%

for file_index = filenumbers % 1:DataInfo.files_amount
    disp(['Finding fpd start from file#', num2str([file_index]),', ',...
        num2str(length(datacolumns)), ' datacolumns'])
    for col_index = datacolumns % 1:length(DataInfo.datacol_numbers)
        % found low peak in DataPeaks_summary.peaks{1,col_index}.firstp_loc(file_index)
        % get baseline
        fs = DataInfo.framerate(file_index);
        data = DataPeaks_mean{file_index, 1}.data(:,col_index);
        time = 0:1/fs:(length(data)-1)/fs;
        if all(isnan(data)) % if all nan
            warning(['No DataPeaks_mean in file & datacol #', num2str([file_index, col_index])])
        else
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



end