% Will create (approximately) half screen size figure
% First, creates full size figure, which is then reduced to half
% some delay is added that resize really works
hfig = figure();org_size = hfig.OuterPosition;
hfig.WindowState = 'maximized';
% because of some delay with WindowState = 'maximed'
% first wait enough that figure is full size
counter=0; pause_time = 0.01; max_waiting_time=0.5; % sec
while (hfig.OuterPosition <= org_size*1.02)
    % wait until figure size is maximized
    % or max_waiting_time sec
    counter = counter + 1;
    if (counter > max_waiting_time/pause_time)
        disp('break')
        break
    end
    pause(pause_time)
end
full_size_fig_parameters=hfig.OuterPosition;
% reducing size to half
set(hfig,'OuterPosition',[full_size_fig_parameters(1) + ...
    round(full_size_fig_parameters(3)/3), ...
    full_size_fig_parameters(2)+round(full_size_fig_parameters(4)/3), ...
    round(full_size_fig_parameters(3)/2),round(full_size_fig_parameters(4)/2)]);
pause(0.1)
zoom on
