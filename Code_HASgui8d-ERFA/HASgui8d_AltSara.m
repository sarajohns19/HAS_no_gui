% Main calculation program for Hybrid Angular Spectrum HASgui8, which uses generalized ERFA for a phased
%   array.  It is assumed the the gui has already loaded the ERFA_ file, which concurrently loads the
%   pressure on the ERFA plane (perfa) and the transducer parameters freq (fMHz), radius of curvature (R), 
%	size of the ERFA plane (Len), radiated power (Pr), distance between the xducer and ERFA plane (sx),
%   and location file of the elements (ElemLoc).  Generalized ERFA first combines the element
%	responses with the correct phases for focusing, then propagates to the front plane of the Modl in the
%	freq domain.  Interpolation matches the points on the propagated perfa with the points on the Modl.
%   In addition, the paramHAS7_ file, which reads in the Modl sample spacings and media properties, and 
%   the Modl_ file of media integers have also been loaded, in that order.
%
%   This script is executed in the main workspace, so all variables there are accessable.
% 
%   HASgui7 has warnings that display when the sample spacing in the propagated perfa pattern is greater than
%	twice (later 1x) the sample spacing in the Modl (perhaps affecting the accuracy of interp2), and when
%	the size of the perfa pattern is not large enough to cover the Modl front plane when it is offset from the
%   xducer axis (although this is redundant with interp2 and is now commented out).
%
%  This version also restructures the HAS section to improve the algorithm (see Notes of 7/7/09 and
%   7/14/09), including adding the backward (only) reflected wave, weighting M2 by the expected
%   beam region, and implementing an optional low pass filter on the angular spectrum to cut off evanescent
%   waves.
%
%   Changes:
%   1/27/11 - Made most of the large arrays and matrices single precision to save memory (perfa was already
%       single, and Modl was already int8 [later int16 for HU of bone]).
%   12/28/12 - Version CalcHAS_ERFA6c: Added absorption [requiring aabs(i) coefficients] and scattering [both
%       Approach B for scatterers smaller than a voxel, and statistical Approach C for scatterers on a scale  
%       larger than several voxels, requiring correlation length corrl and randvc(i)]. Assumed that the 
%       pressure full att coeff a = aabs + scatt.  Q calculation now based on abs coeff aabs only. 
%       Also added maxpoutnorm to allow modification of display normalization (later dropped), and
%       corrected waitbarorig calls.
%   2/16/13 - Changed interp2 to phasor_interp2 to improve interpolation of complex erfa values.
%   2/18/13 - Bypassed the random number generation in the scattering sections in cases where there
%       is no scattering (either max(a - aabs)=0 and/or max(randvc)=0).
%   4/11/13 - Changed warning on erfa spacing to be more stringent: erfa spacing should be <= 1x model spacing.
%   4/23/13 - Dropped adj. maxpoutnorm and maxQnorm capability in HASgui. Now done with colormapeditor.
%   4/24/13 - Changed the way that single precision is done in the memory preallocation section.
%   5/19/15 - Changed call to displa7 (ARFI displacements wdisp added).  Also cleared wdisp for new calculation.
%   5/3/16 - Reduced several model parameter files (e.g., attmodl) to 2D matrices to save memory.  Also corrected
%       the one-layer-off mistake (Rn->Rn+1) in backward wave (see Working Notes2, 7/7/09, revised 4/29/16).
%   7/20/16 - Major change: Now use full integration of excess propagation constant for propagation in the space
%       domain rather than the approximation employed in earlier versions of CalcHAS. (Versions CalcHAS_ERFA7b 
%       and HASgui7b have the option to chose the approx or not.) The full integration is slighty slower due to a 'for'
%       loop (depending upon number of media types) but is more accurate for models with small voxels 
%       (thus large alpha and beta) and/or largely variable speeds of sound or attenuation. 
%       (see Working Notes2, 7/7/09, revised 4/29/16). 
%       Also, statistical scattering by Approach C is now used only to vary the pprimeterm in the full integration
%       step, not to vary each individual parameter (i.e., a, c and rho).
%
%   3/5/17 - This version does NOT have the "anti-leakage" sections used for microparticles.
%          The waitbar is also made to be the MATLAB default.
%   3/10/17 - Multiple reflections added. See the sheets entitled "Latest Diagram of Progression of Pressure in 
%       CalcHAS" 3/10/17 and "Stategy for Multiple Reflections" 3/10/17 to get an overview of the layout for multiple 
%       reflections. It uses the variable numrefl from the gui. To get ready for multiple reflections, the variable pforb
%       was added, to be symmetrical with pbackb; pforb is also now used as the beam profile weighting of bprime.  
%   5/5/17 - Optional plots of the beam power profiles at each loop added.
%   7/12/17 - Improved the calculation of the power deposition Q based on angled beams rather than previously
%        assumed axial beam.  Within each voxel, Q = dI/dz = d[I*exp(-2alpha*r)]/dr * dr/dz = 2alpha*I*dr/dz.  The last 
%        term, dr/dz, is new and takes into account the oblique path taken by the beams.  In the improvement, this 
%        term is averaged over the angles assumed for the beams as obtained from the angular spectrum A, and is 
%        labeled 'ratio_r2dz' in the code.  This improvement matches the results of kWave better than previous code.
%        Also, the Q values for reflected beams are calculated separately and added to the Q for other beams, which
%        assumes linearity for Q, a rough approximation.
%  
%	Copyright D.A. Christensen 2017.
%	April 5, 2017.
% -----------------------------------------------
function [Q,maxQ,pout] = HASgui8d_AltSara(c0,rho0,Dx,Dy,Dz,dmm,offsetxmm,offsetymm,hmm,vmm,zmm,c,a,rho,Modl,Pr,res,perfa); 

