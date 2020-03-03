function varargout = HASgui8e(varargin)
%HASGUI8E M-file for HASgui8e.fig
%      HASGUI8E, by itself, creates a new HASGUI8E or raises the existing
%      singleton*.
%
%      H = HASGUI8E returns the handle to a new HASGUI8E or the handle to
%      the existing singleton*.
%
%      HASGUI8E('Property','Value',...) creates a new HASGUI8E using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to HASgui8e_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      HASGUI8E('CALLBACK') and HASGUI8E('CALLBACK',hObject,...) call the
%      local function named CALLBACK in HASGUI8E.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HASgui8e

% Last Modified by GUIDE v2.5 26-Apr-2019 16:10:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HASgui8e_OpeningFcn, ...
                   'gui_OutputFcn',  @HASgui8e_OutputFcn, ...
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


% --- Executes just before HASgui8e is made visible.
function HASgui8e_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for HASgui8e
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

evalin('base','initializegui7'); % DAC: This line reads in handles to base workspace.

% UIWAIT makes HASgui8e wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HASgui8e_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
