function newcoord = rotcoordpiv(oldcoord,piv,axs,ang)
% A function to 3D-rotate a column vector or matrix of coordinates around a
%   pivot point (piv) by an Euler angle (ang) and Euler axis (axs).  It puts
%   Rodriques' formula into an affine 4x4 rotation/translation matrix M. 
%   (Extracted in part from AxelRot.m by Matt Jacobson via File Exchange.)

%   oldcoord = 3xn matrix of x;y;z coordinates to be rotated.
%   piv = [xp,yp,zp] row vector of pivot coordinates, NOT indices.
%   axs = [u,v,w] row vector giving direction from 0,0,0 of Euler axis of
%       rotation--does not need to be a unit vector.
%   ang = Euler angle in degrees--positive in counterclockwise direction
%   	following the RH rule.

oldcoord=[oldcoord;ones(1,size(oldcoord,2))];  %put ones in bottom row to make 4xn matrix.
R=eye(3);
u=axs(:)/norm(axs); % make unit 3x1 column vector.
x=ang;  % abbrev. angle in degrees.
for ii=1:3
    v=R(:,ii);
    R(:,ii)=v*cosd(x)+cross(u,v)*sind(x)+(u.'*v)*(1-cosd(x))*u;
        %Rodriques' formula, 3x3 rotation matrix.
end
piv=piv(:); % make 3x1 column vector.
AxisShift=piv-(piv.'*u).*u; % 3x1 column vector.
Mshift=eye(4);
Mshift(1:3,4)=-AxisShift;   % 4x4 translation matrix.
Mroto=eye(4);
Mroto(1:3,1:3)=R;   % 4x4 rotation matrix.
M=inv(Mshift)*Mroto*Mshift; % 4x4 rotation/translation matrix.
newcoord=M*oldcoord;    % 4xn matrix.
newcoord=newcoord(1:3,:);   % 3xn matrix of rotated coordinates.

