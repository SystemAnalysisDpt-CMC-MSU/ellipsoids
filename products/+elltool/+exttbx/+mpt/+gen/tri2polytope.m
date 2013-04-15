 function poly = tri2polytope(depth,transfMat)
% TRI2POLYTOPE makes polytope object represanting the 
% triangulation of unit ball in 3D,transformed with
% matrix transfMat: 
% y = transfMat*x; 
% 
% Input:
%       regular: 
%           depth: double[1,1] - the depth of 
%           triangulation.
%           transfMat: double[3,3] - transformation 
%           matrix.
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
checkvar(depth,@(x) isa(x,'double')&&(numel(x) == 1)&&...
    (mod(x,1) == 0) && (x > 0), 'errorTag',...
    'wrongInput','errorMessage',...
    'depth must have positive and have integer value.');
%
checkvar(transfMat,@(x) isa(x,'double')&&all(size(x) == 3)&&...
    numel(x) == 9 , 'errorTag',...
    'wrongInput','errorMessage',...
    'transfMat must be matrix from R^3x3.');
%
[vMat,fMat]=gras.geom.tri.spheretri(depth);
nFaces = size(fMat,1);
normMat = zeros(3,nFaces);
constVec = zeros(1,nFaces);
%
for iFaces = 1:nFaces
    normMat(:,iFaces) = (cross(vMat(fMat(iFaces,3),:) - vMat(fMat(iFaces,2),:),vMat(fMat(iFaces,3),:) - vMat(fMat(iFaces,1),:)))';
    constVec(iFaces) = vMat(fMat(iFaces,3),:)*normMat(:,iFaces);
    if constVec(iFaces) < 0
        constVec(iFaces) = -constVec(iFaces);
         normMat(:,iFaces) = - normMat(:,iFaces);
    end
end
normMat = normMat'/(transfMat);%normMat = normMa*inv(transfMat)
poly = polytope(struct('H',normMat,'K',constVec'));
