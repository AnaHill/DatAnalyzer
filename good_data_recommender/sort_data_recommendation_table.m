Total_sum = [(1:height(recommandation_table))' sum(recommandation_table{:,1:end},2)];
sorted_best_data_column_list = sortrows(Total_sum,2,'descend');