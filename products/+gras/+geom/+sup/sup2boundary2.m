function xBoundMat=sup2boundary2(dirMat,supVec)
% SUP2BOUNDARY2 approximates aMat boundary of 3d set using aMat support
% function values defined for the directions from aMat triangulated unit
% sphere
%
% Input:
%   regular:
%       dirMat: double[nDirs,2] - directions for on which support function
%           is defined
%       supVec: double[nDirs,1] - support function values
%
% Output:
%   xBoundMat: double[nFaces,2] - approximated coordinates of points 
%       on set boundary
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-30 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
nDirs=size(dirMat,1);
xBoundMat=zeros(2,nDirs);
for iDir=1:nDirs-1
    xBoundMat(:,iDir)=dirMat([iDir iDir+1],:)\supVec([iDir,iDir+1]);
end;
xBoundMat(:,end)=dirMat([nDirs 1],:)\supVec([nDirs,1]);
xBoundMat=transpose(xBoundMat);