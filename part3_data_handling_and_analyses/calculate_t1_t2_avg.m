function [t1_t2_avg_and_std] = calculate_t1_t2_avg(t1,t2)
% function [t1_t2_avg_and_std] = calculate_t1_t2_avg(t1,t2);


narginchk(2,2)
nargoutchk(1,1)

t1_t2_avg_and_std = []; 
for kk = 1:length(t1)
    t1_t2_avg_and_std(end+1,:) = [nanmean(t1{kk,1}) nanstd(t1{kk,1}) ...
        nanmean(t2{kk,1}) nanstd(t2{kk,1})];
end

end