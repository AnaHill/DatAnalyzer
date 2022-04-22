function [Data] = remove_offset(Data,DataInfo, ...
    baseline_time_range, baseline_index_start_and_stop,...
    file_index_to_analyze, datacolumns)
% function [Data] = remove_offset(Data,DataInfo, ...
%     baseline_time_range, baseline_index_start_and_stop,...
%     file_index_to_analyze, datacolumns)
narginchk(1,6)
nargoutchk(0,1)
% Assuming data in Data{file_index,1}.data(:,datacolumns) format
if nargin < 2 || isempty(DataInfo) 
    try
        DataInfo = evalin('base','DataInfo');
    catch
        error('No DataInfo')
    end
end   
% default: every file is analyzed
if nargin < 5 || isempty(file_index_to_analyze) 
    file_index_to_analyze = 1:DataInfo.files_amount;
end

fs = DataInfo.framerate(file_index_to_analyze(1));
% default amount of samples to calculate offset based on fs
if fs > 1e3 && fs <= 1e4
    as_def = 100; 
elseif fs > 1e4
    as_def = 1000; 
else
    as_def = round(fs/10);
end

% default range to calculate offset
% mean of first 100 samples
if (nargin < 3 || isempty(baseline_time_range)) && ...
    (nargin < 4|| isempty(baseline_index_start_and_stop))
    baseline_time_range = [0 as_def/fs]; 
    disp(['Calcuting offset from default settings, mean value from t: ',...
        num2str(baseline_time_range)])
    start_index = baseline_time_range(1)/fs+1;
    baseline_index_start_and_stop = [start_index start_index+as_def];
else
    disp(['Calculating value from time: ', num2str(baseline_time_range)])
    disp(['Indexes from ',num2str(baseline_index_start_and_stop(1)),' to ',...
        num2str(baseline_index_start_and_stop(2))])
end
baseline_time_range = unique(sort(baseline_time_range));
if length(baseline_time_range) < 2 
    def_time = .1;
    baseline_time_range = [baseline_time_range baseline_time_range+def_time];
else
    baseline_time_range = [min(baseline_time_range) max(baseline_time_range)];
end

% start and stop indexes
if nargin < 4 || isempty(baseline_index_start_and_stop)
    start_index = baseline_time_range(1)/fs+1;
    baseline_index_start_and_stop = [start_index start_index+as_def];
end

baseline_index_start_and_stop = unique(sort(baseline_index_start_and_stop));
if length(baseline_index_start_and_stop) < 2 
    baseline_index_start_and_stop = [baseline_index_start_and_stop ...
        baseline_index_start_and_stop+as_def];
else
    baseline_index_start_and_stop = [min(baseline_index_start_and_stop) ...
        max(baseline_index_start_and_stop)];
end


% default: all datacolumns analyzed
if nargin < 6 || isempty(datacolumns) 
    datacolumns = 1:length(DataInfo.datacol_numbers);
end



%% Calculate & remove offset (=mean value between baseline_index_start_and_stop) 
framerates = DataInfo.framerate;
bs = baseline_index_start_and_stop(1);
be = baseline_index_start_and_stop(end);
for kk = 1:length(file_index_to_analyze)
    file_index = file_index_to_analyze(kk);
    fs = framerates(file_index);   
	for pp = 1:length(datacolumns)
        col = datacolumns(pp);
        dat = Data{file_index,1}.data(:,col);
        % offset = mean
%         offset_dat = mean(dat(bs:be,1));
        % offset = median --> better than mean? update 2021/09
        offset_dat = median(dat(bs:be,1));
        % remove offset
        dat_offset_removed = dat-offset_dat;
        % update
        Data{file_index,1}.data(:,col) = dat_offset_removed;
        disp(['Removed offset from File#',num2str(file_index),' - datacol#',...
            num2str(col),': ',num2str(round(offset_dat*1e6,2)),'e-6'])
        Data{file_index,1}.removed_offset(col,1) = offset_dat;
    end
    
end


end
