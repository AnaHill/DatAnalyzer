function [Height, Position, Width]=gaussfit(x,y)
% Converts y-axis to a log scale, fits a parabola
% (quadratic) to the (x,ln(y)) data, then calculates
% the position, width, and height of the
% Gaussian from the three coefficients of the
% quadratic fit.  This is accurate only if the data have
% no baseline offset (that is, trends to zero far off the
% peak) and if there are no zeros or negative values in y.
%
% Example 1: Simplest Gaussian data set
% [Height, Position, Width]=gaussfit([1 2 3],[1 2 1]) 
%    returns Height = 2, Position = 2, Width = 2
%
% Example 2: best fit to synthetic noisy Gaussian
% x=50:150;y=100.*gaussian(x,100,100)+10.*randn(size(x));
% [Height,Position,Width]=gaussfit(x,y) 
%   returns [Height,Position,Width] clustered around 100,100,100.
%
% Example 3: plots data set as points and best-fit Gaussian as line
% x=[1 2 3 4 5];y=[1 2 2.5 2 1];
% [Height,Position,Width]=gaussfit(x,y);
% plot(x,y,'o',linspace(0,8),Height.*gaussian(linspace(0,8),Position,Width))
% Copyright (c) 2012, Thomas C. O'Haver
% To prevent problems from taking the log of zero or negative values,
% make the lowest value of y equal to 1% of the maximum value.
maxy=max(y);
for p=1:length(y)
    if y(p)<(maxy/100)
        y(p)=maxy/100;
    end
end % for p=1:length(y),
logyyy=log(abs(y));
[coef,S,MU]=polyfit(x,logyyy,2);
c1=coef(3);c2=coef(2);c3=coef(1);
% Compute peak position and height or fitted parabola
Position=-((MU(2).*c2/(2*c3))-MU(1));
Height=exp(c1-c3*(c2/(2*c3))^2);
Width=norm(MU(2).*2.35703/(sqrt(2)*sqrt(-1*c3)));