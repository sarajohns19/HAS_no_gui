% Shows the rotation orientation of a beam that pivots around a given pivot point at angles
%   theta and psi by showing the intended direction using an arrow positioned on an unrotated model
%   in axes3.
% 
%   Base workspace script.
%   Changes:
%     1/21/13 - Changed edges call to edges6; this made edge plots MUCH
%       faster by using vectors in line command rather than matrices. Added lines ('stripe') on top of box to
%       show plane of theta rotation by calling function 'boxstripe'.
%     2/11/13 - Improved cone visibility.
%     2/15/13 - Modified arrow shaft length to tightly fit in 'stripe' plane.
%
%   Copyright D.A. Christensen 2013.
%   Feb. 15, 2013.

% Build an overall box:
set(handles.figure1,'CurrentAxes',handles.axes3); cla
xrot0=[xb1,xb1,xb2,xb2,xb1,xb1,xb2,xb2,xb2,xb2,xb1,xb1,xb1,xb1,xb2,xb2];  
yrot0=[yb2,yb2,yb2,yb2,yb2,yb1,yb1,yb2,yb1,yb1,yb1,yb1,yb1,yb2,yb2,yb1]; 
zrot0=[zb2,zb1,zb1,zb2,zb2,zb2,zb2,zb2,zb2,zb1,zb1,zb2,zb1,zb1,zb1,zb1]; 
hlrot0=line(xrot0,zrot0,yrot0,'Color',[.6 .6 .6]); view(62, 22); axis image; axis off; hold on

% Retrieve theta and psi (for model rotation wrt beam) from edit boxes; mark pivot point on box w/ *:
piv=str2num(get(handles.edit33,'string')); % piv INDEX is in x,y,z order.
if piv(1)<1 || piv(1)>sm(2) || piv(2)<1 || piv(2)>sm(1) || piv(3)<1 || piv(3)>sm(3) 
    % Note that sm is in y,x,z (row, col matrix) order.
    errordlg('Pivot indices must be inside of model'); return; end
theta=str2double(get(handles.edit34,'string')); % in degrees.
psi=str2double(get(handles.edit35,'string'));
pivmm(1)=xaxis(piv(1)); pivmm(2)=yaxis(piv(2)); pivmm(3)=zaxis(piv(3)); % pivot point in mm units for 3D view.
hg10=plot3(pivmm(1),pivmm(3),pivmm(2),'*b','MarkerSize',6); % Note that 3D-view(62,22) box is in x,z,y order.

% The next lines put stripes on top, sides and bottom of the box (a 'stripe' plane) to indicate direction of theta:
[xss , zss] = boxstripe(theta,piv(1),piv(3),xaxis,zaxis);   % start x,z location of stripe
[xse , zse] = boxstripe(theta+180,piv(1),piv(3),xaxis,zaxis);   % end x,z location of stripe
line([xss,xse],[zss,zse],[yaxis(end),yaxis(end)],'Color','b','LineWidth',1)
line([xss,xss],[zss,zss],[yaxis(end),yaxis(1)],'Color','b','LineWidth',1,'LineStyle','--')
line([xse,xse],[zse,zse],[yaxis(end),yaxis(1)],'Color','b','LineWidth',1)
line([xss,xse],[zss,zse],[yaxis(1),yaxis(1)],'Color','b','LineWidth',1)

% Find length of arrow shaft that will fit tightly inside of 'stripe' plane:
dshaft=sqrt((pivmm(1)-xss).^2 + (pivmm(3)-zss).^2);
yspan=dshaft.*tand(psi);
ctop=yaxis(end)-pivmm(2);  cbot=pivmm(2)-yaxis(1);
if (pivmm(2) - yspan) > yaxis(end);     % hits top of box.
    shtop=-ctop/tand(psi);      % tan neg here.
    lshaft=sqrt(shtop.*shtop + ctop.*ctop);
