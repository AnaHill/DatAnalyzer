function [data_converted, ylabel_text] = ...
    create_data_and_ylabel_text_for_peak_analysis_plot(...
    data_distance_in_seconds, wanted_y_unit, normalizing_indexes)
narginchk(1,3)
nargoutchk(0,2)

% default: Beating rate (BPM)
if nargin < 2 || isempty(wanted_y_unit)
    wanted_y_unit = 'BPM';
end

% default: not normalizing values --> normalizing_y_indexes = []
if nargin < 3 || isempty(normalizing_indexes)
    normalizing_indexes = [];
end

% empty normaling if any index is 0 or below
if ~isempty(normalizing_indexes)
    if any(normalizing_indexes <= 0)
        normalizing_indexes = [];
    end
end
switch wanted_y_unit
    case 'BPM'
       data_converted = 60./data_distance_in_seconds;
       ylabel_text = 'Beating rate (BPM)';
    case 'frequency'
       data_converted = 1 ./ data_distance_in_seconds;
       ylabel_text = 'Frequency (Hz)';     
    case 'peak_distance_in_milliseconds'   
        data_converted = data_distance_in_seconds;
        ylabel_text = 'Peak-to-peak distance (ms)';
    case 'peak_distance_in_seconds'   
        ylabel_text = 'Peak-to-peak distance (s)';
        data_converted = data_distance_in_seconds; 
    otherwise
        error('Check unit!')
end

if ~isempty(normalizing_indexes)
    data_converted = data_converted ./ median(data_converted(normalizing_indexes));
    switch wanted_y_unit
        case 'BPM'
            ylabel_text = 'Beating rate (norm)';
        otherwise
            ylabel_text = 'Peak-to-peak distance (norm)';
    end
end

end
