function poly = tri2polytope(vMat,fMat)
% TRI2POLYTOPE -- makes Polyhedron object represanting the
%                 triangulation of convex nondegenerate
%                 object in 3D or 2D.
%
% Input:
%       regular:
%           vMat: double[nVerts,3]/double[nVerts,2] - (x,y,z) coordinates
%                 of triangulation
%                 vertices
%           fMat: double[nFaces,3]/double[nFaces,2] - indices of face
%                 verties in vertMat.
%
% Output:
%       regular:
%           poly: Polyhedron[1,1] in 3D
%
% $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $
% $Date: <april> $
% $Copyright: Moscow State University,
% Faculty of Computational Mathematics and
% Computer Science, System Analysis Department <2013> $
%
%
import modgen.common.checkvar;
import modgen.common.throwerror;
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
nDims = size(vMat,2);
nFaces = size(fMat,1);
normMat = zeros(nDims,nFaces);
constVec = zeros(1,nFaces);
%
nVertices = size(vMat,1);
for iFaces = 1:nFaces
    if nDims == 3
        firstVec = vMat(fMat(iFaces,3),:) - vMat(fMat(iFaces,2),:);
        secondVec = vMat(fMat(iFaces,3),:) - vMat(fMat(iFaces,1),:);
        normalVec = [firstVec(2) * secondVec(3) - firstVec(3) * secondVec(2) ...
            firstVec(3) * secondVec(1) - firstVec(1) * secondVec(3) ...
            firstVec(1) * secondVec(2) - firstVec(2) * secondVec(1)]';
        notInFacetNum = getNumNotIn(fMat(iFaces,:));
        
    else
        if (fMat(iFaces,2) > nVertices) || (fMat(iFaces,1) > nVertices)
            throwerror('wrongIndex','attemp to access nonexistent element');
        end
         firstVec  = vMat(fMat(iFaces,2),:)-vMat(fMat(iFaces,1),:);
        if (firstVec(1) == 0)
            normalVec = [-1 0]';
        else
            normalVec = ([-firstVec(2)/firstVec(1) 1] ./ sqrt((firstVec(2)/firstVec(1)).^2 + 1))';
        end
        notInFacetNum = getNumNotIn(fMat(iFaces,:));
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
poly = Polyhedron(normMat.',constVec.');
%
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
