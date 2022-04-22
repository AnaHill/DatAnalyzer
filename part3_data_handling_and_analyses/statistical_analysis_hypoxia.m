%% tilastollinen analyysi
% Wilcoxon rank sum test used: ranksum
t1a = Summary_values.(meas_name).t1{1};
t1b = Summary_values.(meas_name).t1{2};
t2a = Summary_values.(meas_name).t2{1};
t2b = Summary_values.(meas_name).t2{2};
p_t1 = [];h_t1 = [];stats_t1 = [];
p_t2 = [];h_t2 = [];stats_t2 = [];

vertaa = 3:6; % mitkä datat -> 3:6 => muut kuin BL arvot
for pp = 1:length(vertaa)
    t1_ver = Summary_values.(meas_name).t1{vertaa(pp)};
    t2_ver = Summary_values.(meas_name).t2{vertaa(pp)};
    
    % create p_t1, h_t1, stats_t1 and p_t2, h_t2, stats_t2
    % catch used if not working (no values to calculte) 
        % --> sets those values first negative, later to NaN
    
    %t1
    try
        [p_t1(pp,1),h_t1(pp,1),stats_t1{pp,1}] = ranksum(t1a,t1_ver);
    catch
        p_t1(pp,1) = -1;
        h_t1(pp,1) = -1;
        stats_t1{pp,1} = -1;
    end
    try
        [p_t1(pp,2),h_t1(pp,2),stats_t1{pp,2}] = ranksum(t1b,t1_ver);
    catch
        p_t1(pp,2) = -1;
        h_t1(pp,2) = -1;
        stats_t1{pp,2} = -1;
    end
    % t2
    try
        [p_t2(pp,1),h_t2(pp,1),stats_t2{pp,1}] = ranksum(t2a,t2_ver);
    catch
        p_t2(pp,1) = -1;
        h_t2(pp,1) = -1;
        stats_t2{pp,1} = -1;
    end
    try
        [p_t2(pp,2),h_t2(pp,2),stats_t2{pp,2}] = ranksum(t2b,t2_ver);
    catch
        p_t2(pp,2) = -1;
        h_t2(pp,2) = -1;
        stats_t2{pp,2} = -1;
    end
    

end


p_t1(p_t1 == -1) = nan;
p_t2(p_t2 == -1) = nan;
h_t1(h_t1 == -1) = nan;
h_t2(h_t2 == -1) = nan;

% not working with stats so easily...
% stats_t1{find(p_t1 == -1) = nan;
% stats_t1(find(p_t1 == -1)) = nan;


[p_t1  h_t1]
[p_t2  h_t2]

Summary_values.(meas_name).p_t1 = p_t1;
Summary_values.(meas_name).p_t2 = p_t2;
Summary_values.(meas_name).h_t1 = h_t1;
Summary_values.(meas_name).h_t2 = h_t2;
Summary_values.(meas_name).stats_t1 = stats_t1;
Summary_values.(meas_name).stats_t2 = stats_t2;
%%
[Summary_values.(meas_name).p_t1  Summary_values.(meas_name).h_t1]
[Summary_values.(meas_name).p_t2  Summary_values.(meas_name).h_t2]
