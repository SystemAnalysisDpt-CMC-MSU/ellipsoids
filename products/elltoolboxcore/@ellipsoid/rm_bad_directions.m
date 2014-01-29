function clrDirsMat = rm_bad_directions(q1Mat, q2Mat, dirsMat,absTol)
%
% RM_BAD_DIRECTIONS - remove bad directions from the given 
%                     list. Bad directions are those which 
%                     should not be used for the support 
%                     function of geometric difference of 
%                     two ellipsoids.
%
% Input:
%   regular:
%       q1Mat: double[nDim, nDim] - shape matrix of minuend
%                                   ellipsoid
%       q2Mat: double[nDim, nDim] - shape matrix of 
%                                   subtrahend ellipsoid
%       dirsMat: double[nDim, nDirs] - matrix of of checked
%                                      directions
%       absTol: double[1,1] - absolute tolerance
%
% Output:
%   clrDirsMat: double[nDim, nClearDirs] - matrix of without
%                                          bad directions
%                                          of dirsMat
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright: The Regents of the University of California
%             2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   
% $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
isGoodDirVec=~ellipsoid.isbaddirectionmat(q1Mat,q2Mat,dirsMat,absTol);
clrDirsMat=[];
if any(isGoodDirVec)
    clrDirsMat=dirsMat(:,isGoodDirVec);
end
