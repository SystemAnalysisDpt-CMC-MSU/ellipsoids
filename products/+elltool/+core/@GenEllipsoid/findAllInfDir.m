function [isInfVec infDirEigMat] = findAllInfDir(ellObj)
% FINDALLINFDIR - find all infinite directions of generalized ellipsoid
%
% Input:
%   regular:
%       ellObj: GenEllipsoid: [1,1] - generalized ellipsoid
%
% Output:
%   isInfVec: logical: [nDim,1] - logical vector, whose i-th component is
%       true if i-th direction in ellipsoid is infinite
%   infDirEigMat: double: [nDim,rSize] - matrix of eigenvectors of 
%       ellipsoid matrix corresponding to infinite elements
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
isInfVec=(diag(ellObj.diagMat)==Inf);
eigvMat=ellObj.eigvMat;
infDirEigMat=eigvMat(:,isInfVec);