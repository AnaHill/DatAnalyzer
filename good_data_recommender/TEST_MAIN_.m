%%
clear all, tmp = matlab.desktop.editor.getActive; cd(fileparts(tmp.Filename)); clear tmp
fold = 'C:\Local\maki9\Data\MATLAB\data_analyysi\data_analysis_files\';
% tarvittaessa
% open('..\KEHITYS\HyvanDatanSuosittelija\PROPOSE_good_data.m')
% open('..\KEHITYS\HyvanDatanSuosittelija\calculate_fft.m') % jos tarvii
% KUVAT / EDITOI sopiviksi: % open('.\testPLOTTAUS.m')
% open('..\KEHITYS\HyvanDatanSuosittelija\TESTAILU_lopullisetElektrodiEhdotukset.m')
%% get data
run('.\test_tee_alkuData.m')
% open('.\test_tee_alkuData.m')
%% set parameters for the recommender
[fft_calc_parameters] =  set_recommender_parameters;
% input(fmaxHz, method_to_choose_data_order,how_many_best_data)
%% set which part of data is used for recommender, use 0 to use whole length
datarows_total = set_datarows(5); % how_many_seconds_used = 5;
%% Get recommendation table
calculate_recommendation_table_in_loop % recommandation_table
% sort recommended datacolumns on table
sort_data_recommendation_table; % output: sorted_best_data_column_list
% figure, plot(Total_sum(:,1), Total_sum(:,2))
% and Picking best data columns (electrodes): how many best columns are chosen
how_many_best = 10; how_many_best = round(length(DataInfo.datacol_numbers)/2); % half
[chosen_data_columns best_electrodes] = ...
    choose_best_electrodes(sorted_best_data_column_list, how_many_best);


%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('data','var')
    file_index = randi(DataInfo.files_amount,1); 
    [data h5info] = read_h5_to_data(DataInfo, file_index);
end
%% Plot Full vs best, random file 
% plot random data: all datacolumns in random file index
plot_random_data_in_electrode_grid  
[hatgridbest,postgridbest] = plot_data_to_subplots_with_layout(...
    data(:,chosen_data_columns), best_electrodes, h5info.framerate, [],[], 1);
%% xlim
xlimits = [2 10];
set(hatgrid,'Xlim',xlimits)
set(hatgridbest,'Xlim',[2 10])


%% plotting pois
% % mitka_datacols=parhaat_5sec_Alusta(1:10,1);
% % [a,b] = ismember(DataInfo.electrode_layout.index,mitka_datacols);
% % find(b); matrix__ = sortrows([b,DataInfo.electrode_layout.electrode_number]);
% % matrix__2 = matrix__(find(matrix__(:,1)),:); el_nums = matrix__2(:,2);
% % [hatgrid,postgrid] = plot_data_to_subplots_with_layout(data(:,mitka_datacols), el_nums, fs, [],[], 1);