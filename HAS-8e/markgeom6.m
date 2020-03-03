function markgeom6(handles,sliceID,sliceindex,Dv,sm)
% Custom function that marks the location of the geom focus in HASgui.
%
%   Changes:
%       2/3/11 - Changed name to markgeom5. Marker changed back to text 'G', so elimated
%           xtick, ytick and ztick in function argument list. Added a test that does not draw
%           marker if checkbox5 is not checked.
%       2/19/13 - Changed name to markgeom6.
%
%     Copyright D.A. Christensen 2013.
%     Feb. 19, 2013.

if get(handles.checkbox5,'value')
geom=str2num(get(handles.edit11,'string'));
switch sliceID
    case 1
        xgeomindex=round(geom(1)/Dv(1) + 0.5 + sm(2)/2); % geom slice index.
        if sliceindex==xgeomindex
%             geom(3)=geom(3)-Dv(3)/4;
%             zpoints=[geom(3),geom(3),geom(3),geom(3)+ztick,geom(3)+ztick;...
%                 geom(3),geom(3)+ztick,geom(3)+ztick,geom(3)+ztick,geom(3)+0.6*ztick];
%             ypoints=[geom(2)+ytick,geom(2)+ytick,geom(2)-ytick,geom(2)-ytick,geom(2);...
%                 geom(2)-ytick,geom(2)+ytick,geom(2)-ytick,geom(2),geom(2)];
%             line(zpoints,ypoints,'Color','k','LineWidth',3)
%             line(zpoints,ypoints,'Color','r','LineWidth',2)
        text(geom(3),geom(2),'G','FontSize',14,'FontWeight','bold','color','black',...
            'HorizontalAlignment','center');
        text(geom(3),geom(2),'G','FontSize',12,'FontWeight','bold','color','red',...
            'HorizontalAlignment','center');
        end
    case 2
        ygeomindex=round(geom(2)/Dv(2) + 0.5 + sm(1)/2); 
        if sliceindex==ygeomindex
%             zpoints=[geom(3),geom(3),geom(3),geom(3)+ztick,geom(3)+ztick;...
%                 geom(3),geom(3)+ztick,geom(3)+ztick,geom(3)+ztick,geom(3)+0.6*ztick];
%             xpoints=[geom(1)-xtick,geom(1)-xtick,geom(1)+xtick,geom(1)+xtick,geom(1);...
%                 geom(1)+xtick,geom(1)-xtick,geom(1)+xtick,geom(1),geom(1)];
%             line(zpoints,xpoints,'Color','k','LineWidth',3)
%             line(zpoints,xpoints,'Color','r','LineWidth',2)
        text(geom(3),geom(1),'G','FontSize',14,'FontWeight','bold','color','black',...
            'HorizontalAlignment','center');
        text(geom(3),geom(1),'G','FontSize',12,'FontWeight','bold','color','red',...
            'HorizontalAlignment','center');
        end
    case 3
        zgeomindex=round(geom(3)/Dv(3));
        if sliceindex==zgeomindex
%             xpoints=[geom(1),geom(1),geom(1),geom(1)+xtick,geom(1)+xtick;...
%                 geom(1),geom(1)+xtick,geom(1)+xtick,geom(1)+xtick,geom(1)+0.6*xtick];
%             ypoints=[geom(2)+ytick,geom(2)+ytick,geom(2)-ytick,geom(2)-ytick,geom(2);...
%                 geom(2)-ytick,geom(2)+ytick,geom(2)-ytick,geom(2),geom(2)];
%             line(xpoints,ypoints,'Color','k','LineWidth',3)
%             line(xpoints,ypoints,'Color','r','LineWidth',2)
        text(geom(1),geom(2),'G','FontSize',14,'FontWeight','bold','color','black',...
            'HorizontalAlignment','center');
        text(geom(1),geom(2),'G','FontSize',12,'FontWeight','bold','color','red',...
            'HorizontalAlignment','center');
        end
end
end