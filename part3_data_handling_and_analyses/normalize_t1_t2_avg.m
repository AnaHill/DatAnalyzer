function [t1avg_norm, t2avg_norm, t1_t2_norm] = normalize_t1_t2_avg(...
    t1_t2_avg_and_std, index_for_normalize)
% Normalize t1avg and t2avg values to mean of values 
% given in index_for_normalize, default is the first index
% t1_t2_avg_and_std: assumed columns are 1) t1avg, 2) t1std, 3) t2avg, 4) t2std
% Examples: 
    % normalize to first value (values in the first row)
        % [t1norm, t2norm, t1t2_norm] =  normalize_t1_t2_avg(t1_t2_avg_and_std)
    % calculate mean of two first t1 and t2 values, normalized to that
    % --> index_for_normalize == [1,2] -->
    % [t1avg_norm, t2avg_norm, t1_t2_norm] = normalize_t1_t2_avg(...
    %     t1_t2_avg_and_std, [1,2])
narginchk(1,2)
nargoutchk(0,3)

% default: normalize values to first index
if (nargin < 2) || isempty(index_for_normalize)
    index_for_normalize = 1; 
end

ix = index_for_normalize;
% Normalizing
% assumed columns: 1) t1avg, 2) t1std, 3) t2avg, 4) t2std
t1avg_norm = mean(t1_t2_avg_and_std(ix,1));
t2avg_norm = mean(t1_t2_avg_and_std(ix,3));
t1_t2_norm = [t1_t2_avg_and_std(:,1:2)/t1avg_norm ...
    t1_t2_avg_and_std(:,3:4)/t2avg_norm];


