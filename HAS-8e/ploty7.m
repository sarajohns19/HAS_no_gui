% Callback for radiobutton that plots y-slice display in HASgui.
%     Base workspace script.
%
%   When radiobutton pushed, whatever file is specified in listbox1 is displayed
%   in a 2-D y-slice at y location in editbox5.
%   This version moves the patch on the box model.
%   Changes:
%     1/26/11 - imagesc is now used for plotting instead of pcolor. Since xaxis
%        and yaxis are redefined to be pt-pt, this eliminated the Dx/2, Dy/2 and
%        Dz/2 offsets. Also changed call to edges5 to put lines at correct edge of pixels.
%     6/2/11 - added text message telling user to rotate back model before saving rotated 
%       pressure and Q patterns.
%     10/23/11 - normalize to maxpoutnorm and maxQnorm, with normmult set by slider 4 (later dropped).
%     1/21/13 - changed edges call to edges6; this made edge plots MUCH
%           faster by using vectors in line command rather than matrices.
%     2/19/13 - added the capability of loading a model file (ModlStandin) via the command window that has some of
%       the media types of a many-media model compressed into a single media type only for purpose of displaying
%       the model and finding the edges.  Since there are fewer media types, the colormap is not as crowded and
%       there are fewer edges to display, making the display clearer. This is used mainly for bone, where CT
%       Hounsfield values may make the Modl have hundreds of different media (density) types.
%   4/23/13 - Dropped adjustable maxpoutnorm and maxQnorm capability in HASgui. Now done with colormapeditor.
%   5/19/15 - Added plot of ARFI displacements (wdisp) as case 4.  Also changed call to dispcoordval7.
%   5/3/16 - Added redundant maxpout calculation here to be convenient when pout changed to different variable.
%
%     Copyright D.A. Christensen 2016.
%     May 3, 2016.

if ~exist('Modl','var'); errordlg('The Modl.mat file must be read in before plotting.','ERROR','modal');
             return; end
set(gcf,'CurrentAxes', handles.axes1)
currentaxis=axis;
fileID=get(handles.listbox1,'value');
sliceindex=round(str2double(get(handles.edit5,'string')));
if sliceindex<1
     sliceindex=1; set(handles.edit5,'string',num2str(sliceindex));
     errordlg('The index must be within the model bounds','ERROR','modal');
     return;
elseif sliceindex>sm(1); 
     sliceindex=sm(1); set(handles.edit5,'string',num2str(sliceindex));
     errordlg('The index must be within the model bounds','ERROR','modal');
     return; end
set(handles.radiobutton2,'value',1)
set(handles.edit21,'string',num2str(yaxis(sliceindex),'%4.1f'))

if exist('ModlStandin','var'); Modlplane=squeeze(ModlStandin(sliceindex,:,:));
else Modlplane=squeeze(Modl(sliceindex,:,:));% ModlStandin is a simplified model file with compressed media types.
end
if get(handles.checkbox2,'value'); [xxl,yyl]=edges6(Modlplane,zaxis,xaxis); end

switch fileID
    case 1
         image(zaxis,xaxis,single(Modlplane)); axis ij; axis image % note ij dir.
         xlabel('Z (mm)'); ylabel('X (mm)');
          if get(handles.checkbox3,'value'); if freezesliceID==2; axis(currentaxis);
             else set(handles.checkbox3,'value',0); end; end
         if exist('customcmap','var'); colormap(customcmap); else colormap('default'); end
         if get(handles.checkbox1,'value'); grid on; else grid off; end
     case 2
         if ~exist('pout','var')
             errordlg('The pressure must be calculated before plotting.','ERROR','modal');
             return;
         else
              imagesc(zaxis,xaxis,squeeze(abs(pout(sliceindex,:,:)))); axis ij; axis image
              if get(handles.checkbox4,'value'); maxpout=max(abs(pout(:))); caxis([0 maxpout]); end
               colormap('default')
              xlabel('Z (mm)'); ylabel('X (mm)');
               if get(handles.checkbox3,'value'); if freezesliceID==2; axis(currentaxis);
                 else set(handles.checkbox3,'value',0); end; end
              if get(handles.checkbox1,'value'); grid on; else grid off; end
              if get(handles.checkbox2,'value'); line(xxl,yyl,'LineWidth',1,'Color','w'); end
         end
     case 3
         if ~exist('Q','var')
             errordlg('The power density must be calculated before plotting.','ERROR','modal');
             return;
         else
             imagesc(zaxis,xaxis,squeeze(Q(sliceindex,:,:))); axis ij; axis image
             if get(handles.checkbox4,'value'); caxis([0 maxQ]); end
              colormap('default')
             xlabel('Z (mm)'); ylabel('X (mm)');
              if get(handles.checkbox3,'value'); if freezesliceID==2; axis(currentaxis);
                 else set(handles.checkbox3,'value',0); end; end
             if get(handles.checkbox1,'value'); grid on; else grid off; end
             if get(handles.checkbox2,'value'); line(xxl,yyl,'LineWidth',1,'Color','w'); end
         end
     case 4
         if ~exist('wdisp','var')
             errordlg('The ARFI displacement must be calculated before plotting.','ERROR','modal');
             set(handles.listbox1,'value',1);
             return;
         else
             imagesc(zaxis,xaxis,squeeze(wdisp(sliceindex,:,:))); axis ij; axis image
             if get(handles.checkbox4,'value'); caxis([0 maxwdisp]); end
              colormap('default')
             xlabel('Z (mm)'); ylabel('X (mm)');
              if get(handles.checkbox3,'value'); if freezesliceID==2; axis(currentaxis);
                 else set(handles.checkbox3,'value',0); end; end
             if get(handles.checkbox1,'value'); grid on; else grid off; end
             if get(handles.checkbox2,'value'); line(xxl,yyl,'LineWidth',1,'Color','w'); end
         end
     case 5
        errordlg('No shear waves implemented yet'); return
end
if ismodlrot; 
    text(0,-Dx*sm(2)*0.53,...
        'Model is rotated/recentered--MUST rotate back before saving pressure.','Color','k');
end
sliceID=2;
markgeom6(handles,sliceID,sliceindex,Dv,sm)
markfocus6(handles,sliceID,sliceindex,Dv,sm,xfocus,yfocus,zfocus,isPA)
set(gcf,'WindowButtonMotionFcn','dispcoordval7');

% Move modl plane.
ypval=yaxis(sliceindex);
set(patchh,'XData',[xb1,xb1,xb2,xb2],'YData',[zb1,zb2,zb2,zb1],...  
    'ZData',[ypval,ypval,ypval,ypval]);
set(handles.figure1,'CurrentAxes',handles.axes2); 

if exist('sliceh','var'); delete(sliceh); clear sliceh; end
% Show modl edges on plane.
if get(handles.checkbox2,'value'); slicelocmat=ypval*ones(2,length(xxl));
        sliceh=line(yyl,xxl,slicelocmat,'LineWidth',0.1,'Color','w'); end
set(handles.figure1,'CurrentAxes',handles.axes1); 