elseif (pivmm(2) - yspan) < yaxis(1);     % hits bottom of box.
    shbot=cbot/tand(psi);
    lshaft=sqrt(shbot.*shbot + cbot.*cbot);
else lshaft=sqrt(yspan.*yspan + dshaft.*dshaft);    % hits side of box.
end

% Put a plane to indicate Modl plane displayed:
xpval=pivmm(1);
patchh3=patch([xpval,xpval,xpval,xpval],[zb1,zb2,zb2,zb1],[yb1,yb1,yb2,yb2],[.4 .4 .8]);
set(patchh3,'FaceAlpha',.2)
if get(handles.checkbox2,'value'); Modlplane=squeeze(OrigModl(:,piv(1),:)); 
    [xxl,yyl]=edges6(Modlplane,zaxis,yaxis);
    slicelocmat=xpval*ones(1,length(xxl));
    sliceh3=line(slicelocmat,xxl,yyl,'LineWidth',0.1,'Color','w');
end

% Put an arrow to indicate direction of beam at pivot point:
[Zc,Xc,Yc]=cylinder(0.5:-0.5:0,15);  % build a 1-layer cone pointed in the Y-direction in MATLAB 3D-view(62,22).
    %(In the MATLAB 3D view(62,22) orientation, Y points in the HAS z-direction and Z in the HAS y-direction).
scyl=(zaxis(end)/8);    % scale it to the length of the axis,
Xc=Xc*scyl; Yc=(Yc-1)*scyl; Zc=Zc*scyl; % and move the tip to 0,0,0.
Xc=Xc+pivmm(1); Yc=Yc+pivmm(3); Zc=Zc+pivmm(2);  % shift it to the pivot point in 3D-view(62,22) box.
Xcv=reshape(Xc,[1,numel(Xc)]); Ycv=reshape(Yc,[1,numel(Yc)]); Zcv=reshape(Zc,[1,numel(Zc)]);
Ccoord=[Xcv;Ycv;Zcv]; % make a 3xn matrix.
piv3Dmm=[pivmm(1),pivmm(3),pivmm(2)];   % this pivot point now in X,Y,Z and x,z,y order for 3D-view(62,22) box.
axs=[0 0 1];
Ccoord=rotcoordpiv(Ccoord,piv3Dmm,axs,theta); % rotate first around y-axis (Z-axis in 3D-view(62,22) box).
axs=[cosd(theta),sind(theta),0];
Ccoord=rotcoordpiv(Ccoord,piv3Dmm,axs,psi);   % then rotate around rotated x"-axis.
Xc=reshape(Ccoord(1,:),size(Xc)); Yc=reshape(Ccoord(2,:),size(Yc)); Zc=reshape(Ccoord(3,:),size(Zc));
hcyl=surf(Xc,Yc,Zc);    % draw a cone
if ismodlrot; ccolor='red'; set(handles.pushbutton27,'ForegroundColor','r');
else ccolor='blue'; set(handles.pushbutton27,'ForegroundColor','k');
end
set(hcyl,'FaceColor','white','EdgeColor',ccolor);

% Make and rotate shaft of length lshaft.
%shaftcoord=[pivmm(1),pivmm(1); pivmm(3)-zaxis(end),pivmm(3); pivmm(2),pivmm(2)];  % fixed length
shaftcoord=[pivmm(1),pivmm(1); pivmm(3)-lshaft,pivmm(3); pivmm(2),pivmm(2)];  
axs=[0 0 1];
shaftcoord=rotcoordpiv(shaftcoord,piv3Dmm,axs,theta);
axs=[cosd(theta),sind(theta),0];
shaftcoord=rotcoordpiv(shaftcoord,piv3Dmm,axs,psi);
hg11=line(shaftcoord(1,:),shaftcoord(2,:),shaftcoord(3,:),'Color',ccolor,'LineWidth',1.5);
  
set(handles.figure1,'CurrentAxes',handles.axes1) % restore current axes to main axes1.

