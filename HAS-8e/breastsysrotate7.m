function breastsysrotate7(xaxis,yaxis,zaxis,handles)
% This callback function brings up a dialog box to determine the theta and psi rotation angles that the UofU breast
%  system needs to focus the transducer on a certain lesion location. Box inputs: x1ind and x2ind are indices of
%  the centerline of the breast system cylinder (xaxis, yaxis and zaxis are used to put the indices into mm units).
%  The dialog box also asks for the indices at the center of the lesion. The function then calcs theta, psi and
%  the slide amount to focus on the lesion, and enters them in the gui. If system limits are exceeded, a warning is
%  given. Positive values of 'slide' are toward the breast from the transducer s=0 position.
%
%  Base workspace script.
%  Changes:
%  2/14/13 - Added the capability of allowing variable mechanical rotation angles beta around the center of the
%   transducer in the plane set by psi.  So now theta and psi are different angles for the transducer than for the
%   rotation of the beam around the focal point on the lesion.  Therefore thetaSys, psiSys and beta are the
%   angles that the transducer mechanism is set at (along with slide), while thetaPiv and psiPiv are the angles
%   that the beam pivots around the geometrical focal point on the lesion.  (See the hand sketches made to
%   accompany this revision.)  Also, to help someone adjusting the breast system, thetaSys, psiSys, beta and
%   slide are written to a non-modal dialog box outside the HASgui, while thetaPiv and psiPiv are put in the
%   edit boxes appropriate for rotating the beam (i.e., rotating the model).
%   The indices of the cylinder centerline (x1ind and y1ind) and M (the distance in mm from the top of the
%   cylinder down to the top of the model) are now stored in application data of the object pushbutton29,
%   and those inputs and outputs have been dropped from the earlier function.  This is so values can be
%   accessed by the callback showrotbeam.  Title of function changed to breastsysrotate6.
%
%   7/21/14 - Updated for latest breast system where the 20 degree slide has been dropped (now the slide is always
%   in the horizontal plane) and the mechanical distances and limits changed; this made the program much simpler. 
%   Also changed the names of thetaPiv to thetamod, etc. to clearly indicate these are model rotation angles.
%
%   Copyright 2014 D. Christensen
%   July 21, 2014

prompt2={'x1, z1 indices at cylinder centerline',...
    'x2, y2, z2 indices at center of desired geom focus',...
    'Beta: lateral angle of xducer rotation around center (deg)',...
    'M: distance from cylinder top down to model top (mm)'...
    'Go to opposite quadrant of thetaSys? 0=no, 1=yes',''};
piv=str2num(get(handles.edit33,'string'));
if piv(1)<1 || piv(1)>length(xaxis) || piv(2)<1 || piv(2)>length(yaxis) || piv(3)<1 || piv(3)>length(zaxis)
    errordlg('Pivot indices must be inside of model'); return; end
x2ind=piv(1); y2ind=piv(2); z2ind=piv(3);
if isappdata(handles.pushbutton29, 'center1'); center1=getappdata(handles.pushbutton29, 'center1');
else center1=[1 1 0 0 0]; end
x1ind=center1(1); z1ind=center1(2); beta=center1(3); M=center1(4); switchquad=center1(5);
initans2={num2str([x1ind,z1ind]),num2str([x2ind,y2ind,z2ind]),num2str(beta),num2str(M),num2str(switchquad),...
    'PRESS OK TO CALC ROTATION PARAMETERS'};
answer2=inputdlg(prompt2,'Breast System Rotation Input',[1;1;1;1;1;1],initans2,'on');   % dialog box
if isempty(answer2); return; end;
center1=[str2num(answer2{1}),str2num(answer2{3}),str2num(answer2{4}),str2num(answer2{5})];
% center1 to be stored; contains centerline xind & yind, beta(deg), M and switchquad (flag for switching quadrants)
x1ind=center1(1); z1ind=center1(2); beta=center1(3); M=center1(4); switchquad=center1(5);
if x1ind<1 || x1ind>length(xaxis) || z1ind<1 || z1ind>length(zaxis) 
    errordlg('Centerline indices must be inside of model'); return; end
setappdata(handles.pushbutton29,'center1',center1);
center2=str2num(answer2{2}); % center of the desired geom focus
x2ind=center2(1); y2ind=center2(2); z2ind=center2(3);
if x2ind<1 || x2ind>length(xaxis) || y2ind<1 || y2ind>length(yaxis) || z2ind<1 || z2ind>length(zaxis)
    errordlg('Focus indices must be inside of model'); return; end

%--- First calculate values on psi-tilted beta-steering plane (plane II)--
R=106.8;  % distance in mm from geom focus to theta & psi rotation axes (even though xducer radius=100mm).
t=R*sind(beta);
m=R*cosd(beta);

