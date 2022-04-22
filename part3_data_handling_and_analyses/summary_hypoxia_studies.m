%% SUMMARY
var__names = {'t1avg','t1std','t2avg','t2std'};
taulu = array2table(t1_t2_avg_and_std,...
    'VariableNames',var__names, 'RowNames',legnames);
taulu_norm = array2table(t1_t2_norm,...
    'VariableNames',var__names, 'RowNames',legnames); 


Summary_values.(meas_name).name = meas_name;
Summary_values.(meas_name).t1 = t1;
Summary_values.(meas_name).t2 = t2;
Summary_values.(meas_name).t1_t2_avg_and_std = taulu; % t1_t2_avg_and_std;
Summary_values.(meas_name).t1_t2_norm = taulu_norm; %t1_t2_norm;
%%
Summary_values.(meas_name).file_index = file_index; 
Summary_values.(meas_name).datacolumns = col; 
for kk = 1:length(file_index)
    file_ind = file_index(kk);
    try
        fs = DataInfo.framerate(file_ind,1);
    catch % old data where framerate only one file
        fs = DataInfo.framerate(1);
    end    
    for pp = 1:length(col)
        col_ind = col(pp);
        Summary_values.(meas_name).mp_times_sec{kk,pp} = ...
            (Data_BPM{file_ind, 1}.mainpeak_locations{col_ind}-1)/fs;
        Summary_values.(meas_name).ap_times_sec{kk,pp} = ...
            (Data_BPM{file_ind, 1}.antipeak_locations{col_ind}-1)/fs;
        Summary_values.(meas_name).fp_times_sec{kk,pp} = ...
                (Data_BPM{file_ind, 1}.flatpeak_locations{col_ind}-1)/fs;
    end
end
%%
try
    Summary_values.(meas_name).valitut_datat = valitut_datat;
catch
end

clear var__names
