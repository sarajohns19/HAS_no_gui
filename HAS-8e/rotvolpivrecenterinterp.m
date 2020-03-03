% This function rotates back a complex-valued volume such as pressure to its original orientation,
%   similar to rotvolpivrecenter.m, but using linear interpolation rather than nearest neighbor to be
%   more accurate, including phase interpolation.  It follows many of the same rotate-back commands
%   found in rotvolpivrecenter.m, except substituting the interp3 command.  It also uncenters the field
%   pattern that was centered when the Modl was rotated.
%   
%   Called by  rotateback.m; calls in turn rotcoordpiv.m
%
% function [new_vol] = rotvolpivrecenterinterp(old_vol,pivind,dx,dy,dz,theta,psi,outofrangeval,isrotback)
%    old_vol    = a 3-D matrix of values on the original grid that is to be rotated.
%    new_vol    = a 3-D matrix of values on a grid that has been rotated.
%    pivind      = a 3x1 vector representing the INDEX point about which the rotation
%                 will be performed; order: [colpiv, rowpiv, pagepiv] or (x,y,z).
%    dx, dy, dz = physical spacing between the x, y, and z values respectively (usu. in m or mm units). 
%                 These are needed to keep the correct aspect ratio of the volume.
%    theta      = rotation about the y axis of the old_volume (in radians).
%    psi        = rotation about an intermediary x-axis (in radians).
%    outofrangeval	 =  0 for a field array.
%    isrotback  = flag that tells that modl is being rotated back (1) (NA since ONLY used for rotating back now).


% 	Changes (also see list of changes in rotvolpivrecenter.m):
%   4/15/17 - Corrected the error where the field pattern did not get shifted back but rather stayed at the
%       center of the grid.  This was done by keeping xaxisback separate from xaxis, etc.  Also, the interp3 
%       built-in function sets out-of-range values to NaN automatically, so they are later set to 0 (outofrangeval).
%   4/18/17 - Added a check for whether the old_vol was real (so used for Q or wdisp) or complex (for pout).
%  
% Copyright D.A.Christensen 4/18/17

function [new_vol] = rotvolpivrecenterinterp(old_vol,pivind,dx,dy,dz,theta,psi,outofrangeval,isrotback)
sy=size(old_vol,1); sx=size(old_vol,2); sz=size(old_vol,3); % note y,x,z order of volumes, like Modl.

xaxis=dx*(-(sx-1)/2:(sx-1)/2); % regenerate the axes (identical to when Modl was read in)
yaxis=dy*(-(sy-1)/2:(sy-1)/2); %    so the rotation takes into account the aspect ratio of the Modl.
zaxis=dz*(1:sz);
pivmm(1)=xaxis(pivind(1)); pivmm(2)=yaxis(pivind(2)); pivmm(3)=zaxis(pivind(3)); % pivot point in mm units.

% rotating back, so shift the pivot point back to original location.
xaxisback=xaxis - dx*(pivind(1)-round((sx+1)/2));
yaxisback=yaxis - dy*(pivind(2)-round((sy+1)/2));
pivot=[0 0 pivmm(3)];   % pivot back around (0,0,z) since the Modl was centered when rotated.

[xarr,yarr,zarr]=meshgrid(xaxisback,yaxisback,zaxis);
Xv=reshape(xarr,[1,numel(xarr)]); Yv=reshape(yarr,[1,numel(yarr)]); Zv=reshape(zarr,[1,numel(zarr)]);
Mcoord=[Xv;Yv;Zv];
        
% rotate back; follow rotation steps in reverse order.
axs=[1 0 0];    % psi now rotates around x-axis in rotated coordinate system. 
Mcoord=rotcoordpiv(Mcoord,pivot,axs,psi); % rotate back around rotated x-axis.
axs=[0,cosd(psi),sind(psi)];    % this axis was found to work empirically (?).
%axs=[0 1 0];
Mcoord=rotcoordpiv(Mcoord,pivot,axs,theta);   % then rotate by theta around tilted axis.

if isreal(old_vol)  %  check for whether old_vol is pout (complex) or Q or wdisp (real):
    new_vol = interp3(xaxis, yaxis, zaxis, old_vol, Mcoord(1,:), Mcoord(2,:), Mcoord(3,:), '*linear', 0);
else
    new_pp = interp3(xaxis, yaxis, zaxis, abs(old_vol), Mcoord(1,:), Mcoord(2,:), Mcoord(3,:), '*linear', 0);
    % Normalized Vector Interpolation
    new_phase = interp3(xaxis, yaxis, zaxis, old_vol ./ abs(old_vol), Mcoord(1,:), Mcoord(2,:), Mcoord(3,:));
    new_phase = angle(new_phase);
    % Unnormalized Vector Interpolation
    % new_phase = interp3(xaxis, yaxis, zaxis, old_vol, Mcoord(1,:), Mcoord(2,:), Mcoord(3,:));
    % new_phase = angle(new_phase);
    new_vol = new_pp.*exp(1i.*new_phase);
end
new_vol(isnan(new_vol)) = outofrangeval;

new_vol = reshape(new_vol, [sy,sx,sz]); % reshape into original array shape; note y,x,z ordering.


