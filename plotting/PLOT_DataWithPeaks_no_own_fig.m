function PLOT_DataWithPeaks_no_own_fig(Data,Data_BPM, ...
    file_index, datacolumns, plot_peak_numbers, plot_datacolumns_to_same_fig)
% function PLOT_DataWithPeaks_no_own_fig(Data,Data_BPM, ...
%     file_index, datacolumns, plot_peak_numbers, plot_datacolumns_to_same_fig)
% PLOT_DataWithPeaks_no_own_fig(Data,Data_BPM,file_index,datacolumns, plot_peak_numbers, plot_datacolumns_to_same_fig)
% PLOT_DataWithPeaks_no_own_fig(Data,Data_BPM, [],[1,3]) 
% PLOT_DataWithPeaks_no_own_fig(Data,Data_BPM) 
% PLOT_DataWithPeaks_no_own_fig(Data,Data_BPM,[],[],1); % with peak numbers
% PLOT_DataWithPeaks_no_own_fig(Data,Data_BPM,1,[1:3],1,1); % with peak numbers and to same fig

narginchk(0,6)
nargoutchk(0,0)
if nargin < 1 || isempty(Data)
    try
        Data = evalin('base','Data');
    catch
        error('No proper Data')
    end
end
if nargin < 2 || isempty(Data_BPM)
    try
        Data_BPM = evalin('base','Data_BPM');
    catch
        error('No proper Data_BPM')
    end
end
if nargin < 3 || isempty(file_index)
    file_index = randi([1 length(Data)],1); 
end
% Choosing subplot parameters based on how many datacolumns are included
if nargin < 4 || isempty(datacolumns)
    datacolumns = 1:length(Data{file_index,1}.data(1,:));
end
% plotting or not peak_numbers
if nargin < 5 || isempty(plot_peak_numbers)
    plot_peak_numbers = 0;
end
% plotting or not to same fig
if nargin < 6 || isempty(plot_datacolumns_to_same_fig)
    plot_datacolumns_to_same_fig = 0;
end

if length(file_index) > 1 
    disp(['Choosing first from file index: ',num2str(file_index(1))])
    file_index = file_index(1);
end
try
    DataInfo = evalin('base', 'DataInfo');
catch
    error('No proper DataInfo')
end
try
    fs = DataInfo.framerate(file_index,1);
catch % old data where framerate only one file
    fs = DataInfo.framerate(1);
end
% disp(['Sampling frequency: ', num2str(fs)])
ts = 1/fs;

%%% fig parameters
[fig_parameters] = cal_subfig_parameters(datacolumns);
sub_fig_rows=fig_parameters(1);
sub_fig_cols=fig_parameters(2);
new_fig_number  = fig_parameters(3);

hfig_raw = []; % for raw data plots, legend easier
legs = [];
for zz = 1:length(datacolumns) 
    col_ind = datacolumns(zz);
    dat = Data{file_index,1}.data(:,col_ind);
    time = 0:ts:(length(dat)-1)*ts;
    try % jos on turhaa tyhjää peak_values_xxx arvoja
        if isfield(Data_BPM{file_index,1},'peak_values_high')
            highpks = length(Data_BPM{file_index,1}.peak_values_high{col_ind});
            title_text_high_peaks = ['High / low peaks: ',...
                num2str(length(Data_BPM{file_index,1}.peak_values_high{col_ind}))]; 
        end
    catch
    end
    try
        if isfield(Data_BPM{file_index,1},'peak_values_low')
            lowpks =length(Data_BPM{file_index,1}.peak_values_low{col_ind});
            try
                if highpks == lowpks % same amount of low and high peaks
                    title_text_low = [num2str(lowpks)];
                else
                    title_text_low = ['\color{red}',num2str(lowpks)];
                end
            catch % no high peaks
                title_text_low = ['\color{red}',num2str(lowpks)];
            end
        end
    catch
    end
    try 
        exp_name_title = [DataInfo.experiment_name,' / ',...
            DataInfo.measurement_name];
        time_name_title = [', t=',num2str(round(...
            DataInfo.measurement_time.time_sec(file_index,1)/3600,1)),'h'];
        try
            assignin('base','file_ind_workspace',file_index);
            name_temp = evalin('base','DataInfo.hypoxia.names{file_ind_workspace}');
            time_name_title = [time_name_title,' (',name_temp,')'];
            
        catch
