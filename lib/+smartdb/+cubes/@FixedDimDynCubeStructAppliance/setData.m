function  setData(self,varargin)
% SETDATA - sets data for all fields of CubeStruct object
%
% Usage: setData(self,varargin)
%
% Input:
%   regular:
%     self:
%     SData: struct [1,1] - structure with values of all fields
%
%   optional:
%     SIsNull: struct [1,1] - structure with logicals
%         determining whether value corresponding to each field
%         and each tuple is null or not
%   properties:
%       isConsistencyCheckedVec: logical [1,1]/[1,2]/[1,3] - 
%           the first element defines if a consistency between the value
%               elements (data, isNull and isValueNull) is checked;
%           the second element (if specified) defines if
%               value's type is checked. 
%           the third element defines if consistency between of sizes
%               between different fields is checked
%             If isConsistencyCheckedVec
%               if scalar, it is automatically replicated to form a
%                   3-element vector
%               if the third element is not specified it is assumed 
%                   to be true
%
%       inferFieldList: logical[1,1] if true, the field names are 
%         inferred from SData
%
%       transactionSafe: logical[1,1] if true, the operation is performed 
%           in a transaction-safe manner
%
%       checkStruct: logical[1,nStruct] - an array of indicators which when
%          true force checking of structure content (including presence of 
%          all required fields). The first element correspod to SData, the
%          second and the third (if specified) to SIsNull and SIsValueNull
%          correspondingly
%
%       structNameList: char[1,]/cell[1,], name of data structure/list of 
%         data structure names to which the function is to
%              be applied, can be composed from the following values
%
%            SData - data itself
%
%            SIsNull - contains is-null indicator information for data 
%                      values
%
%            SIsValueNull - contains is-null indicators for CubeStruct cells 
%               (not for cell values)
%         structNameList={'SData'} by default
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-01-31 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.common.throwerror;
isInferFieldList=false;
isTransactionSafe=true;
[reg,prop]=parseparams(varargin);
nProp=length(prop);
indDelPropVec=[];
%% continue parsing
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'inferfieldlist'
            isInferFieldList=prop{k+1};
            indDelPropVec=[indDelPropVec,[k,k+1]];
        case 'transactionsafe',
            isTransactionSafe=prop{k+1};
            indDelPropVec=[indDelPropVec,[k,k+1]];
        case {'structnamelist','checkstruct','checkconsistency'}
        otherwise,
            throwerror('wrongInput',...
                'property %s is not supported in setData',prop{k});
    end
end
prop(indDelPropVec)=[];
inpArgList=[reg,prop];
%we do this to make the operation transaction safe
if isTransactionSafe
    backupObj=self.getCopy();
    inpArgList=[inpArgList,{'transactionSafe',false}];
end
try     
    if isInferFieldList
        fieldNameList=self.getFieldNameList();
        self.removeFieldsInternal(fieldNameList);
        fieldNameList=transpose(fieldnames(inpArgList{1}));
        fieldDescrList=fieldNameList;
        self.addFieldsInternal(fieldNameList,fieldDescrList);
    end
    self.setDataInternal(inpArgList{:});
catch meObj
    if isTransactionSafe
        self.copyFromInternal(backupObj);
    end
    rethrow(meObj);
end