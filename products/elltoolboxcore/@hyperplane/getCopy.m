function copyHpArr = getCopy(hpArr)
% GETCOPY - gives array the same size as hpArr with copies of elements of
%           hpArr.
%
% Input:
%   regular:
%       hpArr: hyperplane[nDim1, nDim2,...] - multidimensional array of
%           hyperplanes.
%
% Output:
%   copyHpArr: hyperplane[nDim1, nDim2,...] - multidimension array of
%       copies of elements of hpArr.
%
% Example:
%   firstHpObj = hyperplane([-1; 1], [2 0; 0 3]);
%   secHpObj = hyperplane([1; 2], eye(2));
%   hpVec = [firstHpObj secHpObj];
%   copyHpVec = getCopy(hpVec)
%
%   copyHpVec =
%   1x2 array of hyperplanes.
%
%
% $Author: Alexander Karev <Alexander.Karev.30@gmail.com>
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2013 $
if isempty(hpArr)
    copyHpArr = hyperplane.empty(size(hpArr));
elseif isscalar(hpArr)
    copyHpArr=hyperplane();
    fSingleCopy(copyHpArr,hpArr);
else
    sizeCVec = num2cell(size(hpArr));
    copyHpArr(sizeCVec{:}) = hyperplane();
    arrayfun(@fSingleCopy,copyHpArr,hpArr);
end
    function fSingleCopy(copyHp,hp)
        copyHp.normal = hp.normal;
        copyHp.shift = hp.shift;
        copyHp.absTol = hp.absTol;
    end
end