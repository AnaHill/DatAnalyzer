function mea_electrodes_numbers = ...
    find_MEA_electrode_number_from_datacol_index(datacols, electrode_layout)
% function mea_electrodes_numbers =  find_MEA_electrode_number_from_datacol_index(datacols, electrode_layout)
% TODO lisäteksti
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
narginchk(1,2)
nargoutchk(1,1)
if isempty(datacols)
    mea_electrodes_numbers = [];
    warning('No datacols, returning')
    return
end

if nargin < 2 || isempty(electrode_layout)
    [electrode_layout] = read_MEA_electrode_layout();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% finding electrode numbers based on wanted datacolumns
el_nums = electrode_layout.electrode_number;
el_ind = electrode_layout.index;
for kk = 1:length(datacols)
    mea_electrodes_numbers(kk,1) = ...
        el_nums(find(datacols(kk) == el_ind));
end
disp('Finding MEA electrodes based on given (raw) datacol-numbers')
disp(['Chosen datacolumns are: ',num2str(datacols(:)')])
disp(['MEA electrodes found are: ',num2str(mea_electrodes_numbers(:)')])