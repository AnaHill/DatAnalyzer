function [hfig] = PLOT_Data_and_mp_ap_fp(Data,Data_BPM, file_index, datacolumns, plot_peak_numbers)
% PLOT_Data_and_mp_ap_fp(Data,Data_BPM, index,datacolumns, plot_peak_numbers)
% PLOT_Data_and_mp_ap_fp(Data,Data_BPM, [1],[2,4])
% PLOT_Data_and_mp_ap_fp(Data,Data_BPM, [1],[2],1)
% PLOT_Data_and_mp_ap_fp(Data,Data_BPM) 
% PLOT_Data_and_mp_ap_fp(Data,Data_BPM,[],[],1); % with peak_plots
% assumes that  
narginchk(2,5)
nargoutchk(0,1)
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

if length(file_index) > 1 
    disp(['Choosing first from file index: ',num2str(file_index(1))])
    file_index = file_index(1);
end

%%% fig parameters
[fig_parameters] = cal_subfig_parameters(datacolumns);
sub_fig_rows=fig_parameters(1);
sub_fig_cols=fig_parameters(2);
new_fig_number  = fig_parameters(3);

fig_full
% % 
% % MP = get(0, 'MonitorPositions');
% % found_monitor_numbers = 1:length(MP(:,1));
% % fig_ind = find(max(MP(:,3)) == MP(:,3),1);
% % fig_out_pos = [MP(fig_ind,:)];
% % hfig = figure('units','pixel','outerposition',[fig_out_pos]);
% % zoom on;
% % 
% % %hfig=[];
% % % hfig{end+1,1} = figure('units','pixel','outerposition',[fig_out_pos]);
% % hfig = figure('units','pixel','outerposition',[fig_out_pos]);
% % zoom on
try
    fs = DataInfo.framerate(file_index,1);
catch % old data where framerate only one file
    fs = DataInfo.framerate(1);
end
ts = 1/fs; 
for zz = 1:length(datacolumns) 
    col_ind = datacolumns(zz);
    subplot(sub_fig_rows,sub_fig_cols,zz) 
    dat = Data{file_index,1}.data(:,col_ind);
    time_dat = 0:ts:(length(dat)-1)*ts;
    plot(time_dat, dat), hold all, 
    mainpks = length(Data_BPM{file_index,1}.mainpeak_values{col_ind});
    plot(time_dat(Data_BPM{file_index,1}.mainpeak_locations{col_ind}), ...
        Data_BPM{file_index,1}.mainpeak_values{col_ind},'rv',...
        'MarkerFaceColor',[1 0 0], 'Markersize', 10),
    try
        sqtitle_text = ['Datafile#', num2str(file_index),', t=',...
            num2str(round(DataInfo.measurement_time.time_sec(file_index, 1)/3600,1)),...
            'h',10,DataInfo.file_names{file_index, 1}];
    catch
        sqtitle_text = ['Datafile#', num2str(file_index),...
            ' - ', Data{file_index, 1}.filename];
    end
    sgtitle(sqtitle_text,'interpreter','none','fontsize',12)
    title_text_high_peaks = ['High / low peaks: ',...
        num2str(length(Data_BPM{file_index,1}.mainpeak_values{col_ind}))]; 
    %if zz == 1
    try % mea
        title_general_start = ['Electrode#',...
            num2str(DataInfo.MEA_electrode_numbers(col_ind))];
    catch % non-mea or old data
        try
            title_general_start = ['Col#',...
                num2str(DataInfo.datacol_numbers(col_ind,1))];
        catch
            try 
                title_general_start = ['Col#',...
                    num2str(Data{file_index,1}.datacolumns(col_ind))];
            catch % vanhat datat
                title_general_start = ['Electrode#',...
                    num2str(Data{file_index,1}.data_MEA_electrode_number(col_ind))];
            end
        end
    end

    title_general = [title_general_start,10,title_text_high_peaks];
    
    %end
    if isfield(Data_BPM{file_index,1},'antipeak_values')
        ap_ind = Data_BPM{file_index,1}.antipeak_locations{col_ind};
        ap_ind(isnan(ap_ind)) = [];
        ap_val = Data_BPM{file_index,1}.antipeak_values{col_ind};
        ap_val(isnan(ap_val)) = [];
        antipks =length(ap_val);
        if mainpks == antipks % same amount of main and antipeaks
            title_text_low = [num2str(antipks)];
        else
            title_text_low = ['\color{red}',num2str(antipks)];
        end      
        title_full = [title_general,' / ', title_text_low];
        plot(time_dat(ap_ind), ap_val,'^','color',[0 .5 0],...
            'MarkerFaceColor',[0 .5 0],'Markersize', 10), 
    else
        title_full = [title_general_start,10, ' Peaks:  ',...
            num2str(length(Data_BPM{file_index,1}.mainpeak_values{col_ind}))];
    end
    if isfield(Data_BPM{file_index,1},'flatpeak_values')
        fp_ind = Data_BPM{file_index,1}.flatpeak_locations{col_ind};
        fp_ind(isnan(fp_ind)) = [];
        fp_val = Data_BPM{file_index,1}.flatpeak_values{col_ind};
        fp_val(isnan(fp_val)) = [];
        plot(time_dat(fp_ind), fp_val,'d','color',[1 .5 0],...
            'MarkerFaceColor',[1 .5 0], 'Markersize', 10), 
    end
        
    %% Plot peak numbers if wanted -> only if plot_peak_numbers=1
    if plot_peak_numbers == 1
        % include peak number
        extra_in_x_axis = 0.2;
        peak_number_high_time = ...
            time_dat(Data_BPM{file_index,1}.mainpeak_locations{col_ind})...
            + extra_in_x_axis;
        peak_number_high_yval = Data_BPM{file_index,1}.mainpeak_values{col_ind};  
        text(peak_number_high_time,peak_number_high_yval,...
            num2str((1:numel(peak_number_high_time))'))
        if isfield(Data_BPM{file_index,1},'antipeak_values')
            peak_number_low_time = ...
                time_dat(Data_BPM{file_index,1}.antipeak_locations{col_ind})...
                + extra_in_x_axis;
            peak_number_low_yval = Data_BPM{file_index,1}.antipeak_values{col_ind};  
            text(peak_number_low_time,peak_number_low_yval,...
                num2str((1:numel(peak_number_low_time))'))            
        end  
        if isfield(Data_BPM{file_index,1},'flatpeak_values')
            peak_number_flatpeak_time = time_dat(fp_ind)...
                + extra_in_x_axis;
            peak_number_flatpeak_yval = fp_val;  
            text(peak_number_flatpeak_time,peak_number_flatpeak_yval,...
                num2str((1:numel(peak_number_flatpeak_time))'))            
        end  
    end
    title(title_full)
    axis tight
    clear title_full
end

% remove_other_variables_than_needed