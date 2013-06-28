function [propArr, propVal] = getProperty(hpArr,propName,fPropFun)
% GETPROPERTY - gives array the same size as hpArr with values of
%               propName properties for each hyperplane in hpArr.
%               Private method, used in every public property getter.
%
% Input:
%   regular:
%       hpArr: hyperplane[nDim1, nDim2,...] - mltidimensional array
%           of hyperplanes
%       propName: char[1,N] - name property
%   optional: 
%       fPropFun: function_handle[1,1] - function that apply
%           to the propArr. The default is @min.
%
% Output:
%   regular:
%       propArr: double[nDim1, nDim2,...] - multidimension array of
%           propName properties for hyperplanes in rsArr
%   optional:
%       propVal: double[1, 1] - return result of work fPropFun with 
%           the propArr
%
%$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
%$Date: 2013-06$
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
%
import modgen.common.throwerror;
propNameList = {'absTol', 'relTol'};
if ~any(strcmp(propName,propNameList))
    throwerror('wrongInput',[propName,':no such property']);
end
%
if nargin == 2
    fPropFun = @min;
end
propArr = arrayfun(@(x)x.(propName), hpArr);

if nargout == 2
    propVal = fPropFun(propArr(:));
end

end
