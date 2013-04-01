absTol = elltool.conf.Properties.getAbsTol();
% find out which of the directions in dirsMat are bad
firstEll.isbaddirection(fourthEll, dirsMat, absTol)  

% ans =
% 
%      1     0     0     1     0 


% two of five directions specified by dirsMat are bad,
% so, only three ellipsoidal approximations 
% can be produced for this dirsMat:
externalEllArr = firstEll.minkdiff_ea(fourthEll, dirsMat) 

% externalEllAr =
% 1x3 array of ellipsoids.

internalEllArr = firstEll.minkdiff_ia(fourthEll, dirsMat)

% internalEllArr =
% 1x3 array of ellipsoids.