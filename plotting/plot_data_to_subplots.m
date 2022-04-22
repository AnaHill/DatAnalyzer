function [ha,pos,hfig] = plot_data_to_subplots(rawdata, ...
    datacolumns, fs, show_yticklabel, plot_title_text)
% function [ha,pos,hfig] = plot_data_to_subplots(rawdata, ...
%     datacolumns, fs, show_yticklabel,plot_title_text)
% defaults:
    % datacolumns: choosing all datacolumns 
    % fs = DataInfo.framerate(1) or 1 if not found
    % show_yticklabel=0, not showing ylabels
    % plot_title_text = 1, showing title_text
% plot_data_to_subplots plots data columns to separate subplots
% For faster plotting, function uses plotBig if it is available, see 
    % https://github.com/JimHokanson/plotBig_Matlab
% Examples
    % plot_data_to_subplots(data); plot all data, fs=1 Hz assumed
    % plot_data_to_subplots(data,[],DataInfo.framerate(1)); % all data with fs
%
% Required files
    % calculate_subfig_grid.m
    % tight_subplot.m
    % fig_full.m, will create hfig matlab figure class
% Additional files    
    % For faster plotting, function uses plotBig if it is available, see 
        % https://github.com/JimHokanson/plotBig_Matlab
     % (ntitle, available at:  https://se.mathworks.com/matlabcentral/fileexchange/42114-ntitle)
        % update: title can be only plotted with axes command, so no more title is used
        % instead, legend is used to plot "name"

%% TODO: 
    % can not handle if multiple fs are given
    % "title text" is plotted with legend command 
        % legend location is north, would be maybe better slightly to left
        % or could title text be plotted without axes command
%%    
narginchk(1,5)
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
        warning('fs not given, no proper DataInfo found on workspace')
        fs=1;
        disp(['Setting fs = ', num2str(fs),' Hz'])
    end
end

% default: not showing, Ytick only shown if yticklabel_shown == 1;
if nargin < 4 || isempty(show_yticklabel)
    show_yticklabel = 0;
else
    if show_yticklabel ~= 1 && show_yticklabel ~= 0
        show_yticklabel = 0;
    end
end
% default: plot title text
if nargin < 5 || isempty(plot_title_text)
    plot_title_text = 1;
else
    if plot_title_text ~= 1 && plot_title_text ~= 0
        plot_title_text = 1;
    end
end

if length(fs) > 1 % if multiple framerate values are given
    if any(diff(fs ~= 0)) % if framerate not same in each 
        fs = fs(1); 
        warning('TODO: Should be updated, if multiple fs given, now fs = fs(1)--> same TODO: for time vector')
    else % if framerate same in each file
        fs = fs(1);
    end
    disp(['Used fs = ', num2str(fs),' Hz'])
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

time = 0:1/fs:(max(size(rawdata))-1)/fs; % TODO: for multiple fs values
[subplot_rows, subplot_columns] = calculate_subfig_grid(length(datacolumns));
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
% set(ha,'Visible','on')
for ii = 1:length(datacolumns)
        try % if plotBig available
            plotBig(ha(ii), time, rawdata(:,datacolumns(ii)))
        catch
            plot(ha(ii), time, rawdata(:,datacolumns(ii)));
        end
    if plot_title_text == 1
        hold on; hh2=line(ha(ii),nan,nan,'Linestyle', 'none',...
            'Marker', 'none', 'Color', 'none'); % plotting dummy for legend
        text_to_display = ['DataCol#', num2str(datacolumns(ii))];
        legend(hh2,text_to_display,'location','north','fontweight','bold',...
            'Fontsize',[ha(ii).FontSize+2],'box','off');
    end

end
set(ha(ii),'Visible','on') % muuten ei viimeinen aina näy
set(ha,'Xlim',[-inf inf],'Ylim',[-inf inf])
% modifying ticks:
    % remove all x-ticks except bottom subplots
    % remove all y-ticks

set(ha(1:subplot_rows*subplot_columns-subplot_columns),'XTickLabel','');
if show_yticklabel ~= 1
    set(ha,'YTickLabel','')
end
end