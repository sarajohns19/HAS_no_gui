% Callback for radiobutton that freezes the zoom window in HASgui.
%     Base workspace script.
% 
%     Copyright D.A. Christensen 2009.
%     March 1, 2009.

% When checkbox is checked, zoom window is frozen assuming the slice choice
%   has not changed.  When the slice choice is changed, the checkbox is cleared.

freezesliceID=sliceID;