function SEllArr = toStruct(ellArr)
% toStruct -- converts ellipsoid array into structural array.
%
% Input:
%   regular:
%       ellArr: ellipsoid [ellDim1, ellDim2, ...] - array
%           of ellipsoids.
% Output:
%   SEllArr : structural array with size of ellArr.
%
% Example:
%   ellObj = ellipsoid([1 1]', eye(2));
%   ellObj.toStruct()
% 
%   ans = 
% 
%   Q: [2x2 double]
%   q: [1 1]
% 
% $Author: Alexander Karev <Alexander.Karev.30@gmail.com>
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2013 $

    SEllArr = arrayfun(@formCompStruct, ellArr);
end

function SComp = formCompStruct(ellObj)
    SComp = struct('Q',gras.la.sqrtmpos(ellObj.shapeMat, ellObj.absTol),'q',ellObj.centerVec.');
end