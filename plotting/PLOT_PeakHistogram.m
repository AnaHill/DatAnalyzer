function [hfig] = PLOT_PeakHistogram(Data,Data_BPM, index,datacolumns)
% PLOT_PeakHistogram(Data,Data_BPM, [],[1,3]) 
% PLOT_PeakHistogram(Data,Data_BPM) 
% help  function to plot 
narginchk(2,4)
nargoutchk(0,1)
if nargin < 3 || isempty(index)
    index = randi([1 length(Data)],1); 
end
if length(index) > 1
    index = index(1);
    disp('Looking for only first file index(1)')
end

% Choosing subplot parameters based on how many datacolumns are included
if nargin < 4 || isempty(datacolumns)
    datacolumns = 1:length(Data{index,1}.data(1,:));
end

try
    DataInfo = evalin('base', 'DataInfo');
catch
    error('No proper DataInfo')
end

%%% fig parameters
[fig_parameters] = cal_subfig_parameters(datacolumns);
sub_fig_rows=fig_parameters(1);
sub_fig_cols=fig_parameters(2);
new_fig_number  = fig_parameters(3);
MP = get(0, 'MonitorPositions');
found_monitor_numbers = 1:length(MP(:,1));
fig_ind = find(max(MP(:,3)) == MP(:,3),1);
fig_out_pos = [MP(fig_ind,:)];

%hfig=[];
% hfig{end+1,1} = figure('units','pixel','outerposition',[fig_out_pos]);
hfig = figure('units','pixel','outerposition',[fig_out_pos]);
zoom on
% fs = Data{index,1}.framerate; 
try
    fs = DataInfo.framerate(index,1);
catch % old data where framerate only one file
    fs = DataInfo.framerate(1);
end
%% TODO: paremmin
for zz = 1:length(datacolumns) 
    col_ind = datacolumns(zz);
    subplot(sub_fig_rows,sub_fig_cols,zz) 
    dat = Data{index,1}.data(:,col_ind);
    locs_low = Data_BPM{index,1}.peak_locations_low{col_ind};
    locs_high = Data_BPM{index,1}.peak_locations_high{col_ind};
    low_peak_dist = diff(locs_low);
    low_peak_dist_ms = low_peak_dist/fs*1e3;
    high_peak_dist = diff(locs_high);
    high_peak_dist_ms = high_peak_dist/fs*1e3;
    times_low = locs_low/fs; times_low = times_low(1:end-1);
    times_high = locs_high/fs;times_high = times_high(1:end-1);
    %% TODO olisiko parempi kuva
    % histogram(low_peak_dist_ms)
    plot(times_high, high_peak_dist_ms,'ro','Markersize',5), hold all,
    ylabel('HIGH dist (ms)')
    % ylabel('Peak distance / R-R interval (ms)')
    yyaxis right
    plot(times_low, low_peak_dist_ms,'x','Markersize',5,'color', [0 .5 0]),
    xlabel('Time (sec)')
    ylabel('LOW dist (ms)')
    ax = gca;
    ax.YAxis(1).Color = 'r';
    ax.YAxis(2).Color = [0 .5 0];
%     [hcx, valx] = histcounts(low_peak_dist_ms);
%     [hcy, valy] = histcounts(high_peak_dist_ms);
%     x_values = mean([valx(2:end);valx(1:end-1)]);
%     figure, bar(x_values,[hcx;hcy]')
%     figure
%     hist1= histogram(low_peak_dist_ms,'Normalization','pdf','EdgeColor', 'blue', 'FaceColor',  'blue')
%     hold on
%     hist2 = histogram(high_peak_dist_ms, 'EdgeColor', 'green', 'FaceColor',  'green', 'FaceAlpha', 0.07);
%     
    %%
    sqtitle_text = ['Datafile#', num2str(index),', t=',...
        num2str(round(Data{index, 1}.measurement_time.time_sec/3600,1)),...
        'h',10,Data{index, 1}.filename];
    sgtitle(sqtitle_text,'interpreter','none','fontsize',12)
    title_text_high_peaks = ['High / low peaks: ',...
        num2str(length(Data_BPM{index,1}.peak_values_high{zz}))];
    %% TODO: mieti titlet uusiksi
% % %     try % mea
% % %         title_general_start = ['Electrode#',...
% % %             num2str(Data{index,1}.MEA_electrode_numbers(zz))];
% % %     catch % non-mea
% % %         title_general_start = ['Col#',...
% % %             num2str(Data{index,1}.datacolumns(zz))];
% % %     end
% % %     title_general = [title_general_start,10,title_text_high_peaks];
% % %     
% % %     if isfield(Data_BPM{index,1},'peak_values_low')
% % %         lowpks =length(Data_BPM{index,1}.peak_values_low{zz});
% % %         if highpks == lowpks % same amount of low and high peaks
% % %             title_text_low = [num2str(lowpks)];
% % %         else
% % %             title_text_low = ['\color{red}',num2str(lowpks)];
% % %         end      
% % %         
% % %         title_full = [title_general,' / ', title_text_low];
% % % %         plot(time(Data_BPM{index,1}.peak_locations_low{zz}), ...
% % % %             Data_BPM{index,1}.peak_values_low{zz},'x','color',[0 .5 0.]), 
% % %     else
% % %         title_full = [title_general_start,10, ' Peaks:  ',...
% % %             num2str(length(Data_BPM{index,1}.peak_values_high{zz}))];
% % %     end
% % %     title(title_full)
    axis tight
    clear title_full
end

% remove_other_variables_than_needed