%             disp('No hypoxia names defined')
            
        end  
        sqtitle_text = [exp_name_title, ': Datafile#', num2str(file_index),...
            time_name_title,10,DataInfo.file_names{file_index,1}(1:end-3)];
    catch
        try 
            sqtitle_text = ['Datafile#', num2str(file_index),', t=',...
                num2str(round(Data{file_index, 1}.measurement_time.time_sec/3600,1)),...
                'h',10,DataInfo.file_names{file_index,1}(1:end-3)];
        catch
            sqtitle_text = ['Datafile#', num2str(file_index),10,...
                DataInfo.file_names{file_index,1}];
        end
    end
    
    try % muutosten 2021/03 jälkeen
        if isfield(DataInfo,'MEA_electrode_numbers')
            title_general_start = ['Electrode#',...
                num2str(DataInfo.MEA_electrode_numbers(col_ind))]; 
        else
            try
                title_general_start = [DataInfo.datacol_names{col_ind}];
            catch
                title_general_start = ['Col#',...
                    num2str(DataInfo.datacol_numbers(col_ind))];
            end
        end 
    catch    % ennen 2021/03 muutoksia
        try % mea
            title_general_start = ['Electrode#',...
                num2str(Data{file_index,1}.MEA_electrode_numbers(col_ind))]; 
        catch % non-mea or old data
            try 
                title_general_start = ['Col#',...
                    num2str(Data{file_index,1}.datacolumns(col_ind))];
            catch % vanhat datat
                title_general_start = ['Electrode#',...
                    num2str(Data{file_index,1}.data_MEA_electrode_number(col_ind))];
            end
        end
    end
    
    try
        title_general = [title_general_start,10,title_text_high_peaks];
        if isfield(Data_BPM{file_index,1},'peak_values_low')
            title_full = [title_general,' / ', title_text_low];
        else
            title_full = [title_general_start,10,' Peaks (high):  ',num2str(highpks)];
        end
    catch % if not high peaks
        try
            title_full = [title_general_start,10,' Peaks (low):  ',num2str(lowpks)];
        catch
            title_full = [title_general_start,10,' Peaks: 0'];
        end
    end
    

    % plotting: to separate subfigs or to same
    if plot_datacolumns_to_same_fig ~= 1
        subplot(sub_fig_rows,sub_fig_cols,zz)
        sgtitle(sqtitle_text,'interpreter','none','fontsize',12)
    else
        if zz == 1
            sgtitle(sqtitle_text,'interpreter','none','fontsize',12)
        end
    end
    % Update 2022/06: now color index is updated to "raw data
    if zz == 1
        hfig_raw(zz,1) = plot(time, dat);hold all;   % hold on does not work...
        ax = gca; current_next_index = ax.ColorOrderIndex;
    else
        % update color index so that raw data is plotted with next color index
        % related to raw data
        ax.ColorOrderIndex = current_next_index;
        hfig_raw(zz,1) = plot(time, dat); hold all;
        % finally, update color index by one
        current_next_index = current_next_index +1;
    end

    try
        plot(time(Data_BPM{file_index,1}.peak_locations_high{col_ind}), ...
            Data_BPM{file_index,1}.peak_values_high{col_ind},'ro'),
    catch
%         disp('no high peaks found')
    end
    if isfield(Data_BPM{file_index,1},'peak_values_low')
        plot(time(Data_BPM{file_index,1}.peak_locations_low{col_ind}), ...
            Data_BPM{file_index,1}.peak_values_low{col_ind},...
            'x','color',[0 .5 0.]), 
    end
    
    %%% Plot peak numbers if wanted -> only if plot_peak_numbers=1
    if plot_peak_numbers == 1
        % include peak number
        extra_in_x_axis = 0.2;
        if isfield(Data_BPM{file_index,1},'peak_values_high')
            try 
                peak_number_high_time = ...
                    time(Data_BPM{file_index,1}.peak_locations_high{col_ind})...
                    + extra_in_x_axis;
                peak_number_high_yval = Data_BPM{file_index,1}.peak_values_high{col_ind};  
                text(peak_number_high_time,peak_number_high_yval,...
                    num2str((1:numel(peak_number_high_time))'))
            catch
                
            end
        end
        if isfield(Data_BPM{file_index,1},'peak_values_low')
            try 
                peak_number_low_time = ...
                    time(Data_BPM{file_index,1}.peak_locations_low{col_ind})...
                    + extra_in_x_axis;
                peak_number_low_yval = Data_BPM{file_index,1}.peak_values_low{col_ind};  
                text(peak_number_low_time,peak_number_low_yval,...
                    num2str((1:numel(peak_number_low_time))'))            
            catch
            end
        end  
    end
    %%%
	if plot_datacolumns_to_same_fig ~= 1
        title(title_full)
    else % if data from different columns to same figs
        legs{zz,1} = title_general_start;
    end
    axis tight
    clear title_full
end

if plot_datacolumns_to_same_fig == 1
    legend(hfig_raw, legs, 'location', 'best')
end

try
    disp(['Peaks in file#',num2str(file_index),': ',...
        num2str(Data_BPM{file_index, 1}.Amount_of_peaks(:)')])
catch
end
evalin( 'base', 'clear file_ind_workspace' )
end