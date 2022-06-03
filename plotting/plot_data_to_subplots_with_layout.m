function [ha,pos,hfig] = plot_data_to_subplots_with_layout(rawdata, ...
    datacolumns, fs, subplot_rows, subplot_columns, show_yticklabel, plot_title_text)
% function [ha,pos,hfig] = plot_data_to_subplots_with_layout(rawdata, ...
%     datacolumns, fs, subplot_rows, subplot_columns, show_yticklabel,plot_title_text)
% plot_data_to_subplots_with_layout plots data columns to separate subplots, 
% usefull in e.g. MEA plots
% For faster plotting, function uses plotBig if it is available, see 
    % https://github.com/JimHokanson/plotBig_Matlab
% Examples
    % plot_data_to_subplots_with_layout(data); plot all data, fs=1 Hz assumed
    % plot_data_to_subplots_with_layout(data,DataInfo.datacol_numbers,DataInfo.framerate(1));
        % takes info from DataInfo struct
% Required files
    % tight_subplot.m
    % fig_full.m, will create hfig matlab figure class
% Additional files
    % plotBig, available at: https://se.mathworks.com/matlabcentral/fileexchange/60289-jimhokanson-plotbig_matlab?s_tid=srchtitle

%% TODO: 
% - can not handle if multiple fs are given
% - might not work with other than 64 MEA layout
    % following eq. calculates MATLAB's subplot index based on "MEA electrode location"
    % it works at least with 64 MEA from Multichannels
    % where e.g. electrode#42 is in location column = 4 and row = 2
        % column_index = int8(floor(datacolumns(ii)/10));
        % row_index = int8(rem(datacolumns(ii)/10,1)*10);    
        % subplot_index = (row_index-1)*subplot_columns + column_index;
% - Now "title text" is plotted with legend command 
    % legend location is north, would be maybe better slightly to left
    % or could title text be plotted without axes command
%%
narginchk(1,7)
nargoutchk(0,3)

%%%%% Set default values %%%%%%%%%%%%%%%%%%%%%%%%%
% if no datacolumns given, choosing all data
if nargin < 2 || isempty(datacolumns)
    datacolumns = 1:min(size(rawdata));
end
% if framerate fs not given, trying to find DataInfo.framerate(1) from workspace
if nargin < 3 || isempty(fs)
	try
       fs = evalin('base','DataInfo.framerate(1)'); 
       warning(['Framerate fs was not given, loading from workspace DataInfo.framerate(1)'])
       disp(['fs = ', num2str(fs),' Hz'])
    catch
        warning('fs not given and no proper DataInfo found on workspace')
        fs=1;
        disp(['Setting fs = ', num2str(fs),' Hz'])
    end
end
% default layout: 8 x 8 subplot grid (64 MEA layout)
if nargin < 4 || isempty(subplot_rows)
    subplot_rows = 8;
end
if nargin < 5 || isempty(subplot_columns)
     subplot_columns = 8;   
end

% default: not showing yticks, only shown if yticklabel_shown == 1 given
if nargin < 6 || isempty(show_yticklabel)
    show_yticklabel = 0;
else
    if show_yticklabel ~= 1 && show_yticklabel ~= 0
        show_yticklabel = 0;
    end
end
% default: plot title text
if nargin < 7 || isempty(plot_title_text)
    plot_title_text = 1;
else
    if plot_title_text ~= 1 && plot_title_text ~= 0
        plot_title_text = 1;
    end
end

if length(fs) > 1 % if multiple framerate values are given
    if any(diff(fs ~= 0)) % if framerate not same in each 
        % TODO: this should be updated --> also when time vector createad
        fs = fs(1);
    else % if framerate same in each file
        fs = fs(1);
    end
    disp(['Used fs = ', num2str(fs),' Hz'])
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

time = 0:1/fs:(max(size(rawdata))-1)/fs;
fig_full
% [ha, pos] = tight_subplot(Nh, Nw, gap, marg_h, marg_w)
    % gap [gap_h gap_w] for different gaps in height and width in normalized units (0...1)
    % marg_h  margins  or [lower upper] in height in normalized units (0...1)
    % marg_w  margins or [left right] in width in normalized units (0...1)
if show_yticklabel ~= 1
    [ha, pos] = tight_subplot(subplot_rows,subplot_columns,5e-3,[.05 .01],5e-3);
else
    [ha, pos] = tight_subplot(subplot_rows,subplot_columns,1e-2,[.05 .01],[1e-2 5e-3]);
end

for ii = 1:length(datacolumns)
    % TODO: test how this works with other layouts, see explanation at the begin
    column_index = int8(floor(datacolumns(ii)/10));
    row_index = int8(rem(datacolumns(ii)/10,1)*10);    
    subplot_index = (row_index-1)*subplot_columns + column_index;
    
    % plot if not ground or other reference electrode  
    if column_index ~= 0 && row_index ~= 0     
        try % if plotBig available
            plotBig(ha(subplot_index),time, rawdata(:,ii))
            % TODO: could choose below linestyle
%             plotBig(ha(subplot_index),time, rawdata(:,ii),'.-')
        catch
            plot(ha(subplot_index),time, rawdata(:,ii));
        end
        
        if plot_title_text == 1
            % title text will be done with legend function, because 
            % no axes command needed -> much faster plotting
            hold on; hh2=line(ha(subplot_index),nan,nan,'Linestyle', 'none',...
                'Marker', 'none', 'Color', 'none'); % plotting dummy for legend
            text_to_display = ['Ele#', num2str(column_index), num2str(row_index)];
            legend(hh2,text_to_display,...
                'location','north','fontweight','bold',...
                'Fontsize',[ha(subplot_index).FontSize+2],'box','off');
        end
        set(ha(subplot_index),'Ylim',[-inf inf]) % axis tight ei toimi
        set(ha(subplot_index),'Xlim',[-inf inf])
    end
end

% modifying ticks: 
    % remove all x-ticks except bottom subplots
    % remove all y-ticks unless user has chosen to keep them
set(ha(1:subplot_rows*subplot_columns-subplot_columns),'XTickLabel','');
if show_yticklabel ~= 1
    set(ha,'YTickLabel','')
end

end