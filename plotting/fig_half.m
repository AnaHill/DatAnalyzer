% update 2022/02
% previously did not work correctly, if one monitor is closed after MATLABs start
% see: https://se.mathworks.com/matlabcentral/answers/102219-how-do-i-make-a-figure-full-screen-programmatically-in-matlab
hfig = figure();hfig.WindowState = 'maximized';zoom on;
pause(.2) % pause is needed for resize to work properly
set(hfig, 'OuterPosition',[hfig.OuterPosition(1)+round(hfig.OuterPosition(3)/3), ...
    hfig.OuterPosition(2)+round(hfig.OuterPosition(4)/3), ...
    round(hfig.OuterPosition(3)/2),round(hfig.OuterPosition(4)/2)])
%% tryout
% hfig = figure();hfig.WindowState = 'maximized';zoom on;
% fig_out_pos = hfig.OuterPosition;
% fig_out_pos(1) = fig_out_pos(1) +  round(fig_out_pos(3)/3);
% fig_out_pos(2) = fig_out_pos(2) +  round(fig_out_pos(4)/3);
% fig_out_pos(3:4) = round(fig_out_pos(3:4)/2);
% hfig.OuterPosition = fig_out_pos;
% set(hfig, 'OuterPosition',[hfig.OuterPosition(1:2) hfig.OuterPosition(3:4)/2])
% set(hfig, 'OuterPosition',fig_out_pos)
% clear fig_out_pos
%% older
% MP = get(0, 'MonitorPositions');
% found_monitor_numbers = 1:length(MP(:,1));
% fig_ind = find(max(MP(:,3)) == MP(:,3),1);
% fig_out_pos = [MP(fig_ind,:)];
% % half in the middle
% fig_out_pos(1) = fig_out_pos(1) +  round(fig_out_pos(3)/3);
% fig_out_pos(2) = fig_out_pos(2) +  round(fig_out_pos(4)/3);
% fig_out_pos(3:4) = round(fig_out_pos(3:4)/2);
% 
% hfig = figure('units','pixel','outerposition',[fig_out_pos]);
% zoom on;
% clear found_monitor_numbers MP fig_ind fig_out_pos