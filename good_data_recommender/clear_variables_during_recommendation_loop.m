% disp_something = 1;
try
   if disp_something == 1
        disp('clearing variables')
   end
catch

end

clearvars -except recommandation_table datarows_total DataInfo pp fft_calc_parameters tStart...
%     Data how_many_biggest_to_check freqs_for_measdata_amount fmaxHz toleranceHz ...
%     how_many_biggest_electrodes how_many_biggest_electrodes ... 
%     how_many_freqs_to_filter milla_menetelmalla_elektrodikandinaatit ...
%     how_many_datarows disp_something