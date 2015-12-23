function [propArr,propVal]=getProperty(ellArr,propName,fPropFun)
% GETPROPERTY - gives array the same size as ellArr with values of
%               propName properties for each ABasicEllipsoid in ellArr.
%               Private method, used in every public property getter.
%
% Input:
%   regular:
%       ellArr: ABasicEllipsoid[nDim1, nDim2,...] - multidimensional array
%           of ABasicEllipsoids
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
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com>  
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
import modgen.common.throwerror;
propNameList=ellArr.getPropList();
if ~any(strcmp(propName,propNameList))
    throwerror('wrongInput',[propName,':no such property']);
end
if nargin==2
    fPropFun=@min;
end
sizeCVec=num2cell(size(ellArr));
propArr=zeros(sizeCVec{:});
for iElem=1:numel(ellArr)
    propArr(iElem)=ellArr(iElem).(propName);
end
if nargout==2
    propVal=fPropFun(propArr(:));
end
end
