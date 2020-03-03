function [xs,zs]=boxstripe(theta,xpivind,zpivind,xaxis,zaxis)
% A function to find the starting points xs, zs (in mm) on the top of
%   the rotation box for a stripe that points in the direction of theta (in degrees)
%   and goes through the pivot indices xpivind, zpivind (in index numbers).

th=theta*pi/180;        % into radians
s= -xaxis(1);
xpiv = xaxis(xpivind) + s;      % into mm
zpiv = zaxis(zpivind);     
if sign(cos(th))==1        % cos(th) positive so left quadrants
    c=zpiv*tan(th);
    if c + xpiv > xaxis(end) + s     % line 1
        a=xaxis(end) + s - xpiv; th1=(pi/2) - th;
        d = a*tan(th1); zs = zpiv - d; xs = xaxis(end);
    elseif c + xpiv < 0      % line 2
        th2 = (pi/2) + th; e = xpiv*tan(th2);
        zs = zpiv - e; xs = xaxis(1);
    else xs = xpiv + c - s; zs = zaxis(1);      % line 3
    end
else th3 = pi - th;     % cos(th) negative
    b = zaxis(end) - zpiv; f = b*tan(th3);
    if f + xpiv > xaxis(end) + s       % line 4
        a = xaxis(end) + s - xpiv; th4 = th - (pi/2);
        g = a*tan(th4); zs = zpiv + g; xs = xaxis(end);
    elseif f + xpiv < 0      % line 5
        th5 = -th -(pi/2); h = xpiv*tan(th5);
        zs = zpiv + h; xs = xaxis(1);
    else xs = xpiv + f - s; zs = zaxis(end);        % line 6
    end
end

        
        
    