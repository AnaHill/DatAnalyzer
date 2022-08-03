function [timep, xlabel_text] = convert_seconds_to_different_time_units(...
    wanted_time_unit,time_in_seconds, datetime_for_the_first_index)
% function [timep, xlabel_text] = convert_seconds_to_different_time_units(...
%     wanted_time_unit,time_in_seconds, datetime_for_the_first_index)

narginchk(2,3)
nargoutchk(0,2)

if nargin < 3 || isempty(datetime_for_the_first_index)
    try
        DataInfo = evalin('base', 'DataInfo');
        datetime_for_the_first_index = DataInfo.measurement_time.datetime(1);
    catch
        error('No proper DataInfo and/or datetime')
    end
end

switch wanted_time_unit
    case 'duration'
       timep = duration(seconds(time_in_seconds),'format','hh:mm:ss');
       xlabel_text = 'Duration';
    case 'datetime'
        t_dur = duration(seconds(time_in_seconds),'format','hh:mm:ss');
        timep = datetime_for_the_first_index + t_dur;
        xlabel_text = ''; 
    case 'hours'
        timep = time_in_seconds/3600;
        xlabel_text = 'Time (h)';
     case 'seconds'
        timep = time_in_seconds;
        xlabel_text = 'Time (sec)';     
    % TODO: voisiko tämän saada jotenkin järkevästi?!?
    %     case 'file_index'
    %         timep = 1:DataInfo.files_amount;
    %         xlabel_text = 'File#';
    otherwise
        error('check time')
end
end
