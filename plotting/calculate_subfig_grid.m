function [sub_fig_rows, sub_fig_cols] = calculate_subfig_grid(datacolumns_total)
% function [sub_fig_rows, sub_fig_cols] = calculate_subfig_grid(datacolumns_total)
% TODO: warning if too large subfig would be created
narginchk(1,1)
nargoutchk(0,2)

ld = datacolumns_total;

sub_fig_cols = ceil(sqrt(ld));
sub_fig_rows = ceil(ld/sub_fig_cols);

if ld < 4 % jos max 3 -> subplots below each other
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





end

