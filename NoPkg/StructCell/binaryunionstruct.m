function varargout=binaryunionstruct(leftStruct,rightStruct,fieldOpCell,...
    leftFieldOpCell,rightFieldOpCell)
% BINARYUNIONSTRUCT applies a set of binary operations to the fields of two
% structures, each operation can return multiple results.
%
% Usage:
% [S1,S2,S3,...,Sn]=binaryunionstruct(leftStruct,rightStruct,fieldOpCell,leftFieldOpCell,rightFieldOpCell)
%
% Input:
%   regular:
%       leftStruct: struct[n1,n2,...,nk] - first input structure array
%
%       rightStruct: struct[n1,n2,...,nk] - second input structure array
%
%       fieldOpCell: cell[1,nOps] - cell array of operations applied
%          to common fileds of two structures, each operation should return
%             n arguments
%
%   optional:
%   
%       leftFieldOpCell: cell[1,nOps] - cell array of operations that
%          applied to the fields that are present only in the first
%             structure, each operation should return n arguments
%
%               default value: @deal  
%
%       rightFieldOpCell: cell[1,nOps] - cell array of operations that
%          applied to the fields that are present only in the second
%          structure, each operation should return n arguments
%
%               default value: @deal
%
% Output:
%   S1: struct [n1,n2,...,nk,nOps] - contains the first outputs from operations
%   S2: struct [n1,n2,...,nk,nOps] - contains the second outputs from operations
%   ...
%   Sn: struct [n1,n2,...,nk,nOps] - contains n'th outputs from operatons
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%

if nargin<2
    error([upper(mfilename),':incorrectInput'],...
        'there should be at least 2 arguments');
end
%
sizeStructVec=size(leftStruct);
if ~(isstruct(leftStruct)&&isstruct(rightStruct)&&...
        auxchecksize(leftStruct,rightStruct,sizeStructVec))
    error([upper(mfilename),':incorrectInput'],...
        'first and second inputs should be structure arrays of the same size');
end
%
nDims=ndims(leftStruct);
%
if nargin<=2
    fieldOpCell={@binarynotdefined};
elseif isa(fieldOpCell,'function_handle')
    fieldOpCell={fieldOpCell};
end
%

nOps=length(fieldOpCell);
%
if nargin<=4
    rightFieldOpCell=repmat({@(x)deal(x)},1,nOps);
    if nargin<=3
        leftFieldOpCell=repmat({@(x)deal(x)},1,nOps);
    end

end
%
if isa(leftFieldOpCell,'function_handle')
    leftFieldOpCell={leftFieldOpCell};
end
%
if isa(rightFieldOpCell,'function_handle')
    rightFieldOpCell={rightFieldOpCell};
end
%
%
%
isValid=auxcheckfuncell(fieldOpCell);
if ~isValid
    error([upper(mfilename),':incorrectInput'],...
        'the third argument(fieldOpCell) should be a function handle or cell array of function handles');
end
%
isValid=auxcheckfuncell(leftFieldOpCell);
if ~isValid
    error([upper(mfilename),':incorrectInput'],...
        'the fourth argument(leftFieldOpCell) should be a function handle or cell array of function handles');
end
%
isValid=auxcheckfuncell(rightFieldOpCell);
if ~isValid
    error([upper(mfilename),':incorrectInput'],...
        'the fifth argument(rightFieldOpCell) should be a function handle or cell array of function handles');
end
%
leftFieldList=fieldnames(leftStruct);
rightFieldList=fieldnames(rightStruct);
unitedFieldList=reshape(union(leftFieldList,rightFieldList),[],1);
isLeftField=ismember(unitedFieldList,leftFieldList);
isRightField=ismember(unitedFieldList,rightFieldList);
isCommonField=isLeftField&isRightField;
%
nFields=length(unitedFieldList);
nFieldOps=length(fieldOpCell);
%
nArgout=nargout;
%this cell array will contain result
resCell=cell(nArgout,nFields);
%this field is a temporary variable containing result for a specific field
resTmpCell=cell(nArgout,1);
%
for iField=1:nFields
    fieldName=unitedFieldList{iField};
    if isCommonField(iField)
        for iFieldOp=1:nFieldOps
            %
            fieldOp=fieldOpCell{iFieldOp};
            %
            [resTmpCell{:}]=cellfun(fieldOp,reshape({leftStruct.(fieldName)},sizeStructVec),...
                reshape({rightStruct.(fieldName)},sizeStructVec),'UniformOutput',false);
            %
            updaterescell();
            %
        end
    elseif isLeftField(iField)
        for iFieldOp=1:nFieldOps
            leftFieldOp=leftFieldOpCell{iFieldOp};
            %
            [resTmpCell{:}]=cellfun(leftFieldOp,reshape({leftStruct.(fieldName)},sizeStructVec),...
                'UniformOutput',false);
            %
            updaterescell();
            %
        end
    else
        for iFieldOp=1:nFieldOps
            rightFieldOp=rightFieldOpCell{iFieldOp};
            %
            [resTmpCell{:}]=cellfun(rightFieldOp,reshape({rightStruct.(fieldName)},sizeStructVec),...
                'UniformOutput',false);
            %
            updaterescell();
            %
        end
    end
end
%
unitedFieldList=transpose(unitedFieldList);
%
for iOut=1:nArgout
    defCell=[unitedFieldList;resCell(iOut,:)];
    varargout{iOut}=struct(defCell{:});
end
    function updaterescell
        resCell(:,iField)=cellfun(@(x,y)cat(nDims+1,x,y),...
            resCell(:,iField),resTmpCell,'UniformOutput',false);
    end
end

function varargout=binarynotdefined(varargin)
varargout{:}=[];
error('BINARYUNIONSTRUCT:illegalOperation','common fields cannot be processed by default, binary operation required');
end

function isValid=auxcheckfuncell(fieldOpCell)
isValid=iscell(fieldOpCell);
if ~isValid
    isAllFuncVec=cellfun(@(x)isa(x,'function_handle'),fieldOpCell);
    isValid=all(isAllFuncVec);
end
end