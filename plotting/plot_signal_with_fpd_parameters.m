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
    fig_full % creates hfig
end


first_peak_index = DataPeaks_summary.peaks{col_index}.firstp_loc(file_index);


plot(DataPeaks_mean{file_index, 1}.data(:,col_index),'--'),
hold all,plot(first_peak_index:end_index_for_data, datafil)
scatter(fpd_start_index, data_all(fpd_start_index),100,'>','filled')
scatter(first_peak_index,data_all(first_peak_index),100,'o','filled')
scatter(flat_peak_index,val_flatp,100,'sq','filled')
scatter(peak_end_index,peak_end_value,100,'<','filled')


end