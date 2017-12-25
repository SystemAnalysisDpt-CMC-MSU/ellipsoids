classdef ABasicEllipsoid < handle
    properties(Access=protected) 
        absTol
        relTol 
    end
    %
    methods
        function property = get.absTol(self)
            self.beforeGetAbsTol();
            property = self.absTol;
        end
        function property = get.relTol(self)
            self.beforeGetRelTol();
            property = self.relTol;
        end
    end
    methods (Access = protected)
        function beforeGetAbsTol(self) %#ok<MANU>
            % may be overridden in subclass
        end
        function beforeGetRelTol(self) %#ok<MANU>
            % may be overridden in subclass
        end
    end
    %
    methods(Abstract)
        [dimArr,rankArr]=dimension(myEllArr)
        [SDataArr,SFieldNiceNames,SFieldDescr,SFieldTransformFunc]=...
            toStruct(ellArr,isPropIncluded,absTol)        
    end
    methods(Access=protected)
        checkIfScalar(self,errMsg)
        [isEqualArr,reportStr]=isEqualInternal(ellFirstArr,...
            ellSecArr,isPropIncluded)
    end
    methods(Static)
        checkIsMeInternal(objType,ellArr,varargin)
    end
    methods(Access=protected,Abstract)
        checkIsMeVirtual(ellArr,varargin)
        copyEllObj=getSingleCopy(ellObj)
    end
    methods 
        ellArr=repMat(ellObj,sizeVec)
        [absTolArr,absTolVal]=getAbsTol(ellArr,varargin)
        [relTolArr,relTolVal]=getRelTol(ellArr,varargin)
        copyEllArr=getCopy(ellArr)
        isPositiveArr=isEmpty(myEllArr)
    end
end