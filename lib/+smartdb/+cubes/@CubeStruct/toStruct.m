function s=toStruct(obj)
% TOSTRUCT - transforms given CubeStruct object into structure
%
% Input:
%   regular:
%     self: CubeStruct [nDim1,...,nDim2]
%
%
% Output:
%   regular:
%     SObjectData: struct [n1,...,n_k] - structure containing an internal
%        representation of the specified object

warning('CubeStruct:dangereousUsage',...
    'use this method for testing purposes only!');
s=obj.saveObjInternal();