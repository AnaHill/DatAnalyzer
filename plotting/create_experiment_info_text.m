function [experiment_info_text] = create_experiment_info_text(file_index,DataInfo)
% function [experiment_info_text] = create_experiment_info_text(file_index,DataInfo)
% create electrode/datacolumn text for title/legend etc 

narginchk(1,2)
nargoutchk(0,1)

if nargin < 2 || isempty(DataInfo)
    try
        DataInfo = evalin('base','DataInfo');
    catch
        error('No proper DataInfo')
    end
end

exp_name_text = [DataInfo.experiment_name,' / ',...
    DataInfo.measurement_name];
time_name_text = [', t=',num2str(round(...
    DataInfo.measurement_time.time_sec(file_index,1)/3600,1)),'h'];
try % including hypoxia name if available
    name_temp = DataInfo.hypoxia.names{file_index};
    time_name_text = [time_name_text,' (',name_temp,')'];   
catch
    % disp('No hypoxia names defined')
end

experiment_info_text = [exp_name_text, ': Datafile#', num2str(file_index),...
    time_name_text,10,DataInfo.file_names{file_index,1}(1:end-3)];

end

