function isEqualArr = eq(ellFirstArr, ellSecArr, varargin)
% EQ - compares two arrays of ellipsoids
%
% Input:
%   regular:
%       ellFirstArr: ellipsoid: [nDims1,nDims2,...,nDimsN]/[1,1]- the first
%           array of ellipsoid objects
%       ellSecArr: ellipsoid: [nDims1,nDims2,...,nDimsN]/[1,1] - the second
%           array of ellipsoid objects
% Output:
%   isEqualArr: logical: [nDims1,nDims2,...,nDimsN]- array of comparison
%       results
%
%
%$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
%$Date: 2013-06$
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
[isEqualArr, ~] = ellFirstArr.isEqual(ellSecArr);
end