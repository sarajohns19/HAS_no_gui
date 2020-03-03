function markfocus6(handles,sliceID,sliceindex,Dv,sm,focusx,focusy,focusz,isPA)
% Custom function that marks the location of the focus in HASgui.
%
%   Changes:
%       2/3/11 - Changed name to markfocus5. Marker changed back to text 'F', so elimated
%           xtick, ytick and ztick in function argument list. Added a test that does not draw
%           marker if checkbox5 is not checked, so added handles to argument list.
%       2/19/13 - Changed name to markfocus6.
%
%     Copyright D.A. Christensen 2013.
%     Feb. 19, 2013.

if isPA  && get(handles.checkbox5,'value')
    switch sliceID
        case 1
            xfocindex=round(focusx/Dv(1) + 0.5 + sm(2)/2); % focus slice index.
            if sliceindex==xfocindex
%                 zpoints=[focusz,focusz,focusz;focusz,focusz+ztick,focusz+ztick];
%                 ypoints=[focusy+ytick,focusy+ytick,focusy;focusy-ytick,focusy+ytick,focusy];
%                 line(zpoints,ypoints,'Color','k','LineWidth',3)
%                 line(zpoints,ypoints,'Color','y','LineWidth',2) 
            text(focusz,focusy,'F','FontSize',14,'FontWeight','bold','color','black',...
               'HorizontalAlignment','center');
            text(focusz,focusy,'F','FontSize',12,'FontWeight','bold','color','yellow',...
               'HorizontalAlignment','center');
            end
        case 2
            yfocindex=round(focusy/Dv(2) + 0.5 + sm(1)/2); 
            if sliceindex==yfocindex
%                 zpoints=[focusz,focusz,focusz;focusz,focusz+ztick,focusz+ztick];
%                 xpoints=[focusx-xtick,focusx-xtick,focusx;focusx+xtick,focusx-xtick,focusx];
%                 line(zpoints,xpoints,'Color','k','LineWidth',3)
%                 line(zpoints,xpoints,'Color','y','LineWidth',2)
            text(focusz,focusx,'F','FontSize',14,'FontWeight','bold','color','black',...
               'HorizontalAlignment','center');
            text(focusz,focusx,'F','FontSize',12,'FontWeight','bold','color','yellow',...
               'HorizontalAlignment','center');
            end
        case 3
            zfocindex=round(focusz/Dv(3));
            if sliceindex==zfocindex
%                 xpoints=[focusx,focusx,focusx;focusx,focusx+xtick,focusx+xtick];
%                 ypoints=[focusy+ytick,focusy+ytick,focusy;focusy-ytick,focusy+ytick,focusy];
%                 line(xpoints,ypoints,'Color','k','LineWidth',3)
%                 line(xpoints,ypoints,'Color','y','LineWidth',2)
            text(focusx,focusy,'F','FontSize',14,'FontWeight','bold','color','black',...
               'HorizontalAlignment','center');
            text(focusx,focusy,'F','FontSize',12,'FontWeight','bold','color','yellow',...
               'HorizontalAlignment','center');
            end
    end
end
