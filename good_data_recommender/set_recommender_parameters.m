function [recommender_parameters] = set_recommender_parameters(fmaxHz, ...
    method_to_choose_data_order,how_many_best_data)
% set_recommender_parameters provides parameters that are used
%   Detailed explanation goes here
narginchk(0,3)
nargoutchk(0,1)

% default values

if nargin < 1 || isempty(fmaxHz)
    % default fmaxHz = 2.5 Hz
    fmaxHz = 2.5;
end

if nargin < 2 || isempty(method_to_choose_data_order)
    % default method to choose data is mex vs median values below fmaxHz
    method_to_choose_data_order = 'max_vs_median_below_fmaxHz';
end

% if not given, taking all data
if nargin < 3 || isempty(how_many_best_data)
    % default datacolumns in data variable
    try
        data = evalin('base','data');
        how_many_best_data = min(size(data));
    catch
        DataInfo = evalin('base','DataInfo');
        how_many_best_data = length(DataInfo.datacol_numbers);
    end
end

recommender_parameters.fmaxHz = fmaxHz;
recommender_parameters.method_to_choose_data_order = method_to_choose_data_order; 
recommender_parameters.how_many_best_data = how_many_best_data;
disp('set following parameters: ')
recommender_parameters

end