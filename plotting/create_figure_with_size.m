function [hfig] = create_figure_with_size(chosen_figure_size)
% hfig = create_figure_with_size(chosen_figure_size)
% hfig = create_figure_with_size()
% create_figure_with_size()
% Creates certain size figure: three different size options are
    % 'Full screen', 'Default size','Half screen'

narginchk(0,1)
nargoutchk(0,1)

% default figure size full screen if not given
if nargin < 1 || isempty(chosen_figure_size)
    chosen_figure_size = 'Full screen';
end

% Set full screen figure if input is not one of these
% 'Full screen', 'Default size','Half screen'
if all(~strcmp(chosen_figure_size, {'Full screen', 'Default size','Half screen'}))
    warning(['Input parameter ',chosen_figure_size,' not prober'])
    disp('Choosing full screen figure')
    chosen_figure_size = 'Full screen';
end


switch chosen_figure_size
    case 'Full screen'
        hfig = figure;
        hfig.WindowState = 'maximized';
    case  'Default size'
        hfig = figure;
    case 'Half screen'
        % with half screen, some delay is needed to work properly
        % first, figure is created, then waiting until figure is maximixed
        % before reduce size to half of full screen size
        hfig = figure;
        org_size = hfig.OuterPosition;
        % because of some delay with WindowState = 'maximed'
        % this will first wait enough that figure is full size
        hfig.WindowState = 'maximized';
        counter=0;
        pause_time = 0.01;
        max_waiting_time=0.5; % sec, max time to wait for 
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
        
end