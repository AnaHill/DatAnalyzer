function plot_hypoxia_line(timep, dat, DataInfo)
try
    hyp_start = DataInfo.hypoxia.start_time_index;
    hyp_end = DataInfo.hypoxia.end_time_index;
    line([timep(hyp_start) timep(hyp_start)], [min(dat(:)) max(dat(:))],...
        'color', [.4 .4 .4],'linestyle','--')
    line([timep(hyp_end) timep(hyp_end)], [min(dat(:)) max(dat(:))],...
        'color', [.4 .4 .4],'linestyle','--')
catch
    disp('no hypoxia information to plot')
end
end