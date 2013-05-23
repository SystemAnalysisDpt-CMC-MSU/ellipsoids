function copyFrom(self,obj)
% COPYFROM - reconstruct CubeStruct object within a current object using the 
%            input CubeStruct object as a prototype
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