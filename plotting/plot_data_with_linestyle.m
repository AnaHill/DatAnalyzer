function [hfig] = plot_data_with_linestyle(y, x, line_marker, line_color)
% function [hfig] = 
% notice: fig_full script will create hfig structure
    % hfig = figure();hfig.WindowState = 'maximized';zoom on;

% PLOT_DataWithPeaks(Data,Data_BPM) 
% PLOT_DataWithPeaks(Data,Data_BPM,[],[],1); % with peak numbers
% PLOT_DataWithPeaks(Data,Data_BPM,1,[1:3],1,1); % with peak numbers and to same fig

narginchk(1,4)
nargoutchk(0,1)
if nargin < 2 || isempty(x)
    x = 1:length(y(:,1));
end
if nargin < 3 || isempty(line_marker)
    line_marker = '-';
end
if nargin < 4 || isempty(line_color)
    line_color = '';
end

if isempty(line_color)
    hfig = plot(x,y,line_marker);
else
    hfig = plot(x,y,line_marker,'color',line_color);
end

end