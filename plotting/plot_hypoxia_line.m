function [line_hypox_start, line_hypox_end] = ...
    plot_hypoxia_line(timep, dat, DataInfo, disp_if_no_hypoxia_line)
% function [line_hypox_start, line_hypox_end] = plot_hypoxia_line(timep, dat, DataInfo, disp_if_no_hypoxia_line)
% plot hypoxia line if exist in DataInfo.hypoxia
narginchk(3,4)
nargoutchk(0,2)

% default: do not print  "no hypoxia_line"
if nargin < 4 || isempty(disp_if_no_hypoxia_line)
    disp_if_no_hypoxia_line = 0;
end
disp_if_no_hypoxia_line = disp_if_no_hypoxia_line(1);

try
    hyp_start = DataInfo.hypoxia.start_time_index;
    hyp_end = DataInfo.hypoxia.end_time_index;
    line_hypox_start = line([timep(hyp_start) timep(hyp_start)], [min(dat(:)) max(dat(:))],...
        'color', [.4 .4 .4],'linestyle','--');
    line_hypox_end = line([timep(hyp_end) timep(hyp_end)], [min(dat(:)) max(dat(:))],...
        'color', [.4 .4 .4],'linestyle','--');
catch
    line_hypox_start = nan; 
    line_hypox_end = nan; 
    if disp_if_no_hypoxia_line(1) ~= 0
        disp('no hypoxia information to plot')
    end
end

end