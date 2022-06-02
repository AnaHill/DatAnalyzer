function plot_signal_with_fpd_parameters(filenumbers,datacolumns,...
    DataInfo, DataPeaks_mean, DataPeaks_summary, hfig)
% function plot_signal_with_fpd_parameters(filenumbers,datacolumns,...
%     DataPeaks_mean, hfig)
narginchk(0,6)
nargoutchk(0,0)

if nargin < 3 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end

if nargin < 1 || isempty(filenumbers)
    filenumbers = randi(DataInfo.files_amount,1);
end

if nargin < 2 || isempty(datacolumns)
    %datacolumns = randi(length(DataInfo.datacol_numbers),1);
    datacolumns = 1:length(DataInfo.datacol_numbers);
end

if nargin < 4 || isempty(DataPeaks_mean)
    try
        DataPeaks_mean = evalin('base', 'DataPeaks_mean');
    catch
        error('No proper DataPeaks_mean')
    end
end

if nargin < 5 || isempty(DataPeaks_summary)
    try
        DataPeaks_summary = evalin('base', 'DataPeaks_summary');
    catch
        error('No proper DataPeaks_summary')
    end
end

if nargin < 6 || isempty(hfig)
    disp('Create new full size figure.')
    create_new_figure = 1;
else
    create_new_figure = 0;
end

for file_index = filenumbers
    if create_new_figure ~= 0
        fig_full % creates hfig
    end
    fs = DataInfo.framerate(file_index);
    for col_index = datacolumns
        data = DataPeaks_mean{file_index, 1}.data(:,col_index);
        time = 0:1/fs:(length(data)-1)/fs;
        end_index_for_data = length(data);
        low_freq = 1500;
        datafil = lowpass(data,low_freq,fs,'ImpulseResponse','iir','Steepness',0.95);
        
        first_peak_index = DataPeaks_summary.peaks{col_index}.firstp_loc(file_index);
        fpd_start_index = DataPeaks_summary.fpd_start_index(file_index, col_index);
        flat_peak_index = DataPeaks_summary.peaks{1,col_index}.flatp_loc(file_index);
        val_flatp = DataPeaks_summary.peaks{1,col_index}.flatp_val(file_index);
        
        peak_end_index = DataPeaks_summary.fpd_end_index(file_index, col_index);
        peak_end_value = DataPeaks_summary.fpd_end_value(file_index, col_index);
                
%         plot(data,'--'),
%         hold all,
%         plot(first_peak_index:end_index_for_data, datafil(first_peak_index:end_index_for_data))
%         scatter(fpd_start_index, data(fpd_start_index),100,'>','filled')
%         scatter(first_peak_index,data(first_peak_index),100,'o','filled')
%         scatter(flat_peak_index,val_flatp,100,'sq','filled')
%         scatter(peak_end_index,peak_end_value,100,'<','filled')
%         axis tight
        
                        
        plot(time, data,'--'), hold all,
        plot(time(first_peak_index:end_index_for_data), datafil(first_peak_index:end_index_for_data))
        scatter(time(fpd_start_index), data(fpd_start_index),100,'>','filled')
        scatter(time(first_peak_index),data(first_peak_index),100,'o','filled')
        scatter(time(flat_peak_index), val_flatp,100,'sq','filled')
        scatter(time(peak_end_index), peak_end_value,100,'<','filled')
        axis tight
        
        
    end

end