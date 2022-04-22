function [] = PLOT_multiple_peak_histograms(Data,Data_BPM,startdata,howmanyplots)
% PLOT_multiple_peak_histograms(Data,Data_BPM,startdata,howmanyplots)
% PLOT_multiple_peak_histograms(Data,Data_BPM)
% PLOT_multiple_peak_histograms(Data,Data_BPM,1)
% PLOT_multiple_peak_histograms(Data,Data_BPM,1,5)

narginchk(2,4)
nargoutchk(0,0)
if nargin < 3 || isempty(startdata)
    startdata = randi([1 length(Data)],1); 
end
% how many plots are plotted, default is given
if nargin < 4 || isempty(howmanyplots)
    howmanyplots = 10;
end

% check if end value for plots would go out of limit
end_file_number = startdata+howmanyplots-1;
if end_file_number > length(Data)
    howmanyplots = length(Data)- startdata + 1;
end

hfigs_hist = []; 
for pp=1:howmanyplots
    filenum = startdata+pp-1; 
    hf_hist = PLOT_PeakHistogram(Data,Data_BPM,filenum);
    hfigs_hist(end+1,1) = hf_hist;
    zoom on
end
for kk=length(hfigs_hist):-1:1
    figure(hfigs_hist(kk,1))
end