function [vMat,fMat]=spheretri(depth)
% SPHERETRI builds a triangulation of a unit sphere based on recursive
% partitioning each of Icosahedron faces into 4 triangles with vertices in
% the middles of original face edgeMidMat
%
% Input:
%   depth: double[1,1] - depth of partitioning, use 1 for the first level of
%       Icosahedron partitioning, and greater value for a greater level
%       of partitioning
%
% Output:
%   vMat: double[nVerts,3] - (x,y,z) coordinates of triangulation
%       vertices
%   fMat: double[nFaces,3] - indices of face verties in vertMat
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-27$ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
import gras.geom.tri.*;
if ~(numel(depth)&&isnumeric(depth)&&depth>=0&&fix(depth)==depth)
    modgen.common.throwerror('wrongInput',...
        'depth is expected to be a not negative integer scalar');
end
[vMat,fMat]=icosahedron();
[vMat,fMat]=shrinkfacetri(vMat,fMat,0,depth,@normvert);
end
function x=normvert(x)
x=x./repmat(realsqrt(sum((x.*x),2)),1,3);
end