function unionWithAlongDimInternal(self,unionDim,varargin)
% UNIONWITHALONGDIM adds data from the input CubeStructs
%
% Usage: self.unionWithAlongDim(unionDim,inpCube)
% 
% Input:
%   regular:
%   self: 
%       inpCube1: CubeStruct [1,1] - object to get the additional data from
%           ...
%       inpCubeN: CubeStruct [1,1] - object to get the additional data from
%
%   properties:
%       checkType: logical[1,1] - if true, union is only performed when the
%           types of relations is the same. Default value is false
%
%       checkStruct: logical[1,nStruct] - an array of indicators which when
%          true force checking of structure content (including presence of all
%          required fields). The first element correspod to SData, the
%          second and the third (if specified) to SIsNull and SIsValueNull
%          correspondingly
%
%       checkConsistency: logical [1,1]/[1,2] - the
%           first element defines if a consistency between the value
%           elements (data, isNull and isValueNull) is checked;
%           the second element (if specified) defines if
%           value's type is checked. If isConsistencyChecked
%           is scalar, it is automatically replicated to form a
%           two-element vector.
%           Note: default value is true
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-09-16 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
import modgen.common.throwerror;
[reg,prop]=modgen.common.parseparams(varargin);
if ~isempty(prop)
    [~,prop,isTypeChecked]=modgen.common.parseparext(prop,...
        {'checkType';false;'islogical(x)&&isscalar(x)'});
    if ~all(cellfun(@(x)isa(x,'smartdb.cubes.CubeStruct'),reg))
        error([upper(mfilename),':wrongInput'],...
            'all inputs are expected to be of type smartdb.cubes.CubeStruct');
    end
else
    isTypeChecked=false;
end
%
isCheckStructSpec=any(strcmp(prop,'CheckStruct'));
isCheckConsistencySpec=any(strcmp(prop,'CheckConsistency'));
%
if ~isCheckStructSpec||~isCheckConsistencySpec
    isAllStatic=all(cellfun(...
        @(x)smartdb.cubes.CubeStructConfigurator.isOfStaticType(x),...
        reg));
end
if isTypeChecked
    isOk=cellfun('isclass',reg,class(self));
    if ~isOk
        throwerror('wrongInput',...
            'types of inputs are required to be the same');
    end
end
%
if ~isCheckStructSpec&&isAllStatic
    prop=[prop,{'CheckStruct',[false false false]}];
end
%
if ~isCheckConsistencySpec&&isAllStatic
    prop=[prop,{'CheckConsistency',false}];
end
%
nCubes=length(reg);
resCell=cell(1,3);
for iCube=1:nCubes
    [resCell{:}]=reg{iCube}.getDataInternal();
    self.addDataAlongDimInternal(unionDim,resCell{:},prop{:});
end