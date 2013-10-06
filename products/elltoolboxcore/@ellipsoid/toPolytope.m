function poly = toPolytope(varargin)
% TOPOLYTOPE - for ellipsoid ell makes polytope object represanting the
%              boundary of ell
%
% Input:
%   regular:
%       ell: ellipsoid[1,1] - ellipsoid in 3D or 2D.
%   optional:
%       nPoints: double[1,1] - number of boundary points.
%                Actually number of points in resulting
%                polytope will be ecual to lowest
%                number of points of icosaeder, that greater
%                than nPoints.
%
% Output:
%   regular:
%       poly: polytope[1,1] - polytop in 3D or 2D.
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
ell = varargin{1};
checkvar(ell, @(x) isa(x,'ellipsoid') && numel(x) == 1&&...
    (dimension(x) == 3 || dimension(x) == 2), 'errorTag', 'wrongInput',...
    'errorMessage','First argument must be ellipsoid in 3D or 2D');
%
%
%
[vMat,fMat] = getBoundary(ell,varargin{2:end});
nDims = size(vMat,2);
nFaces = size(fMat,2);
if nDims == 2
    for iFaces = 1:nFaces
        if(iFaces == nFaces)
            index = 1;
        else
            index = iFaces + 1;
        end
        ResizedfMat(iFaces,1) = fMat(iFaces);
        ResizedfMat(iFaces,2) = fMat(index);
    end
else
    ResizedfMat = fMat;
end
poly = elltool.exttbx.mpt.gen.tri2polytope(vMat,ResizedfMat);
