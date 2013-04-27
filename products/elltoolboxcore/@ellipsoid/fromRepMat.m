function ellArr = fromRepMat(varargin)
% FROMREPMAT - returns array of equal ellipsoids the same
%              size as stated in sizeVec argument
%
%   ellArr = fromRepMat(sizeVec) - creates an array  size 
%            sizeVec of empty ellipsoids.
%   
%   ellArr = fromRepMat(shMat,sizeVec) - creates an array  
%            size sizeVec of ellipsoids with shape matrix 
%            shMat.
%   
%   ellArr = fromRepMat(cVec,shMat,sizeVec) - creates an
%            array size sizeVec of ellipsoids with shape 
%            matrix shMat and center cVec.
%
% Input:
%   Case1:
%       regular: 
%           sizeVec: double[1,n] - vector of size, have 
%           integer values.
%
%   Case2:
%       regular:
%           shMat: double[nDim, nDim] - shape matrix of 
%           ellipsoids. 
%           sizeVec: double[1,n] - vector of size, have 
%           integer values.
%
%   Case3:
%       regular:
%           cVec: double[nDim,1] - center vector of 
%           ellipsoids
%           shMat: double[nDim, nDim] - shape matrix of 
%           ellipsoids. 
%           sizeVec: double[1,n] - vector of size, have 
%           integer values.
%
%   properties:
%       absTol: double [1,1] - absolute tolerance with default
%           value 10^(-7)
%       relTol: double [1,1] - relative tolerance with default
%           value 10^(-5)
%       nPlot2dPoints: double [1,1] - number of points for 2D plot
%           with default value 200
%       nPlot3dPoints: double [1,1] - number of points for 3D plot
%           with default value 200.
%
% $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $ 
% $Date: <april> $
% $Copyright: Moscow State University,
% Faculty of Computational Mathematics and 
% Computer Science, System Analysis Department <2013> $
%

import modgen.common.checkvar;
%
if nargin > 3
    indVec = [1:2,4:nargin];
    sizeVec = varargin{3};
else
    sizeVec = varargin{nargin};
    indVec = [1:nargin-1];
end
%
checkvar(sizeVec,@(x) isa(x,'double')&&all(isreal(x(:)))&&...
    all(mod(x(:),1) == 0) && all(x(:) > 0) && (size(x,1) == 1),...
    'errorTag','wrongInput','errorMessage',...
    'size array must contain positive integer values.');
%
nEllipsoids = prod(sizeVec);
ellArr(nEllipsoids) = ellipsoid();
% 
ell = ellipsoid(varargin{indVec});
arrayfun(@(x)makeEllipsoid(x),1:nEllipsoids);
ellArr = reshape(ellArr,sizeVec);
%
function makeEllipsoid(index)
    ellArr(index) = getCopy(ell);
end
end
        