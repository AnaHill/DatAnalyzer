function [t1_depol t2_fpd] = ...
    calculate_t1depol_and_t2fpd_times...
    (Data, Data_BPM, DataInfo, file_index, datacolumns) %%%, set_new_fig)
% [t1_depol t2_fpd] = 
% calculate_t1depol_and_t2fpd_times...
% (Data, Data_BPM, DataInfo, file_index, datacolumns, set_new_fig)
% calculates (in ms) 
% i) depolarization time t1 and 
% ii) field potential duration t2  (fpd)
% t1 = 0’ -> 1’  = time it takes from high peak to low peak 
% t2 = 0’ -> 4’ = time it takes from high peak to flat peak 
% set_new_fig = 1 --> plot new fig (default)

% % % narginchk(5,6)
narginchk(4,5)
nargoutchk(0,2)
% all data columns (e.g. electrodes) if not given
if nargin < 5 || isempty(datacolumns)
   try
       datacolumns =  1:length(Data_BPM{file_index(1),1}.peak_values_high);
   catch
       try
           datacolumns =  1:length(Data_BPM{file_index(1),1}.peak_values_low);
       catch
           error('no prober peak information found')
       end
   end
           
end

% default: new fig will
% % % if nargin < 6 || isempty(set_new_fig)
% % %     set_new_fig = 1; % will plot new fig unless non-one value is given
% % % end


for pp = 1:length(file_index)
    ind = file_index(pp);
% % %     if set_new_fig == 1 
% % %         % set new_fig
% % %         fig_full, 
% % %     end
    try
        fs = DataInfo.framerate(ind,1);
    catch % old data where framerate only one file
        fs = DataInfo.framerate(1);
    end

%     t1_depol t2_fpd
    for kk = 1:length(datacolumns)
        col = datacolumns(kk);
        t1_depol{kk,1} = abs(Data_BPM{ind, 1}.mainpeak_locations{col}...
            -Data_BPM{ind, 1}.antipeak_locations{col})/fs * 1e3;
        t2_fpd{kk,1} = abs(Data_BPM{ind, 1}.mainpeak_locations{col}...
            -Data_BPM{ind, 1}.flatpeak_locations{col})/fs * 1e3;
        
        % plot
% % %         % plot_t1depol_t2fpd_times
        
    end
end