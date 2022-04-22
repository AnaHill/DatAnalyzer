function [DataInfo, Data_BPM] = run_check_edges(Data, DataInfo, Data_BPM, gain)
% function [DataInfo,Data_BPM] = run_check_edges(Data, DataInfo, Data_BPM, gain)
narginchk(0,4)
nargoutchk(0,2)
if nargin < 1 || isempty(Data)
    Data = evalin('base','Data');
end
if nargin < 2 || isempty(DataInfo)
    DataInfo = evalin('base','DataInfo');
end
if nargin < 3 || isempty(Data_BPM)
    Data_BPM = evalin('base','Data_BPM');
end
if nargin < 4 || isempty(gain)
    gain = 1.5; % same default as in check_peak_distance_from_edges
end
 

peak_edge_flag = zeros(DataInfo.files_amount,length(DataInfo.datacol_numbers));
for pp=1:DataInfo.files_amount
    for kk=1:length(DataInfo.datacol_numbers)
        try 
            peak_times = Data_BPM{pp,1}.peak_locations{kk,1} /DataInfo.framerate(pp,1);
            end_time = (length(Data{pp,1}.data(:,1))-1)/DataInfo.framerate(pp,1);
            peak_edge_flag(pp,kk) = check_peak_distance_from_edges(peak_times,end_time, gain);
            % [flag] = check_peak_distance_from_edges(peak_times, end_time, gain, start_time)
        catch
            disp('no peaks')
        end
    end
end


[ind_filenum, ind_col] = find(peak_edge_flag > 0);
if isempty(ind_filenum)
    disp('No long delays at the begin or end found based on rule:')
    disp(['If first/last peak distance from the edge > max_peak_distance * ',num2str(gain)])
    disp('where max_pea_distance is maximum peak distance inside data')
    disp('updating DataInfo; removing DataInfo.long_pause_at_edges if exist')
    try
        DataInfo = rmfield(DataInfo , 'long_pause_at_edges');
    catch
        
    end
    return
else % if finding something -> updating DataInfo and Data_BPM
    ind_filenum = sort(unique(ind_filenum));
    abnormal_peak_edges = zeros(length(ind_filenum),1+length(DataInfo.datacol_numbers));
    for zz=1:length(ind_filenum)
        pp=ind_filenum(zz);
        abnormal_peak_edges(zz,:) = [pp peak_edge_flag(pp,:)];
    end
    % updating Data_BPM --> setting BPM based on signal length/#peaks
    disp('Updating DataInfo in the following data')
    disp('In DataInfo.abnormal_peak_edges')
    disp('Filenum# Datacols with different egde flags: ')
    disp([num2str(abnormal_peak_edges)])
    try
        for kk = 1:length(peak_edge_flag(1,:)-1)
            datacol_names{1,kk} = ['MEA',num2str(DataInfo.MEA_electrode_numbers(kk))];
        end
    catch % non-mea data
        for kk = 1:length(peak_edge_flag(1,:)-1)
            datacol_names{1,kk} = ['DataCol',num2str(DataInfo.datacol_numbers(kk))];
        end
    end
    varnames = ['file_index',datacol_names];
%     abnormal_peak_edge_flags = {zeros(size(abnormal_peak_edges))};
%     abnormal_peak_edge_flags{:,1} = abnormal_peak_edges(:,1);
    for pp = 1:length(abnormal_peak_edges(:,1))
        abnormal_peak_edge_flags{pp,1} = abnormal_peak_edges(pp,1);
        for kk = 1:length(abnormal_peak_edges(1,:))-1
            switch abnormal_peak_edges(pp,kk+1)
                case 0
                    abnormal_peak_edge_flags{pp,kk+1} = 'normal';
                case 1
                    abnormal_peak_edge_flags{pp,kk+1} = 'begin';
                case 2
                    abnormal_peak_edge_flags{pp,kk+1} = 'end';
                case 3
                   abnormal_peak_edge_flags{pp,kk+1} = 'begin & end';
            end
        end
    end
    % array2table(abnormal_peak_edge_flags,'Variablenames',varnames)
    DataInfo.long_pause_at_edges.flags = array2table(...
        abnormal_peak_edge_flags,'Variablenames',varnames);
    DataInfo.long_pause_at_edges.id = array2table(...
        abnormal_peak_edges,'Variablenames',varnames);    
    disp(DataInfo.long_pause_at_edges.flags)
    disp('DataInfo.long_pause_at_edges created')

    
    disp('Updating Data_BPM in the long pause at edges')
    disp('Calculating BPM using formula: peaks_amount / full_time_length * 60')
    for pp = 1:length(abnormal_peak_edges(:,1))
        for kk = 1:length(abnormal_peak_edges(1,:))-1
            Data_BPM{abnormal_peak_edges(pp),1}.long_pause_flags = ...
                 DataInfo.long_pause_at_edges.flags(pp,2:end);
            if abnormal_peak_edges(pp,kk+1) > 0 % 0=normal, otherwise
                datap = length(Data{abnormal_peak_edges(pp), 1}.data(:,kk));
                fs  = DataInfo.framerate(abnormal_peak_edges(pp));
                full_time_length = (datap-1)/fs;
                peaks_amount = Data_BPM{abnormal_peak_edges(pp),1}.Amount_of_peaks(kk,1);
                
                Data_BPM{abnormal_peak_edges(pp),1}.BPM_avg(kk,1) = ...
                     peaks_amount / full_time_length * 60;
            end
        end
    end
%     disp('Data_BPM{indexes,1}.long_pause_flags created and .BPM_avg in long delay cases updated')
end
%%
% clear pp kk ind_col ind_filenum peak_times end_time peak_edge_flag

%%

end