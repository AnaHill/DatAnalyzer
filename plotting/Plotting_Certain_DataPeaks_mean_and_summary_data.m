%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot some values, 
% close all
ind_color=1; % fig_full,
% for file_index =  [130:131, 136 140 ] % [31:33] %131; % 130 
% for col_index = 5
file_indexes= 1%[15 20 25]
% file_indexes=file_indexes(3)
col_indexes = [1:3]
%%% randomilla
file_indexes=randi([1 DataInfo.files_amount],[1 1]); 
% col_indexes = randi([1 length(DataInfo.datacol_numbers)],[1 1]);
for file_index = file_indexes
    fig_full
    for col_index = col_indexes
        % file_index =    13
        % col_index = 1
        data=DataPeaks_mean{file_index,1}.data(:,col_index);
        ax = gca;ax.ColorOrderIndex = ind_color;
        plot(data,'--'), hold on
        fpd_ind1 = DataPeaks_summary.fpd_start_index(file_index, col_index);
        fpd_va11 = DataPeaks_summary.fpd_start_value(file_index, col_index);
        fpd_ind2= DataPeaks_summary.fpd_end_index(file_index, col_index);
        fpd_val2 = DataPeaks_summary.fpd_end_value(file_index, col_index);
        firstp_ind = DataPeaks_summary.peaks{col_index}.firstp_loc(file_index);
        firstp_val = DataPeaks_summary.peaks{col_index}.firstp_val(file_index);
        flatp_ind = DataPeaks_summary.peaks{col_index}.flatp_loc(file_index);
        flatp_val = DataPeaks_summary.peaks{col_index}.flatp_val(file_index);
        ax = gca;ax.ColorOrderIndex = ind_color;
        scatter(fpd_ind1, fpd_va11,100,'>','filled','MarkerEdgeColor','k','LineWidth',2)
        ax = gca;ax.ColorOrderIndex = ind_color;
        scatter(firstp_ind, firstp_val ,100,'o','filled','MarkerEdgeColor','k','LineWidth',2)
        ax = gca;ax.ColorOrderIndex = ind_color;
        scatter(flatp_ind, flatp_val ,100,'sq','filled','MarkerEdgeColor','k','LineWidth',2)
        ax = gca;ax.ColorOrderIndex = ind_color;
        scatter(fpd_ind2,fpd_val2,100,'<','filled','MarkerEdgeColor','k','LineWidth',2)
        ax = gca;ax.ColorOrderIndex = ind_color;
        ind_color=ind_color+1;
        axis tight
    end
end
title(['File & col: ',num2str([file_index, col_index])])
%% yllä oleva niin että aika x-akselilla
ind_color=1; % fig_full,
% file_indexes= [40,100,120]; % file_indexes=file_indexes(3)
% col_indexes = [1,3,6];
% randomilla
    file_indexes=randi([1 DataInfo.files_amount],[1 1]); 
    % col_indexes = randi([1 length(DataInfo.datacol_numbers)],[1 1]);
for file_index = file_indexes
    fig_full
    ts = 1/DataInfo.framerate(file_index);
    datalength = length(DataPeaks_mean{file_index,1}.data(:,1));
    time = 0:ts:(datalength-1)*ts;
    for col_index = col_indexes
        data=DataPeaks_mean{file_index,1}.data(:,col_index);
        fpd_ind1 = DataPeaks_summary.fpd_start_index(file_index, col_index);
        fpd_va11 = DataPeaks_summary.fpd_start_value(file_index, col_index);
        fpd_ind2= DataPeaks_summary.fpd_end_index(file_index, col_index);
        fpd_val2 = DataPeaks_summary.fpd_end_value(file_index, col_index);
        firstp_ind = DataPeaks_summary.peaks{col_index}.firstp_loc(file_index);
        firstp_val = DataPeaks_summary.peaks{col_index}.firstp_val(file_index);
        flatp_ind = DataPeaks_summary.peaks{col_index}.flatp_loc(file_index);
        flatp_val = DataPeaks_summary.peaks{col_index}.flatp_val(file_index);
        % set(gca,'ColorOrderIndex',ind_color)
        ax = gca;ax.ColorOrderIndex = ind_color;
        plot(time, data,'--'), hold on
        ax = gca;ax.ColorOrderIndex = ind_color;
        scatter(time(fpd_ind1), fpd_va11, 100,'>','filled','MarkerEdgeColor','k','LineWidth',2)
        ax = gca;ax.ColorOrderIndex = ind_color;
        scatter(time(firstp_ind), firstp_val, 100,'o','filled','MarkerEdgeColor','k','LineWidth',2)
        ax = gca;ax.ColorOrderIndex = ind_color;
        scatter(time(flatp_ind), flatp_val, 100,'sq','filled','MarkerEdgeColor','k','LineWidth',2)
        ax = gca;ax.ColorOrderIndex = ind_color;
        scatter(time(fpd_ind2),fpd_val2, 100,'<','filled','MarkerEdgeColor','k','LineWidth',2)
        ax = gca;ax.ColorOrderIndex = ind_color;
        ind_color=ind_color+1;
        axis tight
    end
end
title(['File & col: ',num2str([file_index, col_index])])