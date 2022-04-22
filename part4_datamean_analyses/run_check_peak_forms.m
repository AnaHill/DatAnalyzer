% check_peak_forms(Data, DataInfo, Data_BPM,...
%     time_range_from_peak, every_nth_data, datacolumns, plot_average)
% check_peak_forms % default values, fastest
% check_peak_forms([],[],[],[], [],[],1); % default time [-.2 1.4], incl mean

%%% find suitable time range
% t_back = -.1; t_forw = .95; % demo 3.3.
% t_back = -.1; t_forw = 1.2; % demo 3.13.

check_peak_forms([],[],[],[t_back t_forw], [],[],1); % % mean plot included