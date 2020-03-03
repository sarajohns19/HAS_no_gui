% Rotates back the Modl file to its original orientation (and translates back
%   the pivot point from the x-y center), and the pressure and Q files (if they have been calculated)
%   to match the original grid when button pushed. 
%   See the function rotvolpivrecenter.m for definitions; set flag isrotback = 1 to indicate rotation
%   is back to original orientation.
% 
%   Changes: 
%   4/15/17 - Modl is now NOT rotated back, just replaced with OrigModl, which avoids seeing the 
%       portions of the Modl that are clipped when it is rotated (but rotating back is sometimes a good check on the 
%       accuracy of the rotation algorithms).  Also, the Q pattern is now interpolated when it is rotated
%       back to improve resolution in the pattern. 
%   4/18/17 - If model is rotated, ARFI is only valid when done on this rotated model, so wdisp is now interpolated 
%       when it is rotated back. 
%
%   Base workspace script.
% Copyright D.A.Christensen 4/15/17


Modl=OrigModl;  % to see original (unclipped) Modl back; comment out if want to see rotated-back Modl.
if ismodlrot
hmrb=msgbox('Model grid is being rotated back and uncentered.','modal');
%Modl=rotvolpivrecenter(Modl,pivs,Dx,Dy,Dz,thetas,psis,1,1); % uncomment to see clipped Modl rotated back.
if exist('pout','var') && exist('pivs','var')
    pout=rotvolpivrecenterinterp(pout,pivs,Dx,Dy,Dz,thetas,psis,0,1);
    Q=rotvolpivrecenterinterp(Q,pivs,Dx,Dy,Dz,thetas,psis,0,1);   % now interpolated.
end
if exist('wdisp','var')
    wdisp=rotvolpivrecenterinterp(wdisp,pivs,Dx,Dy,Dz,thetas,psis,0,1);  % interpolated.
end

% Get geom offset change and depth change (if done while model rotated) before rotating back 
%   to rotate the geom mark G back to correct position.
geomv=[offsetxmm; offsetymm; depth-pivmm(3)];
axs=[1 0 0]; % this axis was found to work empirically (?).
geomv=rotcoordpiv(geomv,[0 0 0],axs,-psis);
axs=[0 1 0]; % this axis was found to work empirically (why different than rotvolpivrecenter?).
%axs=[0,cosd(psis),sind(psis)];
geomv=rotcoordpiv(geomv,[0 0 0],axs,-thetas);
% geom focus was at x,y center of model (see rotvolpivrecenter.m), so readjust to represent uncentered model.
set(handles.edit15,'string',num2str(geomv(1) + Dx*(pivs(1) - round((sm(2)+1)/2)))); 
set(handles.edit16,'string',num2str(geomv(2) + Dy*(pivs(2) - round((sm(1)+1)/2))));
set(handles.edit18,'string',num2str(R*1000 - pivmm(3) - geomv(3)));

% Also get steering location before rotating back to rotate the focal mark F back to correct position.
xsteer=str2double(get(handles.edit4,'string')); ysteer=str2double(get(handles.edit8,'string'));
zsteer=str2double(get(handles.edit9,'string'));
steerv=[xsteer;ysteer;zsteer];
axs=[1 0 0]; % this axis was found to work empirically (?).
steerv=rotcoordpiv(steerv,[0 0 0],axs,-psis);
axs=[0 1 0]; % this axis was found to work empirically (why different than rotvolpivrecenter?).
%axs=[0,cosd(psis),sind(psis)];
steerv=rotcoordpiv(steerv,[0 0 0],axs,-thetas);
set(handles.edit4,'string',num2str(steerv(1))); set(handles.edit8,'string',num2str(steerv(2)));
set(handles.edit9,'string',num2str(steerv(3)));

close(hmrb)
end
ismodlrot=0;    % flag to tell that modl has now been rotated back.
calcgeom6
set(handles.edit6,'ForegroundColor','k'); set(handles.edit5,'ForegroundColor','k');
set(handles.edit7,'ForegroundColor','k');   % set color of slice indices edit boxes back to black.

drawmodl6
