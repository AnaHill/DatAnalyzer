%% update 2022/06: input order changed
% function check_peak_forms(time_range_from_peak, every_nth_data, datacolumns, plot_average,...
%     Data, DataInfo, Data_BPM)
check_peak_forms() % default time [-.2 1.4], no mean
    % check_peak_forms([],[],[],1);incl mean
t_back = -.1; t_forw = .95; % demo 3.3.
check_peak_forms([t_back t_forw])






