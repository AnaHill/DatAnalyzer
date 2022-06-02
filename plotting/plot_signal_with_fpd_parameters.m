function plot_signal_with_fpd_parameters(filenumbers,datacolumns,...
    DataInfo, DataPeaks_mean, DataPeaks_summary, hfig)
% function plot_signal_with_fpd_parameters(filenumbers,datacolumns,...
%     DataPeaks_mean, hfig)
% plot random file, all datacolums
    % plot_signal_with_fpd_parameters
% plot spesific signals, e.g. file indexes 1,5 & 7 and datacolumns 1,3
    % plot_signal_with_fpd_parameters([1,5,7],[1,3])
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

% figure properties
data_multiply = 1; % data in V
time_multiply = 1; % time in s
% 
% data_multiply = 1e3; % data in mV
% time_multiply = 1e3; % time in ms
legs = {}; hplots = []; 
title_text = ['File#',num2str(filenumbers(1))];
for file_index = filenumbers
    if create_new_figure ~= 0
        fig_full % creates hfig
        legs = {};
    end
    fs = DataInfo.framerate(file_index);
    for col_index = datacolumns
        try 
            legs{end+1,1} = ['MEA ele#',num2str(DataInfo.MEA_electrode_numbers(col_index))];
        catch
            legs{end+1,1} = ['Datacolumn#',num2str(col_index)];
        end
        data = DataPeaks_mean{file_index, 1}.data(:,col_index)*data_multiply;
        peak_end_index = DataPeaks_summary.fpd_end_index(file_index, col_index);
        peak_end_value = DataPeaks_summary.fpd_end_value(file_index, col_index);
        time = [0:1/fs:(length(data)-1)/fs]*time_multiply;
        
        
        low_freq = 1500; % TODO paremmin
        datafil = lowpass(data,low_freq,fs,'ImpulseResponse','iir','Steepness',0.95);
        
        first_peak_index = DataPeaks_summary.peaks{col_index}.firstp_loc(file_index);
        fpd_start_index = DataPeaks_summary.fpd_start_index(file_index, col_index);
        flat_peak_index = DataPeaks_summary.peaks{1,col_index}.flatp_loc(file_index);
        flat_peak_value = DataPeaks_summary.peaks{1,col_index}.flatp_val(file_index)*data_multiply;
        

                        
        hplots(end+1,1) = plot(time, data,'--'); hold all,
        color_index_current = get(gca,'ColorOrderIndex');
        plot(time(first_peak_index:end), datafil(first_peak_index:end),'color',[0.4 0.4 0.4])
        set(gca,'ColorOrderIndex',color_index_current-1)
        scatter(time(fpd_start_index), data(fpd_start_index),100,'>','filled')
        set(gca,'ColorOrderIndex',color_index_current-1)
        scatter(time(first_peak_index),data(first_peak_index),100,'o','filled')
        set(gca,'ColorOrderIndex',color_index_current-1)
        scatter(time(flat_peak_index), flat_peak_value,100,'sq','filled')
        set(gca,'ColorOrderIndex',color_index_current-1)
        scatter(time(peak_end_index), peak_end_value,100,'<','filled')
        axis tight
        if time_multiply == 1e3
            xlabel('Time (msec)')
        else
            xlabel('Time (sec)')
        end
        if data_multiply == 1e3
            ylabel('Measurement (mV)')
        else
            ylabel('Measurement (V)')
        end
        
        
    end
    title(title_text), grid on
    legend(hplots,legs,'interpreter','none')
end