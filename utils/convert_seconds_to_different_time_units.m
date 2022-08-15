function [timep, xlabel_text] = convert_seconds_to_different_time_units(...
    wanted_time_unit,time_in_seconds, shift_time_seconds, datetime_for_the_first_index)
% function [timep, xlabel_text] = convert_seconds_to_different_time_units(...
%     wanted_time_unit,time_in_seconds, shift_time_to_negative, datetime_for_the_first_index)
%
% wanted_time_unit
    % 'duration', 'datetime', 'hours', 'seconds'
% shift_time_seconds: how much time is shifted; if negative, send to backwards
% e.g. useful for plotting purposes

narginchk(2,4)
nargoutchk(0,2)
if nargin < 3 || isempty(shift_time_seconds)
    shift_time_seconds = 0;
end
shift_time_seconds=shift_time_seconds(1);

if nargin < 4 || isempty(datetime_for_the_first_index)
    try
        DataInfo = evalin('base', 'DataInfo');
        datetime_for_the_first_index = DataInfo.measurement_time.datetime(1);
    catch
        error('No proper DataInfo and/or datetime')
    end
end

time_in_seconds = time_in_seconds+shift_time_seconds;

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
