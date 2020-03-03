% Rotates the Modl file (a 3D array of integers) when button pushed. Rotation of the grid takes place
%   around the pivot point at angles theta and psi. See the function rotcoordpiv.m for definitions. Sets the
%   distance from xducer to front of model and sets offsets such that geom focus is at given pivot point.
%   Calls the function rotvolpivrecenter, which both rotates and recenters the Modl such that the x,y (not z)
%   location of the pivot point is centered in the rotated model; this avoids possible cutting off the 
%   beam when the pivot point is near a model boundary.
%
% Changes 4/27/11 - Names of angles changed to theta, psi.
%
%   Base workspace script.
% Copyright D.A.Christensen 4/27/11

hmr=msgbox('Model grid is being rotated/recentered.','modal');
pivs=str2num(get(handles.edit33,'string')); % piv INDEX is in x,y,z order.
thetas=str2double(get(handles.edit34,'string')); % in degrees; marked with 's' to denote actual rot angles.
psis=str2double(get(handles.edit35,'string'));

Modl=rotvolpivrecenter(OrigModl,pivs,Dx,Dy,Dz,thetas,psis,1,0);

set(handles.edit18,'string',num2str(R*1000 - Dz*pivs(3))); % show geom focus to be at the pivot.
set(handles.edit15,'string',num2str(0));    % and set offsets to 0 to indicate that x,y now at center of model.
set(handles.edit16,'string',num2str(0));
set(handles.edit4,'string','0'); set(handles.edit8,'string','0');   % reset steering to be at 0,0,0.
set(handles.edit9,'string','0');

close(hmr)
ismodlrot=1;    % flag to tell that modl has now been rotated.
set(handles.listbox1,'value',1);  % draw only model
calcgeom6
clear pout Q wdisp
set(handles.edit6,'ForegroundColor','r'); set(handles.edit5,'ForegroundColor','r');
set(handles.edit7,'ForegroundColor','r');   % change color of plot slices in edit boxes to show model rotated.
drawmodl6

