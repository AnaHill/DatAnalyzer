function [dat, tittext] = which_fpd_correction(fpd_correction_equation,...
    dat, Data_BPM_summary)
% function [dat, tittext] = which_fpd_correction(fpd_correction_equation)
% calculates fpd correction based on user input
% Options: 
    % 1) (default) Izumi-Nakaseko: FPDc=FPD/(60/BPM)^{0.22}
        % https://doi.org/10.1016/j.jphs.2017.08.008
    % 2) Bazett: FPDc=FPD/(60/BPM)^{1/2}
        % 
    % 3) Fridericia: FPDc=FPD/(60/BPM)^{1/3}
    % 4) Pure FPD

narginchk(0,3)
nargoutchk(0,2)

if nargin < 1 || isempty(fpd_correction_equation)
    fpd_correction_equation = 'Izumi-Nakaseko';
end

if nargin < 3 || isempty(Data_BPM_summary)
    Data_BPM_summary = evalin('base','Data_BPM_summary');
end

switch fpd_correction_equation
    case 'Izumi-Nakaseko'
        dat = dat./(Data_BPM_summary.BPM_avg/60).^0.22; % \cite{Hyyppa2018}: Izumi-Nakeseko 2017
        tittext = ['BMP corrected signal duration',10,'FPDc=FPD/(60/BPM)^{0.22} (ms)'];
        disp('Choosing Izumi-Nakaseko: FPDc=FPD/(60/BPM)^{0.22}')
    case 'Bazett'
        dat = dat./sqrt(Data_BPM_summary.BPM_avg/60);
        tittext = ['BMP corrected signal duration',10,'Bazetts FPDc=FPD/(60/BPM)^{1/2} (ms)'];
        disp('Choosing Bazetts: FPDc=FPD/(60/BPM)^{1/2}')
    case 'Fridericia'
        dat = dat./(Data_BPM_summary.BPM_avg/60).^(1/3);
        tittext = ['BMP corrected signal duration',10,'Fridericia FPDc=FPD/(60/BPM)^{1/3} (ms)'];
        disp('Choosing Fridericia: FPDc=FPD/(60/BPM)^{1/3}')
    otherwise
        disp('No proper FPDc chosen:') % dat = dat;
        tittext = ['FPD'];    
end

end