function copyFrom(self,obj)
% COPYFROM - reconstruct CubeStruct object within a current object using the 
%            input CubeStruct object as a prototype
%
% Input:
%   regular:
%     self: CubeStruct [n_1,...,n_k]
%     obj: any [] - internal representation of the object
%     
%   optional:
%     fieldNameList: cell[1,nFields] - list of fields to copy
%
if self.isMe(obj)
    self.copyFromInternal(obj);
elseif isstruct(obj)
    self.loadObjInternal(obj)
else
    error([upper(mfilename),':wrongInput'],...
        ['object instance can only be loaded from ',...
            'an object of the same class or from a structure']);
end
self.inferSIsValueNullIfEmpty();