load('ERFA7_BreastErik47Corr10x10cm401x401_NoPerfa.mat'); 
aabs = a; 
randvc = zeros(size(a));
%%% GUI CODE %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if ~exist('Modl','var')
%             errordlg('The Modl.mat file must be read in before calculating.','ERROR','modal');
%return; end
%offsetxmm=str2double(get(handles.edit15,'string'));  % offsets in mm; get values from gui.
%offsetymm=str2double(get(handles.edit16,'string'));
%xaxiserfaoffs=xaxiserfa+offsetxmm; yaxiserfaoffs=yaxiserfa+offsetymm;   % adjust axes for offsets, all in mm.
%if Dyerfa>Dy || Dxerfa>Dx
%     warndlg(['The sample spacing on the ERFA plane is more than that of the Modl. '...
%         'Should use a higher resolution ERFA file.'],'','modal'); uiwait; end
%tic
%  hwb=waitbar(0,'Initializing Hybrid Angular Spectrum Calculations'); 
%clear Aprime layxs1 layxs2 M2 pfor pout ptot transf Aprimeback Q Refl Z ind pback pref wdisp; % will recalc below.
%load perfacache     % retrieve stored perfa (stored to free memory). Uncomment if uncommented in loadERFA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GUI CODE %%%%%%%%%%%%%%%%%%%%%%%


%%%% HAS5 EQUIVALENT %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rmm=R*1000; % R in m for most calcs, Rmm in mm for gui display.
[lmaxerfa,mmaxerfa,pages]=size(perfa);  % size of ERFA plane.
dyerfa=Len(1)/(lmaxerfa-1); dxerfa=Len(2)/(mmaxerfa-1); % sample spacing in ERFA plane, in m.
Dyerfa=dyerfa*1000; Dxerfa=dxerfa*1000;    % convert to mm.
yaxiserfa=Dyerfa*(-(lmaxerfa-1)/2:(lmaxerfa-1)/2);    % setting up axes in mm units for interpolation.
xaxiserfa=Dxerfa*(-(mmaxerfa-1)/2:(mmaxerfa-1)/2);

xaxiserfaoffs=xaxiserfa+offsetxmm; 
yaxiserfaoffs=yaxiserfa+offsetymm;   % adjust axes for offsets, all in mm.

