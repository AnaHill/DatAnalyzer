function hs = design_notch_filter_for_certain_frequencies(freqs_to_remove,fs,...
    BW, plot_design) 
% function hs = design_notch_filter_for_certain_frequencies(freqs_to_remove, fs, BW, plot_design)
% develops cascade notch filters to remove frequencies given in freqs_to_remove
% Using following 2nd order notch filter design command: 
    % f = fdesign.notch('N,F0,BW',2,freqs_to_remove,BW,fs);
% 1-10 frequencies are connected using cascade command
    % hd = dfilt.cascade(h{1},h{amount_of_freqs_to_filter});
    % For more information, see:
    % https://se.mathworks.com/matlabcentral/answers/146360-design-notching-filter-for-different-frequencies
% Inputs
    % freqs_to_remove = frequencies to remove in [Hz]
	% fs = sampling frequency [Hz], if not given tries to read DataInfo.framerate(1)
    % BW = bandwidth used in notch design [Hz], default = 0.5 Hz
% Output
    % hs = designed notch filter using, sysboj of hd: hs = sysobj(hd);
% Notice, that cascade allows only 10 different frequencies / stages
narginchk(1,4)
nargoutchk(0,1) 

% checking inputs
% max 10 frequencies can be cascaded
if nargin < 1 || isempty(freqs_to_remove)
    warning('No frequencies given, returning')
    return
else
    amount_of_freqs_to_filter = length(freqs_to_remove);
    if amount_of_freqs_to_filter > 10
        amount_of_freqs_to_filter = 10;
        warning('Only max 10 frequencies can be cascaded!')
        disp('Taking first 10 values from the input list')
    end
end

if nargin < 2 || isempty(fs)
    warning('No fs given, trying to define it from the workspace.')
    try
        fs = evalin('base','DataInfo.framerate(1)');
        disp('fs defined from DataInfo.framerate(1)')
    catch
        error('No fs!')
    end
end
% Bandwidth of notch, default: 0.5 Hz
if nargin < 3 || isempty(BW)
    BW = 0.5; 
end
% default: do not plot filter design
if nargin < 4 || isempty(plot_design)
    plot_design = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% creating notch filters
for pp = 1:amount_of_freqs_to_filter
    f{pp,1} = fdesign.notch('N,F0,BW',2,freqs_to_remove(pp),BW,fs);
    h{pp,1} = design(f{pp,1});
end
% cascade created notch filter, results a dfilt object hd
switch amount_of_freqs_to_filter
    case 1
        hd = dfilt.cascade(h{amount_of_freqs_to_filter});
    case 2
        hd = dfilt.cascade(h{1},h{amount_of_freqs_to_filter});
    case 3
        hd = dfilt.cascade(h{1},h{2},h{amount_of_freqs_to_filter});
    case 4
        hd = dfilt.cascade(h{1},h{2},h{3},h{amount_of_freqs_to_filter});
    case 5
        hd = dfilt.cascade(h{1},h{2},h{3},h{4},h{amount_of_freqs_to_filter});
    case 6
        hd = dfilt.cascade(h{1},h{2},h{3},h{4},h{5},h{amount_of_freqs_to_filter});
    case 7
        hd = dfilt.cascade(h{1},h{2},h{3},h{4},h{5},h{6},h{amount_of_freqs_to_filter});
    case 8
        hd = dfilt.cascade(h{1},h{2},h{3},h{4},h{5},h{6},h{7},...
            h{amount_of_freqs_to_filter});
    case 9
        hd = dfilt.cascade(h{1},h{2},h{3},h{4},h{5},h{6},h{7},h{8},...
            h{amount_of_freqs_to_filter});
    case 10
        hd = dfilt.cascade(h{1},h{2},h{3},h{4},h{5},h{6},h{7},h{8},h{9},...
            h{amount_of_freqs_to_filter});
    otherwise
        error('cascade not working!')
end

% If chosen in function input (plot_filter_design), plotting designed filter
if plot_design == 1
    hfvt = fvtool(hd,'Color','white');
end
% generate a filter System object
hs = sysobj(hd);
end
