function info_found_peak  = find_peak_info(peak_values, max_or_min_value)
% function info_found_peak  = find_peak_info(peak_values, max_or_min_value)
narginchk(1,2)
nargoutchk(0,1)
if nargin < 2 || isempty(max_or_min_value)
    max_or_min_value = 'max';
    disp('Assuming maximum value was found.')
end


if any(peak_values < 0) && strcmp(max_or_min_value,'max')
    info_found_peak = 'Unexpected peak(s): Negative maximum value.';
elseif any(peak_values > 0) && strcmp(max_or_min_value,'min')
    info_found_peak = 'Unexpected peak(s): Positive minimum value.';
else % normal case
    if strcmp(max_or_min_value,'max')
        info_found_peak = 'Expected peak(s): Positive maximum value.';
    else
        info_found_peak = 'Expected peak(s): Negative minimum value.';
    end
end
