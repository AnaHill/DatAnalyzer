function found_indexes = find_indexes_in_given_time_range...
    (time_locations_in_sec, time_range_in_sec_to_find_indexes)
% function found_indexes = find_indexes_in_given_time_range...
%     (time_locations_in_sec, time_range_in_sec_to_find_indexes)

narginchk(2,2)
nargoutchk(0,1)

% find indexes that are between peaks_time_range
if isempty(time_locations_in_sec)
    found_indexes = [];
else
    found_indexes(:,1) = ...
        find((time_locations_in_sec >= min(time_range_in_sec_to_find_indexes)) & ...
         (time_locations_in_sec <= max(time_range_in_sec_to_find_indexes)));                    
end

end