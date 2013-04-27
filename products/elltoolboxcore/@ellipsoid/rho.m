function [supArr, bpMat] = rho(ellArr, dirsArr)
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
%       dirsMat: double[nDim,nDims1,nDims2,...,nDimsN]/
%           double[nDim,nDirs]/[nDim,1] - matrix of directions.
%
% Output:
%	supArr: double [nDims1,nDims2,...,nDimsN]/[1,nDirs] - support function
%       of the ellArr in directions specified by the columns of matrix
%       dirsMat. Or, if ellArr is array of ellipsoids, support function of
%       each ellipsoid in ellArr specified by dirsMat direction.
%
%   bpArr: double [nDim,nDims1*nDims2*...*nDimsN]/[nDim,nDirs] - matrix of
%       boundary points
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regesnts of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Author: Vitaly Baranov <vetbar42@gmail.com> $   $Date: 27-04-2013$
% $Copyright: Lomonosov Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

import modgen.common.checkmultvar;

ellipsoid.checkIsMe(ellArr,'first');
modgen.common.checkvar(dirsArr, @(x)isa(x,'double'),...
    'errorMessage','second argument must be matrix of direction vectors.');
checkmultvar(strcat('isscalar(x1)|| (length(x2)==2)&& x2(2)==1 ||',...
    '((numel(x1)==prod(x2(2:end),2))&&(size(x1,1)==1 || size(x1,2)==1)&&',...'
    '(numel(x1))==x2(2)) || all(size(x1)==x2(2:end))'),...
    2,ellArr, size(dirsArr), 'errorTag','wrongSizes','errorMessage',...
    strcat('arguments must be single ellipsoid or single direction ',...
    'vector or arrays of almost the same sizes'));
%
dirSizeVec = size(dirsArr);
ellSizeVec=size(ellArr);
isOneEll = isscalar(ellArr);
isOneDir = dirSizeVec(2)==1 && length(dirSizeVec)==2;

nDim=dirSizeVec(1);
nDimsArr = dimension(ellArr);
checkmultvar('all(x2==x1)',2,nDim,nDimsArr(:), 'errorMessage',...
    'dimensions mismatch.');

if isOneEll % one ellipsoid, multiple directions
    qVec = ellArr.centerVec;
    shMat = ellArr.shapeMat;
    [~, absTol] = getAbsTol(ellArr);
    dirsCArr=num2cell(dirsArr,1);
    %
    [resCArr xCArr] =cellfun(@(x) fSingleRhoForOneEll(x),dirsCArr,...
        'UniformOutput',false);
    supArr = cell2mat(resCArr);
    if length(dirSizeVec)>2
        supArr=reshape(supArr,dirSizeVec(2:end));
    end
    bpMat = cell2mat(xCArr);
elseif isOneDir % multiple ellipsoids, one direction
    [resCArr xCArr] =arrayfun(@(x) fSingleRhoForOneDir(x),ellArr,...
        'UniformOutput',false);
    supArr = cell2mat(resCArr);
    bpMat= horzcat(xCArr{:});
else % multiple ellipsoids, multiple directions
    augxCArr=num2cell(dirsArr,1);
    dirCArr=reshape(augxCArr(1,:),ellSizeVec);
    %
    fComposite=@(ellObj,lVec)fRhoForDir(ellObj,lVec{1});
    [resCArr xCArr]=arrayfun(fComposite,ellArr,dirCArr,...
        'UniformOutput',false);
    supArr = cell2mat(resCArr);
    bpMat= horzcat(xCArr{:});
end
%
    function [supFun xVec] = fRhoForDir(ellObj,dirVec)
        [cenVec ellMat]=double(ellObj);
        absTol=ellObj.getAbsTol();
        sq  = max(realsqrt(dirVec'*ellMat*dirVec), absTol);
        supFun = cenVec'*dirVec + sq;
        xVec = ((ellMat*dirVec)/sq) + cenVec;
    end
    function [supFun xVec] = fSingleRhoForOneDir(singEll)
        cVec  = singEll.centerVec;
        shpMat  = singEll.shapeMat;
        [~, singAbsTol] = getAbsTol(singEll);
        sq = max(realsqrt(dirsArr'*shpMat*dirsArr), singAbsTol);
        supFun = cVec'*dirsArr + sq;
        xVec =((shpMat*dirsArr)/sq) + cVec;
    end
    function [supFun xVec] = fSingleRhoForOneEll(lVec)
        sq  = max(realsqrt(lVec'*shMat*lVec), absTol);
        supFun = qVec'*lVec + sq;
        xVec = ((shMat*lVec)/sq) + qVec;
    end
end
