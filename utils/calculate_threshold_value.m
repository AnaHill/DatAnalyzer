function threshold_value = calculate_threshold_value(peak_value, ...
    baseline_value, threshold_level_from_baseline)
narginchk(1,3)
nargoutchk(0,1)


if nargin < 2 || isempty(baseline_value)
    baseline_value = 0;
    disp('Set baseline value to zero.')
end

% default threshold_level = 10% from baseline
if nargin < 3 || isempty(threshold_level_from_baseline)
    threshold_level_from_baseline = 0.1; % equals 10%
    disp('Set threshold_level to 10% from baseline.')
end

amplitude = peak_value - baseline_value;
threshold_value = amplitude*threshold_level_from_baseline + baseline_value;
% if peak_value > baseline_value
%     threshold_value = amplitude*threshold_level_from_baseline + baseline;
% elseif peak_value < baseline_value
%     threshold_value = amplitude*threshold_level_from_baseline + baseline;
% end