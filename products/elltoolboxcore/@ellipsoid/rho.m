function [supArr, bpMat] = rho(ellArr, dirsMat)
%
% RHO - computes the values of the support function for given ellipsoid
%	and given direction.
%
%	supArr = RHO(ellArr, dirsMat)  Computes the support function of the 
%       ellipsoid ellArr in directions specified by the columns of matrix 
%       dirsMat. Or, if ellArr is array of ellipsoids, dirsMat is expected 
%       to be a single vector.
%
%	[supArr, bpMat] = RHO(ellArr, dirstMat)  Computes the support function 
%       of the ellipsoid ellArr in directions specified by the columns of 
%       matrix dirsMat, and boundary points bpMat of this ellipsoid that 
%       correspond to directions in dirsMat. Or, if ellArr is array of 
%       ellipsoids, and dirsMat - single vector, then support functions and 
%       corresponding boundary points are computed for all the given 
%       ellipsoids in the array in the specified direction dirsMat.
%
%	The support function is defined as
%   (1)  rho(l | E) = sup { <l, x> : x belongs to E }.
%	For ellipsoid E(q,Q), where q is its center and Q - shape matrix,
%   it is simplified to
%   (2)  rho(l | E) = <q, l> + sqrt(<l, Ql>)
%   Vector x, at which the maximum at (1) is achieved is defined by
%   (3)  q + Ql/sqrt(<l, Ql>)
%
% Input:
%   regular:
%       ellArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - array
%           of ellipsoids.
%       dirsMat: double[nDim,nDirs]/[nDim,1] - matrix of directions.
%
% Output:
%	supArr: double [nDims1,nDims2,...,nDimsN]/[1,nDirs] - support function 
%       of the ellArr in directions specified by the columns of matrix 
%       dirsMat. Or, if ellArr is array of ellipsoids, support function of
%       each ellipsoid in ellArr specified by dirsMat direction.
%
%   bpMat: double [nDim,nDims1*nDims2*...*nDimsN]/[nDim,nDirs] - matrix of
%       boundary points
% 
% Example:
%   ellObj = ellipsoid([-2; 4], [4 -1; -1 1]);
%   dirsMat = [-2 5; 5 1];
%   suppFuncVec = rho(ellObj, dirsMat)
% 
%   suppFuncVec =
% 
%       31.8102    3.5394
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regesnts of the University of California 
%              2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

import modgen.common.checkmultvar;

ellipsoid.checkIsMe(ellArr,'first');
modgen.common.checkvar(dirsMat, @(x)isa(x,'double'),...
    'errorMessage','second argument must be matrix of direction vectors.');
checkmultvar('isscalar(x1)||(size(x2,2)==1)',...
    2,ellArr, dirsMat, 'errorMessage',...
    'arguments must be single ellipsoid or single direction vector.');

[nDim, nDirs] = size(dirsMat);
isOneEll = isscalar(ellArr);

nDimsArr = dimension(ellArr);
checkmultvar('all(x2==x1)',2,nDim,nDimsArr(:), 'errorMessage',...
    'dimensions mismatch.');

if ~isOneEll % multiple ellipsoids, one direction
    [resCArr xCArr] =arrayfun(@(x) fSingleRhoForOneDir(x),ellArr,...
        'UniformOutput',false);
    supArr = cell2mat(resCArr);
    bpMat= horzcat(xCArr{:});
else % one ellipsoid, multiple directions
    qVec = ellArr.centerVec;
    shMat = ellArr.shapeMat;
    [~, absTol] = getAbsTol(ellArr);
    dirsCVec = mat2cell(dirsMat,nDim,ones(1,nDirs));
    
    [resCArr xCArr] =cellfun(@(x) fSingleRhoForOneEll(x),dirsCVec,...
        'UniformOutput',false);
    supArr = cell2mat(resCArr);
    bpMat = cell2mat(xCArr);
end

    function [supFun xVec] = fSingleRhoForOneDir(singEll)
        cVec  = singEll.centerVec;
        shpMat  = singEll.shapeMat;
        [~, singAbsTol] = getAbsTol(singEll);
        sq = max(realsqrt(dirsMat'*shpMat*dirsMat), singAbsTol);
        supFun = cVec'*dirsMat + sq;
        xVec =((shpMat*dirsMat)/sq) + cVec;
    end
    function [supFun xVec] = fSingleRhoForOneEll(lVec)
        sq  = max(realsqrt(lVec'*shMat*lVec), absTol);
        supFun = qVec'*lVec + sq;
        xVec = ((shMat*lVec)/sq) + qVec;
    end
end
