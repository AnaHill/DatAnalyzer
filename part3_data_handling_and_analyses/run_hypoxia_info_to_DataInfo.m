function DataInfo = run_hypoxia_info_to_DataInfo(DataInfo, hps, hpe)
% function DataInfo = run_hypoxia_info_to_DataInfo(DataInfo, hps, hpe)
% hps = hypoxia start index
% hpe = hypoxia end index
narginchk(0,3)
nargoutchk(1,1)
if nargin < 1 || isempty(DataInfo)
   DataInfo = evalin('base','DataInfo');
end

tm = DataInfo.measurement_time.time_sec/3600;

if nargin < 2 || isempty(hps)
    % hypoxia information in hour
    if strcmp(DataInfo.experiment_name,'demo3')
        thypox_start = 13; 
    end
    try
        hps = find(tm >= thypox_start,1); % hypoxia start index
    catch
      error('Proper hypoxia start index not found!') 
    end
end

    
if nargin < 3 || isempty(hpe)
	% hypoxia information in hour
    if strcmp(DataInfo.experiment_name,'demo3')
        thypox_start = 13;
        thypox_dur = 8;
        thypox_end = thypox_start+thypox_dur;
    end
    try
        hpe = find(tm >= thypox_end,1); % hypoxia end index
    catch
        disp('Setting hypoxia end index to last one')
        hpe = DataInfo.files_amount; % last index
        % error('Proper hypoxia end index not found!')
    end
end


DataInfo.hypoxia.start_time_index = hps;
DataInfo.hypoxia.end_time_index = hpe;
DataInfo.hypoxia.start_time_sec = tm(hps)*3600;
DataInfo.hypoxia.end_time_sec = tm(hpe)*3600;
% Update hypoxia names
DataInfo = set_hypoxia_time_names(DataInfo);


end
