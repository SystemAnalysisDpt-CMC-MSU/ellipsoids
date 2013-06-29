function hpArr = fromStruct(SHpArr)
% fromStruct -- converts structural array into hyperplanes array.
%
% Input:
%   regular:
%   SHpArr: struct [hpDim1, hpDim2, ...] -  structural array with following fields:
%
%        normal: double[nHpDim, 1] - the normal of hyperplane
%        shift: double[1, 1] - the shift of hyperplane
%
% Output:
%   hpArr : hyperplane [nDim1, nDim2, ...] - hyperplane array with size of
%       SHpArr.
%
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
for iHp = numel(SHpArr) : -1 : 1
    hpArr(iHp) = struct2Hp(SHpArr(iHp));
end
hpArr = reshape(hpArr, size(SHpArr));
end

function hpObj = struct2Hp(SHp)
if (isfield(SHp, 'absTol'))
    SProp = rmfield(SHp, {'normal', 'shift'});
    propNameValueCMat = [fieldnames(SProp), struct2cell(SProp)].';
    hpObj = hyperplane(SHp.normal, SHp.shift, propNameValueCMat{:});
else
    hpObj = hyperplane(SHp.normal, SHp.shift);
end
end