function [use_high_peaks] = should_high_peak_data_be_used(data,elcol,high_peaks_ratio_to_low_peaks)
% function [use_high_peaks] = should_high_peak_data_be_used(data,elcol,high_peaks_ratio_to_low_peaks)
% checks if high peaks data should be used instead of low peaks data
% using following rules: 
% 1) if number of high peaks is at least high_peaks_ratio_to_low_peaks times number of low peaks
    % high_peaks_ratio_to_low_peaks default = 0.8
    % Avoiding that some of high peaks are affecting result 
    % if #Peaks_h > 0.5 x #peaks_l
% 2)if (Amplitude_h > Amplitude_l AND Astd_h < Astd_l) OR
% (Amplitude_h > Amplitude_l AND BPMstd_h < BPMstd_l)
% high_peaks_ratio_to_low_peaks is optional, default = 0.8
if nargin < 3
   high_peaks_ratio_to_low_peaks = 0.8; 
end
%%%%
use_high_peaks = 0; % default, changing if high peaks will be used
hpr = high_peaks_ratio_to_low_peaks;

% high peaks should be at least high_peaks_ratio_to_low_peaks times 
if data.Amount_of_peaks_high(elcol) > hpr*data.Amount_of_peaks_low(elcol)
    % if high peak amplitude > low peak amplitude
    pvh = data.peak_values_high{elcol,1}; % high peak values
    pvl = abs(data.peak_values_low{elcol,1}); % low peak values´
    dh = data.peak_avg_distance_in_ms_high(elcol,:); % high peak distances
    dl = data.peak_avg_distance_in_ms_low(elcol,:); % high peak distances
    pvh_std_per = std(pvh) / mean(pvh) * 100; % high amplitudes std in % compared to Amplitude_avg
    pvl_std_per = std(pvl) / mean(pvl) * 100; % low amplitudes std in % compared to Amplitude_avg 
    bpm_std_h = [dh(2)/dh(1) * 100]; % std of high peak distances in %
    bpm_std_l = [dl(2)/dl(1) * 100]; % std of low peak distances in %
    
    % is amplitude higher in high peaks
    if mean(pvh) > mean(pvl) 
        % if std in % of high peak amplitude  < low peak amplitude
        if pvh_std_per < pvl_std_per % std(pvh) < std(pvl)
            use_high_peaks = 1; 
            disp('Using high peaks as amplitudes larger and std smaller')
        % if std of high BPM  < std low BPM
        elseif bpm_std_h < bpm_std_l
            use_high_peaks = 1; 
            disp('Using high peaks as amplitudes larger and std of BPM smaller')
        else
            if (mean(pvh) / mean(pvl)) > (pvh_std_per / pvl_std_per)
                use_high_peaks = 1; 
                disp(['Using high peaks as amplitudes are larger and ',...
                    ' normalized std smaller change'])
            elseif (mean(pvh) / mean(pvl)) > (bpm_std_h / bpm_std_l)
                use_high_peaks = 1; 
                disp(['Using high peaks as amplitudes are larger and ',...
                    ' normalized BPM std smaller change'])
            else %  do not use high peaks
                disp(['Using low peaks even amplitude of high peaks ',...
                    'is higher as std is smaller with low peaks'])
            end
        end
    end
    % if BPM std is higher in lower peaks than in high peaks
    if (bpm_std_l / bpm_std_h)  > 1.2 % / (mean(pvl) / mean(pvh))
        % something more than 1, as slight variations
%     if bpm_std_l > bpm_std_h
        use_high_peaks = 1; 
        disp('Using high peaks as std of BPM is smaller even though mean amplitude is smaller')
    end
    
    
    %  if low peaks = 0 / NaN    
    if data.Amount_of_peaks_low(elcol) < 3 && data.Amount_of_peaks_high(elcol) > 2
        use_high_peaks = 1; 
        disp('Using high peaks as NaN or close in lower peaks')
    end
    %  if low peaks = 0 / NaN    
    if data.Amount_of_peaks_low(elcol) < 2 && data.Amount_of_peaks_high(elcol) > 1
        use_high_peaks = 1; 
        disp('Using high peaks as NaN in lower peaks')
    end    
    
    % if none --> using low peaks
    if use_high_peaks == 0
        disp('Amplitude is lower or std larger in high peaks --> using low peaks')
    end
    
else
     disp('Less high peaks than low --> using low peaks')
end
            
end




































