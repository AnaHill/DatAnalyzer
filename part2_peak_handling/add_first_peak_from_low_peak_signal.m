function [Data_BPM] = add_first_peak_from_low_peak_signal(...
    Data, Data_BPM,...
    file_index, datacolumns, ... 
    peaks_time_range, peak_numbers_range, time_forward_from_peak,filter_parameters)
% adds higher peaks based on low peaks
% first delete those high peaks that are found in range given
    % peak_number_range
    % time_range
% peak_numbers_range: [first peak  last peak] to delete, assuming all in
% that range 
narginchk(0,8)
nargoutchk(0,1)

%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    DataInfo = evalin('base', 'DataInfo');
catch
    error('No proper DataInfo')
end

if nargin < 1 || isempty(Data)
    try
        Data = evalin('base', 'Data');
    catch
        error('No proper Data')
    end
end

if nargin < 2 || isempty(Data_BPM)
    try
        Data_BPM = evalin('base','Data_BPM');
    catch
        error('No proper Data_BPM')
    end
end 


if nargin < 3 || isempty(file_index)
    try
        file_index = 1:DataInfo.files_amount;
    catch
        error('file_index not proper')
    end
end    

if nargin < 4 || isempty(datacolumns)
    try
        datacolumns = 1:length(DataInfo.datacol_numbers);
    catch
        error('datacolumns not proper')
    end
end

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
        
        if length(peak_numbers_range) > 1 || peak_numbers_range ~= 0
        %%% a) peak_numbers_range used to define times
            % delete given peak numbers
            peak_numbers_to_delete = peak_numbers_range;
            % find time slot: based on time range where peak_numbers_to_delete are located 
            % find high peaks time range based on peak_numbers_to_delete
            try 
                peaks_time_range = Data_BPM{ind,1}.peak_locations_high{col,1}...
                    (peak_numbers_to_delete',1)*ts;
            catch
                
            end
            % define all peak times of low peaks
            peak_times_to_be_used_to_define_new_peaks = ...
                Data_BPM{ind,1}.peak_locations_low{col,1}*ts;
            % add small time backwards and forwards to really include all
            % TODO: pitäisikö olla yllä try sisällä...
            peaks_time_range(1) = peaks_time_range(1)-.1;
            peaks_time_range(end) = peaks_time_range(end)+.1;
            % next -> go to line after follwing else-loop
        else
            %%% b) time_range: peak numbers that are in given time range
            % given in peaks_time_range
            
            % find high peaks times to be deleted
            % find low peak times that are used to find high peaks
            try
                peak_locations_in_time = Data_BPM{ind,1}.peak_locations_high{col,1}*ts;
                peak_numbers_to_delete = find_indexes_in_given_time_range...
                    (peak_locations_in_time, peaks_time_range);
            catch
               % disp('No high peaks to be deleted') 
               peak_numbers_to_delete = [];
            end
            peak_times_to_be_used_to_define_new_peaks = ...
                Data_BPM{ind,1}.peak_locations_low{col,1}*ts;
        end
        % find time locs for peaks that are used to find another peaks
        peak_numbers_to_used_for_new_peak = find_indexes_in_given_time_range...
            (peak_times_to_be_used_to_define_new_peaks, peaks_time_range);
        % delete peaks: high_or_low_peak
        if ~isempty(peak_numbers_to_delete)
            peak_numbers_to_delete = peak_numbers_to_delete(1):peak_numbers_to_delete(end);
        end
        % delete high peaks --> last input=1
        disp(['Deletig high peaks#: ', num2str(peak_numbers_to_delete)])
        [Data_BPM] = delete_peaks_with_peaknumber(Data_BPM,ind,col,...
            peak_numbers_to_delete,1);
        
        % define peak from other after "wrong" peaks have been deleted
        % find first time points of peaks that are used to define another peaks
        % then, based on time_forward_from_peak, calculate max/min
        time_of_peaks = peak_times_to_be_used_to_define_new_peaks...
            (peak_numbers_to_used_for_new_peak);
        % finding high peak pair for each low peak
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
            index_of_current_low_peak = ...
                Data_BPM{ind,1}.peak_locations_low{col}(pkhh);
            icl = index_of_current_low_peak; % lyhyempi
            vcl = Data_BPM{ind,1}.peak_values_low{col}(pkhh); % value
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
            % figure, plot(dat_raw), hold all, plot(dat,'linewidth',2)
% figure, subplot(211), plot(dat_raw), hold all, plot(Data_filtered{1, 1}.yf(index_of_raw_data,:)),plot(dat,'linewidth',2)
% subplot(212),  plot(diff(Data_filtered{1, 1}.yf(index_of_raw_data,:))), hold all, plot(diff(dat),'linewidth',2)
            % get mean of yf(f)  at the begin: p0
            % Calculate Amplitude A = peak_value - p0
            % find trigger level
            % find where yf(f) goes below trigger level
            dat_to_check = dat; 
            %% TODO: tarkista, että tämän sai kommentoida
            % Data_filtered{1, 1}.yf(index_of_raw_data,:); % VÄÄRIN?
            %%
            x=10; % 1/x: th part from the begin taken for calculating p0
            p0 = mean(dat_to_check(1:round(length(dat_to_check)/x)));
            Amp = vcl-p0;
            %%
            change = 0.05; % how much from p0 towards low peaks
            change = 0.01; % how much from p0 towards low peaks
            %%
            
            ytrig_level = p0 + change*Amp;
            ind_temp = find(dat_to_check <= ytrig_level,1);
            % figure, plot(dat_to_check), hold all, plot(ind_temp,dat_to_check(ind_temp),'*')
            val_new_peak(hh,1) = dat_to_check(ind_temp);
            index_new_peak(hh,1) = index_of_raw_data(ind_temp);
            %% 
%             plot_fig_temp = 1; % for debug run this, otherwise comment
            if exist('plot_fig_temp','var')
                fig_full, plot(dat_raw), hold all, 
                plot(Data_filtered{1, 1}.yf(index_of_raw_data,:)),
                plot(dat,'linewidth',2)
                axis tight, 
                line([1 length(dat_raw)], [ytrig_level ytrig_level],'linestyle','--','color','k')
            end
            %% OLD: % find maximum before(/after) low peak
%             [val_new_peak(hh,1) ind_temp] = max(dat);         
%             index_new_peak(hh,1) = index_of_raw_data(ind_temp);
%%
        end
        if filtering ~= 0
            disp('high peaks defined from filtered signal.')
        end
        % figure, plot(time_ind, raw), hold all, plot(time_ind(index_new_peak), val_new_peak,'o')
        % set new high peaks to Data_BPM
        try
            teind = [Data_BPM{ind,1}.peak_locations_high{col,1}; index_new_peak];
            teval = [Data_BPM{ind,1}.peak_values_high{col,1}; val_new_peak];
        catch
            teind = [index_new_peak];
            teval = [val_new_peak];
            
        end
        te_ = [teind teval];
        te_sort = sortrows(te_);
        Data_BPM{ind,1}.peak_locations_high{col,1} = te_sort(:,1);
        Data_BPM{ind,1}.peak_values_high{col,1} = te_sort(:,2);        
    end
end
end