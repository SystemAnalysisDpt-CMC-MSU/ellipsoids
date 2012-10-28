function copyFromInternal(self,obj,varargin)
% COPYFROMINTERNAL creates a copy of CubeStruct object within a current object using the input
% CubeStruct object as a prototype
%
[reg,prop]=modgen.common.parseparams(varargin,...
    {'fieldNameList','fillMissingFieldsWithNulls'});
self.loadObjInternal(obj.saveObjInternal(reg{:}),prop{:});