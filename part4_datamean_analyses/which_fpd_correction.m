function [data_out, tittext] = which_fpd_correction(data_in, fpd_correction_equation,...
    Data_BPM_summary)
% function [data_out, tittext] = which_fpd_correction(data_in, fpd_correction_equation,Data_BPM_summary)
% calculates fpd correction based on user input
% Options: 
    % 1) Izumi-Nakaseko (default): FPDc=FPD/(60/BPM)^{0.22}
        % more info: https://doi.org/10.1016/j.jphs.2017.08.008
    % 2) Bazett: FPDc=FPD/(60/BPM)^{1/2}
    % 3) Fridericia: FPDc=FPD/(60/BPM)^{1/3}
    % 4) Other: Pure FPD

narginchk(1,3)
nargoutchk(0,2)

if nargin < 2 || isempty(fpd_correction_equation)
    fpd_correction_equation = 'Izumi-Nakaseko';
end

if nargin < 3 || isempty(Data_BPM_summary)
    Data_BPM_summary = evalin('base','Data_BPM_summary');
end

switch fpd_correction_equation
    case 'Izumi-Nakaseko'
        data_out = data_in ./ (Data_BPM_summary.BPM_avg/60).^0.22; 
        tittext = ['Izumi-Nakaseko: FPDc = FPD / (60/BPM)^{0.22}'];
        %tittext = [10,'Izumi-Nakaseko: FPDc = FPD / (60/BPM)^{0.22}'];
        disp('Choosing Izumi-Nakaseko: FPDc=FPD/(60/BPM)^{0.22}')
    case 'Bazett'
        data_out = data_in ./ sqrt(Data_BPM_summary.BPM_avg/60);
        tittext = ['Bazett: FPDc = FPD / (60/BPM)^{1/2}'];
        disp('Choosing Bazett: FPDc=FPD/(60/BPM)^{1/2}')
    case 'Fridericia'
        data_out = data_in ./ (Data_BPM_summary.BPM_avg/60).^(1/3);
        tittext = ['Fridericia: FPDc = FPD / (60/BPM)^{1/3}'];
        disp('Choosing Fridericia: FPDc=FPD/(60/BPM)^{1/3}')
    otherwise
        disp('No proper FPDc formula chosen: using FPD')
        data_out = data_in; 
        tittext = ['Pure FPD, not BPM corrected FPDc'];    
end

end