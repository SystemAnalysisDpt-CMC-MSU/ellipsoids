function xBoundMat=sup2boundary3(dirMat,supVec,faceMat)
% SUP2BOUNDARY3 approximates aMat boundary of 3d set using aMat support
% function values defined for the directions from aMat triangulated unit
% sphere
%
% Input:
%   regular:
%       dirMat: double[nDirs,3] - directions for on which support function
%           is defined
%       supVec: double[nDirs,1] - support function values
%
%       faceMat: double[nFaces,3] - faces composing aMat triangulation of aMat
%           unit sphere on which dirMat is defined
%
% Output:
%   xBoundMat: double[nFaces,3] - approximated coordinates of points 
%       on set boundary
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-30$ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
nFaces=size(faceMat,1);
xBoundMat=zeros(3,nFaces);
for iFace=1:1:nFaces
    xBoundMat(:,iFace)=dirMat(faceMat(iFace,:),:)\supVec(faceMat(iFace,:));
end
xBoundMat=xBoundMat.';
