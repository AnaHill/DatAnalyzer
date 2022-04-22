function [mp_ap_times mp_fp_times] = ...
    define_t1_t2(Data, Data_BPM, DataInfo, file_index, col_ind)
narginchk(5,5)
nargoutchk(2,2)
% % 
% % col_ind=col,% piikit=1:14
% % % filu=file_index(kk), 
% % % filu = file_index(randi(length(file_index)))
% % % filu=37
% mp_ap_times = [];mp_fp_times = [];
for kk = 1:length(file_index)
    filu = file_index(kk);
    % HELP_plotData_and_mp_ap_fp(Data,Data_BPM, filu, [col_ind], 1)
    try
    [mp_ap_times(kk,1) mp_fp_times(kk,1)] = ...
        calculate_t1depol_and_t2fpd_times...
        (Data, Data_BPM,DataInfo, filu, col_ind);
    catch % if no signals
        disp('no signals to calculate mp to ap or mp to fp times')
        mp_ap_times{kk,1} = [];
        mp_fp_times{kk,1} = [];
    end
end