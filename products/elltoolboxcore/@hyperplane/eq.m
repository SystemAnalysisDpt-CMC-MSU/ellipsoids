function isEqualArr = eq(fstHypArr, secHypArr, varargin)
%
% EQ - check if two hyperplanes are the same.
%
% Input:
%   regular:
%       fstHypArr: hyperplane [nDims1, nDims2, ...]/hyperplane [1, 1] -
%           first array of hyperplanes.
%       secHypArr: hyperplane [nDims1, nDims2, ...]/hyperplane [1, 1] -
%           second array of hyperplanes.
%   optional:
%       maxTol: double[1,1] - maximum tolerance, used
%           intstead of ellFirstArr.getRelTol()
% Output:
%   isEqualArr: logical[nDims1, nDims2, ...] - true -
%       if fstHypArr(iDim1, iDim2, ...) == secHypArr(iDim1, iDim2, ...),
%       false - otherwise. If size of fstHypArr is [1, 1], then checks
%       if fstHypArr == secHypArr(iDim1, iDim2, ...)
%       for all iDim1, iDim2, ... , and vice versa.
%
% Example:
%   firstHypObj = hyperplane([-1; 1]);
%   secHypObj = hyperplane([-1; 1; 8; -2; 3], 7);
%   thirdHypObj = hyperplane([1; 2; 0], -1);
%   secHypObj == [firstHypObj secHypObj thirdHypObj]
%
%   ans =
%
%        0     1     0
%
%
%$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
%$Date: 2013-06$
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $

[isEqualArr, ~] = fstHypArr.isEqual(secHypArr);
end
