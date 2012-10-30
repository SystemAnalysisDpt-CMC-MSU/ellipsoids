function SObjectData=saveObjInternal(self,varargin)
% SAVEOBJINTERNAL transforms given CubeStruct object into
% structure containing internal representation of object properties
%
% Usage: SObjectData=saveObjInternal(self,varargin)
%
% Input:
%   regular:
%     self: CubeStruct [n_1,...,n_2]
%
%   optional: the same arguments as for getDataInternal
%
% Output:
%   regular:
%     SObjectData: struct [n1,...,n_k] - structure containing an internal
%        representation of the specified object
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
SObjectData=repmat(struct(...
    'fieldMetaData',[],...
    'minDimensionality',[],...
    'SData',[],...
    'SIsNull',[],...
    'SIsValueNull',[]),size(self));
for iElem=1:numel(self)
    SObjectData(iElem)=saveScalarObj(self(iElem),varargin);
end
end
function SObjectData=saveScalarObj(self,argList)
if nargin>2
    error([upper(mfilename),':wrongInput'],...
        'incorrect number of inputs');
end
%
SObjectData=struct();
SObjectData.fieldMetaData=self.fieldMetaData;
SObjectData.minDimensionality=self.minDimensionality;
%
if nargin==2
    [SObjectData.SData,SObjectData.SIsNull,SObjectData.SIsValueNull]=...
        self.getDataInternal(argList{:});
else
    SObjectData.SData=self.SData;
    SObjectData.SIsNull=self.SIsNull;
    SObjectData.SIsValueNull=self.SIsValueNull;
end
end