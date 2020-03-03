% This function rotates a 3-D segmented volume, such as Modl, so the face of the volume
%   is parallel to the face of the transducer and the beam can be propagated using the
%   hybrid angular spectrum technique. The new volume has values that are picked by nearest
%   neighbor interpolation, except for points that fall outside the range of the old volume
%   (which will be set to outofrangeval). This function can also rotate back to the original
%   orientation a volume of field values, such as pressure or Q (but it doesn't linearly interpolate). 
%   Called by rotatemodl.m and rotateback.m; calls in turn rotcoordpiv.m
%
% function [new_vol] = rotvolpivrecenter(old_vol,pivind,dx,dy,dz,theta,psi,outofrangeval,isrotback)
%    old_vol    = a 3-D matrix of values on the original grid that is to be rotated.
%    new_vol    = a 3-D matrix of values on a grid that has been rotated.
%    pivind      = a 3x1 vector representing the INDEX point about which the rotation
%                 will be performed; order: [colpiv, rowpiv, pagepiv] or (x,y,z).
%    dx, dy, dz = physical spacing between the x, y, and z values respectively (usu. in m or mm units). 
%                 These are needed to keep the correct aspect ratio of the volume.
%    theta      = rotation about the y axis of the old_volume (in radians).
%    psi        = rotation about an intermediary x-axis (in radians).
%    outofrangeval	 = either 1(representing water) for Modl, or 0 for a field array.
%    isrotback  = flag that tells whether modl is being rotated back (1).


% Last updated by:
%   Doug Christensen 4/27/11 - Changed Scott Almquist's order of rotation to match coordinate system
%       of Modl: y (vertical) is in direction of increasing ROW index, x (horiz) is
%       in direction of increasing COLUMN index.  Thus theta now rotates first
%       around the y or row axis, and psi next rotates around the rotated x or column axis,
%       leaving the rotated x-axis in the x-z plane. Changed order and names of theta & psi in input
%       argument list. Also the pivot point vector is in the order [colpiv, rowpiv, pagepiv].
%   This function can be used to rotate forward a 3D array of media integers, as in a Modl, as well
%       as to rotate back to the original orientation an array of double precision field values
%       such as pressure or Q (in which case the flag isrotback is set to 1.)
%   Added outofrangeval (usually either 1 (=water) if volume being rotated is integer Modl, or 0
%       if volume is a field of pressure or Q values) to the input argument list. 
%       Changed the nested for loops (very slow for a 301x301x360 Modl) to array multiplications.
%   
%   Added shifts in xaxis and yaxis to place pivot point (which is also forced to be the geometric
%       focus) to be at x,y CENTER of new volume (this is done to allow beam
%       from transducer to be more centered on model and avoid clipping by edges of model). In turn,
%       this required that the geometric focus in gui be moved by the same amount; this was
%       accomplished by changes to rotatemodl.m and rotateback.m.
%       isrotback flag added to arguments to tell that volume is being rotated back, not forward.
%
%   4/15/17 - This function may NOT be needed for rotating BACK any volume if the Modl is not rotated
%       back, but rather replaced by OrigModl (see rotateback.m), and both Q and wdisp are rotated with
%       interpolation by rotvolpivrecenterinterp.m for improved resolution, not this function.
%
% Copyright D.A.Christensen 4/15/17

function [new_vol] = rotvolpivrecenter(old_vol,pivind,dx,dy,dz,theta,psi,outofrangeval,isrotback)

% Store outofrangeval in one voxel of old_vol:
old_vol(1,1,1)=outofrangeval;
sy=size(old_vol,1); sx=size(old_vol,2); sz=size(old_vol,3); % note y,x,z order of volumes, like Modl.

xaxis=dx*(-(sx-1)/2:(sx-1)/2); % regenerate the axes (identical to when Modl was read in)
yaxis=dy*(-(sy-1)/2:(sy-1)/2); %    so the rotation takes into account the aspect ratio of the Modl.
zaxis=dz*(1:sz);
pivmm(1)=xaxis(pivind(1)); pivmm(2)=yaxis(pivind(2)); pivmm(3)=zaxis(pivind(3)); % pivot point in mm units.

if ~isrotback   % forward rotation; shift the axes such that the rotated Modl will be x,y centered.
    xaxis=xaxis + dx*(pivind(1)-round((sx+1)/2));
    yaxis=yaxis + dy*(pivind(2)-round((sy+1)/2));
    pivot=pivmm;
else    % rotating back, so shift the pivot point back to original location.
    xaxis=xaxis - dx*(pivind(1)-round((sx+1)/2));
    yaxis=yaxis - dy*(pivind(2)-round((sy+1)/2));
    pivot=[0 0 pivmm(3)];   % pivot back around (0,0,z) since the Modl was centered when rotated.
end

[xarr,yarr,zarr]=meshgrid(xaxis,yaxis,zaxis);
Xv=reshape(xarr,[1,numel(xarr)]); Yv=reshape(yarr,[1,numel(yarr)]); Zv=reshape(zarr,[1,numel(zarr)]);
Mcoord=[Xv;Yv;Zv]; % make a 3xn matrix of coordinates.

if ~isrotback % forward rotation.
    axs=[0 1 0];
    Mcoord=rotcoordpiv(Mcoord,pivot,axs,-theta); % rotate first around y-axis at pivot;
        % use negative angles since rotcoordpivrecenter is written for RH coord system, while HAS is LH system.
    axs=[cosd(theta),0,sind(theta)];    % this axis was found to work empirically (?).
    %axs=[1 0 0];
    Mcoord=rotcoordpiv(Mcoord,pivot,axs,-psi);   % then rotate around rotated x"-axis, same pivot.
else % rotate back; follow rotation steps in reverse order.
    axs=[1 0 0];    % psi now rotates around x-axis in rotated coordinate system. 
    Mcoord=rotcoordpiv(Mcoord,pivot,axs,psi); % rotate back around rotated x-axis.
    axs=[0,cosd(psi),sind(psi)];    % this axis was found to work empirically (?).
    %axs=[0 1 0];
    Mcoord=rotcoordpiv(Mcoord,pivot,axs,theta);   % then rotate by theta around tilted axis.
end

Xvind = round(Mcoord(1,:)/dx + (sx+1)/2);    % now convert to indices.
xoutind = [find(Xvind<1), find(Xvind>sx)];
Xvind(xoutind)=1;

Yvind = round(Mcoord(2,:)/dy + (sy+1)/2);   % now convert to indices.
youtind = [find(Yvind<1), find(Yvind>sy)];
Yvind(youtind)=1;

Zvind = round(Mcoord(3,:)/dz) ;     % now convert to indices.
zoutind = [find(Zvind<1), find(Zvind>sz)];
Zvind(zoutind)=1;

rotind=sub2ind([sy,sx,sz],Yvind,Xvind,Zvind);   % note y,x,z order of Modl.
rotind(youtind)=1; rotind(xoutind)=1; rotind(zoutind)=1; % index to outofrangeval voxel.
newvolvect= old_vol(rotind); % now read out corresponding values in old_vol.
new_vol=reshape(newvolvect,[sy,sx,sz]);     % reshape into original array shape.
