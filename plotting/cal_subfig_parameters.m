function [fig_parameters] = cal_subfig_parameters(Data, varargin)
% function [fig_parameters] = cal_subfig_parameters(Data, varargin)
% vararging:  max_sub_figs = max number of subfigs in one figure
% fig_parameters = [sub_fig_rows, sub_fig_cols, new_fig_number,num];
if length(varargin) == 0
    max_sub_figs = 25; % max number of subfigs in one figure
    % set(gcf, 'units','normalized');
else
    max_sub_figs =varargin{1};
end
ld = length(Data);
% sub_fig_cols = ceil(sqrt(ld));
% sub_fig_rows = ceil(ld/sub_fig_cols);

if ld > max_sub_figs
    sub_fig_cols = ceil(sqrt(max_sub_figs));
    sub_fig_rows = ceil(max_sub_figs/sub_fig_cols);
else
    sub_fig_cols = ceil(sqrt(ld));
    sub_fig_rows = ceil(ld/sub_fig_cols);
end
if ld < 4 % jos max 3 -> subplots below 
   sub_fig_cols =  1;
   sub_fig_rows = ld;
end
% if ld=7 or 8,  changing to 2x4 matrix
if ld == 7 || ld == 8
    sub_fig_cols = 4;
    sub_fig_rows = 2;
end

% if ld=10,  changing to 2x5 matrix
if ld == 10
    sub_fig_cols = 5;
    sub_fig_rows = 2;
end

% new_fig_number = sub_fig_cols * sub_fig_rows + 1;
new_fig_number = ld + 1;
num=1;
fig_parameters = [sub_fig_rows, sub_fig_cols, new_fig_number,num];

end