% -- Next on horiz. x-z plane at y2 level (plane I)--
x1=xaxis(x1ind); z1=zaxis(z1ind); % in mm.
x2=xaxis(x2ind); y2=yaxis(y2ind); z2=zaxis(z2ind); % in mm.
dx = x2-x1; dz = -(z2-z1); 
    L = 70.0;   % distance in mm from top of cylinder to slide plane.
    h = y2 - (yaxis(end) - (L-M)); % (from vertical plane IV; needed here to check range of beta.)
a=sqrt(dx.*dx + dz.*dz);
if beta<-16 || beta>16 || t>a || m<h   % beta too large to allow focus at desired point
    errordlg('beta rotation angle must decreased to allow focus at desired point'); return; end
g=sqrt(a.*a - t.*t);
gamma=asind(t./a);   % gamma in degrees.
% If switch quadrants in thetab, focus is now on opposite side of centerline so g and gamma change sign.
if switchquad; dz = -dz; dx = -dx; g = -g; gamma = -gamma; end
thetab=atan2(dx,dz)*180/pi; % thetab in degrees.
thetaSys=thetab-gamma;     % this is the rotation theta in degrees for the system transducer.
% Limits on thetaSys for new system are not yet known, so comment out:
% if (thetaSys<-135) || (thetaSys>135);
% uiwait(warndlg(['thetaSys = ',num2str(thetaSys,3),' deg is outside +/-135 deg system limits.',...
%    ' Change parameters and retry.'],'Outside of Limits','modal'))
% end

% -- Now on vert plane containing rotation point and cyl centerline (plane IV)--
psiSys=asind(h./m);  %psiSys is rotation psi in degrees for the system transducer.
if (psiSys<0) || (psiSys>35);
uiwait(warndlg(['psi_Sys = ',num2str(psiSys,3),' deg is outside 0 to 35 deg system limits. ', ...
    'Change parameters and retry.'],'Outside of Limits','modal'))
end
b=m*cosd(psiSys);
D=127.0;    % mm from cyl. centerline to slide=0 position.
slide=D-b-g;
if (slide<0) || (slide>44.5);
uiwait(warndlg(['xducer slide = ',num2str(slide,3),' mm is outside 0 to 44.5 mm system limits. ',...
    'Change parameters and retry.'], 'Outside of Limits','modal'))
end

% -- Now on vert plane containing rotation point and geom focus point (plane III) --
psimod=asind(h./R); % this is rotation psi in degrees for the model pivot procedure; goes into the gui edit box.

% -- Back to horiz x-z plane (plane I)--
thetac=atan2(b,t) * 180/pi; % thetac in degrees.
thetamod= thetab + thetac - 90 - gamma; % this is rotation theta for the model pivot; goes into gui edit box.

% -- Find coordinates of transducer rotation point --
dxtrans=(b+g).*sind(thetaSys);
dztrans=(b+g).*cosd(thetaSys);
xtrans=x1 + dxtrans;
ztrans=z1 - dztrans;
ytrans=y2 - h;

set(handles.edit34,'string',num2str(thetamod,3)); % put found values in edit boxes in HASgui.
set(handles.edit35,'string',num2str(psimod,3));
set(handles.edit33,'string',num2str([x2ind,y2ind,z2ind]));
strsysset=strvcat(['theta_Sys = ',num2str(thetaSys,3),' deg'],[ 'psi_Sys = ',num2str(psiSys,3),' deg'],...
  ['beta = ',num2str(beta,3),' deg'],['slide = ',num2str(slide,3),' mm.'],' ',...
  ['Indices of cylinder centerline (x,z) =', num2str([x1ind,z1ind])],...
  ['Indices of geom focus (x,y,z) =', num2str([x2ind,y2ind,z2ind])]);

evalin('base','showrotbeam')    % preview the axis of rotated beam 

% -- The following lines plot the centerline of the cylinder and the transducer location in the rotation box --
set(handles.figure1,'CurrentAxes',handles.axes3)
plot3(x1,z1,yaxis(1),'ob','MarkerSize',4); % put markers at ends of cyl centerline of UofU breast system.
plot3(x1,z1,yaxis(end),'ob','MarkerSize',4); 
line([x1,x1],[z1,z1],[yaxis(1),yaxis(end)],'Color','b','LineWidth',1,'LineStyle','-.'); % put vertical line
plot3(xtrans,ztrans,ytrans,'ob','MarkerSize',6,'MarkerFaceColor','b')   % mark transducer location
line([xtrans,x2],[ztrans,z2],[ytrans,y2],'Color','b','LineStyle','-.','Clipping','off')
%line([xtrans,x1],[ztrans,z1],[ytrans,ytrans],'Color','b','LineStyle','-.','Clipping','off')
%plot3(xaxis(x1ind),zaxis(z1ind),ytrans,'ob','MarkerSize',4); 
set(handles.figure1,'CurrentAxes',handles.axes1) % restore current axes to main axes1.

hg15 = msgbox(strsysset,'BREAST SYS SETUP','replace'); % put system setup values in dialog box.
end

