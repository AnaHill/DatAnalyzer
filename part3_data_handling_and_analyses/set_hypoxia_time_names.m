function DataInfo = set_hypoxia_time_names(DataInfo)
% function DataInfo = set_hypoxia_time_names(DataInfo)
% set names for hypoxia studies
% set hypoxia names to DataInfo.hypoxia.names
% updates 2021/04:
    % in Demo3, hypoxia are not related to indexes of start/end of hypoxia
        % start_index = when hypoxia is on already (just or after prev index)
        % end_index = when hypoxia is turned off already (somewhere between current and prev index)
    % in Long Ischemia --> hypoxia just after
narginchk(1,1)
nargoutchk(0,1)

% check DataInfo.hypoxia
try
    hy = DataInfo.hypoxia;
catch
    error('No hypoxia defined in DataInfo.hypoxia!')
end

% time vector in hours
experiment_time_in_h =  DataInfo.measurement_time.time_sec/3600;% in h
%%
if ~strcmp(DataInfo.experiment_name,'demo3')
    % disp('Non demo3 data')
    % warning('TODO: check that correct if other than long ischemia data is read')
    % new time vector related to hypoxia
    ind_h_end_ind = find(DataInfo.measurement_time.time_sec >= hy.end_time_sec,1);
    ind_h_end_ind = ind_h_end_ind-1;
    %%% POIKKEUKSET, jolla ei oteta indeksiksi yhtä taaksepäin 
    if strcmp(DataInfo.experiment_name,'d020320') 
        % takaisin yksi hypoksian viimeiseksi indeksiksi -> lisätään
        ind_h_end_ind = ind_h_end_ind+1;
        disp(['Small ind_h_end_ind modification for experiment ',...
           DataInfo.experiment_name,'-', DataInfo.measurement_name])
    end

    time_hypox_h = experiment_time_in_h;
    hy.start_time_index; % monesko
    if hy.start_time_index > 1
        period_before = 1:hy.start_time_index-1;
        t_hypox0 = experiment_time_in_h(hy.start_time_index);
        time_hypox_h = experiment_time_in_h - t_hypox0;
    else
        period_before = 0;
        time_hypox_h = experiment_time_in_h;
    end
    period_hypox = [hy.start_time_index:ind_h_end_ind];
    period_reoxygenation = [ind_h_end_ind+1:length(DataInfo.measurement_time.time_sec)];
    % vähennetään "oikea" hypoksia-aika, eli aloituksesta 24h eteenpän
    t_reoxy_h = experiment_time_in_h(ind_h_end_ind+1:end) - hy.end_time_sec/3600;

    %%% POIKKEUKSET, 
    % jossa t_reoxy_h onkin viimeinen hypoksia arvo (= > 24h)
    if strcmp(DataInfo.experiment_name,'d020320')
       t_reoxy_h = experiment_time_in_h(ind_h_end_ind+1:end) - experiment_time_in_h(ind_h_end_ind);
       disp(['Small t_reoxy modification for experiment ',...
           DataInfo.experiment_name,'-', DataInfo.measurement_name])
    end
    %%%%
    time_reoxy_h = [experiment_time_in_h(1:ind_h_end_ind); t_reoxy_h];
    time_names = {};
    if any(period_before ~= 0)
        for pp = period_before
            time_names{end+1,1} = ['BL: before hypoxia t = ',...
                (num2str(fix(10*time_hypox_h(pp))/10)),'h'];
        end
    end
    for pp = period_hypox
        time_names{end+1,1} = ['Hypoxia t = ',...
            (num2str(fix(10*time_hypox_h(pp))/10)),'h'];
    end
    for pp = period_reoxygenation
        time_names{end+1,1} = ['Reoxygenation t = ',...
            (num2str(fix(10*time_reoxy_h(pp))/10)),'h'];
    end
    disp('DataInfo.hypoxia.names created for non demo3 data')

end


%% demo3
if strcmp(DataInfo.experiment_name,'demo3')
    % new time vector related to hypoxia
    disp('Demo3: now names are related to hypoxia start and end times, not indexes!')
%     ind_h_end_ind = find(DataInfo.measurement_time.time_sec >= hy.end_time_sec,1);
%     ind_h_end_ind = ind_h_end_ind-1;
%     
%     %%% POIKKEUKSET, jolla ei oteta indeksiksi yhtä taaksepäin 
%     if strcmp(DataInfo.measurement_name, 'demo3_13')   
%         % otetaan yksi edeltävä indeksi hypoksian viimeiseksi, sillä 
%         % demo3:ssa automaattinen vaihto 8h tunnin jälkeen, eikä mittaukset
%         % mene ihan tuohon, vaan kaksi mittausta on tuossa välissä 
%         % PÄIVITYS 2021/04: ei tarvitakaan?
%         % TODO: tarkista
%     %     ind_h_end_ind = ind_h_end_ind-1;
%     %     disp(['Small ind_h_end_ind modification for experiment ',...
%     %        DataInfo.experiment_name,'-', DataInfo.measurement_name])
%         warning('TODO: check, if demo 3.13 indexes are now correct')    
%     end 
    % hy = DataInfo.hypoxia;
     hypox_indexes = hy.start_time_index:hy.end_time_index-1;   
    if hy.start_time_index > 1
        baseline_indexes = 1:hy.start_time_index-1;
    else
        baseline_indexes = 0; % no baseline
    end
    time_vector_in_h = experiment_time_in_h - hy.start_time_sec/3600;
    time_names = {zeros(DataInfo.files_amount,1)};
    if any(baseline_indexes ~= 0)
        for pp = baseline_indexes
%             time_names{pp,1} = ['BL: before hypoxia t = ',...
%                 (num2str(fix(10*time_vector_in_h(pp))/10)),'h'];
            time_names{pp,1} = ['BL: before hypoxia t = ',...
                num2str(round(time_vector_in_h(pp,1),1)),'h'];            
        end
    end
    for pp = hypox_indexes
        time_names{pp,1} = ['Hypoxia t = ',...
            num2str(round(time_vector_in_h(pp,1),1)),'h'];
    end
    
    
    % Reoxy
    if hy.end_time_index < DataInfo.files_amount
        reoxy_indexes = hy.end_time_index:DataInfo.files_amount;
        time_vector_in_h_for_reoxy = experiment_time_in_h - hy.end_time_sec/3600;
    else
        reoxy_indexes = 0; % no reoxynation
        time_vector_in_h_for_reoxy = 0;
    end

    if any(reoxy_indexes ~= 0)
        for pp = reoxy_indexes
            time_names{pp,1} = ['Reoxygenation t = ',...
                num2str(round(time_vector_in_h_for_reoxy(pp,1),1)),'h'];
        end
    end    

    
    
    
    
    

    
    
    disp('DataInfo.hypoxia.names created for Demo3 data')
end
%%
DataInfo.hypoxia.names = time_names;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end