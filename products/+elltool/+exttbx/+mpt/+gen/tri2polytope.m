 function poly = tri2polytope(vMat,fMat)
% TRI2POLYTOPE -- makes polytope object represanting the 
%                 triangulation of convex object in 3D. 
% 
% Input:
%       regular: 
%           vMat: double[nVerts,3] - (x,y,z) coordinates of triangulation
%                 vertices
%           fMat: double[nFaces,3] - indices of face verties in vertMat
%
% Output:
%       regular:
%           poly: polytope[1,1] in 3D
%
% $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $ 
% $Date: <april> $
% $Copyright: Moscow State University,
% Faculty of Computational Mathematics and 
% Computer Science, System Analysis Department <2013> $
%
%
import modgen.common.checkvar;
%
checkvar(fMat,@(x) isa(x,'double')&&...
    all(mod(x(:),1) == 0) && all(x(:) > 0), 'errorTag',...
    'wrongInput','errorMessage',...
    'indeces must have positive and integer value.');
%
checkvar(vMat,@(x) isa(x,'double')&&all(size(x,2) == 3),...
     'errorTag','wrongInput','errorMessage',...
    'Matrix of vertices must be matrix from R^nx3.');
%
nFaces = size(fMat,1);
normMat = zeros(3,nFaces);
constVec = zeros(1,nFaces);
%
for iFaces = 1:nFaces
    normMat(:,iFaces) = (cross(vMat(fMat(iFaces,3),:) - ...
        vMat(fMat(iFaces,2),:),vMat(fMat(iFaces,3),:) -...
        vMat(fMat(iFaces,1),:)))';
    constVec(iFaces) = vMat(fMat(iFaces,3),:)*normMat(:,iFaces);
    if constVec(iFaces) < 0
        constVec(iFaces) = -constVec(iFaces);
         normMat(:,iFaces) = - normMat(:,iFaces);
    end
end
%
poly = polytope(normMat',constVec');
