function [datacolumn_info_text] = create_datacolumn_text(datacolumn_ind,DataInfo)
% function [datacolumn_info_text] = create_datacolumn_text(datacolumn_ind,DataInfo)
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

try 
    if isfield(DataInfo,'MEA_electrode_numbers')
        datacolumn_info_text = ['Electrode#',...
            num2str(DataInfo.MEA_electrode_numbers(datacolumn_ind))];
    else
        datacolumn_info_text = ['Col#',...
            num2str(DataInfo.datacol_numbers(datacolumn_ind))];
    end
catch
    datacolumn_info_text = ['unknown data column'];
end