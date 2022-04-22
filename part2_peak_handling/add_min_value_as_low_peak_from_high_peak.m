function [Data_BPM] = add_min_value_as_low_peak_from_high_peak(...
    Data, Data_BPM, file_index, datacolumns, ... % compulsory
    peaks_time_range, peak_numbers_range,time_forward_from_peak,filter_parameters)
% adds lower peaks based on high peaks
%% TODO: katso
% first delete those low peaks that are found in range given
    % peak_number_range
    % time_range
% peak_numbers_range: [first peak  last peak] to delete, assuming all in
% that range 
%% 
narginchk(4,8)
nargoutchk(0,1)

%%%%%%%%%%%%%%%%%%%%%%%%%%


% if both, are empty --> taking whole signal, and finding peaks from each
% using t_max defined earlier --> assuming signal length is always close to
% first signal given
if (nargin < 5 || isempty(peaks_time_range)) && ...
        (nargin < 6 || isempty(peak_numbers_range)) 
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

if nargin < 6 || isempty(peak_numbers_range)
    peak_numbers_range = 0;
end

% default: time forward from peak position to find local max
if nargin < 7 || isempty(time_forward_from_peak)
        % default: backwards -> negative time
        time_forward_from_peak = -5e-3; 
end

% filtering or not
% if empty, no filter
% if length = only 1 --> use default filter values
% if length = 2 [val1 val2] --> use these as filter values
if nargin < 8 || isempty(filter_parameters)
    filtering = 0;
else % set filter
    filtering = 1;
    default_filt_values = 1; % use default filter values
    % for default: see filter_signal_data.m
    %         filt1_size = 70;
    %           filt2_size = 500;
    if length(filter_parameters) > 1 % changing
        default_filt_values = 0;
        filt1_size = filter_parameters(1);
        filt2_size = filter_parameters(2);  
    end
end

%%%%%%%%%%%%%%%%%
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
        disp('Both time and peak range given!')
        disp('Using only time range!')
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
        
        if length(peak_numbers_range) > 1 || peak_numbers_range ~= 0
        %%% a) peak_numbers_range used to define times
            % delete given peak numbers
            peak_numbers_to_delete = peak_numbers_range;
            % find time slot: based on time range where peak_numbers_to_delete are located 
            % find low peaks time range based on peak_numbers_to_delete
            peaks_time_range = Data_BPM{ind,1}.peak_locations_low{col,1}...
                (peak_numbers_to_delete',1)*ts;     
            % define all peak times of high peaks
            peak_times_to_be_used_to_define_new_peaks = ...
                Data_BPM{ind,1}.peak_locations_high{col,1}*ts;
            % add small time backwards and forwards to really include all
            peaks_time_range(1) = peaks_time_range(1)-.1;
            peaks_time_range(end) = peaks_time_range(end)+.1;
            % next -> go to line after follwing else-loop
        else
        %%% b) time_range: peak numbers that are in given time range 
        % given in peaks_time_range

        % find low peaks times to be deleted
        % find high peak times that are used to find low peaks
        peak_locations_in_time = Data_BPM{ind,1}.peak_locations_low{col,1}*ts;
        peak_times_to_be_used_to_define_new_peaks = ...
            Data_BPM{ind,1}.peak_locations_high{col,1}*ts;
        peak_numbers_to_delete = find_indexes_in_given_time_range...
            (peak_locations_in_time, peaks_time_range);
        end
        % find time locs for peaks that are used to find another peaks
        peak_numbers_to_used_for_new_peak = find_indexes_in_given_time_range...
            (peak_times_to_be_used_to_define_new_peaks, peaks_time_range);    
        % delete peaks: low_or_high_peak
        if ~isempty(peak_numbers_to_delete)
            peak_numbers_to_delete = peak_numbers_to_delete(1):peak_numbers_to_delete(end);
            % delete low peaks --> last input=0
            disp(['Deletig low peaks#: ', num2str(peak_numbers_to_delete)])
            % deleting
            [Data_BPM] = delete_peaks_with_peaknumber(Data_BPM,ind,col,...
                peak_numbers_to_delete,0);
        end

        
        % define peak from other after "wrong" peaks have been deleted
        % find first time points of peaks that are used to define another peaks
        % then, based on time_forward_from_peak, calculate max/min
        time_of_peaks = peak_times_to_be_used_to_define_new_peaks...
            (peak_numbers_to_used_for_new_peak);
        % finding low peak pair for each high peak
        % time_ind = measurement time
        index_new_peak = [];
        val_new_peak = [];
        % possible filtering whole data
        if filtering ~= 0
            disp('filtering data for analysis')
            if default_filt_values == 1
                [Data_filtered] = filter_signal_data(...
                    Data,ind, col,[]);
            else % filter values from input
                [Data_filtered] = filter_signal_data(...
                    Data,ind, col,[filt1_size  filt2_size]);  
            end
        end
        for hh = 1:length(peak_numbers_to_used_for_new_peak)
            pkhh = peak_numbers_to_used_for_new_peak(hh);
            index_of_current_high_peak = ...
                Data_BPM{ind,1}.peak_locations_high{col}(pkhh);
            icl = index_of_current_high_peak; % lyhyempi
            vcl = Data_BPM{ind,1}.peak_values_high{col}(pkhh); % value
            t1 = time_of_peaks(hh);
            t2 = t1+time_forward_from_peak;
            time_range_t1tot2 = sort([t1 t2]); 
            index_of_raw_data = index_peak_numbers_in_time_range...
                (time_ind, time_range_t1tot2);                        
            dat = raw(index_of_raw_data,:);
            % possible using filter data
            if filtering ~= 0
                dat_raw = dat;
                dat = Data_filtered{1, 1}.yff(index_of_raw_data,:);
            end
            [val_new_peak(hh,1) ind_temp] = min(dat); 
            index_new_peak(hh,1) = index_of_raw_data(ind_temp); 

        end
        if filtering ~= 0
            disp('low peaks defined from filtered signal.')
        end
        % figure, plot(time_ind, raw), hold all, plot(time_ind(index_new_peak), val_new_peak,'o')
        % set new low peaks to Data_BPM
        teind = [Data_BPM{ind,1}.peak_locations_low{col,1}; index_new_peak];
        teval = [Data_BPM{ind,1}.peak_values_low{col,1}; val_new_peak];
        te_ = [teind teval];
        te_sort = sortrows(te_);
        Data_BPM{ind,1}.peak_locations_low{col,1} = te_sort(:,1);
        Data_BPM{ind,1}.peak_values_low{col,1} = te_sort(:,2);        
    end
end
end