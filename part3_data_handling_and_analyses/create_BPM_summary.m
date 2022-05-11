function [Data_BPM_summary] = create_BPM_summary(...
    normalizing_indexes,chosen_datacol_indexes,DataInfo, Data_BPM)
% function [Data_BPM_summary] = create_BPM_summary(...
%     normalizing_indexes,chosen_datacol_indexes,DataInfo, Data_BPM)
narginchk(0,4)
nargoutchk(0,1)
if nargin < 3 || isempty(DataInfo)
    try
        DataInfo = evalin('base', 'DataInfo');
    catch
        error('No proper DataInfo')
    end
end
if nargin < 4 || isempty(Data_BPM)
    try
        Data_BPM = evalin('base','Data_BPM');
    catch
        error('No proper Data_BPM')
    end
end
disp([10,'%%%%%%%%%%%%%%%%%%%%%%%%%',10,'Creating Data_BPM_summary',10,...
    '%%%%%%%%%%%%%%%%%%%%%%%%%'])
if nargin < 1 || isempty(normalizing_indexes)
    try % if hypoxia -> normalizing to start index
        indexes_before_hypoxia = find(DataInfo.measurement_time.time_sec ...
            <= DataInfo.hypoxia.start_time_sec);
        last_index_before_hypoxia = indexes_before_hypoxia(end);
        % normalizing_indexes = DataInfo.hypoxia.start_time_index;
        if last_index_before_hypoxia  >= 3 
            normalizing_indexes = [last_index_before_hypoxia-2:last_index_before_hypoxia];
            disp('normalizing to last 3 indexes before hypoxia starts')
        elseif last_index_before_hypoxia == 2
            normalizing_indexes = [last_index_before_hypoxia-1:last_index_before_hypoxia];
            disp('normalizing to last 2 indexes before hypoxia starts')
        end
        
    catch % normalizing to first value
        normalizing_indexes = 1;
        disp('normalizing to first value')
    end
end

if nargin < 2 || isempty(chosen_datacol_indexes)
   chosen_datacol_indexes = 1:length(DataInfo.datacol_numbers);
end



ind_col = chosen_datacol_indexes; 
% Amount of peaks and BPM avg
for kk = 1:DataInfo.files_amount
    
    if ~isfield(Data_BPM{kk,1},'Amount_of_peaks')
        %TODO: check that this is good and works in later analysis stages
        Data_BPM_summary.Amount_of_peaks(kk,:) = nan(1,length(DataInfo.datacol_numbers));
        Data_BPM_summary.BPM_avg(kk,:) = nan(1,length(DataInfo.datacol_numbers))';
        Data_BPM_summary.BPM_avg_stdpros(kk,:) = nan(1,length(DataInfo.datacol_numbers));
        for pp = 1:length(ind_col)
            ind = ind_col(pp);
            Data_BPM{kk,1}.peak_values{ind,1} = nan; % nan(1,length(DataInfo.datacol_numbers));
            Data_BPM{kk,1}.peak_locations{ind,1} = nan;
        end
    else
        % disp(['kk  = ', num2str(kk)])   
        Data_BPM_summary.Amount_of_peaks(kk,:) = Data_BPM{kk,1}.Amount_of_peaks(:)';
        Data_BPM_summary.BPM_avg(kk,:) = Data_BPM{kk,1}.BPM_avg(:)';
        dt = Data_BPM{kk,1}.peak_avg_distance_in_ms;
        d(:,1) = Data_BPM_summary.BPM_avg(kk,:)';
        d(:,2) = dt(:,2) ./ dt(:,1)*100;
        d2 = d(chosen_datacol_indexes,:);
        Data_BPM_summary.BPM_avg_stdpros(kk,:) = [d2(:,2)'];
    end
    clear d ds dt d2
end

%% BPM_Amplitudes and peak widths
for kk = 1:DataInfo.files_amount
    % disp(['kk  = ', num2str(kk)])        
    for pp = 1:length(ind_col)
        ind = ind_col(pp);
        % TODO: tarkista että oikein kun säädett 2022/04
        %disp(['row kk  = ', num2str(kk),', col(',num2str(pp)',') = ',num2str(ind)])        
        Data_BPM_summary.peak_values(kk,:) = Data_BPM{kk, 1}.peak_values(:)';
        Data_BPM_summary.peak_locations(kk,:) = Data_BPM{kk, 1}.peak_locations(:)';
        try
            Data_BPM_summary.peak_widths(kk,:) = Data_BPM{kk, 1}.peak_widths(:)';
        catch
        end
        Data_BPM_summary.Amplitude_avg(kk,pp) = nanmean(...
            Data_BPM_summary.peak_values{kk,ind});
        Data_BPM_summary.Amplitude_std_pros(kk,pp) = nanstd(...
            Data_BPM_summary.peak_values{kk,ind}) / ...
            Data_BPM_summary.Amplitude_avg(kk,pp)*100;
        try
            Data_BPM_summary.peak_width_avg(kk,pp) = nanmean(...
                Data_BPM_summary.peak_widths{kk,ind});
            Data_BPM_summary.peak_width_std_pros(kk,pp) = nanstd(...
                Data_BPM_summary.peak_widths{kk,ind}) / ...
                Data_BPM_summary.peak_width_avg(kk,pp)*100;
        catch
        end
    end
end
%% Normalizing amplitudes and BPM
Data_BPM_summary.Amplitude_norm = ...
    Data_BPM_summary.Amplitude_avg ./ nanmean(Data_BPM_summary.Amplitude_avg(normalizing_indexes,:),1);

Data_BPM_summary.BPM_norm = ...
    Data_BPM_summary.BPM_avg ./ nanmean(Data_BPM_summary.BPM_avg(normalizing_indexes,:),1);

%% calculate peak distances
disp([' '])
for file_index = 1:DataInfo.files_amount
%     index = filenumbers(pp);
    try
        fs = DataInfo.framerate(file_index,1);
    catch % old data where framerate only one file
        fs = DataInfo.framerate(1);
    end
    disp(['Calculating Data_BPM_summary.peak_distances in file#',...
        num2str(file_index),'/',num2str(DataInfo.files_amount)])
    for kk = 1:length(chosen_datacol_indexes)
        col_index = chosen_datacol_indexes(kk);
        try
            Data_BPM_summary.peak_distances{file_index,col_index} = ...
                diff(Data_BPM{file_index, 1}.peak_locations{col_index})/...
                fs*1e3;
        catch
            disp(['Error in peak distance in: file index#',num2str(file_index),...
                ' col#',num2str(col_index)])
            disp('Setting now to zero')
            Data_BPM{file_index, 1}.peak_locations{file_index,col_index} = [NaN];
        end
        if isempty(Data_BPM_summary.peak_distances{file_index,col_index})
            disp(['No peak distance in file index#',num2str(file_index),...
                ' col#',num2str(col_index)])
            Data_BPM_summary.peak_distances{file_index,col_index} = NaN; % 0;
        end
    end

end
%% Calculate avg and std peak distances
for file_index = 1:DataInfo.files_amount
    disp(['Calculating average peak distances in file#',...
        num2str(file_index),'/',num2str(DataInfo.files_amount)])
    for kk = 1:length(chosen_datacol_indexes)
        col_index = chosen_datacol_indexes(kk);
        Data_BPM_summary.peak_distances_avg(file_index,col_index) = ...
            mean(Data_BPM_summary.peak_distances{file_index,col_index});
        Data_BPM_summary.peak_distances_std(file_index,col_index) = ...
            std(Data_BPM_summary.peak_distances{file_index,col_index});          
        
    end

end



end