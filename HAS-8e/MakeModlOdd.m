%   Program to add one layer of water to r and/or c side of a Modl that has an odd number of
%       elements (which causes Fourier transform to shift wave as it is propagated).
%       If the Modl is already odd in one or more r, c directions, no additional layer added.
%   May 13, 2019 Copyright D. Christensen

[filename9, pathname] = uigetfile('*.mat','Open Modl_.mat file of model:');
if filename9==0; filename9=''; return; end
load([pathname filename9]);
if ~exist('Modl','var')
    errordlg('The Modl file must contain a variable named ''Modl''.','ERROR','modal');
return; end;

sm=size(Modl); % sm (in y,x,z order) is used extensively throughout the gui.
if 2*round(sm(1)/2)==sm(1) 
    Modl=padarray(Modl,[1 0 ],1,'post');
end
if 2*round(sm(2)/2)==sm(2)
    Modl=padarray(Modl,[0 1 ],1,'post');
end

[newfile,newpath] = uiputfile(filename9,'Save odd Modli_.mat file?');
if newfile~=0
	fullfile=[newpath newfile];
	save(fullfile,'Modl') % Save new odd Modl in .mat file
end 
   