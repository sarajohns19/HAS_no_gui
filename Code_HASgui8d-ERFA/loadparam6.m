% Callback for button that loads parameter files in HASgui6.
%     Base workspace script.
% 
% The parameter file contains most of the initial specifications of the HAS calculation.
% Some parameters are determined by ERFA (fMHz, Rmm, Len). Others in the parameter file can be 
%   modified in boxes in the gui (offsets, focus shifts hmm, vmm, zmm), while model increments 
%   and media properties(Dx, Dy, Dz, a, c, rho) can be modified with the 'View/Modify' button in the gui.
%
% Changes:
%   1/20/11 - Added requirement that the model file be drawn again when the parameter 
%     file contains model increments Dx, Dy or Dz that have changed.  Disable or enable the steering
%     angle edit boxes depending on whether PA or not.
%   12/26/12 - SUBSTANTIAL changes: added absorption coefficients, scattering correlation length, 
%     and scattering st dev to input parameters. Made compatible with earlier parameter files.
%     Also, eliminated requiring parameter file to give initial distance xducer to model (dmm), initial offsets
%     (offsetxmm and offsetymm), and initial electronic focus distances (hmm, vmm, zmm). Instead entered zeros 
%     for all except dmm, which is now entered as the orig ERFA plane distance (sx*1000, in mm) in loadERFA6.  
%     All of these parameters can now be changed readily in the gui, and the position of the ERFA pressure 
%     perfa plane adjusted dynamically by propagation and interpolation.
%   2/16/13 - Extended line to clear the acoustic property vectors (c,a,etc) since new files may be shorter.
%   4/12/15 - Made the default folder to look for the ERFA file to be 'Modls, ERFA & param' inside main folder.
%     Also cleared earlier parameters only after it is determined that file is valid (moved clear later).
%
%     Copyright D.A. Christensen 2015.
%     April 12, 2015.

% global a c Pr pout Q maxpout  % used for parameter estimation calculations only.
if ~exist('Rmm','var')
    errordlg('The ERFA file must be read in before the param file','ERROR','modal')
    return; end
if exist('Dv','var'); prevDv=Dv; else prevDv=0; end % will tell whether file is brand new or reread;

[filename2, pathname] = uigetfile('Modls, ERFA & param/*.m',...
    'Open paramHAS5._m file for ERFA/Hybrid Ang Spectrum calc:');
if filename2==0; filename2=''; return; end
if ~strcmp(filename2(1:5),'param')
errordlg('The file must be a parameter file whose name starts with ''param''.','ERROR','modal');
     return; end;
clear c a rho aabs corrl randvc; % clear earlier versions of these; new file may load shorter vectors here.
truncfilename=filename2(1:length(filename2)-2);	% strip .m from name.
current=cd; cd(pathname); eval(truncfilename); cd(current);
set(handles.edit2,'string',filename2)

if ~exist('aabs','var'); aabs=a; end % make compatible with files that have no aabs, etc.; if so, no scattering.
if ~exist('corrl','var'); corrl=10; end % default correlation length.
if ~exist('randvc','var'); randvc=zeros(1,length(a)); end % default scattering std dev = 0, so no scattering.

Dv=[Dx Dy Dz];  %  in mm.

dmm=str2double(get(handles.edit18,'string'));   % set dmm to value in box18 (initially set as sx in loadERFA).
hmm=0; vmm=0; zmm=0; % set initial values of focus shift to 0.
set(handles.edit4,'string',num2str(0)) 
set(handles.edit8,'string',num2str(0))
set(handles.edit9,'string',num2str(0))
offsetxmm=0; offsetymm=0;   % set initial values of offsets to 0.
set(handles.edit15,'string',num2str(0))
set(handles.edit16,'string',num2str(0))

if ~isPA; set(handles.edit4,'Enable','off');
    set(handles.edit8,'Enable','off');
    set(handles.edit9,'Enable','off');
else set(handles.edit4,'Enable','on');
    set(handles.edit8,'Enable','on');
    set(handles.edit9,'Enable','on'); end

set(handles.edit29,'string',[num2str(Dx),' x ',num2str(Dy),' x ',num2str(Dz)])

clear pout Q
if ~all(Dv==prevDv) && exist('Modl','var')% draw new model only if Dv changes.
 drawmodl6
end
