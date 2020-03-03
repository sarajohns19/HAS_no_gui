%  Callback for button that saves pout, Q and pp results as .mat files in HASgui5.
%     It also stores paramscell, a cell array that lists many of the parameters
%       used in the simulation.
%     Base workspace script.
% 
%   Changes:
%       1/26/11 - Changed name to Savefiles5 (no other changes).
%       1/3/13 - Added abs coeff and corrl to variables saved in paramscell.
%       5/19/15 - Added wdisp to variables saved.  Changed name to Savefiles7.
%
%     Copyright D.A. Christensen 2015.
%     May 19, 2015.

if ismodlrot; 
     warndlg('Model is rotated/recentered--must rotate back before saving pressure.'); end

paramscell={'Xducer file', filename; 'Frequency in MHz', fMHz; ...
    'Radius of Xducer (mm)', Rmm; 'Modl file', filename1; ...
    'Radiated Power from Xducer (W)',Pr; ... 
    'Size of model grid (i,j,k)', [sm(2), sm(1), sm(3)]; 'Voxel sizes (mm)', Dv; ...
    'Overall size of model (mm)', LenModl; ...
    'Offset of Xducer axis from model axis (mm)', [offsetxmm,offsetymm]; ...
    'Distance from Xducer to front plane of model (mm)', dmm; ...
    'Location of steered focus in model (mm)', [lastfocusx, lastfocusy, lastfocusz]; ...
    'Description of media in model',mediadescr; ...
    'Speed of sound in each medium (in m/s)', c; ...
    'Attenuation coeff of each medium (in Np/cm*MHz)',a; ...
    'Absorption coeff of each medium (in Np/cm*MHz)',aabs; ...
    'Std dev of random variation of each medium',randvc; ...
    'Correlation length of random variation (in voxels)',corrl; ...
    'Density of each medium (in kg/m^3)',rho};

	[newfile,newpath] = uiputfile('pout_.mat','Save pressure pout_.mat file?');
	if newfile~=0;
		fullfile=[newpath newfile];
		save(fullfile,'pout','paramscell') % Save pout in .mat file
	end
	
	[newfile1,newpath1] = uiputfile('Q_.mat','Save Q_.mat file?');
	if newfile1~=0;
		fullfile1=[newpath1 newfile1];
		save(fullfile1,'Q','paramscell') % Save Q in .mat file
    end
    
    [newfile3,newpath3] = uiputfile('wdisp_.mat','Save ARFI displacement?');
	if newfile3~=0;
		fullfile3=[newpath3 newfile3];
		save(fullfile3,'wdisp','paramscell') % Save wdisp in .mat file
    end

    [newfile2,newpath2] = uiputfile('pp_.mat','Save pressure on input plane pp_.mat file?');
	if newfile2~=0;
		fullfile2=[newpath2 newfile2];
		save(fullfile2,'pp','paramscell') % Save pp in .mat file
    end