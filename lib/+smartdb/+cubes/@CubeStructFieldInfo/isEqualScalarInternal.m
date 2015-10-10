function [isPositive,reportStr,signOfDiff]=isEqualScalarInternal(self,...
    obj,isCubeStructCompared,cubeStructCompareParamList)
% isEqualScalarInternal compares a given object with a specified one
import modgen.common.throwerror;
if (numel(self)~=1)||(numel(obj)~=1)
    throwerror('wrongInput','only scalar objects are supported');
end
if nargin<4
    cubeStructCompareParamList={};
end
if nargin<3
    isCubeStructCompared=false;
end
reportStr='';
if nargout>2
    signOfDiff=nan;
end
if ~strcmp(self.name,obj.name)
    reportStr='Field name is different';
    isPositive=false;
elseif ~strcmp(self.description,obj.description)
    reportStr='Description is different';
    isPositive=false;
elseif ~isequal(self.type,obj.type)
    isPositive=false;
    reportStr='Types are different';
elseif isCubeStructCompared
    isPositive=isequal(self.cubeStructRef,obj.cubeStructRef,...
            'propEqScalarList',cubeStructCompareParamList);
    if ~isPositive,
        reportStr='CubeStruct reference lists are different';
    end
else
    isPositive=true;
end