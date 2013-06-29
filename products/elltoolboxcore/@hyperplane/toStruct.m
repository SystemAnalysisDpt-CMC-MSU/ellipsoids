function [SDataArr, SFieldNiceNames, SFieldDescr] = toStruct(hpArr, isPropIncluded)
% toStruct -- converts hyperplanes array into structural array.
%
% Input:
%   regular:
%       hpArr: hyperplane [hpDim1, hpDim2, ...] - array
%           of hyperplanes.
%
% Output:
%   ShpArr : struct[nDim1, nDim2, ...] - structural array with size of
%       hpArr with the following fields:
%
%       normal: double[nHpDim, 1] - the normal of hyperplane
%       shift: double[1, 1] - the shift of hyperplane

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
if (nargin < 2)
    isPropIncluded = false;
end

SDataArr = arrayfun(@(hpObj)hp2Struct(hpObj, isPropIncluded), hpArr);
SFieldNiceNames = struct('normal', 'normal', 'shift', 'shift');
SFieldDescr = struct('normal', 'Hyperplane normal.',...
    'shift', 'Hyperplane shift along normal from origin.');

if (isPropIncluded)
    SFieldNiceNames.absTol = 'absTol';
    SFieldDescr.absTol = 'Absolute tolerance.';
    SFieldNiceNames.relTol = 'relTol';
    SFieldDescr.relTol = 'Relative tolerance.';
end
end

function SHp = hp2Struct(hpObj, isPropIncluded)
if (hpObj.isEmpty())
    SHp = struct('normal', [], 'shift', []);
else
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
    if (isPropIncluded)
        SHp.absTol = hpObj.absTol;
        SHp.relTol = hpObj.relTol;
    end
end