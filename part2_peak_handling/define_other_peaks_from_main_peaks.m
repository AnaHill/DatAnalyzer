function [Data_BPM] = define_other_peaks_from_main_peaks...
    (Data, DataInfo, Data_BPM, file_index, ... compulsory
    datacolumns, filter_window_sizes, tmin_mp_to_ap, tmin_ap_to_fp)
% [Data_BPM] = define_other_peaks_from_main_peaks(Data, DataInfo, Data_BPM, 1, [2,4])
% define_other_peaks_from_main_peaks defines antipeak and flat peak based on
% main peaks
% [Data_BPM] = define_other_peaks_from_main_peaks(Data, DataInfo, Data_BPM, 1, [2,4], [], 10e-3)
% [Data_BPM] = define_other_peaks_from_main_peaks...
%     (Data, DataInfo, Data_BPM, file_index, datacolumns, ...
%     filter_window_sizes, tmin_mp_to_ap, tmin_ap_to_fp)

% TODO: mieti jos voisi muitakin filttereitä käyttää
narginchk(4,8)
nargoutchk(0,1)

% all data columns (e.g. electrodes)
if nargin < 5 || isempty(datacolumns)
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

% default: set default filterin methods if not given
if nargin < 6 || isempty(filter_window_sizes)
    % order of the first filter: moving median, for antipeaks
    n_order1 = 30; % ymed1 = medfilt1(rawdata,n_order1); 
    % second, moving mean filter for filtered signal, for flat peaks
    n_order_filt = 100; % ymed1_fil = smoothdata(ymed1,'movmean',n_order_filt);
else %TODO: paremmin, jos käyttäisi muita filtteritä
    if length(filter_window_sizes) == 2
        n_order1 = filter_window_sizes(1);
        n_order_filt = filter_window_sizes(2);        
    elseif length(filter_window_sizes) == 1
        n_order1 = filter_window_sizes;
        n_order_filt = 100;
    else
       error('Filter info not correct.') 
    end
end

% default minimum distance between mp and ap / fp
if nargin < 7 || isempty(tmin_mp_to_ap)
     % min distance between mp and ap
    tmin_mp_to_ap = 0.8e-3; % works typically with normal mea
    % tmin_mp_to_ap = 0.8e-3 / 2; % divided by 2, see next line
    % noticed: now time from high (main) peak after returned to zero, it
    % takes minimum time to low peak location
end

if nargin < 8 || isempty(tmin_ap_to_fp)
    % min distance between ap and fp
    tmin_ap_to_fp = 200e-3; % works typically with normal mea
end


%%
disp(['Filter parameters set.'])
for pp = 1:length(file_index)
    ind = file_index(pp);
    try
        fs = DataInfo.framerate(ind,1);
    catch % old data where framerate only one file
        fs = DataInfo.framerate(1);
    end
    
    for kk = 1:length(datacolumns)
        % tic
        col = datacolumns(kk);
        % filter raw data
        rawdata= Data{ind,1}.data(:,col);
        t = 0:1/fs:(length(rawdata)-1)/fs;
        % filtteröinti: omassa funktiossa
       [Data_filtered] = filter_signal_data(Data, ind, col,...
           [n_order1,n_order_filt]);
% %         Data_filtered{pp,1}.dyf(:,kk) = ymed1_der;
% %         Data_filtered{pp,1}.dyff(:,kk) = ymed1_fil_der;
        % figure, plot(td, ymed1_fil_der)
        % main peaks, shorter term
        mp_t = Data_BPM{ind,1}.mainpeak_locations{col}/fs;
        mp_t_slots = [mp_t; t(end)];
        mp_ind = Data_BPM{ind,1}.mainpeak_locations{col};
        % time between mp_t(ind) and mp_t(ind+1)
        % finding antipeaks from filtered ymed1 signal after main peaks
        % where ydiff1 returns to zero or larger
            % first, index where filtered signal is below zero

        for zz = 1:length(mp_t)
            ind1 = mp_ind(zz);
            % only certain time slot between current peak and next
            Percent = 0.9; % 90% time slot from peak to next peak
            t1 = mp_t_slots(zz); 
            t2 = mp_t_slots(zz+1); % mpt_slots include end of signal
            % addition to time range start value:
            % not t1, but  t1+tmin_mp_to_ap
            try 
                time_range = [t1+tmin_mp_to_ap t1+(t2-t1)*Percent];
            catch % if peak would so close to end of signal
                time_range = [t1 t1+(t2-t1)*Percent];
            end
            % check if enough time after peak to find antipeak
            if diff(time_range) < tmin_mp_to_ap
                % if not found -> skipping (mainpeak so end that no antipeak)
                Data_BPM{ind,1}.antipeak_locations{col,1}(zz,1) = nan;
                Data_BPM{ind,1}.antipeak_values{col,1}(zz,1) = nan;
            else
                % finding time range indexes where ap peak should be 
                ind_first = find(t >= min(time_range),1);
                ind_last = find(t <= max(time_range),1,'last');
                % find first index ind_te where filtered signal is below zero
                datf = Data_filtered{1,1}.yf(ind_first:ind_last);
                ind_te = find(datf < 0,1); clear datf
                if ~isempty(ind_te) % if ind_te found -> change ind_first
                    ind_first = ind_first + ind_te-1;
                end
                index_range = [ind_first ind_last];
                der_dat = Data_filtered{1,1}.dyf...
                    (index_range(1)-1:index_range(end)-1);
