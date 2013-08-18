function [isEqualArr, reportStr] = isEqual(ellFirstArr, ellSecArr, varargin)
% ISEQUAL - produces logical array the same size as
%           ellFirstArr/ellFirstArr (if they have the same).
%           isEqualArr[iDim1, iDim2,...] is true if corresponding
%           ellipsoids are equal and false otherwise.
%
% Input:
%   regular:
%       ellFirstArr: ellipsoid[nDim1, nDim2,...] - multidimensional array
%           of ellipsoids.
%       ellSecArr: ellipsoid[nDim1, nDim2,...] - multidimensional array
%           of ellipsoids.
%   properties:
%       'isPropIncluded': makes to compare second value properties, such as
%       absTol etc.
% Output:
%   isEqualArr: logical[nDim1, nDim2,...] - multidimension array of
%       logical values. isEqualArr[iDim1, iDim2,...] is true if
%       corresponding ellipsoids are equal and false otherwise.
% 
%   reportStr: char[1,] - comparison report.
%
%$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
%$Date: 2013-06$
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $

[~, ~, isPropIncluded] = ...
           modgen.common.parseparext(varargin, {'isPropIncluded'; false});
[isEqualArr, reportStr] = ellFirstArr.isEqualInternal(ellSecArr, ...
    isPropIncluded);
end