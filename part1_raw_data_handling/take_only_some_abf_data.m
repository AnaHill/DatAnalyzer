function [chosen_datacolumns] = take_only_some_abf_data(filename, datacolumns)
% function [datacolumns] = take_only_some_abf_data(filename, datacolumns)
narginchk(1,2)
nargoutchk(0,1)
if nargin < 2 || isempty(datacolumns)
    try
        cols = evalin('base','min(size(raw_data))');
        datacolumns = 1:cols;
    catch
        disp('no given datacolumns or raw_data found')
        disp('No datacolumns found, choosing 1')
        datacolumns = 1;
    end
end

if strcmp(filename,'20170321_04602.WT_A1_P36D45__600nM_adr0001.abf')
    chosen_datacolumns = 1; 
    
else
    disp('no chosen datacolumns given or found, choosing all')
    chosen_datacolumns = datacolumns;
end

disp(['Chosen datacolumns: ', num2str(chosen_datacolumns)])
