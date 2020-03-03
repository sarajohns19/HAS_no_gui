function setfocus6(handles,xaxis,yaxis,zaxis)
% Custom callback function for setting focus steering point in HASgui.
% 
% When the mouse button is pushed, the focal point is set to the coordinates
%   of the mouse cursor.
%
%   Changes:
%       1/26/11 - Since xaxis and yaxis are redefined to be pt-pt, this eliminated
%           the Dx/2, Dy/2 and Dz/2 offsets, and Dv dropped from argument list.
%       2/19/13 - Changed call to calcfocus6. Changed name to setfocus6.
%
%     Copyright D.A. Christensen 2013.
%     Feb. 19, 2013.

 clicktype=get(gcf,'SelectionType');
 if strcmp(clicktype,'alt') % right click only to avoid unintentional focus change.

    posl=get(gca,'CurrentPoint');
	pos=posl(1,1:2);

    xl=get(gca,'xlim');yl=get(gca,'ylim');
    if pos(1)>xl(2) || pos(1)<xl(1) || pos(2)>yl(2) || pos(2)<yl(1); return; end
    
    geom=str2num(get(handles.edit11,'string'));
    
    if get(handles.radiobutton1,'value'); 	% in an X-slice.
        sliceindex=str2double(get(handles.edit6,'string'));
        sliceval=xaxis(sliceindex);
        set(handles.edit4,'string',num2str(sliceval-geom(1),'%4.1f'));
        set(handles.edit8,'string',num2str(pos(2)-geom(2),'%4.1f'));
        set(handles.edit9,'string',num2str(pos(1)-geom(3),'%4.1f'));
    elseif get(handles.radiobutton2,'value'); 	% in a Y-slice
        sliceindex=str2double(get(handles.edit5,'string'));
        sliceval=yaxis(sliceindex);
        set(handles.edit4,'string',num2str(pos(2)-geom(1),'%4.1f'));
        set(handles.edit8,'string',num2str(sliceval-geom(2),'%4.1f'));
        set(handles.edit9,'string',num2str(pos(1)-geom(3),'%4.1f'));
    elseif get(handles.radiobutton3,'value'); 	% in a Z-slice
        sliceindex=str2double(get(handles.edit7,'string'));
        sliceval=zaxis(sliceindex);
        set(handles.edit4,'string',num2str(pos(1)-geom(1),'%4.1f'));
        set(handles.edit8,'string',num2str(pos(2)-geom(2),'%4.1f'));
        set(handles.edit9,'string',num2str(sliceval-geom(3),'%4.1f'));
    end

    evalin('base','calcfocus6')
 end
