function [flag_delay_in_the_edges] = ...
    check_peak_distance_from_edges(peak_times, end_time, gain, start_time)
% function [flag_delay_in_the_edges] = ...
%     check_peak_distance_from_edges(peak_times, end_time, gain, start_time)
% CHECK_PEAK_DISTANCE_FROM_EDGES check if there is long delays in the
% begin/end of the signal, related to peaks found in data

% modification 2021/08:
% now check is based on max_distance * Gain
% where max_distance in maximum peak distances (non-edges

% modification 2021/04:
% now concerning begin and end distance are compared to max peak distance 
% (previously to mean peak distance value)

%   flag_delay_in_the_edges tells, tells status of the signal
%   %  0 = no delay in either edge
%   %  1 = delay in the start before first peak
%   %  2 = delay in the end after last peak
%   %  3 = delay in both edges

%   % Example 1: % flag 3 with delays in both edges
    % Fs = 1000; % samples per second
    % dt = 1/Fs;% seconds per sample
    % StopTime = 61; % seconds
    % time = (0:dt:StopTime)';% seconds
    % BPM = 15; % beats per minute
    % Fc = BPM/60; % hertz
    % Amplitude = 20; % signal amplitude
    % x = cos(2*pi*Fc*time)*Amplitude;
    % signal = awgn(x,Amplitude/5,'measured'); % random noise
    % % setting delays in the begin & end
    % delay_seconds = 5; % how long delay
    % signal(1:Fs*delay_seconds)=rand(Fs*delay_seconds,1)-0.5;
    % signal(end-Fs*delay_seconds+1:end)=rand(Fs*delay_seconds,1)-0.5;
    % % finpeaks
    % [peaks,locs] = findpeaks(signal,'MinPeakDistance',...
    %     Fs/(Fc)/1.5,'MinPeakHeight',Amplitude);
    % % Plot the signal versus time and peaks:
    % figure; plot(time,signal); hold all, plot(time(locs),peaks,'o','color','red')
    % xlabel('time (in seconds)'); title('Signal versus Time');zoom xon;
    % [flag] = check_peak_distance_from_edges(time(locs),time(end)) % check delay flag

%% check inputs and outputs
narginchk(1,4)
nargoutchk(1,1)
% default values if not given
if nargin < 2 || isempty(end_time) % end time is last peak time
    end_time = max(peak_times(:));
end
% gain: how many times longer delay compared avg peak distance is accepted
if nargin < 3 || isempty(gain)
    gain = 1.5;
end
if nargin < 4 || isempty(start_time)
   start_time = 0; 
end
% distance between start and the fist peak
firstpeak_distance = min(peak_times) - start_time;
% distance between last peak and end of signal
lastpeak_distance = end_time - max(peak_times);


% peak distances
peak_distances = diff(peak_times);
peak_distances_avg = mean(peak_distances);
peak_distances_std = std(peak_distances);
peak_distances_max= max(peak_distances);
%% minimum distance that is flagged as delay
% update 2021/08: mean_dist * Gain directly
minimum_distance_for_delay = peak_distances_max*gain;

% previously: avg peak distance + std*gain
% update 2021/04: comparing max peak distance to begin and end,
% minimum_distance_for_delay = peak_distances_max  + peak_distances_std*gain;
    % e.g. if avg = 1 (s), and std = 0.1 (10%), and using gain=1.5 ->
    % delay if flagged if distance is > 1+0.1*gain = 1.15;
    % minimum_distance_for_delay = peak_distances_avg  + peak_distances_std*gain;




%% set flag
% 0 = no delay in either edge
% 1 = delay in start
% 2 = delay in end
% 3 = delay in both edges
flag_delay_in_the_edges = 0;

if firstpeak_distance > (minimum_distance_for_delay)
    flag_delay_in_the_edges = flag_delay_in_the_edges + 1;
end
if lastpeak_distance > (minimum_distance_for_delay)
    flag_delay_in_the_edges = flag_delay_in_the_edges + 2;
end

switch flag_delay_in_the_edges
    case 0
        % disp('edges ok')
    case 1
        warning('Long delay in the begin before first peak')
    case 2
        warning('Long delay in the end after last peak')
    case 3
        warning('Long delays in the begin and end, before&after first/last peaks')
end