% % %                 der_dat = ymed1_der(index_range(1)-1:index_range(end)-1);
                % figure, plot(Data_filtered{1,1}.yf(ind_first:ind_last)), yyaxis right, plot(der_dat)
                %% now finding derivative index: relates to signal type
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % A) Normal MEA data: hp->ap->fp
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % find first time where derivative drops below zero 
                % -> finding next starting from that index
                start_index = find(der_dat < -eps,1);
                % index, where derivative returned (almost) to zero
                derivative_index = start_index - 1 + ...
                    find(der_dat(start_index:end) - 0 >= -eps,1);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % B) Low MEA data: ei kunnolla hp: alas -> ap -> fp
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                if isfield(Data_BPM{ind,1},'signal_type')
                    if strcmp(Data_BPM{ind,1}.signal_type{col,1},'low_mea') ...
                        || strcmp(Data_BPM{ind,1}.signal_type{col,1},'calcium_neg_der')
                        % define start index when derivative is close to
                        % zero
                        der_datf = smoothdata(der_dat,'movmean',10);
                        % figure, plot(der_dat), hold all, plot(der_datf)
%                         start_index = find(der_dat > eps,1);
                        derivative_index = find(der_datf > eps,1);
                    end
                end
                %% set antipeak location index
                antipeak_index =  index_range(1) + derivative_index + 1; % - 1;
                time_peak_index = t(antipeak_index);
                Data_BPM{ind,1}.antipeak_locations{col,1}(zz,1) = antipeak_index;
                Data_BPM{ind,1}.antipeak_values{col,1}(zz,1) = ...
                    Data_filtered{1,1}.yf(antipeak_index);% rawdata(peak_index);
                % if low peak has been found, use that IF it is smaller
                % than antipeak time
                % TODO: pitäisi TOIMIA myös low_main_peak ja muille tyypeille!
                if isfield(Data_BPM{ind,1},'peak_locations_low')
                   try 
                       low_index = Data_BPM{ind,1}.peak_locations_low{col}(zz);
                       if low_index < antipeak_index
                           Data_BPM{ind,1}.antipeak_locations{col,1}(zz,1)=low_index;
                           Data_BPM{ind,1}.antipeak_values{col,1}(zz,1)=...
                               Data_filtered{1,1}.yf(low_index);
                       end
                   catch
                       low_index = [];
                   end
                end
            end
            %% FLAT PEAK
            % finding flat peak: between antipeak_index+100ms k and index_range(end)
%             tmin_ap_to_fp = 200e-3;
            if t(antipeak_index) + tmin_ap_to_fp > max(t)
                % if not found -> skipping (antipeak so end that no flatpeak)
                Data_BPM{ind,1}.flatpeak_locations{col,1}(zz,1) = nan;
                Data_BPM{ind,1}.flatpeak_values{col,1}(zz,1) = nan;
            else
                fp_start_index = find(t >= t(antipeak_index)+tmin_ap_to_fp,1);
                if fp_start_index > index_range(end)
                    Data_BPM{ind,1}.flatpeak_locations{col,1}(zz,1) = nan;
                    Data_BPM{ind,1}.flatpeak_values{col,1}(zz,1) = nan;                   
                else
                    [fpA,fp_index] = max(Data_filtered{1,1}.yff...
                        (fp_start_index:index_range(end)));
                    fp_index = fp_index + fp_start_index-1;

                    Data_BPM{ind,1}.flatpeak_locations{col,1}(zz,1) = fp_index;
                    Data_BPM{ind,1}.flatpeak_values{col,1}(zz,1) = ...
                        Data_filtered{1,1}.yff(fp_index);
                end
            end
            
        end
        
    end
    clearvars -except ...
        Data DataInfo Data_BPM Data_BPM_summary ...
        Data_o2 DataPeaks DataPeaks_mean DataPeaks_mean_summary...
        datacolumns file_index pp ...
        n_order1 n_order_filt tmin_mp_to_ap tmin_ap_to_fp
   
end



end

