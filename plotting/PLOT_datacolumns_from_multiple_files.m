function [] = PLOT_datacolumns_from_multiple_files(Data,Data_BPM,file_index,datacolumns,plot_peak_numbers)
% PLOT_datacolumns_from_multiple_files(Data,Data_BPM,[1:5:20],3)
% PLOT_multiple_data_with_peaks(Data,Data_BPM,startdata,howmanyplots,plot_peak_numbers)
% PLOT_multiple_data_with_peaks(Data,Data_BPM,1,5,1) % with peak numbers
narginchk(2,5)
nargoutchk(0,0)
if nargin < 3 || isempty(file_index)
    file_index = randi([1 length(Data)],1); 
end

if nargin < 4 || isempty(datacolumns)
    datacolumns = 1:length(Data{file_index,1}.data(1,:));
end

% plotting or not peak_numbers
if nargin < 5 || isempty(plot_peak_numbers)
    plot_peak_numbers = 0;
end

hfigs = []; 
for pp=1:length(file_index)
    filenum = file_index(pp);
    hf = PLOT_DataWithPeaks(Data,Data_BPM,filenum,datacolumns,plot_peak_numbers); 
%     hf = PLOT_DataWithPeaks(Data,Data_BPM,filenum) ; 
    hfigs(end+1,1) = hf;
    zoom on
end
for kk=length(hfigs):-1:1
    figure(hfigs(kk,1))
end