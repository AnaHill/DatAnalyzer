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
%% Pois
% function indexed_peak_numbers = index_peak_numbers_in_time_range...
%     (peak_locations_in_time, time_range_to_find_peaks, ts)
% % function indexed_peak_numbers = index_peak_numbers_in_time_range...
% %     (peak_locations_in_time, time_range_to_find_peaks, ts)
% 
% narginchk(2,3)
% nargoutchk(0,1)
% if nargin < 3 || isempty(ts)
%     ts =  1; % assuming 1 sec sampling time
% end
% 
% % find peaks that are between peaks_time_range
% if isempty(peak_locations_in_time)
%     indexed_peak_numbers = [];
% else
%     indexed_peak_numbers(:,1) = ...
%         find((peak_locations_in_time >= min(time_range_to_find_peaks)) & ...
%          (peak_locations_in_time <= max(time_range_to_find_peaks)));                    
% end
% 
% end