% Copied from loadmodel6.m
sm=size(Modl);
% Copied from drawmodel6.m
xaxisinterp=Dx*(-(sm(2)-1)/2:(sm(2)-1)/2); % axes (between centers of end points) for imagesc and interp.
yaxisinterp=Dy*(-(sm(1)-1)/2:(sm(1)-1)/2);     % Dx, Dy and Dz all in mm.
zaxis=Dz*(1:sm(3)); % longitudinal axis has full Dz at the center of the first voxel, since HAS calculates
   % travel through a full distance Dz for each voxel and attributes the resulting pressure to that voxel.
xaxis=xaxisinterp; yaxis=yaxisinterp;   % to allow use of legacy xaxis and y axis labels.
Lx=(sm(2)-1)*Dx; Ly=(sm(1)-1)*Dy; Lz=sm(3)*Dz; LenModl=[Lx,Ly,Lz]; % in mm. Note: Lz is overall length.
lx=Lx/1000; ly=Ly/1000; % convert to m units.

clear Aprime layxs1 layxs2 pfor pout ptot transf Aprimeback Q Refl Z attmodl cmodl ind pback pref rhomodl

%tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% HAS5 EQUIVALENT %%%%%%%%%%%%%%%%%%%


%%% GUI CODE %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [lmax,mmax,nmax] = size(Modl);  % The size of the model (lmax,mmax,nmax) sets the size of the simulation
%     % space.  lmax and y are vertical; mmax and x are horizontal. NOTE: Be aware of the (y,x,z) order of arrays
%     % assumed here.  Therefore lmax by mmax is also the y by x size of the pressure pattern pp on the front 
%     % plane of the Modl, interpolated from perfa. Note: lmax and mmax should be ODD numbers to keep 
%     % fftshift symmetrical, with the dc term at exact center of spectrum.
%     % Note that lmax,mmax,nmax are duplicates of sm(1),sm(2),sm(3) because of legacy. 
% hmm=str2double(get(handles.edit4,'string')); h=hmm/1000; % convert to meter units.
% vmm=str2double(get(handles.edit8,'string')); v=vmm/1000; 
% zmm=str2double(get(handles.edit9,'string')); z=zmm/1000; 
% dmm=str2double(get(handles.edit18,'string')); d=dmm/1000;
% f=fMHz*1e6;	% convert to Hz.
% lastfocusx=geom(1)+hmm; lastfocusy=geom(2)+vmm; lastfocusz=geom(3)+zmm; % save to put into saved files.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GUI CODE %%%%%%%%%%%%%%%%%%%%%%%

%%%% HAS5 EQUIVALENT %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lmax,mmax,nmax] = size(Modl);  % The size of the model (lmax,mmax,nmax) sets the size of the simulation
    % space.  lmax and y are vertical; mmax and x are horizontal.  lmax and mmax are therefore also the size of
	% the pressure pattern pp on the front plane of the Modl, interpolated from perfa. Note: lmax and mmax 
	% should be ODD numbers to keep fftshift symmetrical with the dc term at exact center of spectrum.
    % Note that lmax,mmax,nmax are duplicates of sm(1),sm(2),sm(3) because of legacy. 
 h=hmm/1000; % convert to m units.
 v=vmm/1000; 
 z=zmm/1000; 
 d=dmm/1000;
 f=fMHz*1e6;	% convert to Hz.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% HAS5 EQUIVALENT %%%%%%%%%%%%%%%%%%%

% ----- This section handles the generalized ERFA calculations ----

