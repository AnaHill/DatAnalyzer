function [chosen_data_columns, best_electrodes] = choose_best_electrodes(sorted_best_data_column_list,...
    how_many_best,DataInfo)

narginchk(1,3)
nargoutchk(0,2)

% default: choosing half of the lisht
if nargin < 2 || isempty(how_many_best)
    how_many_best = round(length(sorted_best_data_column_list)/2);
end
if nargin < 3 || isempty(DataInfo)
    DataInfo = evalin('base','DataInfo');
end

chosen_data_columns = sorted_best_data_column_list(1:how_many_best,1);
% finding chosen data columns from DataInfo.electrode_layout
[~,b] = ismember(DataInfo.electrode_layout.index,chosen_data_columns);
temp = sortrows([b,DataInfo.electrode_layout.electrode_number]);
temp2 = temp(find(temp(:,1)),:);
best_electrodes = temp2(:,2); 
clear temp temp2 b 

end
