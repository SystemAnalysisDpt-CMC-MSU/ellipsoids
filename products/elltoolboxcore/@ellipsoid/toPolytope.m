function polyVec = toPolytope(ellVec, depth)
% TOPOLYTOPE --   for each ellipsoid in ellVec makes polytope
%                 object represanting the triangulation of
%                 unit ball in 3D, after affine transform: 
%                 y = shMat*x + cVec
%                 Where shMat and cVec are shape matrix of
%                 and center vector of ellipsoid.
%                 
% Input:
%   regular: 
%       ellVec: ellipsoid[1,n] - vector of  ellipsoids in 3D.
%       depth: double[1,1] - the depth of triangulation.
% Output:
%   regular:
%       poly: polytope[1,n] - vector of polytopes in 3D.
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
checkvar(ellVec, @(x) isa(x,'ellipsoid') && (size(x,1) == 1)&&...
    all(dimension(x) == 3), 'errorTag', 'wrongInput', 'errorMessage',...
    'First arggument must be vector of ellipsoids in 3D');
%
[vMat,fMat] = gras.geom.tri.spheretri(depth);
basePoly = elltool.exttbx.mpt.gen.tri2polytope(vMat,fMat);
for iEll = 1:numel(ellVec)
    [cVec shMat] = double(ellVec(iEll));
    sqrtMat = gras.la.sqrtmpos(shMat);
    polyVec(iEll) = (sqrtMat*basePoly) + cVec;
end
