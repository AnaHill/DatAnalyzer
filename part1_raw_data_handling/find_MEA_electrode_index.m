function meas_ele_index = ...
    find_MEA_electrode_index(electrodes_numbers, electrode_layout)
% function measurement_electrode_numbers =  find_MEA_electrode_index(electrodes_number, electrode_layout)
% FIND_MEA_ELECTRODE_INDEX LS finds defined measurement electrode channel indexes
% this information will be used 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
narginchk(1,2)
nargoutchk(1,1)
if isempty(electrodes_numbers)
    meas_ele_index = [];
    warning('No electrodes, returning')
    %%TODO: choose electrodes
    return
end

if nargin < 2 || isempty(electrode_layout)
    [electrode_layout] = read_MEA_electrode_layout();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% finding columns of the wanted electrodes
el_nums = electrode_layout.electrode_number;
el_ind = electrode_layout.index;
for kk = 1:length(electrodes_numbers)
    meas_ele_index(kk,1) = ...
        el_ind(find(electrodes_numbers(kk) == el_nums));
end
disp('Finding MEA channels (columns in raw data) based on given electrodes')
disp(['Chosen electrodes are: ',num2str(electrodes_numbers(:)')])
disp(['MEA channels (columns) are: ',num2str(meas_ele_index(:)')])
