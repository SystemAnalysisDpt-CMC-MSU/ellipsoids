 function poly = tri2polytope(vMat,fMat)
% TRI2POLYTOPE -- makes polytope object represanting the 
%                 triangulation of convex nondegenerate 
%                 object in 3D or 2D. 
% 
% Input:
%       regular: 
%           vMat: double[nVerts,3]/double[nVerts,2] - (x,y,z) coordinates
%                 of triangulation
%                 vertices
%           fMat: double[nFaces,3]/double[1,nFaces] - indices of face 
%                 verties in vertMat. 
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
checkvar(vMat,@(x) isa(x,'double')&&(size(x,2) == 3 || size(x,2) == 2),...
     'errorTag','wrongInput','errorMessage',...
    'Matrix of vertices must be matrix from R^nx3.');
%
nFaces = size(fMat,1);
nDims = size(vMat,2);
normMat = zeros(nDims,nFaces);
constVec = zeros(1,nFaces);
%
for iFaces = 1:nFaces
    if nDims == 3
        normalVec = (cross(vMat(fMat(iFaces,3),:) - ...
            vMat(fMat(iFaces,2),:),vMat(fMat(iFaces,3),:) -...
            vMat(fMat(iFaces,1),:)))';
        notInFacetNum = getNumNotIn(fMat(iFaces,:));
    else
        if iFaces == nFaces
            num = 1;
        else 
            num = iFaces+1;
        end
        normalVec = null(vMat(fMat(num),:)-vMat(fMat(iFaces),:));
        notInFacetNum = getNumNotIn([fMat(num); fMat(iFaces)]);
    end
    const = vMat(fMat(iFaces,1),:)*normalVec;
    lessConst = vMat(notInFacetNum,:)*normalVec;
    if const < lessConst
        normalVec = -normalVec;
        const = -const;
    end
    %
    constVec(iFaces) = const;
    normMat(:,iFaces) = normalVec;
    %
end
%
poly = polytope(normMat',constVec');

function num = getNumNotIn(numVec)
if all(numVec ~= 1)
    num = 1;
elseif all(numVec ~= 2)
    num = 2;
elseif all(numVec ~= 3)
    num = 3;
else
    num = 4;
end
