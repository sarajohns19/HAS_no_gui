% Program that plots Modl files in HASgui6.
%     Base workspace script.
%     Note: x is along direction of increasing column index, y is along increasing row index of model.
%
%   This program was originally part of loadmodl.m, but was put into a separate file so it could be
%       called by loadparam6.m or viewparam6.m when the model increments were changed by either of
%       those programs without needing to reload the model. Also called by rotatemodl.m to draw rotated modl.
%
%   Changes:
%       2/3/11 - Changed edgesmall to edges5 to put lines at correct edges of pixels.
%       6/2/11 - Added section that shows the intended rotation direction in a separate box in axes3 using
%           the showrotbeam m-file script.
%       12/29/12 - Changed initial pivot point indices to be center of model rather than geometric focus 
%           (in case geom focus falls outside of model).
%       2/21/13 - Changed edges5 to edges6 to speed up drawing of edge lines.
%       5/31/13 - Added warning dialog boxes if the Modl sample increment is smaller than or not an integer
%           multiplier of the ERFA plane increment.  Removed these lines from CalcHAS_ERFA7.
%
%   Copyright D.A. Christensen 2013.
%   May 31, 2013.

if Dyerfa>Dy || Dxerfa>Dx
     warndlg(['The ERFA plane sample increment is more than that of the Modl. Should use a higher '...
         'resolution ERFA file or lower resolution Modl to assure good General ERFA interpolation.'],'','modal');
     uiwait; 
elseif  (floor(Dy/Dyerfa)~=(Dy/Dyerfa)  | floor(Dx/Dxerfa)~=(Dx/Dxerfa)) & Dy~=Dyerfa & Dx~=Dxerfa  
    warndlg(['The Modl sample increment is not equal to an integer multiplier of the ERFA plane increment; '...
         'therefore the General ERFA interpolation will not be as accurate. '...
         'Consider changing the Modl sample increment.'],'','modal'); uiwait; 
end

Lx=(sm(2)-1)*Dx; Ly=(sm(1)-1)*Dy; Lz=sm(3)*Dz; LenModl=[Lx,Ly,Lz]; % in mm. Note: Lz is overall length.
lx=Lx/1000; ly=Ly/1000; % convert to m units.
set(handles.edit3,'string',filename1)
set(handles.edit30,'string',[num2str(sm(2)),' x ',num2str(sm(1)),' x ',num2str(sm(3))])
set(handles.edit31,'string',[num2str(Lx),' x ',num2str(Ly),' x ',num2str(Lz)])

%xaxis=Dx*(-sm(2)/2:(sm(2)/2)-1);    % axes offset 1/2 pixel for pcolor display, but pcolor no longer used.
%yaxis=Dy*(-sm(1)/2:(sm(1)/2)-1);    
xaxisinterp=Dx*(-(sm(2)-1)/2:(sm(2)-1)/2); % axes (between centers of end points) for imagesc and interp.
yaxisinterp=Dy*(-(sm(1)-1)/2:(sm(1)-1)/2);     % Dx, Dy and Dz all in mm.
zaxis=Dz*(1:sm(3)); % longitudinal axis has full Dz at the center of the first voxel, since HAS calculates
   % travel through a full distance Dz for each voxel and attributes the resulting pressure to that voxel.
xaxis=xaxisinterp; yaxis=yaxisinterp;   % to allow use of legacy xaxis and y axis labels.

xtick=(max(xaxis)-min(xaxis))/100; ytick=(max(yaxis)-min(yaxis))/100;
ztick=(max(zaxis)-min(zaxis))/100;   % store short line lengths for marking focus & geom.
tickmax=max([xtick,ytick,ztick]);
xtick=tickmax; ytick=tickmax; ztick=tickmax;    % make tick match the largest length.
lastfocusx=[]; lastfocusy=[]; lastfocusz=[];    % start with no last focus.

depth=Rmm-dmm;  % distance from front of model to geom foc, in mm.
geom=[offsetxmm offsetymm depth];
set(handles.edit11,'string',num2str(geom));
xsteer=str2double(get(handles.edit4,'string'));
ysteer=str2double(get(handles.edit8,'string'));
zsteer=str2double(get(handles.edit9,'string'));
xfocus=geom(1)+xsteer;  % add steering to geom focus to get location of beam focus.
yfocus=geom(2)+ysteer;
zfocus=geom(3)+zsteer;
steer=[xfocus, yfocus, zfocus];
set(handles.edit24,'string',num2str(steer));
geomslicex=round((geom(1)/Dx)+0.5+(sm(2)/2));
geomslicey=round((geom(2)/Dy)+0.5+(sm(1)/2));
geomslicez=round((geom(3)/Dz));

% The next lines determine the initial slice indices for the view:
if geomslicex<1 || geomslicex>sm(2); startslicex=round(sm(2)/2);
else startslicex=geomslicex; end  % making sure slice is inside model.
if geomslicey<1 || geomslicey>sm(1); startslicey=round(sm(1)/2);
else startslicey=geomslicey; end
if geomslicez<1 || geomslicez>sm(3); startslicez=round(sm(3)/2);
else startslicez=geomslicez; end
set(handles.edit6,'string',num2str(startslicex))
set(handles.slider1,'Value',startslicex)
set(handles.edit20,'string',num2str(xaxis(startslicex),'%4.1f'))
set(handles.edit5,'string',num2str(startslicey))
set(handles.slider2,'Value',startslicey)
set(handles.edit21,'string',num2str(yaxis(startslicey),'%4.1f'))
set(handles.edit7,'string',num2str(startslicez))
set(handles.slider3,'Value',startslicez)
set(handles.edit22,'string',num2str(zaxis(startslicez),'%4.1f'))
% Put center of model as pivot point to start; starting indices are 1,1,1,
if sum(str2num(get(handles.edit33,'string')))==3; % so this happens only for new model.
set(handles.edit33,'string',num2str([startslicex,startslicey,startslicez])); % x,y,z order in gui.
end

