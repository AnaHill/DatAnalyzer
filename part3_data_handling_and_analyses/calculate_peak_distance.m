function [peak_dist_ms] = calculate_peak_distance(Data_BPM,DataInfo,filenumbers, datacolumns)
% calculate peak distances in ms
% [peak_dist_ms] = calculate_peak_distance(Data_BPM,DataInfo,filenumbers, datacolumns)
% [peak_dist_ms] = calculate_peak_distance(Data_BPM,DataInfo,[], 3)
narginchk(2,4) 
nargoutchk(0,1)

%%%
if nargin < 3 || isempty(filenumbers)
  filenumbers =  [1:DataInfo.files_amount]';
end
if nargin < 4 ||  isempty(datacolumns)
  datacolumns =  1:length(Data_BPM{filenumbers(1), 1}.peak_locations);% peak_distances_in_ms);
end 


for pp = 1:length(filenumbers)
    index = filenumbers(pp);
    try
        fs = DataInfo.framerate(index,1);
    catch % old data where framerate only one file
        fs = DataInfo.framerate(1);
    end
    disp(['Checking peak distances in file#',num2str(index),'/',num2str(length(filenumbers))])
    for kk = 1:length(datacolumns)
        index_col = datacolumns(kk);
        peak_dist_ms{index,1}(:,index_col) = ...
            diff(Data_BPM{index, 1}.peak_locations{index_col})/...
            fs*1e3;
    end



end

end