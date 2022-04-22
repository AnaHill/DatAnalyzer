%% calculate t1 and t2 
% [mp_ap_times mp_fp_times] = define_t1_t2(Data, Data_BPM, DataInfo,file_index, col);
[t1, t2] = define_t1_t2(Data, Data_BPM, DataInfo,file_index, col);
% iskemia_plot_peaks_mp_ap_fp(Data,Data_BPM, file_index, col)
%% calculate t1avg and t2avg
[t1_t2_avg_and_std] = calculate_t1_t2_avg(t1,t2);

%% Normalize t1avg and t2avg
% calculate mean of two first t1 and t2 values, normalized to that
mihin_normalisoidaan=1:2; % mean of these
[t1avg_norm, t2avg_norm, t1_t2_norm] = normalize_t1_t2_avg(...
    t1_t2_avg_and_std, mihin_normalisoidaan);
