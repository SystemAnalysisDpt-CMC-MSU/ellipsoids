function ShpArr = toStruct(hpArr)
% toStruct -- converts hyperplanes array into structural array.
%
% Input:
%   regular:
%       hpArr: hyperplane [hpDim1, hpDim2, ...] - array
%           of hyperplanes.
% 
% Output:
%   ShpArr : structural array with size of hpArr.
% 
% Example:
%   hpObj = hyperplane([1 1]', 1);
%   hpObj.toStruct()
% 
%   ans = 
% 
%   normal: [2x1 double]
%   shift: 0.7071
% 
% $Author: Alexander Karev <Alexander.Karev.30@gmail.com>
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2013 $

    ShpArr = arrayfun(@formCompStruct, hpArr);
end

function SComp = formCompStruct(hypObj)

[hypNormVec, hypScal] = parameters(hypObj);

normMult = 1/norm(hypNormVec);
hypNormVec  = hypNormVec*normMult;
hypScal  = hypScal*normMult;
if hypScal < 0
    hypScal = -hypScal;
    hypNormVec = -hypNormVec;
end

SComp = struct('normal', hypNormVec, 'shift', hypScal);

end