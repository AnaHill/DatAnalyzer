function ordered_data_candinates = get_recommended_order_of_data...
    (fft_calc_results,fft_calc_parameters, datacolumn_indexes)
% Finds and arrange data candinates
narginchk(2,3)
nargoutchk(0,1)
if nargin < 3 || isempty(datacolumn_indexes)
    datacolumn_indexes = 1:max(size(fft_calc_results.MaxAmplitude_fft));
%     disp(['Datacolumn indexes not given, calculating it ',10,...
%         '(eq. = 1:max(size(fft_calc_results.MaxAmplitude_fft)) ',10,...
%         '= ',num2str(datacolumn_indexes(1)),'-',num2str(datacolumn_indexes(end))])
end

%%%%%%%%%%%%%%%%%%%%%%%
how_many_best_data = fft_calc_parameters.how_many_best_data;
datacolumn_indexes = datacolumn_indexes(:); % make column

switch fft_calc_parameters.method_to_choose_data_order
    % more possible methods to implement, see "jarjesta_hyvat_kandinaatit.m"
    case 'max_vs_median_below_fmaxHz'    
        % compare max/median of fft below fmaxHz
        max_vs_median = fft_calc_results.MaxAmplitude_fft ./ ...
            fft_calc_results.MedianAmplitude_fft;
        fft_max_vs_median =[datacolumn_indexes max_vs_median];
        fft_max_vs_median = sortrows(fft_max_vs_median,2,'descend','MissingPlacement','last');
        ordered_data_candinates = fft_max_vs_median(1:how_many_best_data,1);
    case 'max_vs_mean_below_fmaxHz'    
        % compare max/mean of fft below fmaxHz
        max_vs_mean = fft_calc_results.MaxAmplitude_fft ./ ...
            fft_calc_results.AverageAmplitude_fft;
        fft_max_vs_mean =[datacolumn_indexes max_vs_mean];
        fft_max_vs_mean = sortrows(fft_max_vs_mean,2,'descend','MissingPlacement','last');
        ordered_data_candinates = fft_max_vs_mean(1:how_many_best_data,1);
end
