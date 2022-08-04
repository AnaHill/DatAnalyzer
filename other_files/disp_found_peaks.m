function disp_found_peaks(DataInfo, Data_BPM)
narginchk(0,2)
nargoutchk(0,0)

if nargin < 1 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end

if nargin < 2 || isempty(Data_BPM)
    try
        Data_BPM = evalin('base', 'Data_BPM');
    catch
        error('No proper Data_BPM')
    end
end
disp(['',10,'%%%%%%%%%%%%%%%',10,'Printing number of peaks in each datacolumn: '])
try
    disp(['    ', num2str(DataInfo.datacol_numbers)])
catch % if no DataInfo.datacol_numbers
    try 
        disp(['    ', num2str(1:length(DataInfo.MEA_columns))])
    catch
        disp(['    ', num2str(1:length(Data_BPM{1, 1}.peak_locations))])
    end
end
disp('%%%%%%%%%%%%%%%')

for pp = 1:DataInfo.files_amount
    disp(['File#',num2str(pp), ': ',...
        num2str(Data_BPM{pp, 1}.Amount_of_peaks')])
end

end


