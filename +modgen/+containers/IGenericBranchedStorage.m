classdef IGenericBranchedStorage<handle
    methods
        keyList=getKeyList(self)
        [valueList,varargout]=get(self,keyList,varargin)
        [isKeyVec,fullFileNameCVec]=isKey(self,keyList)
        put(self,keyList,valueObjList,varargin)
        remove(self,keyList)
        removeAll(self)
    end
end