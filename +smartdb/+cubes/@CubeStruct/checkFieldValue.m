function fieldMetaData=checkFieldValue(self,isConsistencyChecked,fieldName,actionType,reg,varargin)
% CHECKFIELDVALUE checks a consistency between a value
% vector for a certain field and is-null vector for the same
% field. In case of no consistency the exception is risen
%
%
% Input:
%   regular:
%       self: CubeStruct[1,1]
%       isConsistencyChecked: logical[1,1], if true, a consistency between
%          the input structures is not checked, true by default
%       fieldName: char[1,] - name of CubeStruct field for which checking
%          is to be performed based on the attached meta-data information
%          (type information in particular)
%       
%   optional:
%       valueCell: cell[1,] that can consist of the following elements in the
%         specified order:
%            value: array [] - array of some type
%               containing the field values
%   
%            isNull: logical/cell [] - array of
%               is-null indicators corresponding value vector
%
%            isValueNull: logical [] - indicates whether a
%               corresponding cell contains NULL
%
%   properties:
%       structNameList: char[1,]/cell[1,] list of structure
%          names for which the input values are specified, can
%          be composed from the following values:
%          {'SData','SIsNull','SIsValueNull'}
%       
%
%       isStructSpecified: logical[1,3] - an alternative way to specify the
%          structures to which the input data is related. 
%
%          default value: {'SData','SIsNull','SIsValueNull'}
%       fieldName: char[1,] - used in combination with
%         structNameList to define a field name to extract
%         value to check agains for the structures not
%         presented in structNameList list
%
%       fillUnspecified: logical[1,1] - if true, the unspecified value
%          elements (SData, SIsNull and/or SIsValueNull) are filled from
%          the internal data
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
import modgen.system.ExistanceChecker;
%

nProp=length(varargin);
nReg=numel(reg);
isStructNameListSpecified=false;
isStructNameListAsLogical=false;
isFieldMetaDataPassed=false;
isUnspecifiedFilled=true;
for k=1:2:nProp-1
    if ~ischar(varargin{k})
        continue;
    end
    switch lower(varargin{k})
        case 'structnamelist',
            structNameList=varargin{k+1};
            isStructNameListSpecified=true;
        case 'isstructspecified',
            isSpecified=varargin{k+1};
            isStructNameListAsLogical=true;
        case 'fieldmetadata',
            fieldMetaData=varargin{k+1};
            isFieldMetaDataPassed=true;
        case 'fillunspecified',
            isUnspecifiedFilled=varargin{k+1};
    end
end
%
if ~isStructNameListAsLogical
    if isStructNameListSpecified
        [isSpecified,indLoc]=ismember(self.completeStructNameList,structNameList);
        if ~(all(isSpecified)||ExistanceChecker.isVar('fieldName'))
            error([upper(mfilename),':wrongInput'],...
                'fieldName property was not set while structNameList is not complete');
        end
        %
        reg(isSpecified)=reg(indLoc(isSpecified));
        reg(~isSpecified)={[]};
    else
        isSpecified=true(size(self.completeStructNameList));
        if nReg<numel(isSpecified)
            isSpecified((nReg+1):end)=false;
        end
    end
elseif isStructNameListSpecified
    error([upper(mfilename),':wrongInput'],...
        ['Only one of isStructSpecified and structNameList parameters ',...
        'can be used at the same time']);
end
%    
if isUnspecifiedFilled
    if ~isSpecified(1)
        reg(1)={self.SData.(fieldName)};
    end
    if ~isSpecified(2)
        reg(2)={self.SIsNull.(fieldName)};
    end
    if ~isSpecified(3)
        reg(3)={self.SIsValueNull.(fieldName)};
    end
end
%
if ~isFieldMetaDataPassed
    fieldMetaData=self.getFieldMetaData(fieldName);
end
checkFieldValue(fieldMetaData,isConsistencyChecked,actionType,isSpecified,reg);