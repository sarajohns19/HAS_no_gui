% Calculates the STEERED focus location in HASgui.
%     Base workspace script.
%
%   This version moves the lines (hs1, hs2, hs3, hs4, hs5, hs6) on the box model.
%   Changes:
%       1/26/11 - Changed name to calcfocus5 and call to displa5.
%       If not phased array, lines are not moved since the lines don't
%       exist, and steering values always left at zero in edit boxes.
%       2/19/13 - Changed name to calcfocus6 and call to displa6.
%       5/19/15 - Changed call to displa7.
%
%     Copyright D.A. Christensen 2013.
%     Feb. 19, 2013

	
xsteer=str2double(get(handles.edit4,'string'));  % steering in mm.
ysteer=str2double(get(handles.edit8,'string'));
zsteer=str2double(get(handles.edit9,'string'));
geom=str2num(get(handles.edit11,'string'));
xfocus=geom(1)+xsteer;  % add steering to geom focus.
yfocus=geom(2)+ysteer;
zfocus=geom(3)+zsteer;
steer=[xfocus, yfocus, zfocus];
set(handles.edit24,'string',num2str(steer));
% move lines:
set(hs4,'XData',steer(1),'YData',Dz,'ZData',steer(2));% note orientation.
set(hs5,'XData',[steer(1),steer(1)],'YData',[steer(3)-6*ztick,steer(3)+6*ztick],...
    'ZData',[steer(2),steer(2)]);
set(hs6,'XData',[steer(1),steer(1)],'YData',[zaxis(1),zaxis(end)],'ZData',[steer(2),steer(2)]);

if exist('sliceindex','var'); displa7; end
	