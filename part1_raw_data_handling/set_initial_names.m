% set initial_names
if ~exist('filetype', 'var')
    disp('No filetype defined. Setting empty and filetype will be chosen later.')
    filetype = '';
end

if ~exist('exp_name', 'var')
    exp_name = 'exp_temp';
end
if ~exist('meas_name', 'var')
    meas_name = 'meas_temp';
end
if ~exist('meas_date', 'var')
    meas_date = '2021_MM_dd';
end

if ~exist('mea_layout_name', 'var')
    mea_layout_name = 'MEA_64_electrode_layout.txt';
    disp(['No electrode layout defined. Default electrode layout will be loaded: ',...
        10, mea_layout_name])
end

