classdef TestPolarEllipsoid < elltool.core.AEllipsoid
    methods
        function self=TestPolarEllipsoid(varargin)
        end
        function polarObj=getScalarPolarTest(~,ell,isRobustMethod)
            polarObj=ell.getScalarPolarInternal(isRobustMethod);
        end
    end
    methods(Static)
        ellArr=fromRepMat(varargin)
        ellArr=fromStruct(SEllArr)
    end
    methods(Access=protected)
        ellObj=shapeSingleInternal(ellObj,isModScal,modMat)
        projectionSingleInternal(ellObj,ortBasisMat)
        checkIsMeVirtual(ellArr,varargin)
        copyEllObj=getSingleCopy(ellObj)
    end
    methods
        polar=getScalarPolarInternal(self,isRobustMethod)
        shapeMat=getShapeMat(self)
        [SDataArr,SFieldNiceNames,SFieldDescr]=...
            toStruct(ellArr,isPropIncluded)
    end
end