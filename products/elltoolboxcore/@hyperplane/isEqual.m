function [isEqualArr, reportStr] = isEqual(hpFirstArr, hpSecArr, varargin)
% ISEQUAL - produces logical array the same size as
%           hpFirstArr/hpFirstArr (if they have the same).
%           isEqualArr[iDim1, iDim2,...] is true if corresponding
%           hyperplanes are equal and false otherwise.
%
% Input:
%   regular:
%       hpFirstArr: hyperplane[nDim1, nDim2,...] - multidimensional array
%           of hyperplanes.
%       hpSecArr: hyperplane[nDim1, nDim2,...] - multidimensional array
%           of hyperplanes.
%   properties:
%       'isPropIncluded': makes to compare second value properties, such as
%       absTol etc.
% Output:
%   isEqualArr: logical[nDim1, nDim2,...] - multidimension array of
%       logical values. isEqualArr[iDim1, iDim2,...] is true if
%       corresponding hyperplanes are equal and false otherwise.
% 
%   reportStr: char[1,] - comparison report.
% 
% Example:
%   firsthpObj = hyperplane([-1; 1], 2);
%   sechpObj = hyperplane([1 2], 1);
%   isEqual(firsthpObj, sechpObj)
%
%   ans =
%
%        0
%
%$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
%$Date: 2013-06$
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
[~, ~, isPropIncluded] = ...
           modgen.common.parseparext(varargin, {'isPropIncluded'; false});
[isEqualArr, reportStr] = hpFirstArr.isEqualInternal(hpSecArr,...
    isPropIncluded, @formCompStruct);

    function SComp = formCompStruct(SHp, SFieldNiceNames, ~)
        SComp.(SFieldNiceNames.normal) = SHp.normal;
        SComp.(SFieldNiceNames.shift) = SHp.shift;
        if (isPropIncluded)
            SComp.(SFieldNiceNames.absTol) = SHp.absTol;
        end
    end
end