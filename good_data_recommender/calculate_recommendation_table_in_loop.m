tStart = tic; 
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
clear recommandation_table 
disp_something = 0;
% kOPIOI ALTA sopivaksi
% open('..\KEHITYS\HyvanDatanSuosittelija\PROPOSE_good_data.m')
% open('..\KEHITYS\HyvanDatanSuosittelija\TESTAILU_lopullisetElektrodiEhdotukset.m')
for pp = 1:DataInfo.files_amount
    tic
    T=[];
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    formatSpec = 'Reading file# %3.0i / %3.0i\n';
    fprintf(formatSpec,pp,DataInfo.files_amount)
%     function [data, h5info,framerate] = read_h5_to_data(info, index, ... % compulsory
%     datarows_total, how_many_datacolumns,start_indexes)
    if strcmp(datarows_total, 'inf')
        % all datarows (= full data)
        [data,info] = read_h5_to_data(DataInfo, pp);
    else
        [data,info] = read_h5_to_data(DataInfo, pp ,datarows_total);
    end
    fprintf('data read from h5 file: '), 
    T(end+1,1)= toc;  
    fprintf('%3.1f sec\n',T(end))
    
    [fft_calc_parameters.f,fft_calc_parameters.P1] = calculate_and_check_fft(data, info.framerate);
        % .fmaxHz
        % .method_to_choose_data_order
        % .how_many_best_data: 60
        % .f
        % .P1
    % calculate fft results: get avg median max fft
    fft_calc_results = calculate_fft_avg_median_max(fft_calc_parameters);
        % .AverageAmplitude_fft 
        % .MaxAmplitude_fft
        % .MedianAmplitude_fft 
   
    fprintf('fft calculation time: '), 
    T(end+1,1)= toc;  
    fprintf('%3.1f sec\n',T(end)-T(end-1))
    
    % get ordered data candinates list
    ordered_data_candinates = get_recommended_order_of_data...
    (fft_calc_results,fft_calc_parameters);
    
    DataColumns = [1:min(size(data))]';
    if ~exist('recommandation_table','var')
        for kk = 1:length(DataColumns)
            datacolname{kk,1} = ['Datacolumn',num2str(DataColumns(kk))];
        end
        recommandation_table = table('rownames',datacolname);
    end
    temp_values = zeros([min(size(data))],1);
    how_many_values = length(ordered_data_candinates);
    for kk = 1:how_many_values
        temp_values(ordered_data_candinates(kk)) = how_many_values+1-kk;
    end
    recommandation_table = addvars(recommandation_table, temp_values);
	% fprintf('IndeksiTaulukko paivitetty: '),  T(end+1,1)= toc;  fprintf('%3.1f sec\n',T(end)-T(end-1))
    %fprintf('testing x...');pause(3);
    fprintf('TOTAL Loop time = '),  
    T(end+1,1)= toc;  
    fprintf('%3.1f sec\n',T(end))
    clear_variables_during_recommendation_loop
end
disp(['Total time: ',num2str(round(toc(tStart),1)),'sec'])
if datarows_total~= 0
    seconds_ = datarows_total/DataInfo.framerate(1);
    eval(['recommandation_table_' num2str(seconds_) 's_from_the_begin=recommandation_table;']);
end
clear pp seconds_ tStart
