function copyEllArr = getCopy(ellArr)
% GETCOPY - returns array the same size as ellArr with copies of 
%           ABasicEllipsoids in ellArr.
%
% Input:
%   regular:
%       ellArr: ABasicEllipsoid [nDim1, nDim2,...,nDimsN] - array of 
%           ABasicEllipsoids.
%
% Output:
%   copyEllArr: ABasicEllipsoid [nDim1, nDim2,...,nDimsN] - array of  
%       copies of ABasicEllipsoids in ellArr.
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
checkIsMeVirtual(ellArr);
if isempty(ellArr)
    copyEllArr=ellArr.empty(size(ellArr));
elseif isscalar(ellArr)
    copyEllArr=getSingleCopy(ellArr);
else
    sizeCVec = num2cell(size(ellArr));
    copyEllArr(sizeCVec{:})=ellFactory(ellArr);
    for iElem = 1:numel(ellArr)
        copyEllArr(iElem)=getSingleCopy(ellArr(iElem));
    end
end
end