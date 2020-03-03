% Program to calculate phase shifts over 3D cone of rays from
%  respective transducer elements to geometric focus (not if electronically steered).
% Base workspace script.
%
% Changes:
%   5/14/15 - Save .mat file of phases along each ray to geom focus to later multiply ERFA
%      file (off line).
%
% Copyright D. Christensen 2015
% May 14, 2015

if  exist('ElemLoc','var'); % this file is read in when ERFA is loaded.
    thvect=ElemLoc(:,1); phivect=ElemLoc(:,2); % column vectors of theta and phi.
    numelem=size(thvect,1);
    if numelem==1
        errordlg(['Transducer is not a phased array. No ray trace possible.'],'ERROR','modal'); return
    end
else errordlg(['ElemLoc file should have been read in with the ERFA files.' ...
        '  Please correct.'],'ERROR','modal'); return
end 

if ~exist('Np','var'); % read in number of points only if it has not yet been read in.
    prompt={'Enter Number of Points on Ray:'};
    titl='Ray Points';  lines=1;  initans={num2str(1000)};
    answer3=inputdlg(prompt,titl,lines,initans,'on');
    if isempty(answer3); return; end
    Np=str2double(answer3{1}); % number of points on ray.
end

if ~exist('Nv','var'); % read in number of vertical voxels to analyze if it has not yet been read in.
    prompt={'Enter Number of Vertical Voxels to Analyze:'};
    titl='Vertical Voxel Number';  lines=1;  initans={num2str(5)};
    answer4=inputdlg(prompt,titl,lines,initans,'on');
    if isempty(answer4); return; end
    Nv=str2double(answer4{1}); % number of points on ray.
end

geom=str2num(get(handles.edit11,'string')); % point in world coords of geom focus.
mgf=round(geom(2)/Dy + 0.5 + sm(1)/2);  % voxel indices at geom focus (gf).
ngf=round(geom(1)/Dx + 0.5 + sm(2)/2);
%  qgf=round(geom(3)/Dz); %  not needed.
% cmodl=single(zeros(size(Modl))); % not  needed.
PHtot=ones(1,numelem);  reflnum=ones(1,numelem); % preallocate memory.
cmodl=c(Modl);
rhomodl=rho(Modl);

figure(1); clf;  % open or reuse figure.
for gg=1:Nv  % scan through vertical group of Nv voxels around geom focus.
    ystep=Dy*(gg-round(Nv/2));  % vertical distance from geom focus to neighboring voxel.
    mms=mgf+(gg-round(Nv/2));   % starting voxel index in vertical scan of Nv voxels.
   
    for g=1:numelem;
        yseg=Rmm*sin(thvect(g))-ystep;  % see sketch for definition of yseg;
        thp=atan(yseg/(Rmm*cos(thvect(g))));    % new theta from neighboring voxel.
        Rp=yseg/sin(thp);   % new radial distance from voxel to transducer element.
        dP=Rp/Np;  % distance between points in P vector, in mm.
        P=0:dP:dP*(Np-1);    % set up P vector with Np elements (none at end).

        PHinc=dP*fMHz*1e3*2*pi/c(1);    % phase incr over one dP for water (default).
        PHadd=PHinc*ones(1,length(P));  % vector of phase additions; start with water.

        Pz=P*cos(thp)*cos(phivect(g));   Px= -P*cos(thp)*sin(phivect(g));
        Py=P*sin(thp);
        Pzp= -(Pz - depth + Dz/2);  Pyp=Py + Dy/2 ;  Pxp=Px + Dx/2;
        qq=ceil(Pzp/Dz);   % indices of voxels the ray passes through in z-direction.
        mo=floor(Pyp/Dy);  no=floor(Pxp/Dx); % offsets in voxel index in y- and x-directions.
        mm=mms + mo;  nn=ngf + no; %indices of voxels ray passes through in y- and x-directions.
        qi=qq(qq>0);  mi=mm(qq>0);   ni=nn(qq>0);   % truncate to only voxels inside Modl.
       
        if max(mi)>sm(1) || min(mi)<1 || max(ni)>sm(2) || min(ni)<1; %ignore rays that fall out sides.
            PHtot(g)=NaN;
        else
  
        cind=sub2ind(size(cmodl), mi, ni, qi);
        medvect=Modl(cind); % vector of media types crossed by ray.
        cvect=cmodl(cind);  % vector of sos values in voxels crossed by ray.
        PHadd(1:length(qi))=PHinc*c(1)./cvect;    % correct for actual sos.
        PHtot(g)=sum(PHadd);   % total phase from transducer element g to voxel.
        rhovect=rhomodl(cind);   impedvect=cvect.*rhovect;
        reflvect=diff(impedvect)./(impedvect(1:end-1)+impedvect(2:end));  % (Z2-Z1)/(Z2+Z1).
        reflnum(g)=sum(reflvect.*reflvect);  %sum of intensity refl coeff encountered along ray.
        medvect=medvect(medvect>1);
        tisslen(g)=length(medvect)*dP;
            if ystep==0
             %Modl(cind)=1;  % to visibly see the voxels that have been passed through
            end
        end
    end
   
avetisslen=mean(tisslen);   % in mm.
averefl=mean(reflnum(g));    % average of reflection coefficient sum.
PHtot=mod(PHtot,2*pi);  % modulus of phase.
phasecent=2*pi/60: 2*pi/30: 2*pi;   % 30 bins.
Nhist=hist(PHtot,phasecent);  [Nhistmax,histmax]=max(Nhist); 
Nhist=circshift(Nhist,[1,(15-histmax)]);    % recenter the peak of histogram.
hold on; subplot(Nv,1,Nv-gg+1); bar(phasecent,Nhist,1) ; 
xlim([0,7.5]); text(6.5,0.3*Nhistmax,[num2str(100*averefl,2) '%']);
text(6.5,0.8*Nhistmax,[num2str(avetisslen,2) ' mm']); 

if ystep==0 % at geom focus.
save RayPhase PHtot
end

end
