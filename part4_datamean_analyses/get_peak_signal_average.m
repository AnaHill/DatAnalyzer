function DataPeaks_mean = get_peak_signal_average(DataPeaks,...
    remove_percent_from_average, file_index_to_analyze, datacolumns)
% function [PeakSignals_mean] = get_peak_signal_average(Data_PeakSignals,...
%     remove_percent_from_average, file_index_to_analyze, datacolumns)
% run get_peak_signals first to create prober Data_PeakSignals
% remove_percent_from_average: in %, how much removed from both sides
% update: removed ySEM variable, as not really needed
narginchk(0,4)
nargoutchk(0,1)

if nargin < 1 || isempty(DataPeaks) 
    try
        DataPeaks = evalin('base','DataPeaks');
    catch
        warning('No Data_PeakSignal, trying to create one with default values')
        disp('Data_PeakSignals = get_peak_signals(); ')
        try
            DataPeaks = get_peak_signals(); 
            disp('DataPeaks created')
        catch
            error('No Data_PeakSignal')
        end

    end
end
% default: 0% of signals are removed from average calculation
if nargin < 2 || isempty(remove_percent_from_average) 
    remove_percent_from_average = 0;
end
% default: every file is analyzed
if nargin < 2 || isempty(file_index_to_analyze) 
    file_index_to_analyze = 1:length(DataPeaks.file_index);
end
file_index_to_analyze = unique(sort([file_index_to_analyze])); 
% default: all datacolumns are analyzed
if nargin < 3 || isempty(datacolumns) 
    datacolumns = 1:length(DataPeaks.data(file_index_to_analyze(1),:));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DataPeaks_mean = [];
% PeakSignals_mean.data = {};
% PeakSignals_mean.file_index = [];
% 
% % poista
% PeakSignals_mean.summary = [];
% PeakSignals_mean.summary.time_range_from_peak = time_range_from_peak;
% PeakSignals_mean.summary.data_mean = {};
% PeakSignals_mean.summary.data_std = {};

min_peak_amount = 5;
if remove_percent_from_average == 0
    disp('remove_percent_from_average=0 -> keeping all signals for average calc')
end

for kk = 1:length(file_index_to_analyze)
    file_index = file_index_to_analyze(kk);
    DataPeaks_mean{file_index,1}.file_index = file_index;
    for pp = 1:length(datacolumns)
        col = datacolumns(pp);
        dat = DataPeaks.data{file_index,col};
        % remove some data if remove_percent_from_average > 0
        if remove_percent_from_average > 0
            disp('Sorting and possible removing some signals before average calculation')
            dat = sort(dat,2);
            % if at least min_peak_amount (5) peaks, removing based on remove_percent
            amount_peaks = min(size(dat));
            if amount_peaks >= min_peak_amount
                number_of_data_to_remove = floor(...
                    amount_peaks*(remove_percent_from_average/100));
                if number_of_data_to_remove >= 1
                    nps = 1:number_of_data_to_remove;
                    npe = amount_peaks-number_of_data_to_remove+1:amount_peaks;
                    dat(:,[nps,npe]) = [];
                    disp(['Removing ', num2str(lenght(nps)),...
                        ' smallest and highest values from sorted signals'])
                else
                   disp(['number_of_data_to_remove = 0 -> keep all signals'])
                end                
            else % taking all if less than min_peak_amount (5) peaks
                disp(['Less than ', num2str(min_peak_amount),...
                    ' peaks found,  keep all signals'])
            end      
        end
        % calculating average, std, confidence intervals
        N = size(dat,2); 
        DataPeaks_mean{file_index,1}.N(1,col) = N;
        DataPeaks_mean{file_index,1}.data(:,col) = nanmean(dat,2);
        DataPeaks_mean{file_index,1}.data_std(:,col) = nanstd(dat,0,2); 
        % confidence interval, see
        % Calculate 95% Probability Intervals Of t-Distribution
        DataPeaks_mean{file_index,1}.CI95(:,col) = tinv([0.025 0.975], N-1);    
        DataPeaks_mean{file_index,1}.CI99(:,col) = tinv([0.005 0.995], N-1);        
        DataPeaks_mean{file_index,1}.time_range_from_peak = DataPeaks.time_range_from_peak;
        % UPDATE 2021/06: YSEM not anymore calculated
        % Compute ‘Standard Error Of The Mean’ Of All Experiments At Each Value Of ‘x’
        % DataPeaks_mean{file_index,1}.ySEM(:,col) = nanstd(dat,0,2)/sqrt(N);

        % confidence levels are not now calculated, see plot_signal_average.m
        
        
    end
end
end

