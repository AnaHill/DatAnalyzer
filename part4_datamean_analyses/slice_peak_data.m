%slice peak data
col = datacolumns(pp);
locs = Data_BPM{file_index, 1}.peak_locations{col};
index_from_start = index_from_peak(end)-index_from_peak(1);
locs_start = locs+index_from_peak(1);
% delete non full signals (peak is too close to begin)
locs_start(locs_start <= 0) = [];
locs_end = locs_start+index_from_start;
% delete if last signal(s) are not fully
% also deleted locs_start of those
if any (locs_end > length(Data{file_index, 1}.data(:,col)))
    index_end_to_delete = find(locs_end > length(Data{file_index, 1}.data(:,col)));
    locs_end(index_end_to_delete) = [];
    locs_start(index_end_to_delete) = [];
end

locs_start = uint64(locs_start);
index_from_start = uint64(index_from_start);
locs_end = uint64(locs_end);
col = uint64(col);
DataPeak{1,col} = double(zeros((index_from_start+1),length(locs_start)));

%%%%%% Make matrix from data between locs_start and locs_end
for zz = 1:length(locs_start)
    DataPeak{1,col}(:,zz) = Data{file_index, 1}.data...
        (locs_start(zz):locs_end(zz),col);
end
