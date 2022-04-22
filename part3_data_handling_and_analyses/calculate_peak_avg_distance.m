function [peak_dist_ms_avg_and_std] = calculate_peak_avg_distance...
    (Data_BPM_summary,DataInfo,filenumbers, datacolumns)
% calculate avg and std of peak distances
% [peak_dist_ms_avg_and_std] = calculate_peak_distance(Data_BPM_summary,DataInfo,filenumbers, datacolumns
% [peak_dist_ms_avg_and_std] = calculate_peak_distance(Data_BPM_summary,DataInfo)
% [peak_dist_ms_avg_and_std] = calculate_peak_distance(Data_BPM_summary,DataInfo,[], 3)
narginchk(2,4) 
nargoutchk(0,1)


if nargin < 3 || isempty(filenumbers)
    filenumbers =  [1:DataInfo.files_amount]';
end
if nargin < 4 ||  isempty(datacolumns)
    datacolumns =  1:length(Data_BPM_summary.peak_distances...
        {filenumbers(1)}(1,:));
end 


for pp = 1:length(filenumbers)
    index = filenumbers(pp);
    disp(['Calculating avg peak distance in file#',num2str(index),'/',num2str(length(filenumbers))])
    for kk = 1:length(datacolumns)
        index_col = datacolumns(kk);
        peak_dist_ms_avg_and_std.avg(index,index_col) = ...
            mean(Data_BPM_summary.peak_distances{index,1}(:,index_col));
        peak_dist_ms_avg_and_std.std(index,index_col) = ...
            std(Data_BPM_summary.peak_distances{index,1}(:,index_col));
        
    end



end

end