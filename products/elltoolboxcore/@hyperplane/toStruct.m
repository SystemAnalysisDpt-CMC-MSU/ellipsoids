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

    ShpArr = arrayfun(@hp2Struct, hpArr);
end

function SHp = hp2Struct(hpObj)

[hpNormVec, hpScal] = parameters(hpObj);

normMult = 1/norm(hpNormVec);
hpNormVec  = hpNormVec*normMult;
hpScal  = hpScal*normMult;
if hpScal < 0
    hpScal = -hpScal;
    hpNormVec = -hpNormVec;
end

SHp = struct('normal', hpNormVec, 'shift', hpScal);

end