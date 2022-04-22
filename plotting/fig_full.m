% update 2022/02
% previously did not work correctly, if one monitor is closed after MATLABs start
% see: https://se.mathworks.com/matlabcentral/answers/102219-how-do-i-make-a-figure-full-screen-programmatically-in-matlab
hfig = figure();hfig.WindowState = 'maximized';zoom on;

% jotain valittaa javaframesta, alla oleva ei toiminut
% hfig = figure; pause(0.00001); frame_h = get(handle(hfig),'JavaFrame');
% set(frame_h,'Maximized',1);

% ehkä myös maximize funktion käyttö
% https://se.mathworks.com/matlabcentral/fileexchange/25471-maximize

%% older
    % MP = get(0, 'MonitorPositions');
    % found_monitor_numbers = 1:length(MP(:,1));
    % fig_ind = find(max(MP(:,3)) == MP(:,3),1);
    % fig_out_pos = [MP(fig_ind,:)];
    % hfig = figure('units','pixel','outerposition',[fig_out_pos]);
    % zoom on;
    % clear found_monitor_numbers MP fig_ind fig_out_pos


% set(hfig, 'Visible','off'), disp('set figure hfig visible off')
% set(hfig, 'Visible','on'),

