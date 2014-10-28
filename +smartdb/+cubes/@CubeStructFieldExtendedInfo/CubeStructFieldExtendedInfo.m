classdef CubeStructFieldExtendedInfo<smartdb.cubes.CubeStructFieldInfo
    % CUBESTRUCTFIELDEXTENDEDINFO is a container for an extended
    % information about CubeStruct field
    %
    %
    % $Author: Ilya Roublev  <iroublev@gmail.com> $	$Date: 2014-07-10 $ 
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2014 $
    %
    %
    properties (Access=protected,Hidden)
        %
        % pattern for size along some dimensions, if i-th element equals to
        % NaN, then the size along this dimension is arbitrary, otherwise
        % this size should be exactely equal to the element of the pattern
        sizePatternVec=nan(1,0)
        % if true, then sizes along dimensions for which pattern in
        % sizePatternVec is not given should be equal to 1 (i.e. the number
        % of dimensions of field data should not exceed those given in the
        % pattern), otherwise the sizes along these additional dimensions
        % may be arbitrary
        isSizeAlongAddDimsEqualOne=false
        % if true, then values of field should be unique (uniqueness is
        % determine for the pair of value and isNull), in this case
        % isValueNull should be equal to false for all elements; otherwise
        % no restriction on uniqueness exists
        isUniqueValues=false
        %
    end
    methods
        function copyFrom(self,obj)
            copyFrom@smartdb.cubes.CubeStructFieldInfo(self,obj);
            if ~isempty(obj),
                sizePatternVecList=obj.getSizePatternVecList();
                [self.sizePatternVec]=deal(sizePatternVecList{:});
                %
                isSizeAlongAddDimsEqualOneMat=...
                    num2cell(obj.getIsSizeAlongAddDimsEqualOneMat());
                [self.isSizeAlongAddDimsEqualOne]=...
                    deal(isSizeAlongAddDimsEqualOneMat{:});
                %
                isUniqueValuesMat=num2cell(obj.getIsUniqueValuesMat());
                [self.isUniqueValues]=deal(isUniqueValuesMat{:});
            end
        end
        function set.sizePatternVec(self,value)
            errorMessageStr=['sizePatternVec field is expected to be '...
                'numeric row vector with each value being either '...
                'nonnegive integer or NaN'];
            modgen.common.checkvar(value,...
                'isnumeric(x)&&isreal(x)&&(isrow(x)||isempty(x))',...
                'errorTag','wrongInput','errorMessage',errorMessageStr);
            value=double(reshape(value,1,[]));
            if ~all(isnan(value)|(...
                    isfinite(value)&floor(value)==value&value>=0)),
                modgen.common.throwerror('wrongInput',...
                    errorMessageStr);
            end
            self.sizePatternVec=value;
        end
        function set.isSizeAlongAddDimsEqualOne(self,value)
            modgen.common.checkvar(value,...
                'isscalar(x)&&islogical(x)',...
                'errorTag','wrongInput','errorMessage',[...
                'isSizeAlongAddDimsEqualOne field is expected to be '...
                'scalar logical']);
            self.isSizeAlongAddDimsEqualOne=value;
        end
        function set.isUniqueValues(self,value)
            modgen.common.checkvar(value,...
                'isscalar(x)&&islogical(x)',...
                'errorTag','wrongInput','errorMessage',[...
                'isUniqueValues field is expected to be '...
                'scalar logical']);
            self.isUniqueValues=value;
        end
    end
    %
    methods (Static, Access=protected)
        function inpArgList=processCustomArrayArgList(varargin)
            inpArgList=...
                processCustomArrayArgList@smartdb.cubes.CubeStructFieldInfo(varargin{:});
            if nargin>=5
                inpArgList=[inpArgList,{'sizePatternVecList',varargin{5}}];
            end
            %
            if nargin>=6
                inpArgList=[inpArgList,{'isSizeAlongAddDimsEqualOneMat',...
                    varargin{6}}];
            end
            %
            if nargin>=7
                inpArgList=[inpArgList,{'isUniqueValuesMat',varargin{7}}];
            end
        end
    end
    methods (Access=protected)
        SObjectData=saveObjInternal(self)
        % SAVEOBJINTERNAL saves a current object state to a structure,
        %    please note that this function is only used for implementing
        %    isEqual method
        %
        
        resArray=buildArrayByProp(self,cubeStructRefList,varargin)
        % BUILDARRAYBYPROP is a helper method for filling an object arrays
        % with the specified properties        
    end
    methods (Static)
        resArray=customArray(cubeStructRef,nameList,descriptionList,...
            typeSpecList,sizePatternVecList,...
            isSizeAlongAddDimsEqualOneMat,isUniqueValuesMat)
        resArray=defaultArray(cubeStructRefList,sizeVec)
        %
        function isPositive=isMe(inpObj)
            curClassName=mfilename('class');
            isPositive=isa(inpObj,curClassName);
        end
    end
    methods
        function self=CubeStructFieldExtendedInfo(varargin)
            % CUBESTRUCTFIELDEXTENDEDINFO is a constructor for the class of
            % the same name
            %
            % Input:
            %
            %   Case0 (default construtor): no input parameters
            %
            %   Case1 (copy constructor):
            %       obj: CubeStructFieldExtendedInfo[] - object array which
            %           served as a prototype for a constructed object
            %           array of the same size
            %
            %   Case2 (property-based constructor):
            %       see a documentation for buildArrayByProp method for a
            %          list of allowed properties
            %
            %
            % Output:
            %   self: CubeStructFieldExtendedInfo[] - constructed object
            %       array
            %
            %
            
            self@smartdb.cubes.CubeStructFieldInfo(varargin{:});
        end
        %
        function fieldSizePatternVec=getSizePatternVec(self)
            import modgen.common.throwerror;
            if numel(self)~=1
                throwerror('wrongInput',...
                    'this method only works for scalar objects');
            end
            fieldSizePatternVec=self.sizePatternVec;
        end
        %
        function fieldSizePatternVecList=getSizePatternVecList(self)
            if ~isempty(self)
                fieldSizePatternVecList={self.sizePatternVec};
                fieldSizePatternVecList=reshape(fieldSizePatternVecList,...
                    size(self));
            else
                fieldSizePatternVecList=cell.empty(size(self));
            end
        end
        %
        function setSizePatternVecList(self,valueList)
            if ~isempty(self)
                [self.sizePatternVec]=deal(valueList{:});
            end
        end
        %
        function fieldIsSizeAlongAddDimsEqualOne=getIsSizeAlongAddDimsEqualOne(self)
            import modgen.common.throwerror;
            if numel(self)~=1
                throwerror('wrongInput',...
                    'this method only works for scalar objects');
            end
            fieldIsSizeAlongAddDimsEqualOne=self.isSizeAlongAddDimsEqualOne;
        end
        %
        function fieldIsSizeAlongAddDimsEqualOneMat=...
                getIsSizeAlongAddDimsEqualOneMat(self)
            if ~isempty(self)
                fieldIsSizeAlongAddDimsEqualOneMat=...
                    vertcat(self.isSizeAlongAddDimsEqualOne);
                fieldIsSizeAlongAddDimsEqualOneMat=reshape(...
                    fieldIsSizeAlongAddDimsEqualOneMat,size(self));
            else
                fieldIsSizeAlongAddDimsEqualOneMat=false(size(self));
            end
        end
        %
        function setIsSizeAlongAddDimsEqualOneMat(self,valueMat)
            if ~isempty(self)
                valueMat=num2cell(valueMat);
                [self.isSizeAlongAddDimsEqualOne]=deal(valueMat{:});
            end
        end
        %
        function fieldIsUniqueValues=getIsUniqueValues(self)
            import modgen.common.throwerror;
            if numel(self)~=1
                throwerror('wrongInput',...
                    'this method only works for scalar objects');
            end
            fieldIsUniqueValues=self.isUniqueValues;
        end
        %
        function fieldIsUniqueValuesMat=getIsUniqueValuesMat(self)
            if ~isempty(self)
                fieldIsUniqueValuesMat=vertcat(self.isUniqueValues);
                fieldIsUniqueValuesMat=reshape(fieldIsUniqueValuesMat,...
                    size(self));
            else
                fieldIsUniqueValuesMat=false(size(self));
            end
        end
        %
        function setIsUniqueValuesMat(self,valueMat)
            if ~isempty(self)
                valueMat=num2cell(valueMat);
                [self.isUniqueValues]=deal(valueMat{:});
            end
        end
        %
        function checkFieldValue(self,varargin)
            import modgen.common.throwerror;
            checkFieldValue@smartdb.cubes.CubeStructFieldInfo(self,varargin{:});
            isSpecifiedVec=varargin{end-1};
            if ~isSpecifiedVec(1)
                throwerror('wrongInput',...
                    'value element of data is obligatory');
            end
            valueCVec=varargin{end};
            if ~isequal(size(valueCVec{1}),[0 0]),
                patternVec=self.sizePatternVec;
                nAddDims=ndims(valueCVec{1})-numel(patternVec);
                if self.isSizeAlongAddDimsEqualOne,
                    nAddCurDims=2-numel(patternVec);
                    if nAddCurDims>0,
                        patternVec=[patternVec ones(1,nAddCurDims)];
                        nAddDims=nAddDims-nAddCurDims;
                    end
                    isnWrong=nAddDims<=0;
                else
                    if nAddDims>0,
                        patternVec=[patternVec nan(1,nAddDims)];
                        nAddDims=0;
                    end
                end
                if isnWrong,
                    sizeVec=size(valueCVec{1});
                    if nAddDims<0,
                        sizeVec=[sizeVec ones(1,-nAddDims)];
                    end
                    sizeVec(isnan(patternVec))=NaN;
                    isnWrong=isequaln(patternVec,sizeVec);
                end
                if ~isnWrong,
                    throwerror('wrongInput',...
                        'size check failed for field %s',self.name);
                end
                if self.isUniqueValues,
                    if isSpecifiedVec(3),
                        if any(valueCVec{3}(:)),
                            throwerror('wrongInput',[...
                                'isValueNull should be equal to false '...
                                'for field %s'],self.name);
                        end
                    end
                    isSpecifiedVec(3)=false;
                    if ~all(cellfun('prodofsize',uniquejoint(cellfun(...
                            @(x)x(:),valueCVec(isSpecifiedVec),...
                            'UniformOutput',false),1))==numel(valueCVec{1})),
                        throwerror('wrongInput',[...
                            'check for uniqueness of values failed for '...
                            'field %s'],self.name);
                    end
                end
            end
        end
    end
end