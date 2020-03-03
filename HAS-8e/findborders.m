function Markedslice=findborders(Modlslice)
% A function that puts nonzero integers in all pixels of a given slice of the
% Modl that has a different media on any of its four sides.  This will be
% used as a patch to avoid pressure leakage into the sides of any bone/marrow
% voxel when modelling microCT bone.
Mdif1=diff(Modlslice,1,1); % takes difference in media numbers upward.
Mdif2=[Mdif1;zeros(1,size(Mdif1,2))]; % puts zeros at bottom of diff matrix.
Mdif3=[zeros(1,size(Mdif1,2));Mdif1]; % also moves diff matrix down one row.
Mdify=abs(Mdif2) + abs(Mdif3); % adds the two matrices but avoids subtraction.
Mdif1=diff(Modlslice,1,2); % now takes difference in media numbers right->left.
Mdif2=[Mdif1,zeros(size(Mdif1,1),1)]; % puts zeros on far right col of diff matrix.
Mdif3=[zeros(size(Mdif1,1),1),Mdif1]; % also moves diff matrix to the right one col.
Mdifx=abs(Mdif2) + abs(Mdif3); % adds the two matrices but avoids subtraction.
Markedslice=Mdify + Mdifx;