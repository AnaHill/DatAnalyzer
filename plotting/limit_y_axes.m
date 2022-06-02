function limit_y_axes(ylimits, ylimits_o2)
% function limit_y_axes(ylimits, ylimits_o2)
% use if want to limit y-axis to certain range
narginchk(0,2)

if nargin < 1 || isempty(ylimits)
    ylimits = [-inf inf];
end

if nargin < 2 || isempty(ylimits_o2)
    ylimits_o2 = [-inf inf];
end

% check how many subplots 
how_many_subplots = 0;
fig_handle = get(get(gcf,'children'),'type');
for pp=1:numel(fig_handle)
    if strcmp(fig_handle{pp},'axes')
        how_many_subplots = how_many_subplots + 1;
    end
end

% limit y-axis / y-axes
for pp = 1:how_many_subplots
    subplot(how_many_subplots,1,pp)
    try
        Data_o2 = evalin('base', 'Data_o2');
        yyaxis left
        ylim([ylimits])
        yyaxis right
        ylim([ylimits_o2])
    catch
        ylim([ylimits])
    end
end