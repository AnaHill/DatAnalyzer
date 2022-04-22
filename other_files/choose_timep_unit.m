function [timep, xlabel_text] = choose_timep_unit(timep_unit,DataInfo)
switch timep_unit
    case 'datetime'
        timep = DataInfo.measurement_time.datetime;
        xlabel_text = '';
    case 'hours'
        timep = DataInfo.measurement_time.time_sec/3600;
        xlabel_text = 'Time (h)';
        
    case 'file_index'
        timep = 1:DataInfo.files_amount;
        xlabel_text = 'File#';
    otherwise
        error('check time')
end
end