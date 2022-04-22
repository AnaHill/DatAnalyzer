function [Data_BPM] = add_peaks_from_other(...
    Data, Data_BPM, file_index, ... % compulsory
    datacolumns, peaks_from_high_to_low, ...
    peaks_time_range, peak_numbers_range, time_forward_from_peak)
% [Data_BPM] = add_peaks_from_other(Data,Data_BPM,1,3,0,[0 65])
% adds other peaks based on other side peak locations
% first delete those peaks that are found in range given
% peak_numbers_range: [first peak   last peak] to delete, assuming all in
% that range

% peaks_from_high_to_low
    % 1 (1 or above ) = add lower peaks based on high peaks
    % -1 (below < 1)  = add higher peaks based on low peaks
% examples
    % 
narginchk(3,8)
nargoutchk(0,1)

% all data columns (e.g. electrodes) if not given
if nargin < 4 || isempty(datacolumns)
   try
       datacolumns =  1:length(Data_BPM{file_index(1),1}.peak_values_high);
   catch
       try
           datacolumns =  1:length(Data_BPM{file_index(1),1}.peak_values_low);
       catch
           error('no prober peak information found')
       end
   end
           
end

% default: finding low peaks from high peak locations
if nargin < 5 || isempty(peaks_from_high_to_low)
    peaks_from_high_to_low = 1; 
end
if peaks_from_high_to_low > 1
    peaks_from_high_to_low = 1; % high peaks used to find low peaks
end
if peaks_from_high_to_low < 1
    peaks_from_high_to_low = 0; % use low peaks to find high pekas
end

% if both, are empty --> taking whole signal, and finding peaks from each
% using t_max defined earlier --> assuming signal length is always close to
% first signal given
if (nargin < 6 || isempty(peaks_time_range)) && ...
        (nargin < 7 || isempty(peak_numbers_range)) 
    % max time range (estimation), add one sec extra
    try
        fs = DataInfo.framerate(file_index(1),1);
    catch % if only one framerate 
        fs = DataInfo.framerate(1);
    end
    ts = 1/fs; 
    tmax = ts * length(Data{file_index(1),1}.data(:,datacolumns(1)))+1;
    peaks_time_range = [0 tmax]; 
    peak_numbers_range = 0;
end

if isempty(peaks_time_range)
    peaks_time_range = 0;
end

if nargin < 7 || isempty(peak_numbers_range)
    peak_numbers_range = 0;
end

% default: time forward from peak position to find local max
if nargin < 8 || isempty(time_forward_from_peak)
    if peaks_from_high_to_low  == 1 % finding low peaks from high peaks
        time_forward_from_peak = 2e-3; % range from main peak forward 
    else % finding high peaks from low peaks, 
        % default is BACKWARDS (low_mea type signal)
        time_forward_from_peak = -2e-3; 
    end
end


% deleting other peaks (if any) based on peaks_from_high_to_low
% peaks_from_high_to_low 
    % 1 = get low peaks from high peaks -> delete low  -> delete_high_peaks = 0;
    % 0 = get high peaks from low peaks -> delete high -> delete_high_peaks = 1; 
if peaks_from_high_to_low == 1 
	delete_high_peaks = 0; 
else
    delete_high_peaks = 1; % delete high peaks
end

% using only minimum and maximum time and peak range values
if length(peaks_time_range) > 1
    peaks_time_range = [min(peaks_time_range) max(peaks_time_range)];
end

if length(peak_numbers_range) > 1
    peak_numbers_range = [min(peak_numbers_range) max(peak_numbers_range)];
end

% Check if both, time and peak range are given in input: 
% if yes, use only time range
if length(peak_numbers_range) > 1 || peak_numbers_range ~= 0
    if ~isempty(peaks_time_range) && length(peaks_time_range) > 1
        peak_numbers_range = 0;
        disp('Both time and peak range given -> using only time range')
    end
end

