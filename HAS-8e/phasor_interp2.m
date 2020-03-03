function z = phasor_interp2( X,Y,y,XI,YI,method,extrapval )

% 2D routine that more correctly interpolates complex matrices such as
%  pressure waves than does interp2.  Uses normalized input matrix to find
%  accurate phase angles.  X, XI are row vectors; Y, YI are col. vectors.
if min(y(:))==0
    zia = interp2(X,Y,y,XI,YI,method,extrapval);    % to avoid 0/0
else
    zia = interp2(X,Y,y./abs(y),XI,YI,method,extrapval);  % normalized y here only
end
za = angle(zia);  % in radians
zm = interp2(X,Y,abs(y),XI,YI,method,extrapval);
z= zm.*exp(1i*za);

end

