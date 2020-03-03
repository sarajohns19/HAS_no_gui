%	Callback to be used with HASgui.
%	Toggles zoom on and off.
%
%   Base workspace script.
%	Copyright 2009 by D.A. Christensen

tbval=get(handles.togglebutton1,'value');
if tbval==1; zoom on;
    set(handles.togglebutton1,'String','Turn Zoom Off','BackgroundColor',[0.5 0.5 1],...
        'ForegroundColor',[1 1 1]);
else zoom off;
    set(handles.togglebutton1,'String','Turn Zoom On','BackgroundColor','w',...
        'ForegroundColor',[0 0 0]);
end