function varargout = EditCmap4Modl(varargin)
%       Note: To use this colormap editor with a standalone figure not part of HASgui, first open
%       the figure in base workspace, the type 'EditCmap4Modl(gcf)' with gcf as the input
%       argument.

%EDITCMAP4MODL M-file for EditCmap4Modl.fig
%      EDITCMAP4MODL, by itself, creates a new EDITCMAP4MODL or raises the existing
%      singleton*.
%
%      H = EDITCMAP4MODL returns the handle to a new EDITCMAP4MODL or the handle to
%      the existing singleton*.
%
%      EDITCMAP4MODL('Property','Value',...) creates a new EDITCMAP4MODL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to EditCmap4Modl_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%h
%      EDITCMAP4MODL('CALLBACK') and EDITCMAP4MODL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in EDITCMAP4MODL.M with the given input
%      arguments.
% Edit the above text to modify the response to help EditCmap4Modl

% Last Modified by GUIDE v2.5 06-Apr-2017 13:48:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditCmap4Modl_OpeningFcn, ...
                   'gui_OutputFcn',  @EditCmap4Modl_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% -------- Executes just before EditCmap4Modl is made visible.
function EditCmap4Modl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

[hcbo,hfig]=gcbo;  % handles to cbo and main figure (HASgui) that initiated the callback.
%       Note: To use this colormap editor with a standalone figure not part of HASgui, open
%       the figure in base workspace, the type 'EditCmap4Modl(gcf)' with gcf as the input
%       argument. Then the following will apply:
if nargin>3; hfig=varargin{1}; end% in later ML versions, nargin includes 3 args not including user arg.
if ishandle(hfig)
    cmap=get(hfig,'colormap'); % get starting colormap from main figure.
    colormap(cmap)  % set this gui to this colormap.
    n=size(cmap,1);  % display starting colormap in axescolormap in this gui.
    caxis=[1 n];
    image(1:n)
    set(gca,'ytick',[])
	set(gca,'ticklength',[0 0]) % get rid of all tick marks.
    handles.mainfig=hfig;    % store handle to cbo, main fig and current cmap in handles structure.
    handles.cmap=cmap;
    handles.cbo=hcbo;
    handles.ca=gca;
	set(gcf,'WindowButtonDownfcn',{@SelectColorIndex,handles}) % select index with click.
    if nargin>3; figure(varargin{1}); end   % bring in figure if not called from HASgui.
else errordlg('No figure identified for this colormap editor')
end

% Choose default command line output for EditCmap4Modl
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% ------- Outputs from this function are returned to the command line.
function varargout = EditCmap4Modl_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;

% -------- Callback for selecting the color index to be changed by a mouse click.
function SelectColorIndex(hObject, eventdata, handles)
axes(handles.ca);
cpm=get(gca,'CurrentPoint'); cp=cpm(1,1:2);
xl=get(gca,'XLim'); yl=get(gca,'YLim');
if cp(1)>=xl(1) && cp(1)<=xl(2) && cp(2)>= yl(1) && cp(2)<=yl(2)
    colorindex=round(cp(1));
    set(handles.customindex,'string',num2str(colorindex))
end

% ----------- Executes on button press in Apply.
function Apply_Callback(hObject, eventdata, handles)
% hObject    handle to Apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.mainfig,'colormap',handles.cmap) % transfer new colormap to main fig.
% Store colormap in appdata of HASgui button only if the HASgui is the caller. Then
% transfer customcmap to base workspace; pushbutton30 is handle of cbo in baseworkspace:
if ishandle(handles.cbo)
    customcmap=handles.cmap;
    setappdata(handles.cbo,'cmap',customcmap);     
    evalin('base','customcmap=getappdata(handles.pushbutton30,''cmap'');') 
    close
end

% Not currently called:
function customindex_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function customindex_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ---------- Executes on button press in NewColor.
function NewColor_Callback(hObject, eventdata, handles)
% hObject    handle to NewColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cmap=handles.cmap;   % retrive current colormap.
cind=str2num(get(handles.customindex,'string'));    % get index of colormap to be changed.
clr = uisetcolor(cmap(cind,:), 'Select New Color');    % return the new color.
cmap(cind,:)=clr; % insert into colormap.
colormap(cmap)  % set this gui to this new colormap.

% Update handles structure
handles.cmap=cmap;
guidata(hObject, handles);

% ---------- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

customcmap=handles.cmap;
[newfile,newpath] = uiputfile('Modls, ERFA & param/customcmap_x.mat',...
    'Save CustomColormap in Modls Folder');
if newfile==0; return; end
fullfile=[newpath newfile];
save(fullfile,'customcmap') % save colormap in .mat file.
set(handles.mainfig,'colormap',customcmap)  % apply to main fig colormap.
% Store colormap in appdata of HASgui button only if the HASgui is the caller. Then
% transfer customcmap to base workspace; pushbutton30 is handle of cbo in baseworkspace:
if ishandle(handles.cbo)
    setappdata(handles.cbo,'cmap',customcmap);     
    evalin('base','customcmap=getappdata(handles.pushbutton30,''cmap'');') 
end

% -------- Executes on button press in Browse.
function Browse_Callback(hObject, eventdata, handles)
% hObject    handle to Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename1, pathname] = uigetfile('Modls, ERFA & param/*.mat',...
    'Open customcmap_x.mat file of colormap:');
if filename1==0; return; end
load([pathname filename1]);
if ~exist('customcmap','var')
    errordlg('The file must contain a variable named ''customcmap''.','ERROR','modal');
return; end;
cmap=customcmap;
colormap(cmap)  % set this gui to this colormap.
n=size(cmap,1);  % display starting colormap in axescolormap in this gui.
caxis=[1 n];
image(1:n)
set(gca,'ytick',[])
set(gca,'ticklength',[0 0]) % get rid of all tick marks.
%set(gcf,'WindowButtonDownfcn',{@SelectColorIndex,handles})
%set(handles.mainfig,'colormap',cmap)  % apply now.
handles.cmap=cmap;  % store handle to current colormap in handles structure.
% Update handles structure
guidata(hObject, handles);
