function applySetFuncInternal(self,hFunc,toFieldNameList,varargin)
% APPLYSETFUNCINTERNAL applies some function to each cell of the specified fields
% of a given CubeStruct object
%
% Usage: applySetFuncInternal(self,hFunc,toFieldNameList)
%
% Input:
%   regular:
%       self: CubeStruct [1,1] - class object
%
%       hFunc: function handle [1,1] - handle of function to be
%         applied to fields, the function is assumed to
%           1) have the same number of input/output arguments
%           2) the number of input arguments should be
%              length(structNameList)*length(fieldNameList)
%           3) the input arguments should be ordered according to the
%           following rule
%               (x_struct_1_field_1,x_struct_1_field_2,...,struct_n_field1,
%               ...,struct_n_field_m)
%
%   optional:    
%       toFieldNameList: char or char cell [1,nFields] - list of
%         field names to which given function should be applied
%
%         Note: field lists of length>1 are not currently supported !
%
%
%   properties:
%       uniformOutput: logical[1,1] - specifies if the result
%          of the function is uniform to be stored in non-cell
%          field, by default it is false for cell fileds and
%          true for non-cell fields
%
%       structNameList: char[1,]/cell[1,], name of data structure/list of 
%         data structure names to which the function is to
%              be applied, can be composed from the following values
%
%            SData - data itself
%
%            SIsNull - contains is-null indicator information for data values
%
%            SIsValueNull - contains is-null indicators for CubeStruct cells (not
%               for cell values
%         structNameList={'SData'} by default
%   
%       inferIsNull: logical[1,2] - if the first(second) element is true,  
%           SIsNull(SIsValueNull) indicators are inferred from SData, 
%           i.e. with this indicator set to true it is sufficient to apply 
%           the function only to SData while the rest of the structures 
%           will be adjusted automatically.
%
%       inputType: char[1,] - specifies a way in which the field value is
%          partitioned into individual cells before being passed as an
%          input parameter to hFunc. This parameter directly corresponds to
%          outputType parameter of toArray method, see its documentation
%          for a list of supported input types.
%
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
import modgen.system.ExistanceChecker;
if nargin<3
    toFieldNameList=self.getFieldNameList();
end
if ischar(toFieldNameList)
    toFieldNameList={toFieldNameList};
end
if ~auxchecksize(toFieldNameList,[1 nan])
    error([upper(mfilename),':wrongInput'],...
        'toFieldNameList is expected to be of size [1,]');
end
%
if isempty(toFieldNameList)
    error([upper(mfilename),':wrongInput'],...
        'toFieldNameList is expected to contain at least 1 element');
end
%
if length(toFieldNameList)>1
    error([upper(mfilename),':wrongInput'],...
        'currently only single-argument functions are supported');
end
%
if ~all(cellfun('isclass',toFieldNameList,'char'))
    error([upper(mfilename),':wrongInput'],...
        'all elements of fieldNameList are expected to be of char type');
end
if ~all(ismember(toFieldNameList,self.fieldNameList))
    error([upper(mfilename),':wrongInput'],...
        'not all inputs correspond to field names');
end
[~,prop]=modgen.common.parseparams(varargin,[],0);
%
isNullInferred=false;
nProp=length(prop);
structNameList={'SData'};
isInputTypeSpecified=false;
for k=1:2:nProp
    switch lower(prop{k})
        case 'uniformoutput',
            isUniformOutput=prop{k+1};
        case 'structnamelist',
            structNameList=prop{k+1};
        case 'inferisnull',
            isNullInferred=prop{k+1};
        case 'inputtype',
            inputType=prop{k+1};
            isInputTypeSpecified=true;
        otherwise,
            error([upper(mfilename),':wrongInput'],...
                'unknown property: %s',prop{k});
    end
end
%
if ischar(structNameList)
    structNameList={structNameList};
end
%
if ~auxchecksize(structNameList,[1 nan])
    error([upper(mfilename),':wrongInput'],...
        'structNameList is expected to be of size [1,]');
end
%
if isempty(structNameList)
    error([upper(mfilename),':wrongInput'],...
        'structNameList is expected to contain at least 1 element');
end
%
if self.getNElems()==0
    return;
end
%
colVec=cell(size(structNameList));
%
if ~isInputTypeSpecified
    outputType='adaptiveCell';
else
    outputType=inputType;
end
[colVec{:},isToCellMat]=self.toArray(...
    'structNameList',structNameList,...
    'fieldNameList',toFieldNameList{1},'replaceNull',...
    false,'groupByColumns',true,'outputType',outputType);
%
colVec=[colVec{:}];
isFromCellVec=transpose(isToCellMat(:));
%
resCVec=cell(size(colVec));
[resCVec{:}]=cellfun(hFunc,colVec{:},'UniformOutput',false);
if ExistanceChecker.isVar('isUniformOutput')
   isFromCellVec(:)=isUniformOutput;
end
if any(isFromCellVec)
    resCVec(isFromCellVec)=cellfun(@(x)modgen.cell.cell2mat(x),...
        resCVec(isFromCellVec),...
        'UniformOutput',false);
end
%
self.setFieldInternal(toFieldNameList{1},resCVec{:},'structNameList',structNameList,...
    'inferIsNull',isNullInferred);