function [hfig] = PLOT_DataWithPeaks_no_own_figure(Data,Data_BPM, index, datacolumn,...
    plot_peak_numbers)
% PLOT_DataWithPeaks(Data,Data_BPM, index,datacolumns, plot_peak_numbers)
% help  function to plot 
narginchk(2,5)
nargoutchk(0,1)
if nargin < 3 || isempty(index)
    index = randi([1 length(Data)],1); 
end
% Choosing subplot parameters based on how many datacolumns are included
if nargin < 4 || isempty(datacolumn)
    datacolumn = randi(length(Data{index,1}.data(1,:)));
end
% plotting or not peak_numbers
if nargin < 5 || isempty(plot_peak_numbers)
    plot_peak_numbers = 0;
end
% PLOTTING ONLY first column given
datacolumn=datacolumn(1);
% % % %%% fig parameters
% % % [fig_parameters] = cal_subfig_parameters(datacolumn);
% % % sub_fig_rows=fig_parameters(1);
% % % sub_fig_cols=fig_parameters(2);
% % % new_fig_number  = fig_parameters(3);
% % % MP = get(0, 'MonitorPositions');
% % % found_monitor_numbers = 1:length(MP(:,1));
% % % fig_ind = find(max(MP(:,3)) == MP(:,3),1);
% % % fig_out_pos = [MP(fig_ind,:)];
% % % 
% % % %hfig=[];
% % % % hfig{end+1,1} = figure('units','pixel','outerposition',[fig_out_pos]);
% % % hfig = figure('units','pixel','outerposition',[fig_out_pos]);
% % % zoom on
DataInfo = evalin('base','DataInfo');
try
    fs = DataInfo.framerate(index,1);
catch % old data where framerate only one file
    fs = DataInfo.framerate(1);
end
ts = 1/fs; % Data{index, 1}.framerate;   
for zz = 1:length(datacolumn) 
    col_ind = datacolumn(zz);
% % %     subplot(sub_fig_rows,sub_fig_cols,zz) 
    dat = Data{index,1}.data(:,col_ind);
    time = 0:ts:(length(dat)-1)*ts;
    plot(time, dat), hold all, 
    highpks = length(Data_BPM{index,1}.peak_values_high{col_ind});
    plot(time(Data_BPM{index,1}.peak_locations_high{col_ind}), ...
        Data_BPM{index,1}.peak_values_high{col_ind},'ro'),
    try 
    sqtitle_text = ['Datafile#', num2str(index),', t=',...
        num2str(round(Data{index, 1}.measurement_time.time_sec/3600,1)),...
        'h',10,Data{index, 1}.filename];
    sgtitle(sqtitle_text,'interpreter','none','fontsize',12)
    catch
    end
    
    title_text_high_peaks = ['High / low peaks: ',...
        num2str(length(Data_BPM{index,1}.peak_values_high{col_ind}))]; 
    %if zz == 1
    try % mea
%         title_general_start = ['Electrode#',...
%             num2str(Data{index,1}.MEA_electrode_numbers(col_ind))];
        title_general_start = ['Electrode#',...
            num2str(DataInfo.MEA_electrode_numbers(col_ind))];
    catch 
        try % mea, old name 'MEA_electrode_number'
            title_general_start = ['Electrode#',...
                num2str(Data{index,1}.data_MEA_electrode_number(col_ind))];
        catch % non-mea
        title_general_start = ['Col#',...
            num2str(Data{index,1}.datacolumns(col_ind))];
        end
    end
    title_general = [title_general_start,10,title_text_high_peaks];
    
    %end
    if isfield(Data_BPM{index,1},'peak_values_low')
        lowpks =length(Data_BPM{index,1}.peak_values_low{col_ind});
        if highpks == lowpks % same amount of low and high peaks
            title_text_low = [num2str(lowpks)];
        else
            title_text_low = ['\color{red}',num2str(lowpks)];
        end      
        
        title_full = [title_general,' / ', title_text_low];
        plot(time(Data_BPM{index,1}.peak_locations_low{col_ind}), ...
            Data_BPM{index,1}.peak_values_low{col_ind},'x','color',[0 .5 0.]), 
    else
        title_full = [title_general_start,10, ' Peaks:  ',...
            num2str(length(Data_BPM{index,1}.peak_values_high{col_ind}))];
    end
    
    %% Plot peak numbers if wanted -> only if plot_peak_numbers=1
    if plot_peak_numbers == 1
        % include peak number
        extra_in_x_axis = 0.2;
        peak_number_high_time = ...
            time(Data_BPM{index,1}.peak_locations_high{col_ind})...
            + extra_in_x_axis;
        peak_number_high_yval = Data_BPM{index,1}.peak_values_high{col_ind};  
        text(peak_number_high_time,peak_number_high_yval,...
            num2str((1:numel(peak_number_high_time))'))
        if isfield(Data_BPM{index,1},'peak_values_low')
            peak_number_low_time = ...
                time(Data_BPM{index,1}.peak_locations_low{col_ind})...
                + extra_in_x_axis;
            peak_number_low_yval = Data_BPM{index,1}.peak_values_low{col_ind};  
            text(peak_number_low_time,peak_number_low_yval,...
                num2str((1:numel(peak_number_low_time))'))            
        end  
    end
    title(title_full)
    axis tight
    clear title_full
end

% remove_other_variables_than_needed