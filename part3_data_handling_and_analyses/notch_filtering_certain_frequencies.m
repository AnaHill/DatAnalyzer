function hs = design_notch_filter_for_certain_frequencies(freqs_to_remove,...
    % fs, BW, remove_50Hz,plot_filter_design)
% function hs = design_notch_filter_for_certain_frequencies(freqs_to_remove, fs, BW, remove_50Hz,plot_filter_design)
% develops cascade notch filters to remove frequencies given in freqs_to_remove
% Using following 2nd order notch filter design command: 
    % f = fdesign.notch('N,F0,BW',2,freqs_to_remove,BW,fs);
% 1-10 frequencies are connected using cascade command
    % hd = dfilt.cascade(h{1},h{amount_of_freqs_to_filter});
    % For more information, see:
    % https://se.mathworks.com/matlabcentral/answers/146360-design-notching-filter-for-different-frequencies
% Inputs
    % freqs_to_remove = frequencies to remove in [Hz]
    % BW = bandwidth used in notch design [Hz]
    % fs = sampling frequency [Hz]
% Output
    % hs = designed notch filter using, sysboj of hd: hs = sysobj(hd);
% Notice, that cascade allows only 10 different frequencies / stages
% TODO: paremmin tuo cascade, nyt "manuaalinen"
narginchk(1,5)
nargoutchk(0,1) 

% default values:
if nargin < 1 || isempty(freqs_to_remove)
    warning('No frequencies given')
    disp('No frequencies given to filtered')
    if nargin < 4 || isempty(remove_50Hz)
        disp('Not filter even any frequency or 50 Hz -> returning')
        return
    end
end

if nargin < 2 || isempty(fs)
    try
        fs = evalin('base','DataInfo.framerate(1)');
        disp('fs defined from DataInfo.framerate(1)')
    catch
        error('give fs')
    end
end
% Bandwidth of notch
if nargin < 3 || isempty(BW)
    BW = 0.5; % BW = 1;
end

% default: remove 50 Hz
if nargin < 4 || isempty(remove_50Hz)
    remove_50Hz = 1;
end

% default: do not plot filter design
if nargin < 5 || isempty(plot_filter_design)
    plot_filter_design = 0;
end
%%% checking inputs
if length(freqs_to_remove) < 1
    warning('No frequencies to remove')
    amount_of_freqs_to_filter = 0;
else
    amount_of_freqs_to_filter = length(freqs_to_remove);
end


if amount_of_freqs_to_filter > 10
    amount_of_freqs_to_filter = 10;
    warning('Only max 10 harmonics components are applied in notch!')
end

% default: remove 50 Hz and its harmonic components
if nargin < 4 || isempty(remove_50Hz)
    remove_50Hz = 1;
end

for pp = 1:amount_of_freqs_to_filter
    f{pp,1} = fdesign.notch('N,F0,BW',2,freqs_to_remove(pp),BW,fs);
    h{pp,1} = design(f{pp,1});
end

%% Removing or not also 50 Hz 
if remove_50Hz == 0 % not removing
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
else % remove also interference at 50 Hz 
    F0 = 50;
    f50hz = fdesign.notch('N,F0,BW',2,F0,BW,fs); 
    h50hz = design(f50hz);
    switch amount_of_freqs_to_filter
        case 1
            hd = dfilt.cascade(h{amount_of_freqs_to_filter},h50hz);
        case 2
            hd = dfilt.cascade(h{1},h{amount_of_freqs_to_filter},h50hz);
        case 3
            hd = dfilt.cascade(h{1},h{2},h{amount_of_freqs_to_filter},h50hz);
        case 4
            hd = dfilt.cascade(h{1},h{2},h{3},h{amount_of_freqs_to_filter},...
                h50hz);
        case 5
            hd = dfilt.cascade(h{1},h{2},h{3},h{4},h{amount_of_freqs_to_filter},...
                h50hz);
        case 6
            hd = dfilt.cascade(h{1},h{2},h{3},h{4},h{5},h{amount_of_freqs_to_filter},...
                h50hz);
        case 7
            hd = dfilt.cascade(h{1},h{2},h{3},h{4},h{5},h{6},h{amount_of_freqs_to_filter},...
                h50hz);
        case 8
            hd = dfilt.cascade(h{1},h{2},h{3},h{4},h{5},h{6},h{7},...
                h{amount_of_freqs_to_filter},h50hz);
        case 9
            hd = dfilt.cascade(h{1},h{2},h{3},h{4},h{5},h{6},h{7},h{8},...
                h{amount_of_freqs_to_filter},h50hz);
        case 10
            hd = dfilt.cascade(h{1},h{2},h{3},h{4},h{5},h{6},h{7},h{8},h{9},...
                h{amount_of_freqs_to_filter});
            warning('Now no 50 Hz is fitered!')
        otherwise
            disp('Just filtering 50 Hz')
            hd = dfilt.cascade(h50hz);
    end
end
% If chosen in function input (plot_filter_design), plotting designed filter
if plot_filter_design == 1
    hfvt = fvtool(hd,'Color','white');
end
hs = sysobj(hd);
end
