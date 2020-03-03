% Callback for button that views, and can modify, certain parameters in HASgui6. 
%	Base workspace script.
%
% The parameter file contains most of the specifications of the HAS calculation.
%   After viewing in a dialog box, the values can be changed and take effect 
%   when the dialog box is closed.
%
% Changes:
%   2/1/11 - Added call to drawmodl5.m (a separate draw program) when the  model
%       increments Dx, Dy or Dz have been changed.
%   12/26/12 - SUBSTANTIAL changes: added absorption coefficients, forward/back scattering
%       ratio, and scattering angle limit to input parameters. Streamlined str2nm arguments.
%   2/8/13 - Put mediadescr line into edit box 12 when 'OK' button is pushed.   
%
%   Copyright D.A. Christensen 2013.
%   Feb. 8, 2013

if ~exist('Dv','var')
        errordlg('The parameter file must be read in before viewing it.','ERROR','modal');
        return; end

prevDv=Dv;
prompt={'Type of each medium:',...
    'Sound speed of each medium (in m/s):',...
    'Attenuation coeff of each medium (in Np/cm*MHz):',...
    'Absorption coeff of each medium (in Np/cm*MHz):'...
    'Scattering correlation length (in index units):',...
    'Std dev of acoustic parameters of each medium:',...
    'Density of each medium (in kg/m^3):',...
    'Radiated power of transducer (in W):',...
    'Size of Modl increments, Dx, Dy, Dz (in mm):'...
    '',...
    '',...
    'Frequency of transducer (in MHz):',...
    'Radius of curvature of transducer (mm):',...
    'Distance of ERFA plane from transducer (mm):'};
commentstr1 = 'MAKE CHANGES TO ABOVE, THEN PRESS OK';
commentstr2 = '--ONLY VALUES ABOVE CAN BE CHANGED--';
titl=truncfilename; % name of parameter file.
lines=[2;2;2;2;1;2;2;1;1;1;1;1;1;1]; 
initans={mediadescr,num2str(c),num2str(a),num2str(aabs),num2str(corrl),num2str(randvc),...
    num2str(rho),num2str(Pr),num2str(Dv),commentstr1,commentstr2,num2str(fMHz),...
    num2str(Rmm),num2str(1000*sx)};
answer1=inputdlg(prompt,titl,lines,initans,'on');
if isempty(answer1); return; end
mediadescr=answer1{1};
c=str2num(answer1{2}); 
a=str2num(answer1{3});
aabs=str2num(answer1{4});
corrl=str2num(answer1{5});
randvc=str2num(answer1{6});
rho=str2num(answer1{7}); 
Pr=str2num(answer1{8});
Dv=str2num(answer1{9}); 
Dx=Dv(1); Dy=Dv(2); Dz=Dv(3);
set(handles.edit29,'string',[num2str(Dx),' x ',num2str(Dy),' x ',num2str(Dz)])
set(handles.edit12,'string',mediadescr) % refresh mediadescr.

clear pout Q
if ~all(Dv==prevDv) && exist('Modl','var')
drawmodl6
end