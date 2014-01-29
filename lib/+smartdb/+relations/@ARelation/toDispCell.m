function dataCell=toDispCell(self,varargin)
% TODISPCELL - transforms values of all fields into their character
%              representation
%
% Usage: resCMat=toDispCell(self)
%
% Input:
%   regular:
%     self: ARelation [1,1] - class object
%     
%   properties:
%       nullTopReplacement: any[1,1] - value used to replace null values
%       fieldNameList: cell[1,] of char[1,] - field name list
%
% Output:
%   dataCell: cell[nRows,nCols] of char[1,] - cell array containing the
%       character representation of field values
%   
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-04-06 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
NUM_TYPE_LIST={'int8','int16','int32','int64','uint8',...
    'uint16','uint32','uint64','double','single'};
N_MAX_DISP_ELEM=20;
self=smartdb.relations.DynamicRelation(self);
[~,~,fieldNameList]=modgen.common.parseparext(varargin,...
    {'fieldNameList';self.getFieldNameList()});
nFields=length(fieldNameList);
%
isScalarVec=prod(...
    self.getFieldValueSizeMat(fieldNameList,...
    'skipMinDimensions',true),2)==1;
isScalarList=num2cell(isScalarVec);
fieldTypeSpecList=self.getFieldTypeSpecList(fieldNameList);
isNumFieldVec=cellfun(@checkTypeFunc,...
    fieldTypeSpecList,isScalarList.');
%
isCCCharVec=cellfun(@(x)isequal(x,{'cell','cell','char'}),...
    fieldTypeSpecList);
isCCharVec=cellfun(@(x)isequal(x,{'cell','char'}),...
    fieldTypeSpecList);
%
for iField=1:nFields
    fieldName=fieldNameList{iField};
    if isNumFieldVec(iField)
        self.applySetFunc(@customMat2Str,{fieldName},...
            'UniformOutput',false,'inferIsNull',[true false]);
    elseif isCCCharVec(iField)
        self.applySetFunc(@charMat2Str,{fieldName},...
            'UniformOutput',false,'inferIsNull',[true false]);
    elseif isCCharVec(iField)
        if ~isScalarVec(iField)
            self.applySetFunc(@charMat2Str,{fieldName},...
                'UniformOutput',false,'inferIsNull',[true false],...
                'inputType','notUniform');
        end
    else 
        self.applySetFunc(@any2ClassStr,{fieldName},...
            'UniformOutput',false,'inferIsNull',[true false],...
            'inputType','notUniform');
    end
end
dataCell=self.toMat(varargin{:});
    function res=charMat2Str(x)
        MAX_TOTAL_LENGTH=64;
        nDims=ndims(x);
        if nDims==2&&...
                numel(x)<=N_MAX_DISP_ELEM&&...
                sum(reshape(cellfun('prodofsize',x),[],1))<=...
                MAX_TOTAL_LENGTH;
            res=modgen.cell.cellstr2expression(x);
        else
            res=any2ClassStr(x);
        end
    end
    function res=customMat2Str(x)
        nDims=ndims(x);
        if nDims==2&&numel(x)<=N_MAX_DISP_ELEM
            res=mat2str(x);
        else
            res=any2ClassStr(x);
        end
    end
    function res=any2ClassStr(x)
        res=[class(x),'[',modgen.string.catwithsep(...
            cellfun(@num2str,num2cell(size(x)),...
            'UniformOutput',false),'x'),']'];
    end
    function isPos=checkTypeFunc(x,isScalar)
        isPos=numel(x)==1&&any(strcmp(x,NUM_TYPE_LIST))||...
            numel(x)==2&&any(strcmp(x{2},NUM_TYPE_LIST))&&isScalar;
    end
end