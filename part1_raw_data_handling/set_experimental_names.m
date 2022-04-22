function [info_out] = set_experimental_names(folder_of_files,info_temp)
% SET_EXPREIMENTAL_NAMES asks info related data that will be analyzed
    % experiment and measurement names, and measurement date
% function [experiment_name,measurement_name, measurement_date] = ...
%     set_experimental_names(folder_of_files,info)
% in: 
    % folder_of_files: folder for data
    % info: optional; initial names for out files that can be used/modified
% out: info_out struct which includes variables
    % experiment_name
    % measurement_name
    % measurement_date
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
narginchk(1,2)
nargoutchk(1,1)


% if info not given --> taking from folder structure 
if nargin < 2 
    temp_exp_names=[];
    [startIndex,endIndex] = regexp(folder_of_files,'\'); 
    % last folder typically measurement name --> second last folder might be
    % experimental
    % 2nd last folder name
    temp_exp_names{1} = folder_of_files(startIndex(end-2)+1:startIndex(end-1)-1);
    % last folder name --> default for measurement name
    temp_exp_names{end+1,1} = folder_of_files(startIndex(end-1)+1:startIndex(end)-1);
    % measurement date
    temp_exp_names{end+1,1} = '2021_XX_XX';
else
    temp_exp_names = info_temp;
    if isrow(temp_exp_names)
        temp_exp_names = temp_exp_names';
    end
    if length(temp_exp_names) > 3
        temp_exp_names = temp_exp_names(1:3);
    end
    while length(temp_exp_names) < 3
        temp_exp_names{end+1,1} = 'temp';
    end
end
prompt = {['Folder location: ',folder_of_files,10,'Write experiment name'],...
    'Write measurement name (typically parallel measurement indicator)',...
    'Write measurement date, typically starting date (format: YYYY_MM_DD)'};
dlgtitle = 'Set name';
definputs = [temp_exp_names];
opts.Interpreter = 'none';
output_names = inputdlg(prompt,dlgtitle,[1 200],definputs,opts);

if isempty(output_names)
    info_out.experiment_name = 'not_given';
    info_out.measurement_name = 'not_given';
    info_out.measurement_date = 'not_given';    
else
    info_out.experiment_name = output_names{1};
    info_out.measurement_name = output_names{2};
    info_out.measurement_date = output_names{3};
end

end