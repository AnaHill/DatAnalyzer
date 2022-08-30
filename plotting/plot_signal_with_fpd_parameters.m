function [legs, hplots] = plot_signal_with_fpd_parameters(filenumbers, datacolumns,...
    hfig, multiply_data, previous_legends, previous_hplots, ...
    DataInfo, DataPeaks_mean, DataPeaks_summary)
% function [legs, hplots] = plot_signal_with_fpd_parameters(filenumbers, datacolumns,...
%     hfig, multiply_data, previous_legends, previous_hplots, ...
%     DataInfo, DataPeaks_mean, DataPeaks_summary)
% Examples
% plot random file, all datacolums
    % plot_signal_with_fpd_parameters;
% plot spesific signals, e.g. file indexes 1,5 & 7 and datacolumns 1,3
    % plot_signal_with_fpd_parameters([1,5,7],[1,3]);
% plot specific signal so that time = sec and data = original
    % plot_signal_with_fpd_parameters(4,[],[],0)
% plot a specific signal to previous figure (to current figure), e.g. 
    % [legs,hplots] = plot_signal_with_fpd_parameters(1,2), hold all, plot_signal_with_fpd_parameters(2,2,gcf, [], legs,hplots)
%  [legs,hplots] = plot_signal_with_fpd_parameters(22,[2,4]); hold all, plot_signal_with_fpd_parameters(5,3,gcf, [], legs,hplots);
% plot same electrode on different time/file instances
% [legs,hplots] = plot_signal_with_fpd_parameters(1,1);hold all,[legs,hplots] = plot_signal_with_fpd_parameters(10,1,gcf, [], legs,hplots);[legs,hplots] = plot_signal_with_fpd_parameters(22,1,gcf, [], legs,hplots);

max_inputs = 9;    
narginchk(0,max_inputs)
nargoutchk(0,2)

% reading from workspace if not given: DataInfo, DataPeaks_mean, DataPeaks_summary)
if nargin < max_inputs - 2 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
        disp('DataInfo read from workspace.')
    catch
        error('No proper DataInfo!')
    end
end

% default: plot randomly all datacolumns from one file
if nargin < 1 || isempty(filenumbers)
    filenumbers = randi(DataInfo.files_amount,1);
end

if nargin < 2 || isempty(datacolumns)
    datacolumns = 1:length(DataInfo.datacol_numbers);
end

if nargin < 3 || isempty(hfig)
    disp('Create new full size figure.')
    create_new_figure = 1;
else
    create_new_figure = 0;
end

% default: multiply data x 1e3 for mV and time 1e3 for milliseconds
if nargin < 4 || isempty(multiply_data)
    multiply_data = 1;
end
% figure properties
if any(multiply_data) == 1
    data_multiply = 1e3; % data in mV
    time_multiply = 1e3; % time in ms
else % give data in original and time in seconds
    data_multiply = 1; % data in V
    time_multiply = 1; % time in s
end

% default: no previous legends used
if nargin < 5 || isempty(previous_legends)
    previous_legends = [];
end
if nargin < 6 || isempty(previous_hplots)
    previous_hplots = [];
end

if nargin < max_inputs - 1 || isempty(DataPeaks_mean)
    try
        DataPeaks_mean = evalin('base', 'DataPeaks_mean');
        disp('DataPeaks_mean read from workspace.')
    catch
        error('No proper DataPeaks_mean!')
    end
end
if nargin < max_inputs || isempty(DataPeaks_summary)
    try
        DataPeaks_summary = evalin('base', 'DataPeaks_summary');
        disp('DataPeaks_summary read from workspace.')
    catch
        error('No proper DataPeaks_summary!')
    end
end
%%
legs = {}; hplots = []; 
title_text = 'FP signal';%['File#',num2str(filenumbers(1))];
markersize_= 200;
for file_index = filenumbers
    if create_new_figure ~= 0
        fig_full % creates hfig
        legs = {}; hplots = [];
        title_text = 'FP signal';% ['File#',num2str(file_index)];
    else
        legs = previous_legends;
        hplots = previous_hplots;
    end
    fs = DataInfo.framerate(file_index);
    for col_index = datacolumns
        try 
            legs{end+1,1} = ['File#',num2str(file_index),' - MEA ele#',...
                num2str(DataInfo.MEA_electrode_numbers(col_index))];
        catch
            legs{end+1,1} = ['File#',num2str(file_index),' - Datacolumn#',...
                num2str(col_index)];
        end
        data = DataPeaks_mean{file_index, 1}.data(:,col_index)*data_multiply;
        time = [0:1/fs:(length(data)-1)/fs]*time_multiply;
        peak_end_index = DataPeaks_summary.fpd_end_index(file_index, col_index);
        peak_end_value = DataPeaks_summary.fpd_end_value(file_index, col_index)*data_multiply;
                        
        % plot raw and filtered data
        hplots(end+1,1) = plot(time, data); hold all,
        color_index_current = get(gca,'ColorOrderIndex');
        first_peak_index = DataPeaks_summary.peaks{col_index}.firstp_loc(file_index);
        fpd_start_index = DataPeaks_summary.fpd_start_index(file_index, col_index);
        flat_peak_index = DataPeaks_summary.peaks{1,col_index}.flatp_loc(file_index);
        flat_peak_value = DataPeaks_summary.peaks{1,col_index}.flatp_val(file_index)*data_multiply;
        
        if color_index_current > 1
            set(gca,'ColorOrderIndex',color_index_current-1)
        end
        scatter(time(fpd_start_index), data(fpd_start_index),markersize_,'>','filled')
        if color_index_current > 1
            set(gca,'ColorOrderIndex',color_index_current-1)
        end
        scatter(time(first_peak_index),data(first_peak_index),markersize_,'^','filled')
        if color_index_current > 1
            set(gca,'ColorOrderIndex',color_index_current-1)
        end
        scatter(time(flat_peak_index), flat_peak_value,markersize_,'v','filled')
        if color_index_current > 1
            set(gca,'ColorOrderIndex',color_index_current-1)
        end
        scatter(time(peak_end_index), peak_end_value,markersize_,'<','filled')
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