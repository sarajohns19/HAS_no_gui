function sliceviewset6(handles,sliceID,secflag)
% Custom callback function for HASgui that couples the slice display components together.
%   The sliceID integer tells whether it is a x-, y-, or z-slice.  If secflag == 0,
%   the value in the index display box is sent to the slider. If secflag == 1, the value
%   from the slider is sent to the index display box. (The matching axis values are sent
%   to the respective axis value display boxes in the plotx programs.)
%
%   Changes:
%       2/19/13 - changed plot calls to plotx6, ploty6 and plotz6.
%       5/19/15 - changed plot calls to plotx7, ploty7 and plotz7.
%           These plot scripts add ARFI displacement.
%
%     Copyright D.A. Christensen 2015.
%     May 19, 2015.


switch sliceID
    case 1
        switch secflag
            case 0 
                val=str2double(get(handles.edit6,'string'));
                set(handles.slider1,'value',round(val));
            case 1
                val=get(handles.slider1,'value');
                set(handles.edit6,'string',num2str(round(val)));
        end
        evalin('base','plotx7')
    case 2
        switch secflag
            case 0 
                val=str2double(get(handles.edit5,'string'));
                set(handles.slider2,'value',round(val));
            case 1
                val=get(handles.slider2,'value');
                set(handles.edit5,'string',num2str(round(val)));
        end
        evalin('base','ploty7')
    case 3
        switch secflag
            case 0 
                val=str2double(get(handles.edit7,'string'));
                set(handles.slider3,'value',round(val));
            case 1
                val=get(handles.slider3,'value');
                set(handles.edit7,'string',num2str(round(val)));
        end
        evalin('base','plotz7')
end
