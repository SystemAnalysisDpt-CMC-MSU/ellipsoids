classdef IDynamicCubeStructInternal<handle
    methods (Abstract,Access=protected, Hidden)
        reorderFieldsInternal(self,indReorderVec)
        %
        catWithInternal(self,inpObj,varargin)
        %
        renameFieldsInternal(self,fromFieldNameList,toFieldNameList)
        %
        addFieldsInternal(self,addFieldNameList,addFieldDescrList)
        removeFieldsInternal(self,removeFieldList)
        setDataInternal(self,varargin)
        copyFromInternal(self,obj,varargin)        
        addDataAlongDimInternal(self,catDimension,varargin)
        varargout=getUniqueDataAlongDimInternal(self,catDim,varargin)
        % GETUNIQUEDATAALONGDIM - returns internal representation of CubeStruct data set 
        %                         unique along a specified dimension set    
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
    end
    methods (Access=protected,Static,Hidden)
        prohibitProperty(propNameList,inpList)
    end
end
