function [f, P1] = calculate_and_check_fft(data, fs, plotting_fft)
% function [f, P1] = calculate_and_check_fft(data, fs, plotting_fft)
narginchk(1,3)
nargoutchk(0,2)

if nargin < 2 || isempty(fs)
    try
        fs = evalin('base','DataInfo.framerate(1)');
        warninig('No fs given, defined as DataInfo.framerate(1)')
        disp(['fs = ',num2str(fs)])
    catch
        error('give fs')
    end
end

if nargin < 3 || isempty(plotting_fft)
    plotting_fft = 0;
end
%% calculate FFT
L = max(size(data));
% warning if L is odd 
f = fs*(0:(L/2))/L;
Y = fft(data);
P2 = abs(Y/L);
P1 = P2(1:L/2+1,:);
P1(2:end-1,:) = 2*P1(2:end-1,:);

% if plotting fft
if plotting_fft == 1
    fig_full
    plot(f,P1)
end

end
