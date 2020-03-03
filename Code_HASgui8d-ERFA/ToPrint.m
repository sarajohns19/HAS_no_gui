        horig=handles.axes1;
		thiscolormap=get(handles.figure1,'colormap');
%         hf=findobj('tag','printfig'); % is there an existing print fig?
%         if ishandle(hf) ;close(hf);   % if so, close it and open new figure
%             hf=figure;
%         else hf=figure; % if not, open new figure
%         end
        hf=figure;  % open new figure
        set(hf,'tag','printfig');
        gca; axis off;
        copyobj(horig,hf)
		colormap(thiscolormap); 
        set(hf,'NumberTitle','off','Name',['FOR PRINTING - ' datestr(now)])
       