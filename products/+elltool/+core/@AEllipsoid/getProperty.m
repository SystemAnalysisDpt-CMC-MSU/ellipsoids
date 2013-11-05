function [propArr, propVal] = getProperty(ellArr,propName,fPropFun)
% GETPROPERTY - gives array the same size as ellArr with values of
%               propName properties for each ellipsoid in ellArr.
%               Private method, used in every public property getter.
%
% Input:
%   regular:
%       ellArr: ellipsoid[nDim1, nDim2,...] - mltidimensional array
%           of ellipsoids
%       propName: char[1,N] - name property
%   optional: 
%       fPropFun: function_handle[1,1] - function that apply
%           to the propArr. The default is @min.
%
% Output:
%   regular:
%       propArr: double[nDim1, nDim2,...] - multidimension array of
%           propName properties for ellipsoids in rsArr
%   optional:
%       propVal: double[1, 1] - return result of work fPropFun with 
%           the propArr
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $
%$Date: 2012-11-17$
%$Author: Grachev Artem  <grachev.art@gmail.com> $
%$Date: March-2013$
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
import modgen.common.throwerror;
propNameList = {'absTol','relTol','nPlot2dPoints','nPlot3dPoints',...
    'nTimeGridPoints'};
if ~any(strcmp(propName,propNameList))
    throwerror('wrongInput',[propName,':no such property']);
end
%
if nargin == 2
    fPropFun = @min;
end

propArr= arrayfun(@(x)x.(propName),ellArr);

if nargout == 2
    propVal = fPropFun(propArr(:));
end

end
