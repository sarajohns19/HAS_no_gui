function distchange6(handles,up_down,Dv,isPA)
% Custom callback function for HASgui that increments the distance
%   from transducer to model up or down by Dz when pushbuttons are pushed.
%
%   Changes:
%       1/26/11 - Changed name to distchange5, edit19 to edit29, and call to calcgeom5.
%           Added Dv and isPA to argument list rather than reading from edit box 29.
%       2/29/11 - Removed the lines that kept the focus at the same location.
%       2/19/13 - Changed call to calcgeom6. Changed name to distchange6.
%
%     Copyright D.A. Christensen 2013.
%     Feb. 19, 2013.


Dz=Dv(3);
val=str2double(get(handles.edit18,'string'));
zsteer=str2double(get(handles.edit9,'string'));
    if up_down==1; val=val+Dz; % zsteer=zsteer+Dz;
    else val=val-Dz; % zsteer=zsteer-Dz; % DON'T keep steering in same location.
    end
set(handles.edit18,'string',num2str(val));
if isPA; set(handles.edit9,'string',num2str(zsteer)); end
evalin('base','calcgeom6')
