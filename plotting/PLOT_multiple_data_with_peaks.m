function [] = PLOT_multiple_data_with_peaks(Data,Data_BPM,startdata,howmanyplots,plot_peak_numbers)
% PLOT_multiple_data_with_peaks(Data,Data_BPM,startdata,howmanyplots,plot_peak_numbers)
% PLOT_multiple_data_with_peaks(Data,Data_BPM)
% PLOT_multiple_data_with_peaks(Data,Data_BPM,1)
% PLOT_multiple_data_with_peaks(Data,Data_BPM,1,5)
% PLOT_multiple_data_with_peaks(Data,Data_BPM,1,5,1) % with peak numbers
narginchk(2,5)
nargoutchk(0,0)
if nargin < 3 || isempty(startdata)
    startdata = randi([1 length(Data)],1); 
end
% how many plots are plotted
if nargin < 4 || isempty(howmanyplots)
    howmanyplots = 10;
end
% plotting or not peak_numbers
if nargin < 5 || isempty(plot_peak_numbers)
    plot_peak_numbers = 0;
end


% check if end value for plots would go out of limit
end_file_number = startdata+howmanyplots-1;
if end_file_number > length(Data)
    howmanyplots = length(Data)- startdata + 1;
end

hfigs = []; 
for pp=1:howmanyplots
    filenum = startdata+pp-1; 
    hf = PLOT_DataWithPeaks(Data,Data_BPM,filenum,[],plot_peak_numbers); 
%     hf = PLOT_DataWithPeaks(Data,Data_BPM,filenum) ; 
    hfigs(end+1,1) = hf;
    zoom on
end
for kk=length(hfigs):-1:1
    figure(hfigs(kk,1))
end