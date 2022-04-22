function time_and_derivative_of_data = derivate_signal(data, time, fs)
% function time_and_derivative_of_data = derivate_signal(data, time, fs)
% derivate signal d(data)/dt
% time_and_derivative_of_data = [td,yd]
narginchk(1,3)
nargoutchk(0,1)

if nargin < 2 || isempty(time)
    try
        disp('Empty time vector --> creating based on sample frate fs')
        time = [0:1/fs:(length(data)-1)/fs]'; 
        disp('Time vector created from fs info, starting time t=0')
        disp('Notice for time vector of derivative signal:')
        disp('Assigning yd an midway between two subsequent data points')
        disp('So td = (time(2:end)+time(1:(end-1)))/2');
    catch
        error('No proper time or fs given!')
    end
end


ydiff=diff(data);
tdiff=diff(time);
% this is to assign yd an midway between two subsequent x
td = (time(2:end)+time(1:(end-1)))/2;
% calculating time derivative yd = delta_y / delta_t: 
% (y(n+1)-y(n))/(t(n+1)-t(n)) = ydiff(n) / tdiff(n)
for hh = 1:length(tdiff)
    yd(hh,1) = ydiff(hh) ./ tdiff(hh); %; diff(ymed1) ./diff(t);
end
time_and_derivative_of_data= [td, yd];
end