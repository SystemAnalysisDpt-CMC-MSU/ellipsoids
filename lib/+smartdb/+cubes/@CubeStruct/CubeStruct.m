classdef CubeStruct<dynamicprops&modgen.common.obj.HandleObjectCloner&...
        smartdb.cubes.IDynamicCubeStructInternal
    % CUBESTRUCT provides a basic functionality for implementing both
    % ARelation and Cube classes
    %
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-28 $ 
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2012 $
    %
    %
    properties (Access=protected,Hidden,Dependent=true,Transient=true)
        %
        fieldNameList
        fieldDescrList
        fieldTypeSpecList
    end
    properties(Access=private)
        minDimensionality
        %minimum dimensionality (=1 for relations and = # of keys for cubes)
        %of field values
    end
    %
    properties (Constant,GetAccess=protected)
        completeStructNameList={'SData','SIsNull','SIsValueNull'};        
        DEFAULT_MIN_DIMENSIONALITY=0
    end
    %
    properties (Access=private, Hidden)
        fieldMetaData=smartdb.cubes.CubeStructFieldInfo(zeros(1,0))
        %
    end
    properties(Access=private,Hidden)
        SData=struct()
        SIsNull=struct()
        SIsValueNull=struct()
    end
    %
    methods (Access=private)
        %
        [isThereVec,indLocVec]=getIsFieldVec(self,fieldNameList)
        %
        [isThereVec,indLocVec]=getIsFieldVecCheck(self,fieldNameList)
        %
        function setMinDimensionality(self,minDimensionality)
            self.minDimensionality=minDimensionality;
        end
    end
    methods (Abstract,Access=protected)
        initialize(self,varargin)
        % INITIALIZE method is to be implemented by derived classes and
        % serves for setting values of fieldNameList and fieldDescrList
        % fields
    end
    methods (Access=protected)
        displayInternal(self,typeStr,varargin)
    end
    methods
        function display(self,varargin)
            % DISPLAY - puts some textual information about CubeStruct object in screen
            % 
            % Input:
            %  regular:
            %      self.
            %
            self.displayInternal('CubeStruct',varargin{:});
        end
    end
    methods
        function self=CubeStruct(varargin)
            % CUBESTRUCT - constructor for CubeStruct class
            %
            % Input:
            %   Case1 (copy constructor):
            %       regular:
            %          cubeObj: CubeStruct: [1,1]
            %   
            %   Case2 (building from structures):
            %       regular:
            %           SData: struct[1,1]
            %       optional:
            %
            %           SIsNull: struct[1,1]
            %           SIsValueNull: struct[1,1]
            %
            %       properties:
            %           SubCase1:
            %               fieldMetaData: CubeStructFieldInfo[1,nFields] - an
            %                   array of field meta data objects, 
            %           SubCase2:
            %
            %               fieldNameList: char cell [1,nFields] - list of 
            %                   names for fields of given object
            %
            %               fieldDescrList: char cell [1,nFields] - list of
            %                   descriptions for fields of given object
            %
            %               fieldTypeSpecList: cell[1,nFields] of cell of 
            %                   char - field type specification            
            %
            %           minDimensionality: numeric[1,1] - minimum
            %               dimensionality of CubeStruct field values.
            %               Use minDimensionality=1 for relations and
            %               minDimensionality=# of keys for cubes
            %
            %           checkConsistency: logical[1,1] - determines if
            %               consistency of input data structures is checked
            %
            %           structNameList: cell[] of char - determines which
            %               structures are specified on input
            %
            %           checkstruct: logical[1,1] - determines if presence of
            %               all relation fields in the input structures is checked
            %
            % Output:
            %   self: CubeStruct[1,1] - created object
            %
            %
            minDimensionality=...
                smartdb.cubes.CubeStruct.DEFAULT_MIN_DIMENSIONALITY;
            %
            [reg,prop]=modgen.common.parseparams(varargin);
            nReg=length(reg);
            if nReg>=1
                isCubeObjectOnInput= smartdb.cubes.CubeStruct.isMe(reg{1});
            else
                isCubeObjectOnInput=false;
            end
            %
            if ~isCubeObjectOnInput && nReg>3
                error([upper(mfilename),':wrongInput'],...
                    'incorrect number of regular arguments');
            end
            %
            if isCubeObjectOnInput
                if ~(numel(prop)==0||numel(prop)==2&&...
                        strcmpi(prop{1},'minDimensionality'))
                    %
                    error([upper(mfilename),':wrongInput'],...
                        ['when CubeStruct object is on input ',...
                        'no properties apart from minDimensionality ',...
                        '(which is ignored) is allowed']);
                end
                %
                if isempty(reg{1})
                    self=self.empty(size(reg{1}));
                else
                    self=repmatAuxInternal(self,size(reg{1}));
                    self.copyFromInternal(reg{:});
                end
            else
                isConsistencySpecified=false;
                isStructCheckedSpecified=false;
                isStructNameListSpecified=false;
                indPropDelVec=[];
                for k=1:2:length(prop)-1
                    switch lower(prop{k})
                        case 'structnamelist',
                            isStructNameListSpecified=true;
                            structNameList=prop{k+1};
                            indPropDelVec=[indPropDelVec,[k,k+1]];
                        case 'checkconsistency',
                            isCheckConsistency=prop{k+1};
                            isConsistencySpecified=true;
                            indPropDelVec=[indPropDelVec,[k,k+1]];
                        case 'mindimensionality',
                            minDimensionality=prop{k+1};
                            if ~isnumeric(minDimensionality)||minDimensionality<0
                                error([mfilename,':wrongInput'],...
                                    'minDimension is expected to be a non-negative number');
                            end
                            indPropDelVec=[indPropDelVec,[k,k+1]];
                        case 'checkstruct',
                            isStructCheckedVec=prop{k+1};
                            isStructCheckedSpecified=true;
                            indPropDelVec=[indPropDelVec,[k,k+1]];
                    end
                end
                prop(indPropDelVec)=[];
                %
                smartdb.cubes.CubeStructFieldInfoBuilder.flush();
                smartdb.cubes.CubeStructFieldInfoBuilder.setCubeStructRef(self);
                self.initialize(prop{:});
                self.setMinDimensionality(minDimensionality);
                %
                if isConsistencySpecified
                    inpArgList={'checkConsistency',isCheckConsistency};
                else
                    inpArgList={};
                end
                %
                if isStructCheckedSpecified
                    inpArgList=[inpArgList,{'checkStruct',isStructCheckedVec}];
                end
                %
                if isStructNameListSpecified
                    inpArgList=[inpArgList,{'structNameList',structNameList}];
                end
                %
                fieldMetaData=...
                    smartdb.cubes.CubeStructFieldInfoBuilder.build();
                %
                self.setDataInternal(reg{:},...
                    'transactionSafe',false,...
                    'fieldMetaData',fieldMetaData,...
                    inpArgList{:},'dataChangeIsComplete',false);
                %
                smartdb.cubes.CubeStructFieldInfoBuilder.flush();
                %
                self.defineFieldsAsProps();
                self.changeDataPostHook();
            end
            %
            %
        end
        function fieldNameList=get.fieldNameList(self)
            fieldNameList=self.fieldMetaData.getNameList;
        end
        %
        function fieldDescrList=get.fieldDescrList(self)
            fieldDescrList=self.fieldMetaData.getDescriptionList();
        end
        %
        function set.fieldNameList(~,fieldNameList)
            smartdb.cubes.CubeStructFieldInfoBuilder.setNameList(fieldNameList);
        end
        %
        function set.fieldDescrList(~,fieldDescrList)
            smartdb.cubes.CubeStructFieldInfoBuilder.setDescrList(fieldDescrList);
        end
        %
        function set.fieldTypeSpecList(self,fieldTypeSpecList)
            smartdb.cubes.CubeStructFieldInfoBuilder.setTypeSpecList(fieldTypeSpecList);
        end
        %
    end
    methods (Hidden, Sealed)
        %we use getField internally which justifies Sealed access modifier
        propVal=getField(self,fieldName)
    end
    methods (Access=protected,Static,Hidden)
        inpArgList=inferFieldNamesFromSData(inpArgList)
        outObj=loadobj(inpObj)
        function isPositive=isMe(inpObj)
            curClassName=mfilename('class');
            isPositive=isa(inpObj,curClassName);
        end
        function prohibitProperty(propNameList,inpList)
            if ischar(propNameList)
                propNameList={propNameList};
            end
            for iProp=1:numel(propNameList)
                if any(strcmpi(propNameList{iProp},inpList))
                    error([upper(mfilename),':wrongInput'],...
                        'property %s is not supported in this context',...
                        propNameList{iProp});
                end
            end
        end        
    end
    methods (Access=private, Hidden)
        SObjectData=saveObjInternal(self,varargin)
        loadObjInternal(self,SObjectData,varargin)
    end
    methods (Access=protected, Hidden)
        minDimensionSizeVec=getMinDimensionSizeInternal(self,dimNumVec,varargin)
        % GETMINDIMENSIONSIZE returns a size vector for the specified
        % dimensions. If no dimensions are specified, a size vector for
        % all dimensions up to minimum CubeStruct dimension is returned
        function changeDataPostHook(~)
        end
        copyFromInternal(self,obj,varargin)
    end
    methods (Access=protected, Hidden,Sealed)
        minDimensionSizeVec=getMinDimensionSizeByDataInternal(self,dimNumVec,varargin)
        nFields=getNFieldsInternal(self,varargin)
        nElems=getNElemsInternal(self,varargin)
        varargout=applyTupleGetFuncInternal(self,varargin)
        resVec=applyGetFuncInternal(self,varargin)
        % APPLYGETFUNC applies a function to the specified fields as columns, i.e.
        % the function is applied to each field as whole, not to each cell
        % separately
        
        sizeMat=getFieldValueSizeMatInternal(self,varargin)
        %
        varargout=getDataInternal(self,varargin)
        % GETDATAINTERNAL returns an indexed projection of CubeStruct object's
        % content   
        %
        parseAndAssignFieldProps(self,varargin)
        %
        defineFieldsAsProps(self,fieldNameList)
        %
        reorderFieldsInternal(self,indReorderVec)
        %
        catWithInternal(self,inpObj,varargin)
        %
        addFieldsInternal(self,addFieldNameList,varargin)
        removeFieldsInternal(self,removeFieldList)
        setDataInternal(self,varargin)
        %
        % SETDATAINTERNAL sets values of all cells for all fields          
        %the following methods are used by CubeStruct 
        %internal methods which makes it dangereous to leave them open 
        %for redefinition. To protect them we use Sealed access modifier.
        %
        function checkIfObjectScalar(self)
            if numel(self)~=1
                error([upper(mfilename),':noScalarObj'],...
                    'only scalar objects are supported');
            end
        end        
        %
        applySetFuncInternal(self,hFunc,toFieldNameList,varargin)        
        %
        sortInd=getSortIndexInternal(self,sortFieldNameList,sortDim,varargin)
        %
        function fieldMetaDataVec=getFieldMetaData(self,fieldNameList)
            fieldMetaDataVec=self.fieldMetaData;
            if nargin==2
                fieldMetaDataVec=fieldMetaDataVec.filterByName(fieldNameList);
            end
        end
        %
        function setFieldMetaData(self,fieldMetaData,fieldNameList)
            if nargin<=2
                inpArgList={};
                isFieldNameListSpec=false;
            else
                inpArgList={fieldNameList};
                isFieldNameListSpec=true;
            end
            curFieldMetaData=self.getFieldMetaData(inpArgList{:});
            isEmptyMd=~isFieldNameListSpec&&isempty(curFieldMetaData);
            %
            isCopy=~isEmptyMd&&...
                (numel(curFieldMetaData)==numel(fieldMetaData));
            %
            if isCopy
                curFieldMetaData.copyFrom(fieldMetaData);
            else
                self.fieldMetaData=fieldMetaData;
            end
        end
        function setDefaultFieldType(self,fieldNameList)
            if nargin==1
                fieldNameList=self.getFieldNameList();
            end
            if ischar(fieldNameList)
                fieldNameList={fieldNameList};
            end
            setDefaultType(self.getFieldMetaData(fieldNameList));
        end
        inferFieldMetaData(self,fieldNameList)
        %
        [valueVec,isNullVec,isValueNullVec]=generateDefaultFieldValue(self,varargin)
        %
        [SDataNew,SIsNullNew,SIsValueNullNew]=generateDefaultDataSet(self,varargin)
        %
        [SDataNew,SIsNullNew,SIsValueNullNew]=generateEmptyDataSet(self,varargin)
        %
        renameFieldsInternal(self,fromFieldNameList,toFieldNameList,...
            toFieldDescrList)
        %
        isFieldsCheck(self,fieldList,isUniquenessChecked)
        %
        inferSIsValueNullIfEmpty(self)
        %
        fieldMetaData=checkFieldValue(self,isConsistencyChecked,fieldName,varargin)
        %
        checkStructNameList(self,structNameList,isCorrectnessChecked)
        % CHECKSTRUCTNAMELIST checks that the field name list is consistent with
        % the list of the field names for CubeStruct object in question
        %
        newFieldMetaData=checkData(self,isConsistencyChecked,varargin)
        % CHECKSTRUCTSFORCONSISTENCY verifies SData,SIsNull and SIsValueNull
        % structures for consistency
        %
        function [isPositive,errorStr]=isFieldSizeValid(self,value)
            % ISFIELDSIZEVALID checks if the specified field value has a
            % correct size for a given CubeStruct object
            %
            %
            leadDimVec=self.getMinDimensionSizeInternal();
            isPositive=modgen.common.isfirstdimsizeasspecified(value,...
                leadDimVec);
            if ~isPositive
                errorStr=sprintf(['field have size %s while expected ',...
                    'leading dim size is %s'],...
                    mat2str(size(value)),mat2str(leadDimVec));
            else
                errorStr='';
            end
        end
        %
        [SData,SIsNull,SIsValueNull]=replaceNullsInStruct(self,SData,SIsNull,SIsValueNull,varargin)
        % REPLACENULLS replaces the values corresponding to nulls with the
        % stubs
        %
        checkStruct(self,SData,isFieldConsistencyChecked,fieldNameList)
        % CHECKSTRUCT perform check that input structure may be
        % structure containing values of all cells for all fields
        %
        checkValueVsIsNull(self,varargin)
        % CHECKVALUEVSISNULL checks a consistency between a value
        % vector for a certain field and is-null vector for the same
        % field. In case of no consistency the exception is risen
        %
        clearFieldsAsProps(self,clearFieldNameList)
        addDataAlongDimInternal(self,catDimension,varargin)
        varargout=removeDuplicatesAlongDimInternal(self,catDim,varargin)
        % REMOVEDUPLICATESALONGDIM removes duplicates in CubeStruct object
        % along a specified dimension
        varargout=getUniqueDataAlongDimInternal(self,catDim,varargin) 
        [isThere indTheres]=isMemberAlongDimInternal(self,other,dimNum,varargin)
        % ISMEMBERALONGDIM - performs ismember operation of CubeStruct data slices
        %                    along the specified dimension        
        permuteDimInternal(self,dimOrderVec,isInvPermute)        
        sortByAlongDimInternal(self,sortFieldNameList,sortDim,varargin)        
        changeMinDimInternal(self,minDim)
        reorderDataInternal(self,varargin)        
        %The following methods being public are still used by CubeStruct 
        %internal methods which makes it dangereous to leave them open 
        %for redefinition. To protect them we use Sealed access modifier.
        clearDataInternal(self)
        reshapeDataInternal(self,sizeVec)
        unionWithAlongDimInternal(self,unionDim,varargin) 
        setFieldInternal(self,fieldName,varargin)
        %
        % SETFIELD sets values of all cells for given field
        function self=repmatAuxInternal(self,sizeVec)
            nElem=prod(sizeVec);
            if nElem>1
                self(nElem)=self.createInstance();
                for iElem=2:nElem-1
                    self(iElem).defineFieldsAsProps();
                end
                self=reshape(self,sizeVec);
            end
        end
    end
    methods (Sealed)
        varargout=toArray(self,varargin)
        % TOARRAY transforms values of all fields for all CubeStruct cells
        % into a multi-dimentional array    
        value=getFieldDescrList(self,fieldNameList)
        % GETFIELDDESCRLIST returns the list of CubeStruct field
        % descriptions 
        fieldIsNullCVec=getFieldIsNull(self,fieldName)
        % GETFIELDISNULL returns for given field a nested logical/cell
        % array containing is-null indicators for cell content        
        fieldIsNullCVec=getFieldIsValueNull(self,fieldName)
        % GETFIELDISVALUENULL returns for given field logical vector
        % determining whether value of this field in each cell is null
        % or not. 
        value=getFieldNameList(self)
        % GETFIELDNAMELIST returns the list of CubeStruct object field names        
        typeInfoList=getFieldTypeList(self,varargin)
        % GETFIELDTYPELIST returns list of field types in given CubeStruct object        
        typeSpecList=getFieldTypeSpecList(self,varargin)
        % GETFIELDTYPESPECLIST returns a list of field type specifications. Field
        % type specification is a sequence of type names corresponding to field
        % value types starting with the top level and going down into the nested
        % content of a field (for a field having a complex type).        
        nElems=getNElems(self)
        % GETNELEMS returns a number of elements in a given object        
        nFields=getNFields(self)
        % GETNFIELDS returns number of fields in given object        
        [isPositive,isUniqueFields,isThereVec]=isFields(self,fieldList)
        % ISFIELDS returns whether all fields whose names are given in
        % the input list are in the field list of given object or not
        s=toStruct(obj) 
        %
        sizeMat=getFieldValueSizeMat(self,varargin)
        % GETFIELDVALUESIZEMAT returns a matrix composed from the size
        % vectros for the specified fields
        %    
        function minDimensionality=getMinDimensionality(self)
            % GETMINDIMENSIONALITY - returns a minimum dimensionality for a given 
            %                        object
            %
            % Input:
            %   regular:
            %       self
            %
            % Output:
            %   minDimensionality: double[1,1] - minimum dimensionality of
            %      self object
            %
            %
            minDimensionality=self.minDimensionality;
        end
    end
    methods (Static)
        relDataObj=fromStructList(catDim,className,structList)
            % FROMSTRUCTLIST - creates an object of specified type from a list of 
            %                  structures interpreting each structure as the data for 
            %                  several CubeStruct data slices.
            %        
    end
end