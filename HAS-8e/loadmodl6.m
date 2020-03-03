% Callback for button that loads and plots Modl files in HASgui5.
%     Base workspace script.
%     Note: x is along direction of increasing column index, y is along increasing row index of model.
%
% Changes:
%   1/21/11 - Modl is now an int8 array that specifies the various media types in the model.
%     Added a line that converts legacy double precision Modl files to int8.
%     Using imagesc instead of pcolor for all plots, since imagesc will handle int8.  Also full model plot
%       with values in center of pixel; this required redefining xaxis and yaxis, eliminating Dx/2 offsets.
%       Dv has been dropped from argument list of setfocus5. WindowButtonDownFcn is not set if not PA.
%   2/1/11 - Have put last portion of original loadmodl.m into a separate file, drawmodl5.m, that draws the
%       model.  drawmodl5.m is now called at the end of this file, and also called when the model increment
%       values Dx, Dy and Dz are changed by loadparam5.m or viewparam5.m without having to reload the model
%       file.
%   4/29/11 - Added ismodlrot, a flag set to 0 to indicate that new modl has not yet been rotated.
%   2/18/13 - Added line to clear any file ModlStandin (for easier bone imaging) that might have been
%       loaded earlier.  Also changed class of Modl to int16 to allow for bone models with many media types.
%       If already int8, as preferred from modgen, leave as int8.
%   4/12/15 - Made the default folder to look for the ERFA file to be 'Modls, ERFA & param' inside main folder.
%       Also changed steps of slice view slider to increment only one slice per click for Mac platform.
%   5/19/15 - Changed call to dispcoordval7 (which added display of ARFI displacements).  Also cleared wdisp.
%       Also left single precision Modl files as single precision to load MR data as 'Modl' to view (but not
%       simulate).
%   5/3/19 - Made odd i,j Modl sizes mandatory.
%
%     Copyright D.A. Christensen 2019.
%     May 3, 2019.

if ~exist('R','var')||~exist('Dx','var')
    errordlg('The ERFA and param files must be read in before the Modl file','ERROR','modal')
    return; end
[filename1, pathname] = uigetfile('currentdirstr/Modls, ERFA & param/*.mat','Open Modl_.mat file of model:');
if filename1==0; filename1=''; return; end
load([pathname filename1]);
if ~exist('Modl','var')
    errordlg('The Modl file must contain a variable named ''Modl''.','ERROR','modal');
return; end;

clear ModlStandin   % clear if loaded for previous many-media model; no effect if no file.   
% Change double class Modl to int16 to save memory; if int8 or int32, leave as is:
if strcmp(class(Modl),'double');  Modl=int16(Modl); end 

if exist('pout','var'); clear pout ptot Q wdisp;  end  % clear previous pressure, etc since new model.   

sm=size(Modl); % sm (in y,x,z order) is used extensively throughout the gui.
clear sliceh
if 2*round(sm(1)/2)==sm(1) || 2*round(sm(2)/2)==sm(2);
    errordlg(['The i and j dimensions of the Modl MUST be odd integers,'...
        ' so pad Modl with MakeModlOdd.m'],'','modal');
return; end;

% The next lines set up the sliders for selecting the slice to view:
set(handles.slider1,'Max',sm(2),'Min',1,'SliderStep',[1/(sm(2)-1),1/(sm(2)-1)])
set(handles.slider2,'Max',sm(1),'Min',1,'SliderStep',[1/(sm(1)-1),1/(sm(1)-1)])
set(handles.slider3,'Max',sm(3),'Min',1,'SliderStep',[1/(sm(3)-1),1/(sm(3)-1)])

set(handles.edit33,'string',num2str([1,1,1]));
set(handles.edit34,'string',num2str(0));set(handles.edit35,'string',num2str(0));
OrigModl=Modl; % save the original unrotated Modl.
ismodlrot=0;
sliceID=1;
drawmodl6  % a separate base workspace program to do the majority of the functions for model drawing.

% Set up mouse action for all subsequent views:
sliceID=1; fileID=1;
set(gcf,'WindowButtonMotionFcn','dispcoordval7'); 
if isPA; set(gcf,'WindowButtonDownFcn','setfocus6(handles,xaxis,yaxis,zaxis)'); end


