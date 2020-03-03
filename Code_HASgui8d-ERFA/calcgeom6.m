% Calculates the geom focus location in HASgui and shows position in box model.
%     Base workspace script.
% 
%   This version moves the lines (hg1, hg2, hg3, hg4, hg5, hg6) on the box model.
%
%   Changes:
%       1/26/11 - Changed name to calcgeom5. Moves EFRA extent indicator he4 also.
%                 Lines hg1, hg2 and hg3 are no longer being used.
%       2/23/11 - Now also moves geom focus lines hg7, hg8 and hg9 in rotation box in axes3.
%       4/30/11 - Lines hg7, hg8 and hg9 are no longer being used.
%       2/19/13 - Changed call to calcfocus6. Changed name to calcgeom6.
%       4/15/17 - Also update pivot point location when offsets or depth changed, except if the
%               model is rotated (keep same pivot points as when first rotated).
%
%     Copyright D.A. Christensen 2017.
%     April 15, 2017.

offsetxmm=str2double(get(handles.edit15,'string'));  % offsets in mm.
offsetymm=str2double(get(handles.edit16,'string'));
dmm=str2double(get(handles.edit18,'string'));
depth=Rmm-dmm;  % distance from front of model to geom foc, in mm.
geom=[offsetxmm offsetymm depth];
set(handles.edit11,'string',num2str(geom)); % put mm values into geom focus box.
if  ~ismodlrot  % also put indices into pivot location box except if model rotated.
    offsetxind = round(offsetxmm/Dx + (sm(2)+1)/2);    % now convert to indices.
    offsetyind = round(offsetymm/Dy + (sm(1)+1)/2);    % note y,x,z order of sm.
    depthind = round(depth/Dz);
    geomind=[offsetxind offsetyind depthind];
    set(handles.edit33,'string',num2str(geomind)); 
end

% move lines:
set(hg4,'XData',geom(1),'YData',Dz,'ZData',geom(2));% note orientation.
% set(hg1,'XData',[xb1,xb1,xb2],'YData',[geom(3),geom(3),geom(3)],'ZData',[yb1,yb2,yb2]);
% set(hg2,'XData',[geom(1),geom(1)],'YData',[geom(3)-(zb2-zb1)/10,geom(3)+(zb2-zb1)/10],...
%     'ZData',[yb2,yb2]);
% set(hg3,'XData',[xb1,xb1],'YData',[geom(3)-(zb2-zb1)/10,geom(3)+(zb2-zb1)/10],...
%     'ZData',[geom(2),geom(2)]);
set(hg5,'XData',[geom(1),geom(1)],'YData',[geom(3)-6*ztick,geom(3)+6*ztick],...
    'ZData',[geom(2),geom(2)]);
set(hg6,'XData',[geom(1),geom(1)],'YData',[zaxis(1),zaxis(end)],'ZData',[geom(2),geom(2)]);
set(he4,'XData',xel+offsetxmm,'YData',zel,'ZData',yel+offsetymm);
% set(hg7,'XData',geom(1),'YData',Dz,'ZData',geom(2));% note orientation.
% set(hg8,'XData',[geom(1),geom(1)],'YData',[geom(3)-6*ztick,geom(3)+6*ztick],...
%     'ZData',[geom(2),geom(2)]);
% set(hg9,'XData',[geom(1),geom(1)],'YData',[zaxis(1),zaxis(end)],'ZData',[geom(2),geom(2)]);

calcfocus6      % update steered focal location.