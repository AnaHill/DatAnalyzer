function [Rule] = set_default_filetype_rules_for_peak_finding(FrameRate, signal)
% rules_to_find_peaks(FrameRate,peak_rule,)
narginchk(0,2)
nargoutchk(0,1)

% default values: typical MEA values
if nargin < 1
    FrameRate = 25e3;
end
if nargin < 2
   signal = 'MEA'; 
end
% Rule.peak_rule_type = peak_rule;
% default is that only high peaks are counted --> not in MEA
Rule.is_low_peaks_counted = 0;
%  minimum peak width to eliminate noise peaks
Rule.minimum_peak_width = 50; %TODO: katso sopivat arvot eri ryhmille
switch signal
    case {'MEA'} % MEA
        Rule.is_low_peaks_counted = 1; % also low peaks
        Rule.signal = signal; 
        Rule.FrameRate = FrameRate; 
        Rule.Gain = 1.3; 
        Rule.ExtraGain = 0.4; 
        Rule.MinDif = 0.005;
        Rule.MaxBPM = 120; 
        Rule.MinDist_sec = 60/Rule.MaxBPM;
        Rule.MinDist_frames = Rule.MinDist_sec*FrameRate;
        Rule.MinPeakValue  = 2.5e-5; % pretty good stardard
    case {'CA'}% {'CalciumImaging'} % Calcium imaging
        Rule.signal = signal; 
        Rule.Gain = 1.3; 
        Rule.ExtraGain = 0.6; 
        Rule.MinDif = 0.005;
        Rule.MaxBPM = 180; % 135;
        Rule.MinDist_sec = 60/Rule.MaxBPM;
        Rule.MinDist_frames = Rule.MinDist_sec*FrameRate;
%         Rule.FrameRate = 35; % calcium imaging, mutta vaihtelee
        Rule.MinPeakValue  = 5; % TODO: m‰‰rit‰ sopiva arvo
    case {'AP'} % {'APdata'} % action_potential_data
        Rule.signal = signal; 
        Rule.FrameRate = FrameRate; 
        Rule.Gain = 1.3; 
        Rule.ExtraGain = 0.4; % 0.6; 
        Rule.MinDif = 0.005;
        Rule.MaxBPM = 180; % CHECK
        Rule.MinDist_sec = 60/Rule.MaxBPM;
        Rule.MinDist_frames = Rule.MinDist_sec*FrameRate;
        Rule.MinPeakValue  = 400;
    case {'Video'} % {'VideoToBPM'} % VideoToBPM
        Rule.signal = signal; 
        Rule.Gain = 1.3; 
        Rule.ExtraGain = 0.6; 
        Rule.MinDif = 0.005;
        Rule.MaxBPM = 180;% 135;
        Rule.MinDist_sec = 60/Rule.MaxBPM;
        Rule.MinDist_frames = Rule.MinDist_sec*FrameRate;
        Rule.FrameRate = FrameRate;
        Rule.MinPeakValue  = 20; % TODO: m‰‰rit‰ sopiva arvo
    otherwise % ask all
        % TODO: 
        Rule.FrameRate = FrameRate; 
        Rule.signal = signal; 
        disp('TODO to ask all parameters, now only Framerate and rule set')    
end
disp(['Default peak finding rules set using rule "',num2str(signal),'"'])


