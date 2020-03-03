% Callback for listbox that choses the file to display in HASgui.
%     Base workspace script.
%
% The listbox value tells the file that will be displayed.  The callback executes
%   and display updated when the listbox is changed.
% This version calls plotx6, etc., which has enhanced box model features.
%   Changes:
%       2/19/13 - changed plot calls to plotx6, ploty6 and plotz6.
%       5/19/15 - changed plot calls to plotx7, ploty7 and plotz7.
%           These plot scripts add ARFI displacement.
%
%     Copyright D.A. Christensen 2015.
%     May 19, 2015.

if get(handles.radiobutton1,'value'); plotx7
elseif get(handles.radiobutton2,'value'); ploty7
elseif get(handles.radiobutton3,'value'); plotz7
end