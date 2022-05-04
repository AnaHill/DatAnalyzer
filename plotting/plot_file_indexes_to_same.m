function hfig = plot_file_indexes_to_same(file_indexes, Data, Data_BPM, datacolumns, ...
    plotting_data_columns_to_same, plotting_peak_numbers)
% function hfig = plot_file_indexes_to_same(file_indexes, Data, Data_BPM, datacolumns, ...
%     plotting_data_columns_to_same, plotting_peak_numbers );
% hfig = plot_file_indexes_to_same(file_indexes);
narginchk(1,6)
nargoutchk(0,1)
if isempty(file_indexes) % nargin < 1 || isempty(file_indexes)
    error('Give two or more file indexes')
else
    if length(file_indexes) < 2
         % TODO: plottaisikin normaalin piiroksen jos antaa yhden
        error('Give two or more file indexes')
    end
end

if nargin < 2 || isempty(Data)
    try
        Data = evalin('base','Data');
    catch
        error('No proper Data')
    end
end
if nargin < 3 || isempty(Data_BPM)
    try
        Data_BPM = evalin('base','Data_BPM');
        bpm_found = 1;
    catch
        % error('No proper Data_BPM')
        bpm_found = 0;
        disp('No peaks Data_BPM found, plotting only raw data')
    end
end


% Choosing subplot parameters based on how many datacolumns are included
if nargin < 4 || isempty(datacolumns)
    % taking datacolumn lenght from first file_index
    datacolumns = 1:length(Data{file_indexes(1),1}.data(1,:));
end
% plotting datacolumns to separate subplots (default) all or to same fig
if nargin < 5 || isempty(plotting_data_columns_to_same)
    plotting_data_columns_to_same = 0;
end

% include or not peak_numbers: default is to include
if nargin < 6 || isempty(plotting_peak_numbers)
    plotting_peak_numbers = 1;
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
extra_in_x_axis = 0.2; % for peak numbers



%% tarviiko, poista
% try
%     fs = DataInfo.framerate(file_index,1);
% catch % old data where framerate only one file
%     fs = DataInfo.framerate(1);
% end
% % disp(['Sampling frequency: ', num2str(fs)])
% ts = 1/fs;
% hfig_raw = []; % for raw data plots, legend easier
% legs = [];
%%
if plotting_data_columns_to_same == 0
    data_with_legend = [];
    legs = cell(length(file_indexes),length(datacolumns));
else % all plots to one figure without subplots
    legs = [];
    data_with_legend = [];
end

for kk = 1:length(file_indexes)
    file_index = file_indexes(kk);
    if kk == 1
        % default = Full screen size
        hfig = create_figure_with_size();   
    end
    % assuming data length (#rows) to be same in each data column in one file index
    time = 0:1/DataInfo.framerate(file_index):...
        (length(Data{file_index}.data(:,1))-1)/DataInfo.framerate(file_index);
    for pp = 1:length(datacolumns)
        col_index = datacolumns(pp);
        try
            leg_start = ['File#', num2str(file_index),'(t=',...
                num2str(round(DataInfo.measurement_time.time_sec(file_index)/3600,1)),'h)'];
        catch
            leg_start = ['File#', num2str(file_index)];
        end
        if plotting_data_columns_to_same == 0 || length(datacolumns) < 2
            % if all data columns are plotted to same figure --> no subplots needed
            % otherwise, plot subplots based on amount of chosen datacolumns
            subplot(sub_fig_rows,sub_fig_cols,pp)
            if isfield(DataInfo,'MEA_electrode_numbers')
                title(['El#',num2str(DataInfo.MEA_electrode_numbers(col_index))]);
            else
                title(['Col#',num2str(DataInfo.datacol_numbers(col_index))]);
            end
            data_with_legend(kk,pp) = plot_data_with_linestyle(Data{file_index}.data(:,col_index),time);
            % legend can be shorter as subplot title tells data column info
            legs{kk,pp} = [leg_start];% ,', file_index=',num2str(file_index)];
        else % no subplots: include el/col# in legend
            data_with_legend(end+1) = plot_data_with_linestyle(Data{file_index}.data(:,col_index),time);
            if isfield(DataInfo,'MEA_electrode_numbers')
                legs{end+1} = [leg_start,': El#',num2str(DataInfo.MEA_electrode_numbers(col_index))];
            else
                legs{end+1} = [leg_start,': Col#',num2str(DataInfo.datacol_numbers(col_index))];
            end
            
        end
        hold all
        
        
        if bpm_found == 1 % plotting possible peaks
            try
                peak_times = time(Data_BPM{file_index,1}.peak_locations_high{col_index});
                peak_values = Data_BPM{file_index,1}.peak_values_high{col_index};
                plot(peak_times, peak_values,'ro')
                highpeak_amount = length(peak_values);
                % if include peak numbers in plot
                if plotting_peak_numbers == 1
                    text(peak_times+extra_in_x_axis,peak_values,...
                        num2str((1:numel(peak_times))'))
                end
            catch %  warning('no high peaks found')
                highpeak_amount = 0;
            end
            try
                peak_times = time(Data_BPM{file_index,1}.peak_locations_low{col_index});
                peak_values = Data_BPM{file_index,1}.peak_values_low{col_index};
                plot(peak_times, peak_values,'x','color',[0 .5 0.])
                lowpeak_amount = length(peak_values);
                % if include peak numbers in plot
                if plotting_peak_numbers == 1
                    text(peak_times+extra_in_x_axis,peak_values,...
                        num2str((1:numel(peak_times))'))
                end
            catch %  warning('no low peaks found')
                lowpeak_amount = 0;
            end
        end % end: % plotting possible peaks
        axis tight
    end % end pp = 1:length(datacolumns)
end % end for kk = 1:length(file_indexes)
sgtitle([DataInfo.experiment_name, ' - ', DataInfo.measurement_name],...
    'interpreter','none','fontsize',12)

if plotting_data_columns_to_same == 0 % each datacolumn to own suplot
    % each subplots with own legends
    for pp = 1:length(datacolumns)
        subplot(sub_fig_rows,sub_fig_cols,pp)
        if length(legs) > 3 % legend text in two columns if more than 3 data
            legend(data_with_legend(:,pp), legs(:,pp), ...
                'location', 'best','interpreter','none','NumColumns',2)
        else
            legend(data_with_legend(:,pp), legs(:,pp), ...
                'location', 'best','interpreter','none')
        end
    end
else %% plotting datacolumns data to same fig --> no subplots
    if length(legs) > 3 % legend text in two columns if more than 3 data
        legend(data_with_legend, legs, 'location', 'best',...
            'interpreter','none','NumColumns',2)
    else
        legend(data_with_legend, legs, 'location', 'best',...
            'interpreter','none')
    end

end
zoom on












end




