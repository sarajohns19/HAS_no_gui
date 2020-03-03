function offsetchange6(handles,offsetaxis,up_down,Dv,isPA)
% Custom callback function for HASgui that increments the offset of
%   the transducer up or down by Dx or Dy when pushbuttons are pushed.
%
%   Changes:
%       1/26/11 - Changed name to offsetchange5 and call to calcgeom5.
%           Added Dv and isPA to argument list rather than reading from edit box 29.
%           Disabled setting the steering values in edit boxes if not PA.
%       2/29/11 - Removed the lines that kept the focus at the same location.
%       2/19/13 - Changed call to calcgeom6. Changed name to offsetchange6.
%
%     Copyright D.A. Christensen 2013.
%     Feb. 19, 2013.

switch offsetaxis
    case 1  % xoffset
        val=str2double(get(handles.edit15,'string'));
        Dx=Dv(1);
        xsteer=str2double(get(handles.edit4,'string'));  % steering in mm.
        if up_down==1; val=val+Dx; % xsteer=xsteer-Dx;   
        else val=val-Dx; % xsteer=xsteer+Dx; % DON'T keep steering in same location.
        end
        set(handles.edit15,'string',num2str(val));
        if isPA; set(handles.edit4,'string',num2str(xsteer)); end
    case 2  % yoffset
        val=str2double(get(handles.edit16,'string'));
        Dy=Dv(2);
        ysteer=str2double(get(handles.edit8,'string'));
        if up_down==1; val=val+Dy; % ysteer=ysteer-Dy;
        else val=val-Dy; % ysteer=ysteer+Dy;
        end
        set(handles.edit16,'string',num2str(val));
        if isPA; set(handles.edit8,'string',num2str(ysteer)); end
end
 evalin('base','calcgeom6')