%% saves, closes and clean up 
% When Excel sheet
    % sheetName = 'Sheet'; % EN: Sheet, DE: Tabelle, etc. (Lang. dependent)
    % objExcel = actxserver('Excel.Application');
    % objExcel.Workbooks.Open(fullfile(excelFilePath, excelFileName)); % Full path is necessary!

% Save, close and clean up.
try
    objExcel.ActiveWorkbook.Save;
    objExcel.ActiveWorkbook.Close;
    objExcel.Quit;
    objExcel.delete;
catch
    disp('No active excel sheet found.')
end