% Force renderer to be hardware opengl
set(handles.figure1,'renderer','opengl')
opengl hardware

% Now show an X-slice view of the model at the geom focus plane:
set(handles.radiobutton1,'value',1)
set(handles.listbox1,'value',1)
sliceID=1;
sliceindex=geomslicex;
set(handles.figure1,'CurrentAxes', handles.axes1)
image(zaxis,yaxis,single(squeeze(Modl(:,sliceindex,:)))); axis xy; axis image;
xlabel('Z (mm)'); ylabel('Y (mm)');
if exist('customcmap','var'); colormap(customcmap); else colormap('default'); end
cmapchanged=0; % flag telling whether colormapeditor has changed the colormap for the Modl.
% if exist('modeldescr'); set(handles.edit12,'string',modeldescr); end
if exist('mediadescr','var'); set(handles.edit12,'string',mediadescr); end
if ismodlrot; 
    text(0,Dy*sm(1)*0.53,...
        'Model is rotated/recentered--MUST rotate back before saving pressure.','Color','k');
end
% Now build a box model of Modl to show various focal planes:
xb1=xaxis(1); xb2=xaxis(end);
yb1=yaxis(1); yb2=yaxis(end);
zb1=zaxis(1); zb2=zaxis(end);
xb=[xb1,xb1,xb1;xb2,xb1,xb1;xb2,xb1,xb2;xb1,xb1,xb2];
yb=[yb1,yb1,yb1;yb1,yb1,yb2;yb1,yb2,yb2;yb1,yb2,yb1];
zb=[zb1,zb1,zb2;zb1,zb2,zb2;zb2,zb2,zb2;zb2,zb1,zb2];
xll=[xb1,xb2,xb2;xb2,xb2,xb2];
yll=[yb2,yb2,yb2;yb2,yb2,yb1];
zll=[zb1,zb1,zb1;zb1,zb2,zb1];

set(handles.figure1,'CurrentAxes',handles.axes2); cla % change current axes to axes2.
hbox=patch(xb,zb,yb,[.85 .85 .85]); view(62, 22); axis image; set(gca,'FontSize',8); hold on
xlabel('X (mm)','FontSize',8); ylabel('Z (mm)','FontSize',8); 
zlabel('Y (mm)','FontSize',8);  % note Matlab orientation of box figure.
line(xll,zll,yll,'Color',[.5 .5 .5]);

 % Put a plane to indicate plane displayed.
xpval=xaxis(startslicex);
patchh=patch([xpval,xpval,xpval,xpval],[zb1,zb2,zb2,zb1],[yb1,yb1,yb2,yb2],[.4 .4 .8]);
set(patchh,'FaceAlpha',.2)
if get(handles.checkbox2,'value'); Modlplane=squeeze(Modl(:,startslicex,:)); 
    [xxl,yyl]=edges6(Modlplane,zaxis,yaxis);
    slicelocmat=xpval*ones(1,length(xxl));
    sliceh=line(slicelocmat,xxl,yyl,'LineWidth',0.1,'Color','w');end

 % Mark geom focus with asterisk on model box.
hg4=plot3(geom(1),Dz,geom(2),'*r','MarkerSize',6); 
hg5=line([geom(1),geom(1)],[geom(3)-6*ztick,geom(3)+6*ztick],[geom(2),geom(2)],...
    'Color','r','LineWidth',3);
hg6=line([geom(1),geom(1)],[zaxis(1),zaxis(end)],[geom(2),geom(2)],...
    'Color','r','LineWidth',1,'LineStyle',':');

% Next mark steered focus with asterisk on model box.
if isPA % transducer is a phased array, so can be steered.
hs4=plot3(steer(1),Dz,steer(2),'*y','MarkerSize',6); 
hs5=line([steer(1),steer(1)],[steer(3)-6*ztick,steer(3)+6*ztick],[steer(2),steer(2)],...
    'Color','y','LineWidth',3);
hs6=line([steer(1),steer(1)],[zaxis(1),zaxis(end)],[steer(2),steer(2)],...
    'Color','y','LineWidth',1,'LineStyle',':');
else hs4=[]; hs5=[]; hs6=[];    % transducer is solid, so no steering.
end

% Put rectangle to show extent of ERFA plane
xel=[xaxiserfa(1),xaxiserfa(1),xaxiserfa(end),xaxiserfa(end),xaxiserfa(1)];
yel=[yaxiserfa(1),yaxiserfa(end),yaxiserfa(end),yaxiserfa(1),yaxiserfa(1)];
zel=[Dz, Dz, Dz, Dz, Dz]; % account for Dz being z value at front plane location.
he4=line(xel+offsetxmm,zel,yel+offsetymm,'LineWidth',1.5,'Color','green','Clipping','off');

% Now show the pivot point (new geom focus) and direction of the beam in axes3:
showrotbeam
set(handles.figure1,'CurrentAxes',handles.axes1) % restore current axes to main axes1.

if get(handles.checkbox1,'value'); grid on; else grid off; end
set(handles.listbox1,'value',1);  % draw only model
markgeom6(handles,sliceID,sliceindex,Dv,sm)
markfocus6(handles,sliceID,sliceindex,Dv,sm,xfocus,yfocus,zfocus,isPA)
hfig=gcf;
