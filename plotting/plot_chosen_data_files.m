function [] = plot_chosen_data_files(Data, DataInfo, ...
    filenumbers, datacolumns, helping_levels, MonitorNumber)
% function [] = plot_chosen_data_files(Data, DataInfo, ...
%     filenumbers, datacolumns, helping_levels, MonitorNumber)
% PLOT_CHOSEN_DATA_FILES Plots chosen datafiles from Data

narginchk(2,6)
nargoutchk(0,0)

% default: plotting every 10th file, so that first and last will be plotted
if nargin < 3
   filenumbers = [1:10:DataInfo.files_amount]';
   if filenumbers(end) < DataInfo.files_amount
       filenumbers(end+1,1) = DataInfo.files_amount;
   end
end
% default: all data columns plotted
if nargin < 4
    datacolumns =  1:min(size(Data{filenumbers(1),1}.data));
end
% default: levels that are plotted 
if nargin < 5
    helping_levels = 2.7*[1 -1]*1e-5;
    disp(['Setting default helping level (abs): ',num2str(helping_levels(1))])
end
% default: last monitor is plotted (typically second, larger screen in
% laptops)
if nargin < 6
    MonitorNumber = 0; % set to zero --> last MP will be chosen
end
    
%%% checking input data
% check filenumbers and datacolumns -> raising error if not found
datafilenumbers = [1:DataInfo.files_amount]';
if any(ismember(filenumbers,datafilenumbers) == 0) 
    error('No correct filenumber found in data, check!')
end
datacolumns_all = 1:length(Data{filenumbers(1),1}.data(1,:));
if any(ismember(datacolumns,datacolumns_all) == 0) 
    error('No correct datacolumn found in data, check!')
end

% warning if a lot of figures would be drawn (now over 20)
if max(size(filenumbers)) > 20
    warning([num2str(max(size(filenumbers))),...
        ' figures will be drawn, are you sure?'])
    answer = questdlg(['Are you sure you want to plot all ',...
        num2str(max(size(filenumbers))),' figs?'],'Plotting all', 'Yes','No','No');
    switch answer
        case 'Yes'
            plot_all_index = 1;
        otherwise
            plot_all_index = 0;
    end
else
    plot_all_index = 1;
end

% if helping_levels does not include only two values, changing so that
% two values are [helping_levels(1) -helping_levels(1)]
if max(size(helping_levels)) ~= 2
    disp('Helping_levels does not have two parameters')
    disp('Changing helping levels to [helping_levels(1) -helping_levels(1)]')
    helping_levels = helping_levels(1);
    helping_levels(end+1) = -helping_levels;
end
%%%%%%%%%%%%%%
% choosing monitor for figure, default is the largest
% % MP = get(0, 'MonitorPositions');
% % found_monitor_numbers = 1:length(MP(:,1));
% % if ~ismember(MonitorNumber,found_monitor_numbers)% taking last value in MP
% % %     fig_out_pos = [MP(end,:)];
% %     fig_ind = find(max(MP(:,3)) == MP(:,3),1);
% %     fig_out_pos = [MP(fig_ind,:)];
% % else
% %     fig_out_pos = [MP(MonitorNumber,:)];
% % end
hfigchekc = figure();hfigchekc.WindowState = 'maximized';zoom on;
fig_out_pos = get(hfigchekc,'outerposition'); close(hfigchekc), clear hfigchekc

% Choosing subplot parameters based on how many datacolumns are included
[fig_parameters] = cal_subfig_parameters(datacolumns);
sub_fig_rows=fig_parameters(1);
sub_fig_cols=fig_parameters(2);
new_fig_number  = fig_parameters(3);

%%%%%%%%%%%%%%%%%% 
if ~plot_all_index == 1 
    disp('Chosen not to plot all data')
else % if plotting all filenumbers
    num=1;
    hfig=[];
    hfig{end+1,1} = figure('units','pixel','outerposition',[fig_out_pos]);
    zoom on, 
    for index = 1:length(filenumbers)
        if num == new_fig_number
            hfig{end+1,1} = figure('units','pixel','outerposition',[fig_out_pos]);
            zoom on,
            num = 1;
        end
        datanumber=filenumbers(index);
        d_raw = Data{datanumber,1};
    %     ts = 1/d_raw.framerate;
        try
            fs = DataInfo.framerate(datanumber,1);
        catch % old data where framerate only one file
            fs = DataInfo.framerate(1);
        end
        ts = 1/fs;
        d_raw_time = 0:ts:(length(d_raw.data(:,1))-1)*ts;
        for pp=1:length(datacolumns) 
            subplot(sub_fig_rows,sub_fig_cols,num)
            plot(d_raw_time, d_raw.data(:,datacolumns(pp)))
            grid on
            title_text = [DataInfo.experiment_name,' - ',DataInfo.measurement_name,...
                10, 'File# ',num2str(datanumber),', Time (h): ',...
                num2str(round(DataInfo.measurement_time.time_sec(datanumber)/3600,1)),...
                ', '];
            % check if MEA data
            if isfield(DataInfo, 'MEA_columns') % if MEA data
                title_text_extra = ['Electrode#',...
                    num2str(DataInfo.MEA_electrode_numbers(pp))];
            else
                title_text_extra = ['Datacolumn#',num2str(datacolumns(pp))];
            end
            title([title_text, title_text_extra], 'interpreter','none')
            num=num+1;
            xlim([-1 max(d_raw_time)])
            line([0 d_raw_time(end)], [helping_levels(1) helping_levels(1)],...
                'linestyle','--','color', [0.6 0.6 0.6])
            line([0 d_raw_time(end)], [helping_levels(2) helping_levels(2)],...
                'linestyle', '--','color', [0.6 0.6 0.6])
            axis tight
        end
    end   
    % presenting first above
    for fig_index = length(hfig):-1:1
        figure(hfig{fig_index,1}); 
    end

end

        
end