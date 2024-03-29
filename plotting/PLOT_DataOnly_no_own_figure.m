function PLOT_DataOnly_no_own_figure(Data,...
    file_index, datacolumns, plot_datacolumns_to_same_fig)
% PLOT_DataOnly_no_own_figure(Data,index,datacolumns, plot_peak_numbers, plot_datacolumns_to_same_fig)
% PLOT_DataOnly_no_own_figure(Data,[],[1,3]) 
narginchk(1,4)
nargoutchk(0,0)
if nargin < 2 || isempty(file_index)
    file_index = randi([1 length(Data)],1); 
end
% Choosing subplot parameters based on how many datacolumns are included
if nargin < 3 || isempty(datacolumns)
    datacolumns = 1:length(Data{file_index,1}.data(1,:));
end
% plotting or not to same fig
if nargin < 4 || isempty(plot_datacolumns_to_same_fig)
    plot_datacolumns_to_same_fig = 0;
end

if length(file_index) > 1 
    disp(['Choosing first from file index: ',num2str(file_index(1))])
    file_index = file_index(1);
end
DataInfo = evalin('base', 'DataInfo');

try
    fs = DataInfo.framerate(file_index,1);
catch % old data where framerate only one file
    fs = DataInfo.framerate(1);
end
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
    try 
        exp_name_title = [DataInfo.experiment_name,' / ',...
            DataInfo.measurement_name];
        time_name_title = [', t=',num2str(round(DataInfo.measurement_time.time_sec...
                (file_index, 1)/3600,1)),'h'];
        try
            assignin('base','file_ind_workspace',file_index);
            name_temp = evalin('base','DataInfo.hypoxia.names{file_ind_workspace}');
            time_name_title = [time_name_title,' (',name_temp,')'];
            
        catch
            
            
        end
        try 
            dot_ind = max(strfind(DataInfo.file_names{file_index, 1},'.'))-1; 
            sqtitle_text = [exp_name_title, ': Datafile#', num2str(file_index),...
                time_name_title,10,DataInfo.file_names{file_index, 1}(1:dot_ind)];
        catch
            dot_ind = max(strfind(Data{file_index, 1}.filename,'.'))-1; 
            sqtitle_text = [exp_name_title, ': Datafile#', num2str(file_index),...
                time_name_title,10,Data{file_index, 1}.filename(1:dot_ind)];
        end
    catch
        try 
            dot_ind = max(strfind(DataInfo.file_names{file_index, 1},'.'))-1; 
            sqtitle_text = ['Datafile#', num2str(file_index),', t=',...
                num2str(round(DataInfo.measurement_time.time_sec(file_index)/3600,1)),...
                'h',10,DataInfo.file_names{file_index, 1}(1:dot_ind)];
        catch
            sqtitle_text = ['Datafile#', num2str(round(...
                Data{file_index, 1}.measurement_time.time_sec/3600,1)),10,...
                DataInfo.file_names{file_index, 1}];
        end
    end
    try % mea 
        title_general_start = ['Electrode#',...
            num2str(DataInfo.MEA_electrode_numbers(col_ind))]; 
    catch % non-mea or old data
        try
            title_general_start = [DataInfo.datacol_names{col_ind}];
        catch
            try 
            title_general_start = ['Col#',...
                num2str(DataInfo.datacol_numbers(col_ind))];
            catch
                try
                    title_general_start = ['Col#',...
                        num2str(Data{file_index,1}.datacolumns(col_ind))];
                catch % old data
                    title_general_start = ['Electrode#',...
                        num2str(Data{file_index,1}.data_MEA_electrode_number(col_ind))];
                end
            end
        end
        
        

    end
    title_full  = [title_general_start];

    % plotting: to separate subfigs or to same
    if plot_datacolumns_to_same_fig ~= 1
        subplot(sub_fig_rows,sub_fig_cols,zz)
    else
        if zz == 1
            sgtitle(sqtitle_text,'interpreter','none','fontsize',12)
        end
    end
    hfig_raw(zz,1) = plot(time, dat); hold all, 
    %%%
    if plot_datacolumns_to_same_fig ~= 1
        title(title_full,'interpreter','none','fontsize',12)
    else
        legs{zz,1} = title_full;
    end
    axis tight
    xlabel('Time (sec)')
    ylabel('Measurement (V)') % TODO: if other unit is used
    clear title_full
   
end % 1:length(datacolumns)
if plot_datacolumns_to_same_fig == 1
    legend(hfig_raw, legs, 'location', 'best')
else % if subplots, add sgtitle
    sgtitle(sqtitle_text,'interpreter','none','fontsize',12)
end
% remove_other_variables_than_needed
evalin( 'base', 'clear file_ind_workspace' )
end