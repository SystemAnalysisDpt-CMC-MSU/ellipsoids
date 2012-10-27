function s=toStruct(obj)
warning('CubeStruct:dangereousUsage',...
    'use this method for testing purposes only!');
s=obj.saveObjInternal();