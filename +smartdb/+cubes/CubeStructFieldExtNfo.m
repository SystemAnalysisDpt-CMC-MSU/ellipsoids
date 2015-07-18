classdef CubeStructFieldExtNfo<smartdb.cubes.CubeStructFieldNfo
    methods (Access=protected)
        function setFieldMetaDataCheck(~,value)
            if ~isa(value,'smartdb.cubes.CubeStructFieldExtendedInfo')
                modgen.common.throwerror('wrongInput',['fieldMetaData field ',...
                    'should be of smartdb.cubes.CubeStructFieldInfo type']);
            end
        end
    end
    methods
        function setSizePatternVec(self,value)
            self.fieldMetaData.sizePatternVec=value;
        end
        function setIsSizeAlongAddDimsEqualOne(self,value)
            self.fieldMetaData.isSizeAlongAddDimsEqualOne=value;
        end
        function setIsUniqueValues(self,value)
            self.fieldMetaData.isUniqueValues=value;
        end
        function self=CubeStructFieldExtNfo(varargin)
            if nargin>0
                if (nargin==1)&&isa(varargin{1},...
                        'smartdb.cubes.CubeStructFieldExtendedInfo')
                    self.fieldMetaData=varargin{1};
                elseif (nargin>=1)&&smartdb.cubes.CubeStructFieldExtNfo.isMe(varargin{1})
                    self.fieldMetaData=smartdb.cubes.CubeStructFieldExtendedInfo(...
                        varargin{1}.fieldMetaData,varargin{2:end});
                else
                    self.fieldMetaData=smartdb.cubes.CubeStructFieldExtendedInfo(...
                        varargin{:});
                end
            end
        end
    end
    methods (Static)
        function self=customArray(cubeStructRef,nameList,descriptionList,...
                typeSpecList,sizePatternVecList,...
                isSizeAlongAddDimsEqualOneMat,isUniqueValuesMat)
            resArray=smartdb.cubes.CubeStructFieldExtendedInfo.customArray(...
                cubeStructRef,nameList,descriptionList,...
                typeSpecList,sizePatternVecList,...
                isSizeAlongAddDimsEqualOneMat,isUniqueValuesMat);
            %
            self=smartdb.cubes.CubeStructFieldExtNfo(resArray);
        end
        function self=defaultArray(cubeStructRefList,sizeVec)
            resArray=smartdb.cubes.CubeStrutFieldExtendedInfo.defaultArray(...
                cubeStructRefList,sizeVec);
            self=smartdb.cubes.CubeStructFieldExtNfo(resArray);
        end
        %
        function isPositive=isMe(inpObj)
            curClassName=mfilename('class');
            isPositive=isa(inpObj,curClassName);
        end
    end
    methods
        function fieldSizePatternVec=getSizePatternVec(self)
            fieldSizePatternVec=...
                self.fieldMetaData.getSizePatternVec();
        end
        %
        function fieldSizePatternVecList=getSizePatternVecList(self)
            fieldSizePatternVecList=...
                self.fieldMetaData.getSizePatternVecList();
        end
        %
        function setSizePatternVecList(self,valueList)
            self.fieldMetaData.setSizePatternVecList(valueList);
        end
        %
        function fieldIsSizeAlongAddDimsEqualOne=...
                getIsSizeAlongAddDimsEqualOne(self)
            fieldIsSizeAlongAddDimsEqualOne=...
                self.fieldMetaData.getIsSizeAlongAddDimsEqualOne();
        end
        %
        function fieldIsSizeAlongAddDimsEqualOneMat=...
                getIsSizeAlongAddDimsEqualOneMat(self)
            fieldIsSizeAlongAddDimsEqualOneMat=...
                self.fieldMetaData.getIsSizeAlongAddDimsEqualOneMat();
        end
        %
        function setIsSizeAlongAddDimsEqualOneMat(self,valueMat)
            self.fieldMetaData.setIsSizeAlongAddDimsEqualOneMat(valueMat);
        end
        %
        function fieldIsUniqueValues=getIsUniqueValues(self)
            fieldIsUniqueValues=self.fieldMetaData.getIsUniqueValues(self);
        end
        %
        function fieldIsUniqueValuesMat=getIsUniqueValuesMat(self)
            fieldIsUniqueValuesMat=self.fieldMetaData.getIsUniqueValuesMat(self);
        end
        %
        function setIsUniqueValuesMat(self,valueMat)
            setIsUniqueValuesMat(self.fieldMetaData,valueMat)
        end
    end
end

