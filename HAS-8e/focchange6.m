function focchange6(handles,focusaxis,up_down,Dv,isPA)
% Custom callback function for HASgui that increments the focus location
%    up or down by Dx, Dy or Dz when pushbuttons are pushed.
%
%   Changes:
%       1/26/11 - Changed name to focchange5, edit19 to edit29, and call to calcfocus5.
%           Added Dv and isPA to argument list rather than read from edit box 29.
%           Disabled if not a phased array.
%       2/19/13 - Changed call to calcfocus6. Changed name to focchange6.
%
%     Copyright D.A. Christensen 2013.
%     Feb. 19, 2013.

if isPA
switch focusaxis
    case 1
         val=str2double(get(handles.edit4,'string'));
        Dx=Dv(1);
        if up_down==1; val=val+Dx;
        else val=val-Dx;
        end
        set(handles.edit4,'string',num2str(val));
    case 2
        val=str2double(get(handles.edit8,'string'));
        Dy=Dv(2);
        if up_down==1; val=val+Dy;
        else val=val-Dy;
        end
        set(handles.edit8,'string',num2str(val));
    case 3
         val=str2double(get(handles.edit9,'string'));
        Dz=Dv(3);
        if up_down==1; val=val+Dz;
        else val=val-Dz;
        end
        set(handles.edit9,'string',num2str(val));
end
evalin('base','calcfocus6')
end

