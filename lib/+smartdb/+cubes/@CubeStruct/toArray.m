function varargout=toArray(self,varargin)
% TOARRAY - transforms values of all CubeStruct cells into a multi-
%           dimentional array
%
% Usage: resCArray=toArray(self,varargin)
%
% Input:
%   regular:
%     self: CubeStruct [1,1]
%
%   properties:
%     checkInputs: logical[1,1] - if false, the method skips checking the
%        input parameters for consistency
%
%     fieldNameList: cell[1,] - list of filed names to return
%
%     structNameList: cell[1,]/char[1,], data structure list
%        for which the data is to be taken from, can consist of the 
%        following values
%
%       SData - data itself
%       SIsNull - contains is-null indicator information for data values
%       SIsValueNull - contains is-null indicators for CubeStruct cells 
%          (not for cell values)
%
%     groupByColumns: logical[1,1], if true, each column is returned in a
%        separate cell
%
%     outputType: char[1,] - method of formign an output array, the
%        following methods are supported:
%            'uniformMat' - the field values are concatenated without any
%                    type/size transformations. As a result, this method 
%                    will fail if the specified fields have different types 
%                    or/and sizes along any dimension apart from catDim
%
%            'uniformCell' - not-cell fields are converted to cells
%                    element-wise but no size-transformations is performed.
%                    This method will fail if the specified fields have
%                    different sizes along any dimension apart from catDim
%
%            'notUniform' - this method doesn't make any assumptions about
%                    size or type of the fields. Each field value is wrapped 
%                    into cell in a such way that a size of resulting cell 
%                    is minDimensionSizeVec for each field. Thus if for
%                    instance is size of cube object is [2,3,4] and a field
%                    size is [2,4,5,10,30] its value is splitted into 2*4*5
%                    pieces with each piece of size [1,1,1,10,30] put it
%                    its separate cell
%            'adaptiveCell' - functions similarly to 'nonUniform' except for
%                    the cases when a field value size equals 
%                    minDimensionSizeVec exactly i.e. the field takes only 
%                    scalar values. In such cases no wrapping into cell is 
%                    performed which allows to get a more transparent  
%                    output.
%
%     catDim: double[1,1] - dimension number for
%        concatenating outputs when groupByColumns is false
%
%
%     replaceNull: logical[1,1], if true, null values from SData are
%        replaced by null replacement, = true by default
%
%     nullTopReplacement: - can be of any type and currently only applicable
%       when  UniformOutput=false and of
%       the corresponding column type if UniformOutput=true.
%
%       Note!: this parameter is disregarded for any dataStructure different
%          from 'SData'. 
%       
%       Note!: the main difference between this parameter and the following
%          parameters is that nullTopReplacement can violate field type
%          constraints thus allowing to replace doubles with strings for
%          instance (for non-uniform output types only of course)
%
%
%     nullReplacements: cell[1,nReplacedFields]  - list of null
%        replacements for each of the fields
%
%     nullReplacementFields: cell[1,nReplacedFields] - list of fields in
%        which the nulls are to be replaced with the specified values,
%        if not specified it is assumed that all fields are to be replaced
%
%        NOTE!: all fields not listed in this parameter are replaced with 
%        the default values
%
%
% Output:
%   Case1 (one output is requested and length(structNameList)==1):
%
%       resCMat: matrix/cell[]  with values of all fields (or
%         fields selected by optional arguments) for all CubeStruct
%         data cells
%
%   Case2 (multiple outputs are requested and their number = 
%     length(structNameList) each output is assigned resCMat for the 
%     corresponding struct
%
%   Case3 (2 outputs is requested or length(structNameList)+1 outputs is
%   requested). In this case the last output argument is
%
%        isConvertedToCell: logical[nFields,nStructs] -  matrix with true 
%           values on the positions which correspond to fields converted to 
%           cells
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-05-25 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.system.ExistanceChecker;
import modgen.common.num2cell;
import modgen.common.throwwarn;
%
s = warning('off', 'MATLAB:mat2cell:TrailingUnityVectorArgRemoved');
self.checkIfObjectScalar();
%
[reg,prop]=modgen.common.parseparams(varargin);
if ~isempty(reg)
    error([upper(mfilename),':wrongInput'],...
        ['property name-value sequence should not contain ',...
        'any regular arguments']);
end
nProp=length(prop);
isInputConsistencyChecked=true;
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'checkinputs',
            isInputConsistencyChecked=prop{k+1};
            prop([k k+1])=[];
            nProp=length(prop);
            break;
    end
end
%
if isInputConsistencyChecked
    [~,prop]=modgen.common.parseparams(varargin,[],0);
    nProp=length(prop);
    for k=1:2:nProp
        switch lower(prop{k})
            case {'fieldnamelist','structnamelist'}
                if ischar(prop{k+1})
                    prop{k+1}={prop{k+1}};
                end
                if ~iscellstr(prop{k+1})
                    error([upper(mfilename),':wrongInput'],...
                        '%s is expected to be a cell array of strings',prop{k});
                end
                switch lower(prop{k})
                    case 'fieldnamelist',
                        self.isFieldsCheck(prop{k+1});
                    case 'structnamelist',
                        self.checkStructNameList(prop{k+1});
                end
            case 'outputtype',
                if ~ischar(prop{k+1})
                    error([upper(mfilename),':wrongInput'],...
                        'outputType is expected to have a character type');
                end
                if ~any(ismember(lower(prop{k+1}),...
                        {'uniformcell','uniformmat','notuniform','adaptivecell'}))
                    error([upper(mfilename),':wrongInput'],...
                        'outputType=%s is not supported',prop{k+1});
                end
            case 'groupbycolumns',
                if ~islogical(prop{k+1})
                    error([upper(mfilename),':wrongInput'],...
                        'groupByColumns is expected to have a logical type');
                end
        end
    end
end
isGroupedByColumns=false;
minDim=self.getMinDimensionality;
minDimSizeVec=self.getMinDimensionSize();
catDim=minDim+1;
isCatDimSpecified=false;
nullReplaceArgList={};
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'structnamelist',...
                structNameList=prop{k+1};
        case 'nulltopreplacement',...
                nullTopReplacement=prop{k+1};
        case {'nullreplacementfields','nullreplacements'}
            nullReplaceArgList=[nullReplaceArgList,...
                prop([k,k+1])];
        case 'outputtype',...
                outputType=prop{k+1};
        case 'fieldnamelist',...
                fieldNameList=prop{k+1};
        case 'replacenull',
            isNullTopReplaced=prop{k+1};
        case 'groupbycolumns',
            isGroupedByColumns=prop{k+1};
        case 'catdim',
            catDim=prop{k+1};
            isCatDimSpecified=true;
        otherwise,
            error([upper(mfilename),':wrongInput'],...
                'unknown property: %s',prop{k});
    end
end
%
if ~modgen.system.ExistanceChecker.isVar('fieldNameList')
    fieldNameList=self.getFieldNameList();
else
    if ischar(fieldNameList)
        fieldNameList={fieldNameList};
    end
end
nFields=length(fieldNameList);
isConvertedToCellMat=false(nFields,3);
%
if ~ExistanceChecker.isVar('structNameList')
    structNameList={'SData'};
else
    if ischar(structNameList)
        structNameList={structNameList};
    end
end
[isSpecified,indLoc]=ismember(self.completeStructNameList,structNameList);
%
if ~ExistanceChecker.isVar('outputType')
    if ~isSpecified(1)&&~isSpecified(2)&&isSpecified(3)
        outputType='uniformMat';
    else
        outputType='adaptiveCell';
    end
end
%
if isGroupedByColumns&&isCatDimSpecified
    error([upper(mfilename),':wrongInput'],...
        'catDim only makes sense when groupByColumns=false');
end
%
if nFields==0
    if strcmpi(outputType,'uniformMat')||(nargout>1)||...
            ~isequal(isSpecified,[true false false])
        error([upper(mfilename),':noFields'],...
            ['cannot produce an array representation as ',...
            'the object contain no fields']);
    else
        if ~isGroupedByColumns
            resArray=cell([minDimSizeVec,0]);
        else
            resArray=cell(1,0);
        end
        if nargout==0
            if ~isGroupedByColumns
                showcell(resArray,'printVarName',false);
            else
                %do nothing
            end
        elseif nargout==1
            varargout{1}=resArray;
        end
    end
else

    if ~ExistanceChecker.isVar('nullTopReplacement')
        nullTopReplacement='NULL';
    end
    %
    if ExistanceChecker.isVar('isNullTopReplaced')
        if isNullTopReplaced &&~isSpecified(1)
            throwwarn('wrongInput',...
                'nullTopReplacement will be disregarded');
            isNullTopReplaced=false;
        end
        if isNullTopReplaced&&strcmpi(outputType,'uniformMat')
            throwwarn('wrongInput',...
                ['nullTopReplacement will be disregarded as it is not ',...
                'yet supported for outputType=uniformMat']);
            isNullTopReplaced=false;
        end
    else
        isNullTopReplaced=~strcmpi(outputType,'uniformMat');
        if ~isNullTopReplaced&&(isSpecified(1)||isSpecified(2))
            isNullInFieldVec=false(1,nFields);
            for iField=1:nFields
                fieldName=fieldNameList{iField};
                if any(self.SIsValueNull.(fieldName)(:))
                    isNullInFieldVec(iField)=true;
                end
                %
            end
            if any(isNullInFieldVec)
                throwwarn('wrongInput:garbageFields',...
                    ['the output will containt some garbage as field(s) (%s) ',...
                    'contain null values'],...
                    modgen.string.catwithsep(fieldNameList(isNullInFieldVec),','));
            end
        end
    end
    resCVec=toFieldListInternal(self,fieldNameList,structNameList);
    isFieldNullVec=self.getIsFieldValueNull();
    if isNullTopReplaced
        isNullTopReplacedVec=true(1,nFields);
    else
        isNullTopReplacedVec=isFieldNullVec;
    end
    %
    switch lower(outputType)
        case 'uniformcell',
            for iStruct=1:3
                if isSpecified(iStruct)
                    isNotCell=~cellfun('isclass',resCVec{indLoc(iStruct)},'cell');
                    resCVec{indLoc(iStruct)}(isNotCell)=cellfun(...
                        @num2cell,resCVec{indLoc(iStruct)}(isNotCell),...
                        'UniformOutput',false);
                    isConvertedToCellMat(:,iStruct)=isNotCell;
                end
            end
        case 'notuniform',
            for iStruct=1:3
                if isSpecified(iStruct)
                    num2CellArgList=cellfun(@getMat2CellArgList,...
                        resCVec{indLoc(iStruct)},'UniformOutput',false);
                    resCVec{indLoc(iStruct)}=cellfun(...
                        @(x,y)mat2cell(x,y{:}),...
                        resCVec{indLoc(iStruct)},num2CellArgList,...
                        'UniformOutput',false);
                    isConvertedToCellMat(:,iStruct)=true;
                end
            end
        case 'adaptivecell',
            for iStruct=1:3
                if isSpecified(iStruct)
                    isCellVec=cellfun('isclass',resCVec{indLoc(iStruct)},'cell');
                    isVectorialVec=cellfun('ndims',resCVec{indLoc(iStruct)})>2|...
                        cellfun('size',resCVec{indLoc(iStruct)},2)~=1;
                    isToCellVec=~isCellVec|isCellVec&isVectorialVec;
                    %
                    num2CellArgList=cellfun(@getMat2CellArgList,...
                        resCVec{indLoc(iStruct)}(isToCellVec),'UniformOutput',false);
                    resCVec{indLoc(iStruct)}(isToCellVec)=cellfun(...
                        @(x,y)mat2cell(x,y{:}),...
                        resCVec{indLoc(iStruct)}(isToCellVec),num2CellArgList,...
                        'UniformOutput',false);
                    isConvertedToCellMat(:,iStruct)=isToCellVec;
                end
            end
        case 'uniformmat',
            %do nothing
        otherwise,
            error([upper(mfilename),':wrongInput'],...
                'Oops, we should be here');
    end
    %
    if isNullTopReplaced&&isSpecified(1)
        if isSpecified(3)&&all(cellfun('isclass',resCVec{indLoc(3)},'logical'))
            isNullCVec=resCVec(indLoc(3));
        else
            isNullCVec=toFieldListInternal(self,fieldNameList,{'SIsValueNull'});
        end
        nullRepMatSizeVec=[minDimSizeVec,1];
        for iField=1:nFields
            if isNullTopReplacedVec(iField)
                if isFieldNullVec(iField)
                    resCVec{indLoc(1)}{iField}=repmat({nullTopReplacement},nullRepMatSizeVec);
                else
                    resCVec{indLoc(1)}{iField}(isNullCVec{1}{iField})={nullTopReplacement};
                end
            end
        end
    end
    %
    isConvertedToCellMat=isConvertedToCellMat(:,isSpecified);
    %
    if ~isGroupedByColumns
        try
            resCVec=cellfun(@(x)cat(catDim,x{:}),resCVec,'UniformOutput',false);
            %if a number of Cube elements is zero we redefine an output to make
            %sure that it is of a proper size
%             if self.getNElems==0&&~strcmpi(outputType,'uniformMat')
%                 for iStruct=1:2
%                     if isSpecified(iStruct)
%                         nMaxDim=max(self.getMinDimensionality,catDim);
%                         sizeVec=zeros(1,nMaxDim);
%                         sizeVec(catDim)=length(fieldNameList);
%                         resCVec{indLoc(iStruct)}=cell(sizeVec);
%                     end
%                 end
%             end
        catch meObj
            if strcmpi(outputType,'notUniform')||strcmpi(outputType,'adaptive')
                newMeObj=MException([upper(mfilename),':cannotDoCat'],...
                    'Oops, we should not be here...');
            else
                newMeObj=MException([upper(mfilename),':cannotDoCat'],...
                    ['Concatenation is not possible as the selected ',...
                    'fields have incompatible types or dimensions, ',...
                    'try different outputType']);
            end
            %
            newMeObj=addCause(newMeObj,meObj);
            throw(newMeObj);
        end
        %
    end
    if nargout==0
        if ~isGroupedByColumns
            resArray=cat(catDim,resCVec{:});
            if ~iscell(resArray)
                resArray=num2cell(resArray);
            end
            showcell(resArray,'printVarName',false);
        else
            %do nothing
        end
    elseif nargout==1
        if ~isGroupedByColumns
            varargout{1}=cat(catDim,resCVec{:});
        else
            varargout{1}=cat(2,resCVec{:});
        end
        %
    elseif nargout==length(structNameList)
        varargout=resCVec;
        %
    elseif nargout==2
        if ~isGroupedByColumns
            varargout{1}=cat(catDim,resCVec{:});
        else
            varargout{1}=cat(2,resCVec{:});
        end
        varargout{2}=isConvertedToCellMat;
        %
    elseif nargout==(length(structNameList)+1)
        varargout=[resCVec,{isConvertedToCellMat}];
        %
    else
        error([upper(mfilename),':wrongInput'],...
            'a number of output arguments is incompatible with structNameList');
    end
    warning(s);
end
    function inpArgList=getMat2CellArgList(x)
        maxDim=max(minDim,ndims(x));
        sizeVec=modgen.common.getfirstdimsize(x,maxDim+1);
        inpArgList=num2cell(sizeVec(1:minDim));
        inpArgList=cellfun(@(x)ones(x,1),inpArgList,...
            'UniformOutput',false);
        sizeValueVec=sizeVec(minDim+1:end);
        if any(sizeValueVec~=1)
            inpArgList=[inpArgList,num2cell(sizeValueVec)];
        end
    end
%
    function resCVec=toFieldListInternal(self,fieldNameList,structNameList)
        resCVec=cell(size(structNameList));
        [fieldUniqueNameList,~,indBackward]=unique(fieldNameList);
        if ~isequal(length(fieldUniqueNameList),length(fieldNameList))
            [resCVec{:}]=self.getDataInternal('structNameList',structNameList,...
                'fieldNameList',fieldUniqueNameList,nullReplaceArgList{:});
            resCVec=cellfun(@(x)transpose(struct2cell(x)),resCVec,'UniformOutput',false);
            resCVec=cellfun(@(x)x(indBackward),resCVec,'UniformOutput',false);
        else
            [resCVec{:}]=self.getDataInternal('structNameList',structNameList,...
                'fieldNameList',fieldNameList,nullReplaceArgList{:});
            resCVec=cellfun(@(x)transpose(struct2cell(x)),...
                resCVec,'UniformOutput',false);
        end
    end
end