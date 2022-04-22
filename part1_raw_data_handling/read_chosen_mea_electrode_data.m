function [chosen_mea_data] = read_chosen_mea_electrode_data(info, rawmeadata)
%READ_CHOSEN_MEA_ELECTRODE_DATA Reads chosen electrodes data from rawdata (.h5)
% Reads chosen electrode data (=certain columns) from rawdata(.h5 file)
% and converts them to proper value based on info in .h5
% output chosen_mea_data includes converted raw data in double digits
% info needs to include MEA_columns
% rawdata needs to include structure with
    % .MSCFile and .info which includes ADzero ConversionFactor Exponent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
narginchk(2,2)
nargoutchk(0,1)

try
    % picks chosen data columns to variable col
    col = uint8(info.MEA_columns)';
    % converts chosen data columns data to raw signal data
    chosen_mea_data = double(rawmeadata.MCSFile(:,col) - ...
        rawmeadata.info.ADZero(col)') .* ...
        (double(rawmeadata.info.ConversionFactor(col)) .* ...
        10.^double(rawmeadata.info.Exponent(col)))';
catch
    error('reading certain electode data from raw data not working!')
end