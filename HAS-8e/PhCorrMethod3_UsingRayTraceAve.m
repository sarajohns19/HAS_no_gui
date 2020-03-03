% Program to calculate phase shifts over a 3D cone of rays from the intended focal point
%   in Modl back to all element locations on a phased-array transducer. Assumes ElemLoc angles
%   and radius Rmm have been previously loaded as part of load ERFA. If any ray falls outside the
%   model extent and therefore phase can't be calculated, its phase is set to zero and an alert
%   is given to the user to rerun with padded model.
%
%   This program follows Method3 by using ray tracing (as compared to Method1, which pre-calculates
%	beams from each element independently into the focal volume, and Method2, which uses time reversal).
%
%   This version finds all rays within each element and averages the phase changes over these rays.
%   Base workspace script.
%
%   Copyright D. Christensen 2019
%       July 2, 2019

if exist('ElemLoc','var') % finding phases makes sense only if transducer is a phased array.
    
    thvect=ElemLoc(:,1); phivect=ElemLoc(:,2); % column vectors of theta and phi.
    numelem=size(thvect,1);
% Legacy section:  
% if ~exist('Np','var') % read in number of points along ray only if it has not yet been read in.
%     prompt={'Enter Number of Points on Ray:'};
%     titl='Ray Points';  lines=1;  initans={num2str(1000)};
%     answer3=inputdlg(prompt,titl,lines,initans,'on');
%     if isempty(answer3); return; end
%     Np=str2double(answer3{1}); % number of points on ray.
% end
Np=5000;  % a reasonable choice of number of samples along ray: enough for accuracy
                    %  without slowing down the calculations too much.

foc = str2num(get(handles.edit24,'string')); % coords of intended focus.
xf=foc(1); yf=foc(2); zf=foc(3);  % note x,y,z order of editbox24, different from y,x,z order of Modl array.
mfoc = round(yf/Dy  + sm(1)/2 + 0.5);  % y voxel index at intended focus (foc).
nfoc = round(xf/Dx + sm(2)/2 + 0.5);   qfoc=round(zf/Dz); %  x and z voxel indices.
cmodl = c(Modl);      % speed of sound in each voxel.
PhCorr3 = zeros(1,numelem);   % preallocate memory.

hwb9=waitbar(1,'<----- Calculating Ray Phases','Name','Ray Tracing');
ModlRT = Modl;      %  to visualize ray paths.
dthphi = Dx/Rmm; nang = round(relem*1e3/Dx);    % angle increment and number of increments.
phasemat = zeros(2*nang+1 , 2*nang+1);  % preallocate memory.
num_rayoutside = 0;  % total number of rays that fall outside of Modl space; start with 0.

for g=1:numelem     % loop through elements.
     angrange = -nang*dthphi:dthphi:nang*dthphi;
    for gth=1:2*nang+1
        thmat=thvect(g) + angrange(gth);
        for gphi=1:2*nang+1
            phimat=phivect(g) + angrange(gphi);
  
            xe = Rmm*cos(thmat)*sin(phimat) - offsetxmm;   % xcoord of this element (Note: xe pos inward;
                                                                % opposite of x direction in HAS. Internally consistent here).
            ye = Rmm*sin(thmat) + offsetymm;      % all distances in mm units.
            ze = Rmm*(1-cos(thmat)*cos(phimat));
            LP = sqrt((dmm+zf-ze).^2 + (xe+xf).^2 + (ye-yf).^2);    % length of P vector in mm.
            thetae = asin((ye-yf)./LP);   phie = asin((xe+xf)./(LP + cos(thetae)));     % angles from foc to elem.
            dP = LP/Np;         % increment in P length in mm.
            P = 0:dP:dP*(Np-1);     % vector of length increases along hypotenus of ray from foc to elem.
            phinc = dP*fMHz*1e3*2*pi/c(1);      % phase incr over one dP for water (default).
            Phvect = phinc*ones(1,length(P));       % vector of phases, start with water.
            Pz = P*cos(thetae)*cos(phie);      % projection of P along z axis.
            Px =  -P*cos(thetae)*sin(phie);      Py = P*sin(thetae);       % projections along x and y axes.
            Pzp =  -(Pz - zf + Dz/2);      % make Pzp increase positive from Modl front.
            Pyp = Py + Dy/2 ;      Pxp = Px + Dx/2;
            qq = ceil(Pzp/Dz);   % indices of voxels the ray passes through in z-direction.
            mo = floor(Pyp/Dy);  no = floor(Pxp/Dx); % offsets in voxel indices in y- and x-directions.
            mm = mo + mfoc;  nn = no + nfoc; % indices of voxels that ray passes through in y- and x-directions.
            mi = mm(qq>0);  ni = nn(qq>0);  qi = qq(qq>0);   % truncate to only voxels inside Modl.
            if max(mi) > sm(1) || min(mi) < 1 || max(ni) > sm(2) || min(ni) < 1  %  if this ray falls outside Modl.
                phasemat(gth,gphi) = nan;  
            else
                cind=sub2ind(size(cmodl), mi, ni, qi);
                cvect=cmodl(cind);  % vector of sos values in voxels crossed by ray.
                Phvect(1:length(qi))=phinc*c(1)./cvect;    % correct for actual sos for voxels inside Modl.
                phasemat(gth,gphi)=sum(Phvect);   % total phase from transducer element g to voxel.
                ModlRT(cind)=1;  % use Modl=ModlRT in HASgui to visualize voxels that are passed through.
            end
        end
    end
    
    phsors=exp(1i*phasemat);    % now average angle in phasor language to avoid discontinuity near 0 and 2pi.
    meanphsors=mean(mean(phsors,'omitnan'),'omitnan');
    if isnan(meanphsors) 
        PhCorr3(g) = 0;  num_rayoutside = num_rayoutside +1;   % ignore phase correction if all rays outside Modl.
    else
        PhCorr3(g) = atan2(imag(meanphsors),real(meanphsors));  
    end
    waitbar(1-g/numelem)
    
end
if num_rayoutside > 0 
    warndlg([num2str(num_rayoutside) ' total ray sets fall outside of Modl extent, so zero phase is set for those'....
    ' elements. Phase correction will not be accurate.  Should pad model correspondingly and run again.'],'',...
    'modal'); uiwait;
end

close(hwb9)
angpgvect=shiftdim((exp(+1i*PhCorr3)),-1);   % vector of inverse phase shifts in page dimension.

else; warndlg('Transducer is not phased array, so no phase correction applicable','','modal'); uiwait;
    set(handles.checkbox9,'value',0);
end

clear  cmodl % to free memory. 

