function hfig = plot_high_and_low_peaks(Data,Data_BPM, file_index, col)
nargoutchk(0,1)
narginchk(4,4)
hfig=[];
for kk = 1:length(file_index)
    hfig{kk,1} = PLOT_DataWithPeaks(Data,Data_BPM, file_index(kk),col,1); 
    zoom on,
end

for kk=length(hfig):-1:1
    figure(hfig{kk,1})
end