function copyEllArr = getCopy(ellArr)
% GETCOPY - gives array the same size as ellArr with copies of
%           elements of ellArr.
%
% Input:
%   regular:
%       ellArr: ellipsoid[nDim1, nDim2,...] - multidimensional array
%           of ellipsoids.
%
% Output:
%   copyEllArr: ellipsoid[nDim1, nDim2,...] - multidimension array of
%       copies of elements of ellArr.
%
% $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: March-2013 $
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $  $Date: 24-04-2013 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
if isscalar(ellArr)
    copyEllArr=ellipsoid();
    fSingleCopy(copyEllArr,ellArr);
else
    sizeCVec = num2cell(size(ellArr));
    copyEllArr(sizeCVec{:}) = ellipsoid();
    arrayfun(@fSingleCopy,copyEllArr,ellArr);
end
    function fSingleCopy(copyEll,ell)
        copyEll.centerVec=ell.centerVec;
        copyEll.shapeMat=ell.shapeMat;
        copyEll.absTol=ell.absTol;
        copyEll.relTol=ell.relTol;
        copyEll.nPlot2dPoints=ell.nPlot2dPoints;
        copyEll.nPlot3dPoints=ell.nPlot3dPoints;
    end
end