for pp = 1:length(file_index)
    ind = file_index(pp);
    try
        fs = DataInfo.framerate(ind,1);
    catch % old data where framerate only one file
        fs = DataInfo.framerate(1);
    end
    ts = 1/fs;
    time_ind = 0:ts:(length(Data{ind,1}.data(:, datacolumns(1)))-1)*ts;
    for kk = 1:length(datacolumns)
        col = datacolumns(kk);
        raw = Data{ind,1}.data(:,col);
        % Index peaks to be deleted + times for new peaks (based on other peaks)
        
        %%% a) peak_numbers_range used to define times
        if length(peak_numbers_range) > 1 || peak_numbers_range ~= 0
            % delete given peak numbers
            peak_numbers_to_delete = peak_numbers_range;
            % find time slot: based on time range where peak_numbers_to_delete are located 
            if peaks_from_high_to_low == 1
                % find low peaks time range based on peak_numbers_to_delete
                peaks_time_range = Data_BPM{ind,1}.peak_locations_low{col,1}...
                    (peak_numbers_to_delete',1)*ts;  
                
                % define all peak times of high peaks
                peak_times_to_be_used_to_define_new_peaks = ...
                    Data_BPM{ind,1}.peak_locations_high{col,1}*ts;
                % next -> go to line after follwing else-loop
            else
                % find high peaks time range based on peak_numbers_to_delete
                peaks_time_range = Data_BPM{ind,1}.peak_locations_high{col,1}...
                    (peak_numbers_to_delete',1)*ts;     
                % define all peak times of low peaks
                peak_times_to_be_used_to_define_new_peaks = ...
                    Data_BPM{ind,1}.peak_locations_low{col,1}*ts;
                % next -> go to line after follwing else-loop
            end
            % add small time backwards and forwards to really include all
            peaks_time_range(1) = peaks_time_range(1)-.1;
            peaks_time_range(end) = peaks_time_range(end)+.1;
        %%% b) time_range: peak numbers that are in given time range 
        % given in peaks_time_range
        else 
            if delete_high_peaks == 0 
                % find low peaks times to be deleted
                % find high peak times that are used to find new low peaks
                peak_locations_in_time = Data_BPM{ind,1}.peak_locations_low{col,1}*ts;            
                peak_times_to_be_used_to_define_new_peaks = ...
                    Data_BPM{ind,1}.peak_locations_high{col,1}*ts;
            else
                % find high peaks times to be deleted
                % find low peak times that are used to find high peaks
                peak_locations_in_time = Data_BPM{ind,1}.peak_locations_high{col,1}*ts;
                peak_times_to_be_used_to_define_new_peaks = ...
                    Data_BPM{ind,1}.peak_locations_low{col,1}*ts;
            end
            peak_numbers_to_delete = find_indexes_in_given_time_range...
                (peak_locations_in_time, peaks_time_range);      
        end
        % find time locs for peaks that are used to find another peaks
        peak_numbers_to_used_for_new_peak = find_indexes_in_given_time_range...
            (peak_times_to_be_used_to_define_new_peaks, peaks_time_range);    
        % delete peaks: high_or_low_peak
        if ~isempty(peak_numbers_to_delete)
            peak_numbers_to_delete = peak_numbers_to_delete(1):peak_numbers_to_delete(end);
        end
        [Data_BPM] = delete_peaks_with_peaknumber(Data_BPM,ind,col,...
            peak_numbers_to_delete,delete_high_peaks);
        
        % define peak from other after "wrong" peaks have been deleted
        % find first time points of peaks that are used to define another peaks
        % then, based on time_forward_from_peak, calculate max/min
% % %         if peaks_from_high_to_low == 1 % times_of_high peaks for find low peaks 
% % %             % find times of high peaks
% % %             loc_times_to_find_another_peaks = ...
% % %                 Data_BPM{ind,1}.peak_locations_high...
% % %                 {col,1}(peak_numbers_to_delete,1)*ts;
% % %         else % high peaks from low peaks
% % %             loc_times_to_find_another_peaks = ...
% % %                 Data_BPM{ind,1}.peak_locations_low...
% % %                 {col,1}(peak_numbers_to_delete,1)*ts;    
% % %         end        
        time_of_peaks = ...
            peak_times_to_be_used_to_define_new_peaks(peak_numbers_to_used_for_new_peak);
        % finding low/high peak pair for each high/low peak
        % time_ind = measurement time
        index_new_peak = [];
        val_new_peak = [];
        for hh = 1:length(peak_numbers_to_used_for_new_peak)
            t1= time_of_peaks (hh);
            t2 = t1+time_forward_from_peak;
            time_range_t1tot2 = sort([t1 t2]); 
            index_of_raw_data = index_peak_numbers_in_time_range...
                (time_ind, time_range_t1tot2);                        
            % find Data in
            dat = raw(index_of_raw_data,:);
            if peaks_from_high_to_low == 1 
                % find minimum after (/before?) high peak
                [val_new_peak(hh,1) ind_temp] = min(dat);
            else 
                % find maximum before(/after) low peak
                [val_new_peak(hh,1) ind_temp] = max(dat);
            end
            index_new_peak(hh,1) = index_of_raw_data(ind_temp);
            
        end
        % figure, plot(time_ind, raw), hold all, plot(time_ind(index_new_peak), val_new_peak,'o')
        % set new peaks to Data_BPM
        if peaks_from_high_to_low == 1 
            % set low peaks
            teind = [Data_BPM{ind,1}.peak_locations_low{col,1}; index_new_peak];
            teval = [Data_BPM{ind,1}.peak_values_low{col,1}; val_new_peak];
            te_ = [teind teval];
            te_sort = sortrows(te_);
            Data_BPM{ind,1}.peak_locations_low{col,1} = te_sort(:,1);
            Data_BPM{ind,1}.peak_values_low{col,1} = te_sort(:,2); 
        else 
            % set high peaks
            teind = [Data_BPM{ind,1}.peak_locations_high{col,1}; index_new_peak];
            teval = [Data_BPM{ind,1}.peak_values_high{col,1}; val_new_peak];
            te_ = [teind teval];
            te_sort = sortrows(te_);
            Data_BPM{ind,1}.peak_locations_high{col,1} = te_sort(:,1);
            Data_BPM{ind,1}.peak_values_high{col,1} = te_sort(:,2); 
        end            
    end
end
end