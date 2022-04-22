%% Summarize_plots_for_multiple__experiments
% DataInfo, Data_BPM_summary, DataPeaks_summary, (Data_o2)
meas_name = [];
main_fold = 'C:\Local\maki9\Data\DataAnalyysi\AcuteHypoxia_MarttaH\data\';
experi_name='Acute_hypoxia_HEB04602wt_p42_090321_MACS290321_';
meas_name{1} = 'MEA21001a'; % chosen_datacolumns = 3;
meas_name{end+1} = 'MEA21001b'; % chosen_datacolumns = 3;
meas_name{end+1} = 'MEA21002a'; 
meas_name{end+1} = 'MEA21002b'; 

datacol_choose = {3, 3,3,3,[1:4]};
parameter_names = {'DataInfo','Data_BPM_summary', 'DataPeaks_summary'};

fig_full, hold all, 
for meas_index = 1:length(meas_name)
    full_fold = [main_fold,experi_name,meas_name{meas_index},'\'];
    chosen_datacolumns = datacol_choose{meas_index};
    for parameter_index = 1:length(parameter_names)
        full_name = [parameter_names{parameter_index},'_',experi_name,meas_name{meas_index}];
        load([full_fold full_name ])
    end
    DataPeaks_summary_PlotVertailu
    leg_names{meas_index,1} = [meas_name{meas_index},': El#',...
        num2str(DataInfo.MEA_electrode_numbers(datacol_choose{meas_index}))];
end
sgtitle(experi_name)
legend(leg_names)