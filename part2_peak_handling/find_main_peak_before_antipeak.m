function [Data_BPM] = find_main_peak_before_antipeak...
    (Data, DataInfo, Data_BPM, file_index, ... compulsory
    datacolumns, filter_window_sizes, tmin_mp_to_ap)
% [Data_BPM] = find_main_peak_before_antipeak(Data, DataInfo, Data_BPM, 1, [2,4])
% if antipeak is found, calculates "main peak" before antipeak
% [Data_BPM] = find_main_peak_before_antipeak(Data, DataInfo, Data_BPM, 1, [2,4], [], 10e-3)

narginchk(4,7)
nargoutchk(0,1)

% all data columns (e.g. electrodes)
if nargin < 5 || isempty(datacolumns)
   try
       datacolumns =  1:length(Data_BPM{file_index(1),1}.antipeak_locations);
   catch
       error('no prober antipeak information found')
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

% default minimum distance between mp and ap
if nargin < 7 || isempty(tmin_mp_to_ap)
     % min distance between mp and ap
    tmin_mp_to_ap = -5e-3; % works typically with normal mea
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
       [Data_filtered] = filter_signal_data(Data, ind, col,...
           [n_order1,n_order_filt]);
       % fig_full, plot(Data{ind,1}.data), yyaxis right, plot(Data{ind,1}.yf)
       % fig_full, plot(Data{ind, 1}.time_derivative, Data{ind,1}.data), yyaxis right, plot(Data{ind, 1}.measurement_time.time_sec, Data{ind,1}.yf)
        % antipeaks, shorter term
        ap_t = Data_BPM{ind,1}.antipeak_locations{col}/fs;
        ap_t_slots = [ap_t; t(end)];
        ap_ind = Data_BPM{ind,1}.antipeak_locations{col};
        for zz = 1:length(ap_t)
            ind1 = ap_ind(zz);
            % only certain time slot between current peak and next
            t1 = ap_t_slots(zz); 
            time_range = sort([t1+tmin_mp_to_ap t1]);
            % if antipeak is too close to begin of the signal
            if min(time_range) < 0
                time_range(1) = 0;
            end
            % finding time range indexes where mp peak should be 
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
            %% now finding derivative index
            % define start index when derivative is close to zero
            der_datf = smoothdata(der_dat,'movmean',10);
            % figure, plot(der_datf), yyaxis right, plot(diff(der_datf))
%             derivative_index = find(der_datf < -eps,1);
            derivative_index = find(der_datf < -eps,1);
            % figure, plot(der_datf), hold all, line([1 length(der_datf)], [-eps -eps])
            % set mainpeak location index
            mainpeak_index =  index_range(1) + derivative_index + 1; % - 1;
            time_peak_index = t(mainpeak_index);
            Data_BPM{ind,1}.mainpeak_locations{col,1}(zz,1) = mainpeak_index;
            Data_BPM{ind,1}.mainpeak_values{col,1}(zz,1) = ...
                Data_filtered{1,1}.yf(mainpeak_index);
% % %             % if low peak has been found, use that IF it is smaller
% % %             % than antipeak time
% % %             % TODO: pitäisi TOIMIA myös low_main_peak ja muille tyypeille!
% % %                 if isfield(Data_BPM{ind,1},'peak_locations_low')
% % %                    try 
% % %                        low_index = Data_BPM{ind,1}.peak_locations_low{col}(zz);
% % %                        if low_index < antipeak_index
% % %                            Data_BPM{ind,1}.antipeak_locations{col,1}(zz,1)=low_index;
% % %                            Data_BPM{ind,1}.antipeak_values{col,1}(zz,1)=...
% % %                                Data_filtered{1,1}.yf(low_index);
% % %                        end
% % %                    catch
% % %                        low_index = [];
% % %                    end
% % %                 end
            
        end
        
    end
    remove_other_variables_than_needed
    clearvars -except ...
        Data DataInfo Data_BPM Data_BPM_summary ...
        Data_o2 DataPeaks DataPeaks_mean DataPeaks_mean_summary...
        datacolumns file_index pp ...
        n_order1 n_order_filt tmin_mp_to_ap tmin_ap_to_fp

end



end

