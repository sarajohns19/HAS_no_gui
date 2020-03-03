% Callback for button that loads ERFA files in HASgui6.
%     Base workspace script.
%     Note: x is along direction of increasing column index, y is along increasing row index of perfa.
% 
% ERFA_.mat is a file that contains the element pressures (perfa) on the ERFA plane, as well 
% 	as the frequency in MHz (fMHz), size of the ERFA plane in m (Len), distance between the 
%   xducer and ERFA plane in m (sx), radius of curvature of the xducer in m (R),  and location file 
%   of the elements (ElemLoc). If the xducer is solid and not a phased array, perfa has only one 
%   page and ElemLoc is not included in the file.  ERFA also assumes a total xducer power of 1 W.
%
%   Changes:
%   1/14/11 - Changed the calculation of dxerfa and dyerfa to match calculations done in ERFAMaker5; that is: 
%           dxerfa = Len(2)/(mmaxerfa-1), not dxerfa = Len(2)/mmaxerfa. This is equivalent to condsidering the
%           ERFA plane size (Len) to be from end point to end point. (The values of dxerfa and dyerfa are then
%           'neat' values when number of samples is odd; e.g., if Len(2) = 100 mm and mmaxerfa = 101, then 
%           dxerfa = 1.0 mm. The Dx and Dy values in a Modl that matches ERFA will usually be 'neat' values.
%           The Modl increment should be integer multiples of the ERFA increment for most accurate interpolation.)
%   1/20/11 - Made all perfa files single precision.  Added a line that converts legacy double precision 
%           perfa files to single precision.
%   12/29/12 - Set the initial distance xducer to Modl to be ERFA plane distance here instead of in loadparam6.
%   4/12/15 - Made the default folder to look for the ERFA file to be 'Modls, ERFA & param' inside main folder.
%
%     Copyright D.A. Christensen 2015.
%     April 12, 2015.

if exist('R','var');
    button4=questdlg(['Do you want to reload a new ERFA file?  (If so, you will need to reload the '...
        'param and Modl files also.)'],'RELOAD ERFA?' );
    switch button4
        case 'Yes'
%             save handlescache handles  % save handles for reload of a different ERFA.
            set(gcf,'WindowButtonMotionFcn',[]); 
            set(gcf,'WindowButtonDownFcn',[]);
            set(handles.edit2,'string','RELOAD PARAM FILE');
            set(handles.edit3,'string','RELOAD MODL FILE'); 
%             clear all; load handlescache;
        case 'No'; return; case 'Cancel'; return; case ''; return
    end
end
[filename, pathname] = uigetfile('currentdirstr/Modls, ERFA & param/*.mat',...
    'Open ERFA_.mat file of transducer pressure:');
if filename==0;  filename=''; return; end
hww=msgbox('Wait for large ERFA file to load.','modal');
load([pathname filename]);
if ~exist('R','var')||~exist('perfa','var')||~exist('Len','var')
errordlg('The ERFA file must contain transducer variables such as ''perfa'' , ''Len'' and ''R''.','ERROR','modal');
close(hww); 
return; end
set(handles.edit1,'string',filename)

if strcmp(class(perfa),'double'); perfa=single(perfa); end % always use single precision perfa to save memory.

Rmm=R*1000; % R in m for most calcs, Rmm in mm for gui display.
[lmaxerfa,mmaxerfa,pages]=size(perfa);  % size of ERFA plane.
dyerfa=Len(1)/(lmaxerfa-1); dxerfa=Len(2)/(mmaxerfa-1); % sample spacing in ERFA plane, in m.
Dyerfa=dyerfa*1000; Dxerfa=dxerfa*1000;    % convert to mm.
set(handles.edit23,'string',[num2str(Dxerfa),' x ',num2str(Dyerfa)])
set(handles.edit25,'string',[num2str(size(perfa,2)),' x ',num2str(size(perfa,1)),' x ',num2str(size(perfa,3))])
set(handles.edit26,'string',[num2str(Len(2)*1000),' x ',num2str(Len(1)*1000)])
set(handles.edit18,'string',num2str(sx*1000)) % set initial distance xducer to Modl to be the ERFA distance.

yaxiserfa=Dyerfa*(-(lmaxerfa-1)/2:(lmaxerfa-1)/2);    % setting up axes in mm units for interpolation.
xaxiserfa=Dxerfa*(-(mmaxerfa-1)/2:(mmaxerfa-1)/2); 

% The next two lines may be used if memory is tight. If uncommented, the corresponding perfa
%   lines in the CalcHAS_ERFA callback must be uncommented.
%save perfacache perfa   % save for use in CalcHAS_ERFA.
%clear perfa     % to free up memory.

close(hww)
