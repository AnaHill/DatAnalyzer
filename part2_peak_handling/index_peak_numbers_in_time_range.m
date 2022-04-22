function found_indexes = index_peak_numbers_in_time_range...
    (peak_locations_in_time, time_range_to_find_peaks, ts)
% function indexed_peak_numbers = index_peak_numbers_in_time_range...
%     (peak_locations_in_time, time_range_to_find_peaks, ts)

narginchk(2,3)
nargoutchk(0,1)
if nargin < 3 || isempty(ts)
    ts =  1; % assuming 1 sec sampling time
end

% find indexes that are between peaks_time_range
if isempty(peak_locations_in_time)
    found_indexes = [];
else
    found_indexes(:,1) = ...
        find((peak_locations_in_time >= min(time_range_to_find_peaks)) & ...
         (peak_locations_in_time <= max(time_range_to_find_peaks)));                    
end

end