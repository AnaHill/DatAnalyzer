function [] = delete_empty_excel_sheets(excelFileName,excelFilePath)
%%%%%%%%%%%%%%
% To delete empty first sheet, see: 
% https://se.mathworks.com/matlabcentral/answers/92449-how-can-i-delete-the-default-sheets-sheet1-sheet2-and-sheet3-in-excel-when-i-use-xlswrite
narginchk(1,2)
nargoutchk(0,0)
% Open Excel file.
%excelFileName = [savefile_name,'.xls'];
if nargin < 2 || isempty(excelFilePath)
    excelFilePath = [pwd,'\'];
end
sheetName = 'Sheet'; % EN: Sheet, DE: Tabelle, etc. (Lang. dependent)
objExcel = actxserver('Excel.Application');
objExcel.Workbooks.Open(fullfile(excelFilePath, excelFileName)); % Full path is necessary!
% Delete sheets.
try
      % Throws an error if the sheets do not exist.
      objExcel.ActiveWorkbook.Worksheets.Item([sheetName '1']).Delete;
      objExcel.ActiveWorkbook.Worksheets.Item([sheetName '2']).Delete;
      objExcel.ActiveWorkbook.Worksheets.Item([sheetName '3']).Delete;
      disp('First sheets deleted')
catch
      disp('Sheets not found'); % Do nothing.
end
% Save, close and clean up excel file.
close_excel_file