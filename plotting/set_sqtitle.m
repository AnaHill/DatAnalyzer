function [sqtitle_text] = set_sqtitle(Data,DataInfo, file_index, col_ind)
narginchk(3,4)
nargoutchk(0,1)

if nargin < 4 || isempty(col_ind)
    sqtitle_text = [DataInfo.experiment_name ,' - ', ...
            DataInfo.measurement_name];
    
else
    try 
        sqtitle_text = [DataInfo.experiment_name ,' - ', ...
            DataInfo.measurement_name, 10, 'Electrode#',...
            num2str(DataInfo.MEA_electrode_numbers(col_ind))];
    catch
        sqtitle_text = [DataInfo.experiment_name ,' - ', ...
            DataInfo.measurement_name, 10, 'Electrode#',...
        num2str(Data{file_index(1),1}.data_MEA_electrode_numbers(col_ind))]; 
    end 

end


end
