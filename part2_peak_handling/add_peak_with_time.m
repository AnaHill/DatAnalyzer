function [Data_BPM] = add_peak_with_time(Data, Data_BPM, DataInfo, file_index,...
    datacolumns,time_range,high_or_low_peaks)
% 
% if only one value given ,default_time = 0.3 s forward from that 
    % -> local maxima is fouund from [Data(t_input:t_input+0.3)
% Examples
    % [Data_BPM] = add_peaks_with_time(Data, Data_BPM, DataInfo, file_index, datacolumns, time_range, high_or_low_peak)
    % fil = 1; col = 2; time_range = [0.8 1.8]; 
    % temp = add_peaks_with_time(Data_BPM, DataInfo, fil,col, time_range )
    % PLOT_DataWithPeaks(Data, temp,fil,col,1);
    % temp = add_peaks_with_time(temp, DataInfo, fil,col, time_range,0);
    % PLOT_DataWithPeaks(Data, temp,fil,col,1);
    % time_range2=59.4; % only one peak, next after this time
    % temp = add_peaks_with_time(temp, DataInfo, fil,col, time_range2,0);
    % PLOT_DataWithPeaks(Data, temp,fil,col,1);
%

narginchk(6,7)
nargoutchk(0,1)
% set high peaks to find for default
if nargin < 6 || isempty(high_or_low_peaks)
    high_or_low_peaks = 1; 
    disp('Default used: Finding local maximum (high peak)')
else 
    if high_or_low_peaks > 1
        high_or_low_peaks = 1;
        disp('Given high_or_low_peaks > 1 --> Finding local maximum (high peak)')
    elseif high_or_low_peaks < 1
        high_or_low_peaks = 0;
        disp('Given high_or_low_peaks < 1 --> Finding local minimum (low peak)')
    else
        disp('Finding local maximum (high peak)')
    end
end
% set time range to min and max values given
if length(time_range) > 1
    time_range = [min(time_range) max(time_range)];
% 	disp(['Finding peak in time range: ',num2str(time_range)])
else % if time range not given: finding local max/min with X time 
    default_time = 0.3; % default time
    time_range = [time_range time_range+default_time];
%     time_range = [min(time_range) ]
    disp(['Finding peak using default time additional to given first time (sec): ',num2str(default_time)])
    %     disp(['--> time range: ',num2str(time_range)])
end

switch high_or_low_peaks
    case 0 % low peaks
        add_info_start = ['LOW peak: finding minima '];
    case 1 % high
        add_info_start = ['HIGH peak: finding maxima '];
end
add_info_text = ['between t = ',...
           num2str(time_range(1)),'-',num2str(time_range(2)),' sec'];
disp([add_info_start, add_info_text])
disp(['From files: ', num2str(file_index(:)')])
disp(['From datacolumns: ', num2str(datacolumns(:)'),10,'%%%%%%%%%%%%%%'])

for pp = 1:length(file_index)
    ind = file_index(pp);
    try
        fs = DataInfo.framerate(ind,1);
    catch % old data where framerate only one file
        fs = DataInfo.framerate(1);
    end
    dat_raw = Data{ind,1}.data;
    time = 0:1/fs:(length(dat_raw(:,1))-1)/fs;
    time_index = [find(time >= time_range(1),1) ...
        find(time <= time_range(2),1,'last')];
    for kk = 1:length(datacolumns)
       col = datacolumns(kk);
       dat = dat_raw(:,col);
       if high_or_low_peaks == 0% low peaks
           % negative data for low peaks
           dat = -dat; 
       end
       dat = dat(time_index(1):time_index(2)); 
       % figure, plot(time(time_index(1):time_index(2)),dat)
       [peak_value,ind_temp] = max(dat);
       % if multiple same max values -> taking only first one
       ind_temp = ind_temp(1);
       peak_index = time_index(1) + ind_temp - 1;
       peak_time = round(time(peak_index),2);    
       % disp(add_info_text)
       disp([10,'From file#', num2str(ind), ', datacol#', num2str(col)])
       switch high_or_low_peaks
           case 0 % low peaks
               peak_value = -peak_value;
               peak_dat_val = Data_BPM{ind,1}.peak_values_low{col,1};
               peak_dat_loc = Data_BPM{ind,1}.peak_locations_low{col,1};
               disp(['Low peak found',10,'t (sec)  Meas (*1e5)'])
               disp([num2str([peak_time, round(peak_value*1e5,2)])])
           case 1
               peak_dat_val = Data_BPM{ind,1}.peak_values_high{col,1};
               peak_dat_loc = Data_BPM{ind,1}.peak_locations_high{col,1};
               disp(['High peak found',10,'t (sec)  Meas (*1e5)'])
               disp([num2str([peak_time, round(peak_value*1e5,2)])])
       end
            teind = [peak_dat_loc; peak_index];
            teval = [peak_dat_val; peak_value];
            te_ = [teind teval];
            te_sort = sortrows(te_);
       switch high_or_low_peaks
           case 0 % low peaks
               Data_BPM{ind,1}.peak_locations_low{col,1} = te_sort(:,1);
               Data_BPM{ind,1}.peak_values_low{col,1} = te_sort(:,2);
           case 1
               Data_BPM{ind,1}.peak_locations_high{col,1} = te_sort(:,1);
               Data_BPM{ind,1}.peak_values_high{col,1} = te_sort(:,2);
       end
            
       %% poista duplikaatit mikäli on
       if length(te_sort(:,1)) == length(unique(te_sort(:,1)))
           % no duplicatates
       else
           disp('Duplicate peak found, deleting duplicates')
           [~, ind_no_dub] = unique(te_sort(:, 1));
           disp(['Unique indexes are: ', num2str(ind_no_dub')])
           switch high_or_low_peaks
               case 0 % low peaks
                   Data_BPM{ind,1}.peak_values_low{col} = ...
                       Data_BPM{ind,1}.peak_values_low{col}(ind_no_dub,:);
                   Data_BPM{ind,1}.peak_locations_low{col} = ...
                       Data_BPM{ind,1}.peak_locations_low{col}(ind_no_dub,:);
                   try
                       Data_BPM{ind,1}.peak_widths_low{col} = ...
                           Data_BPM{ind,1}.peak_widths_low{col}(ind_no_dub,:);
                   catch
                       disp('Problems with peak_widths_low')
                   end
               case 1 %  high peaks
                   Data_BPM{ind,1}.peak_values_high{col} = ...
                       Data_BPM{ind,1}.peak_values_high{col}(ind_no_dub,:);
                   Data_BPM{ind,1}.peak_locations_high{col} = ...
                       Data_BPM{ind,1}.peak_locations_high{col}(ind_no_dub,:);
                   try
                       Data_BPM{ind,1}.peak_widths_high{col} = ...
                           Data_BPM{ind,1}.peak_widths_high{col}(ind_no_dub,:);
                   catch
                       disp('Problems with peak_widths_high')
                   end
           end
       end
    end
end
    
end