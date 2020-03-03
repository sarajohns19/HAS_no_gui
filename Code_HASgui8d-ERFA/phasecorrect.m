% Loads the phases found along each ray trace from the transducer elements to the geom 
%   focus (stored in RayPhase.mat by RayTrace3D script) and adjusts the perfa file from the
%   transducer to cancel the approximated phase aberration.
%
% Copyright 2015 D.A.Christensen
% May 15, 2015

origperfa=perfa;  % save uncorrected perfa to reload later if desired.
load RayPhase.mat    % load PHtot values for each ray to geom focus.
angpgvect=shiftdim((exp(+1i*PHtot)),-1);   % vector of inverse phase shifts in page dimension.
angpgvect(isnan(angpgvect))=0;     % ignore rays that fall outside model edges (NaN angles).
angarr=repmat(single(angpgvect),[lmaxerfa,mmaxerfa,1]);  % make 3D array to mult perfa.
perfa=perfa.*angarr;    % now perfa has corrected phases for each element to run HAS.