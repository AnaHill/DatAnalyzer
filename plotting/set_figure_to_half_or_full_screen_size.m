function hfig = set_figure_to_half_or_full_screen_size(hfig,full_sized)
% function hfig = set_figure_to_half_or_full_screen_size(hfig,full_sized)
% full size image if full_sized = 1, otherwise half screen
narginchk(0,2)
nargoutchk(0,1)

if nargin < 1 || isempty(hfig)
    hfig = figure;
end
if nargin < 2 || isempty(full_sized)
    full_sized = 0;
end
org_size = hfig.OuterPosition;
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

if any(full_sized ~= 1)
    % reducing size to half
    set(hfig,'OuterPosition',[full_size_fig_parameters(1) + ...
        round(full_size_fig_parameters(3)/3), ...
        full_size_fig_parameters(2)+round(full_size_fig_parameters(4)/3), ...
        round(full_size_fig_parameters(3)/2),round(full_size_fig_parameters(4)/2)]);
    pause(0.1)  
    
end

end