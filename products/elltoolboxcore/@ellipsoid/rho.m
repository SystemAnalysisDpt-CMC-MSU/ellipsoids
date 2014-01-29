function [supArr, bpArr] = rho(ellArr, dirsArr)
%
% RHO - computes the values of the support function for given ellipsoid
%       and given direction.
%
%       supArr = RHO(ellArr, dirsMat)  Computes the support function of the
%       ellipsoid ellArr in directions specified by the columns of matrix
%       dirsMat. Or, if ellArr is array of ellipsoids, dirsMat is expected
%       to be a single vector.
%
%       [supArr, bpArr] = RHO(ellArr, dirstMat)  Computes the support function
%       of the ellipsoid ellArr in directions specified by the columns of
%       matrix dirsMat, and boundary points bpArr of this ellipsoid that
%       correspond to directions in dirsMat. Or, if ellArr is array of
%       ellipsoids, and dirsMat - single vector, then support functions and
%       corresponding boundary points are computed for all the given
%       ellipsoids in the array in the specified direction dirsMat.
%
%       The support function is defined as
%   (1)  rho(l | E) = sup { <l, x> : x belongs to E }.
%       For ellipsoid E(q,Q), where q is its center and Q - shape matrix,
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
%           double[nDim,nDirs]/[nDim,1] - array or matrix of directions.
%
% Output:
%       supArr: double [nDims1,nDims2,...,nDimsN]/[1,nDirs] - support function
%       of the ellArr in directions specified by the columns of matrix
%       dirsMat. Or, if ellArr is array of ellipsoids, support function of
%       each ellipsoid in ellArr specified by dirsMat direction.
%
%   bpArr: double[nDim,nDims1,nDims2,...,nDimsN]/
%           double[nDim,nDirs]/[nDim,1] - array or matrix of boundary points
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
% $Copyright: Lomonosov Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
% $Author: Vitaly Baranov <vetbar42@gmail.com> $   $Date: 27-04-2013$
% $Copyright: Lomonosov Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2013 $
%
%
import modgen.common.checkmultvar;
%
ellipsoid.checkIsMe(ellArr,'first');
modgen.common.checkvar(dirsArr, @(x)isa(x,'double'),...
    'errorMessage','second argument must be matrix of direction vectors.');
%
dirSizeVec = size(dirsArr);
ellSizeVec=size(ellArr);
isOneEll = isscalar(ellArr);
isOneDir = dirSizeVec(2)==1 && length(dirSizeVec)==2;
%
nEll=prod(ellSizeVec);
nDim=dirSizeVec(1);
nDirs=prod(dirSizeVec(2:end));
%
if ~(isOneEll || isOneDir || ...
        nEll==nDirs&&(ellSizeVec(1)==1 || ellSizeVec(2)==1)&&...
        length(dirSizeVec)==2 ||...
        all(ellSizeVec==dirSizeVec(2:end)))
    modgen.common.throwerror('wrongInput:wrongSizes',...
        strcat('arguments must be single ellipsoid or single direction ',...
        'vector or arrays of almost the same sizes'));
end
%
nDimsArr = dimension(ellArr);
checkmultvar('all(x2==x1)',2,nDim,nDimsArr(:), 'errorMessage',...
    'dimensions mismatch.');
%
if isOneEll % one ellipsoid, multiple directions
    cenVec = ellArr.centerVec;
    ellMat = ellArr.shapeMat;
    [~, absTol] = getAbsTol(ellArr);
    dirsMat=reshape(dirsArr,nDim,nDirs);
    %
    [supArr bpArr] = gras.geom.ell.rhomat(ellMat, dirsMat,absTol, cenVec);
    if length(dirSizeVec)>2
        supArr=reshape(supArr,dirSizeVec(2:end));
        bpArr=reshape(bpArr,dirSizeVec);
    end
elseif isOneDir % multiple ellipsoids, one direction
    fComposite=@(ellObj)fRhoForDir(ellObj,dirsArr);
    [resCArr xCArr]=arrayfun(fComposite,ellArr,...
        'UniformOutput',false);
    supArr = cell2mat(resCArr);
    bpArr = horzcat(xCArr{:});
    if length(ellSizeVec)>2
        reshVec=[nDim,ellSizeVec];
        bpArr = reshape(bpArr,reshVec);
    end
else % multiple ellipsoids, multiple directions
    augxCArr=num2cell(dirsArr,1);
    dirCArr=reshape(augxCArr(1,:),ellSizeVec);
    %
    fComposite=@(ellObj,lVec)fRhoForDir(ellObj,lVec{1});
    [resCArr xCArr]=arrayfun(fComposite,ellArr,dirCArr,...
        'UniformOutput',false);
    supArr = cell2mat(resCArr);
    bpArr= horzcat(xCArr{:});
    bpArr=reshape(bpArr,dirSizeVec);
end
%
    function [supFun xVec] = fRhoForDir(ellObj,dirVec)
        [cenVec ellMat]=double(ellObj);
        absTol=ellObj.getAbsTol();
        [supFun xVec] = gras.geom.ell.rhomat(ellMat, dirVec,absTol,...
            cenVec);
    end
end