if isPA  %  phased array?  If so, electronically steer.
    ang=SteeringPhasesPA(v,h,z,R,ElemLoc,f,c0); % multiply perfa pages by steering phases and sum.
    angpgvect=shiftdim((exp(-1i*ang))',-1);
    angarr=repmat(single(angpgvect),[lmaxerfa,mmaxerfa,1]);
    serfa=sum(perfa.*angarr,3); % summed perfa.
    serfa=serfa*sqrt(Pr);   % adjust for total radiated power since perfa normalized to 1 W.
    clear angarr % to free memory.
else serfa=perfa*sqrt(Pr);   % solid transducer, so no need to consider phase.  Adjust power as above.
end
%clear perfa angarr  % to free memory. Uncomment if load line uncommented above and in loadERFA.

% Interpolate summed erfa onto smaller grid to match pp. Note conj to account for R-S.  phasor_interp2 is custom.
ppe=conj(phasor_interp2(xaxiserfaoffs,yaxiserfaoffs,serfa,xaxisinterp,yaxisinterp','*linear',0)); 
ferfa=fftshift(fft2(ppe));   % into freq domain to allow propagation to a different distance between ERFA and model.

% These next lines change the distance from the ERFA plane to front face of Modl, depending on gui input.
    % Note that mmax is the max x index, lx is the extent of model in x in meters, and bprime is the mean
    % propagation constant.
emdist=d-sx;  % distance to propagate from ERFA plane to front of Modl; okay to be negative.
bprimeerfa=2*pi*f/c0;  % region in front of Modl is water, so mean bprime = omega/c0.
alpha=((1:mmax)-ceil(mmax/2))*(2*pi/(bprimeerfa*lx));   % vector of alpha in water (so use bprimeerfa).
beta=((1:lmax)-ceil(lmax/2))*(2*pi/(bprimeerfa*ly));         % vector of beta in water.
[alpha_sq,  beta_sq] = meshgrid(alpha.^2, beta.^2);   % lmax by mmax matrices for water transfer function.
expon=1 - alpha_sq - beta_sq;   % inside sqrt part of exponent in transfer function below. When expon neg,  
     % evanescent waves will decay for positive emdist, but will blow up in the backward direction for negative 
     % emdist. So the next lines filter out those evanescent waves. (Note: Since the direction cosines alpha = 
     % fx times lambda and beta = fy times lambda, alpha and beta can be > 1 for high spatial frequencies caused 
     % by spatial details that are < lambda. Then 1 - alpha_sq - beta_sq will be negative and transfer function will 
     % result in decaying expon waves for positive emdist, but increasing waves for neg emdist.)
if emdist<0
    transferfa=zeros(lmax,mmax);
    ind2=find(expon>0);
    transferfa(ind2)=exp(1i*bprimeerfa*emdist*sqrt(expon(ind2)));
else
    transferfa=exp(1i*bprimeerfa*emdist*sqrt(expon));
end
pp=ifft2(ifftshift(ferfa.*transferfa));  % pressure matrix at front face of model.
 
%  -------- This section initializes for HAS calculations ----------

% Preallocate memory of 3D variables inside loop for speed; also make single precision.
    % These 3D variables used later in calculations or debugging, but some variables are 2D to save memory.  
    cmodl=zeros(size(Modl),'single');   % speed of sound; needed for ARFI calculation (but could recalc if mem tight)
    absmodl=zeros(size(Modl),'single');  % absorption; needed for ARFI and Q calculation (could recalc if mem tight)
    Z=zeros(size(Modl),'single');       % acoustic  impedance; needed for ARFI and Q calculation (could recalc).
    Refl=zeros(size(Modl),'single');    % reflection coefficient; saved for backward wave calculation (could recalc).
sqrtexpon=zeros(size(Modl),'single');  % sqrt(1-alpha_sqr-beta_sqr); used in transf, r and rp.
transf=zeros(size(Modl),'single');  % transfer function; needed for backward wave propagation.
Aprime=zeros(size(Modl),'single');    % angular spectra; used for debugging with pout=Aprime (could make matrix)
Aprimeback=zeros(size(Modl),'single');  % ditto
pfor=zeros(size(Modl),'single');	% pressure array, forward propagation.
pfortot=zeros(size(Modl),'single');	% initialize accumulated pressure array, forward propagation.
pref=zeros(size(Modl),'single');        % back reflection
pref2=zeros(size(Modl),'single');       % forward reflection
pprime=zeros(size(Modl),'single');      % after passage through thin space-domain layer.
pback=zeros(size(Modl),'single');         % pressure array, back propagation.
pbacktot=zeros(size(Modl),'single');       % initialize accumulated pressure array, back propagation.
Q=zeros(size(Modl),'single');      % power deposition pattern.
bprime=zeros(1,nmax);   % vector of mean propagation coefficient.

% TempA=zeros(size(Modl),'single');    % angular spectra after propagation, to test for evanescent decay.

dx=Dx/1000;   dy=Dy/1000;   dz=Dz/1000; % convert to meter units (lowercase in meters);

% --------- Approach C to model scattering; this assumes random variation > voxel size -----------------
if max(randvc)~=0   % do next lines only if there will be scattering due to non-zero std dev of parameters.
% The next lines can modify pprimeterm such that there is random spatial variation in overall propagation in space:
    rrandcrs=1:corrl:lmax+corrl; % rrandcrs is a course row (vector) grid for the random parameter variation, etc,
    crandcrs=1:corrl:mmax+corrl; % where corrl is correlation length (in indices) of the random variation.
    prandcrs=1:corrl:nmax+corrl;
    randarrcrs=ones(length(rrandcrs),length(crandcrs),length(prandcrs)); % make a course grid array, spacing = corrl.
    randarrcrs=single(randn(size(randarrcrs))); %array now contains normal random numbers: mean = 0, std dev = 1.
    [cfine,rfine,pfine]=meshgrid(1:mmax,1:lmax,1:nmax); % define indices of final finer array of random numbers.
    randarrfine=interp3(crandcrs,rrandcrs,prandcrs,randarrcrs,cfine,rfine,pfine,'*linear'); %interp to finer array.
    vararray=abs(1+randvc(Modl).*randarrfine); % array of random variation around 1, never negative due to abs.
else vararray=ones(size(Modl),'single'); % if no scattering.
end
% -----------------

if length(unique(Modl)) > min([length(c),length(a),length(aabs),length(rho),length(randvc)])...
        || length(a) ~= length(aabs)
 errordlg('The number of media types in the acoustic parameter files does not match the number of media in Modl')
return; end

% Populate 3D property arrays; convert units from [Np/cm*MHz] to [Np/m]; assume linear in f [in MHz].
absmodl=aabs(Modl)*1e2*fMHz;    % aabs(i) is pressure absorption coefficient (no random variation in it now).
cmodl=c(Modl);    %  speed of sound (no random variation in it now).
if min(min(min(cmodl)))==0; error ('Some speed of sound values are zero.'); end
    
% Set up values for (virtual) layer 0 -- assume water in region in front of modl.
A0=fftshift(fft2(pp));    % pp is pressure pattern on front plane of modl.
bprime0=2*pi*f/c0;    % layer 0 is water, so average bprime0 = omega/c0 (same as bprimeerfa).
Z0=rho0*c0;   % impedance of water.

% close(hwb);   % close initialization wait bar

%%%% GUI CODE %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%numrefl=get(handles.popupmenu1,'value');  numrefl=numrefl-1;  % number indicating how many reflections to do;
                                        % 'value' in popupmenu is position on list; since zero is first position on list, subtract 1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% GUI CODE %%%%%%%%%%%%%%%%%%%%%%%%

numrefl = 1; 
 nr= 0;     % number indicating what reflection is being done in multiple reflections.
%  Pbeam=zeros(nmax,numrefl+2,'single');      % preallocate memory for Pbeam vectors.
                                                                                           
%  ======== Start of Multiple Reflection 'for' loop ===============================                                                                                            
                                                                                            
for loop = 1:1:(numrefl/2) +1
    
%----- Start of forward increment in n (slice number) ( + z propagation direction) -------------
%hwb1=waitbar(0,['Calculating Forward Propagation -----> Reflection #', num2str(nr)]); 
for n=1:nmax
    
  if nr==0     % first loop through forward propagation section (0 reflections):
         
    % Set up 2D acoustic property matrices (to save memory) for this particular plane:
    attmodl=a(Modl(:,:,n))*1e2*fMHz;     % a(i) is pressure total attenuation coefficient (assume linear freq depend). 
    rhomodl=rho(Modl(:,:,n));  % rho is density.
    % scattmodl=attmodl-absmodl(:,:,n);    % pressure scatt coefficient = atten - abs. REVISIT later.

	b=2*pi*f./cmodl(:,:,n);    % 2D matrix of propagation constant.
    Z(:,:,n)=rhomodl.*cmodl(:,:,n).*(1-1i*attmodl./b);% impedance of layer n (slightly complex-be careful in P calcs).
        if n==1   
            Refl(:,:,1)=(Z(:,:,1) - Z0)./(Z(:,:,1) + Z0);     % layer 1 exception.
            pforb=pp.*(1+Refl(:,:,1));   %  pforb due to source pressure pattern pp.
                                                          %  pforb--sim to pbackb--added 3/10/17; see "Latest Diagram....
        else 
            Refl(:,:,n)=(Z(:,:,n) - Z(:,:,n-1))./(Z(:,:,n) + Z(:,:,n-1));  % pressure reflection coeficient from layer n.
            pref(:,:,n-1)=Refl(:,:,n).*pfor(:,:,n-1);   % reflected pressure from forward propagation.
            pforb=pfor(:,:,n-1).*(1+Refl(:,:,n));     
        end
    bprime(n)=sum(sum(abs(pforb).*b))./sum(sum(abs(pforb)));    % mean propagation constant, 
                                                    % averaged over entire plane area, weighted by expected beam region.
    alpha=((1:mmax)-ceil(mmax/2))*(2*pi/(bprime(n)*lx));   % vector of alpha for this layer.
    beta=((1:lmax)-ceil(lmax/2))*(2*pi/(bprime(n)*ly));         % vector of beta. See earlier comments on alpha, beta.
    [alpha_sq,  beta_sq] = meshgrid(alpha.^2, beta.^2);   % lmax by mmax matrices for transfer function (and r, rp).
    sqrtexpon(:,:,n) = sqrt(1 - alpha_sq - beta_sq);  % sqrt part of exponent in transfer function and in r, rp below.
              % (Even if it is imag when arg negative, evanescent waves will decay since bprime and dz always pos).
    transf(:,:,n)=exp(1i*bprime(n).*dz.*sqrtexpon(:,:,n));
    
    r = dz./sqrtexpon(:,:,n);    % oblique path length as function of cos of angles (alpha, beta), for atten and abs.
    rp = dz.*sqrtexpon(:,:,n);    % phase path length as function of cos of angles (alpha, beta), for phase change.
    complex_idx = imag(rp) > 0;
    rp(complex_idx) = 0; r(complex_idx) = 0;  % to avoid exp increasing when r's are complex and dbvect is neg.

    bvect = 2*pi*f./c;     % propagation constant vector; length = number of media types in model (units 1/m).
    avect = a*1e-4*f;   % attenuation vector; length = number of media types in model (units Np/m) (linear freq dep).
    dbvect = bvect - bprime(n);  % excess of media prop constant over mean prop constant (bprime); can be neg.    
    
  else   % second or later loop through forward propagation section (two or more reflections):
      A0=ones(size(pp));
      if n==1   % layer 1 exception
          pforb=pref2(:,:,1);
      else
          pref(:,:,n-1)=Refl(:,:,n).*pfor(:,:,n-1);   % reflected pressure from forward propagation.
          pforb=pfor(:,:,n-1).*(1+Refl(:,:,n)) + pref2(:,:,n);
      end
      
  end   % end of separating first loop from later loops.
  
    %  These next lines do full numerical integration of the exponential propagation in the space domain, 
        %  weighted by A (see Eq. 4, Working Notes1, 5/8/06, revised 4/29/16).
    pprimeterm = NaN(1,length(a));  % preallocate vector; use NaN to detect error if pprimeterm not fully found.
    for kk = unique(Modl(:,:,n))'     % find media type integers in this layer of the Modl (note col vector).
        if n==1 || sum(sum(abs(A)))==0
            Asum=sum(sum(abs(A0)));     %  Asum is used to normalize weighted exponentials; layer 1 exception here.
            pprimeterm(kk)=sum(sum(exp(1i*dbvect(kk).*rp).*(exp(-avect(kk).*r)).*abs(A0)))/Asum;
            ratio_r2dz=(sum(sum(r.*abs(A0)))./Asum)/dz;
        else
            Asum=sum(sum(abs(A)));       % A is an lmax by mmax matrix of ang spectrum, found in previous layer.      
            pprimeterm(kk)=sum(sum(exp(1i*dbvect(kk).*rp).*(exp(-avect(kk).*r)).*abs(A)))/Asum;
                % Note that r is used for oblique path length in attenuation calculation; also in Q calculation next.
            ratio_r2dz=(sum(sum(r.*abs(A)))./Asum)/dz;  % ratio of angle-averaged path length r to dz, for Q calc. 
        end
    end
    pprime=pforb.*pprimeterm(Modl(:,:,n)).*vararray(:,:,n); % space-domain effects; vary by random amt (Approach C).
    
    I = real((pprime.*conj(pprime))./(2*Z(:,:,n)));  % I = psquared/2Z is the intensity pattern in this plane (save?).
    Q(:,:,n) = Q(:,:,n) + 2*absmodl(:,:,n).*I*ratio_r2dz; % Q = 2alpha*I*dr/dz; new last term. Accumulate reflections.
   
    Aprime(:,:,n) = single(fftshift(fft2(pprime)));	% complex Eq (8); wraparound fft.
    A = Aprime(:,:,n).*transf(:,:,n);	   % Eq (9rev).
    pmat = single(ifft2(ifftshift(A)));	  % Eq (10).
    
%     TempA(:,:,n) = A;   % temporary storage of A for debugging.
    
%     % --Approach B to implicitly model forward scattering due to scatterers < voxel size adds the next four lines--
%     if max(a-aabs)~=0    % do only if there will be scattering due to difference between abs and attenuation.
%         randphasemat=2*pi*(rand(lmax,mmax));   % matrix of uniformly distributed random phase shifts 0 to 2pi.
%         pmat=pmat+ pmat.*sqrt(dz*scattmodl).*exp(1i*randphasemat);   % add scatter component into pressure.
%     end
   
    pfor(:,:,n)=pmat;
	%waitbar(n/nmax)
end
% --------- End of forward propagation --------------------------
%close(hwb1);
nr=nr+1;
%   Pbeam(:,nr)=squeeze(sum(sum(abs(pfor(:,:,:).*conj(pfor(:,:,:))./(2*Z(:,:,:))))))*dx*dy;   % for later analysis.
pfortot=pfortot + pfor;  % accumulate pfor; could also add at each n slice to eliminate pfor array for memory savings.

if nr==numrefl + 1       % Branch out of loop if next backward propagation not needed.
    break
end

%------------ Start of backward increment in n (slice number) ( - z propagation direction) -------------

   % hwb2=waitbar(1,['<----- Calculating Backward Propagation, Reflection #', num2str(nr)]);
    pback(:,:,nmax)=0;   % set up conditions for nmax layer.
    A=0;

    for n=(nmax-1):-1:1     % start at nmax-1 since pref=0 at last boundary.
        pbackb=pback(:,:,n+1).*(1-Refl(:,:,n+1)) + pref(:,:,n);  % add transmitted backward wave to reflected wave.
                                                                         % Note neg Refl since in opposite direction; Refl calculated earlier.
        
    % Assume that bprime(n) is the same as in forward increments (so sqrtexpon is the same) and no need
    %     to recalculate the following, restated here just for reference; bvect and avect are also same as earlier.
    %
    % r = dz./sqrtexpon(:,:,n);    % oblique path length as function of cos of angles (alpha, beta).
    % p = dz.*sqrtexpon(:,:,n);    % phase path length as function of cos of angles (alpha, beta).
    % complex_idx = imag(rp) > 0;
    % rp(complex_idx) = 0; r(complex_idx) = 0;  % to avoid exp increasing when r's are complex and dbvect is neg.
    % dbvect = bvect - bprime(n);  % excess of media prop constant over mean prop constant (bprime); can be neg.
        
        %  These next lines do full numerical integration of the exponential propagation in the space domain, 
            %  weighted by A (see Eq. 4, Working Notes1, 5/8/06, revised 4/29/16).
        pprimeterm = NaN(1,length(a));  % preallocate vector; use NaN to detect error if pprimeterm not fully found.
        for kk = unique(Modl(:,:,n))'     % find media type integers in this layer of the Modl (note col vector).
            if A==0 
                pprimeterm(kk)=1;       % to avoid dividing by zero.
                ratio_r2dz=1;       % since A=0, no angular spread.
            else
                Asum=sum(sum(abs(A))); % A is lmax by mmax matrix of ang spectrum, found in previous loop cycle.
                pprimeterm(kk)=sum(sum(exp(1i*dbvect(kk).*rp).*(exp(-avect(kk).*r)).*abs(A)))/Asum;
                ratio_r2dz=(sum(sum(r.*abs(A)))./Asum)/dz;
            end
        end
        
        pbackprime=pbackb.*pprimeterm(Modl(:,:,n)).*vararray(:,:,n);     % backward prop in space domain.
        
        I = real((pbackprime.*conj(pbackprime))./(2*Z(:,:,n)));  %  intensity pattern in this plane for backward prop.
        Q(:,:,n) = Q(:,:,n) + 2*absmodl(:,:,n).*I*ratio_r2dz; %  accumulate reflections.
    
        Aprimeback(:,:,n)=single(fftshift(fft2(pbackprime)));	  % complex Eq (8); wraparound fft.
        A=Aprimeback(:,:,n).*transf(:,:,n);	    % Eq (9rev) in reverse direction.
        pmat=single(ifft2(ifftshift(A)));	% Eq (10).

%         % --Approach B to model backward scattering adds next four lines--
%         if max(a-aabs)~=0   % do only if there will be scattering due to difference between abs and attenuation.
%             randphasemat=2*pi*(rand(lmax,mmax)); % matrix of uniformly distributed random phase shifts 0 to 2pi.
%             pmat=pmat+ pmat.*sqrt(dz*scattmodl).*exp(1i*randphasemat); % add scatter into pressure.
%         end
   
    pback(:,:,n)=pmat;
    pref2(:,:,n)=-Refl(:,:,n).*pback(:,:,n);    % Note negative Refl since in opposite direction.
    %waitbar(n/nmax)
    end
    % ------- End of backward propagation -----------------
    
   % close(hwb2);
    nr = nr +1;   % get ready for next loop
%     Pbeam(:,nr)=squeeze(sum(sum(abs(pback(:,:,:).*conj(pback(:,:,:))./(2*Z(:,:,:))))))*dx*dy;   % for later analysis.
    pbacktot=pbacktot + pback;
end
% ================ End of Multiple Reflection 'for' loop ======================

ptot=pfortot+pbacktot;    % complex add forward and backward waves.
% These next lines are for later analysis of power profiles, if desired.
%     Pbeam(:,nr+1)=squeeze(sum(sum(abs(pfortot(:,:,:).*conj(pfortot(:,:,:))./(2*Z(:,:,:))))))*dx*dy;   
%     Pbeam(:,nr+2)=squeeze(sum(sum(abs(pbacktot(:,:,:).*conj(pbacktot(:,:,:))./(2*Z(:,:,:))))))*dx*dy;  
%     Pbeam(:,nr+3)=squeeze(sum(sum(abs(ptot(:,:,:).*conj(ptot(:,:,:))./(2*Z(:,:,:))))))*dx*dy;  
%     for fign=1:nr+3     % for plotting the beam powers at each loop, plus the overall beam power profiles:
%         figure; plot(Pbeam(:,fign))
%     end

 % I=((ptot.*conj(ptot))./(2*abs(Z)));  % total 3D intensity if desired; overwrite individual intensities.
 %Q=real(absmodl.*ptot.*conj(ptot./Z)); % power deposition. (Assumes only dz path length - Legacy).
maxQ=max(Q(:));
pout=ptot;      % NOTE: Can use gui to view any array by loading that array into base workspace with name 'pout'.
maxpout=max(abs(pout(:)));   % this is also redundantly done in plotx7, ploty7 and plotz7 for convenience.

%toc

%set(handles.listbox1,'value',2);    % view pressure pattern.
%displa7
