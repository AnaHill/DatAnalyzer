function found_indexes = find_first_index_where_data_reach_threshold...
    (data,threshold_values,larger_or_smaller)
% find_first_index_where_data_reach_threshold(data,threshold_values)
% find_first_index_where_data_reach_threshold(data,threshold_values,'smaller')
narginchk(2,3)
nargoutchk(0,1)
% default: finding first index where data is larger than threshold value
if nargin < 3 || isempty('larger_or_smaller')
    disp('Set level to find larger value than given threshold')
    larger_or_smaller = 'larger';
end
% assuming column-ordered data
datacolumns_amount = length(data(1,:));
if datacolumns_amount > length(threshold_values)
    threshold_values = threshold_values(1)*ones(1,datacolumns_amount);
    disp('Threshold_values was not defined to each data column.')
    disp('Set threshold value to each data column to threshold_values(1)')
end

found_indexes = NaN*(1:datacolumns_amount);
for col_ind = 1:datacolumns_amount
    if strcmp(larger_or_smaller,'larger')
        found_indexes(1,col_ind) = find(data(:,col_ind) >= ...
            threshold_values(col_ind),1,'first');
    else % finding smaller than threshold value 
        found_indexes(1,col_ind) = find(data(:,col_ind) <= ...
            threshold_values(col_ind),1,'first');
    end
end


end