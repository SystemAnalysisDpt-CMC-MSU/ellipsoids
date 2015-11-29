function copyEllArr = getCopy(ellArr)
% GETCOPY - returns array the same size as ellArr with copies of 
%           GenEllipsoids in ellArr.
%
% Input:
%   regular:
%       ellArr: GenEllipsoid [nDim1, nDim2,...,nDimsN] - array of 
%           GenEllipsoids.
%
% Output:
%   copyEllArr: GenEllipsoid [nDim1, nDim2,...,nDimsN] - array of  
%       copies of GenEllipsoids in ellArr.
% 
% Example:
%   ellObj = GenEllipsoid([-1; 1], [2 0; 0 3]);
%   copyEllObj = getCopy(ellObj)
% 
%
%   copyEllObj = 
%
%       |    
%       |-- centerVec : [-1 1]
%       |               -----
%       |------- QMat : |2|0|
%       |               |0|3|
%       |               -----
%       |               -----
%       |---- QInfMat : |0|0|
%       |               |0|0|
%       |               -----
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
import elltool.core.GenEllipsoid;
GenEllipsoid.checkIsMe(ellArr);
if isempty(ellArr)
    copyEllArr=ellipsoid.empty(size(ellArr));
elseif isscalar(ellArr)
    copyEllArr=GenEllipsoid();
    fSingleCopy(copyEllArr,ellArr);
else
    sizeCVec=num2cell(size(ellArr));
    copyEllArr(sizeCVec{:})=GenEllipsoid();
    arrayfun(@fSingleCopy,copyEllArr,ellArr);
end
    function fSingleCopy(copyEll,ell)
        copyEll.centerVec=ell.centerVec;
        copyEll.diagMat=ell.diagMat;
        copyEll.eigvMat=ell.eigvMat;
    end
end