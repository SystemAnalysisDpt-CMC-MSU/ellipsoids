classdef AEllipsoid < elltool.core.ABasicEllipsoid
    methods
        function ellObj=AEllipsoid(varargin)
            ellObj=ellObj@elltool.core.ABasicEllipsoid();
        end
        resArr=repMat(self,varargin)
        centerVec=getCenterVec(self)
    end
    methods(Access=protected)
        isModScal=shapeInternal(ellArr,modMat)
    end
    methods(Abstract)
        shapeMat=getShapeMat(self)
        [SDataArr,SFieldNiceNames,SFieldDescr]=...
            toStruct(ellArr,isPropIncluded)
    end
    methods(Abstract)
        polar=getScalarPolarInternal(self,isRobustMethod)
    end
    methods(Abstract, Static)
        ellArr=fromRepMat(varargin)
        ellArr=fromStruct(SEllArr)
    end
    methods
        [dimArr,rankArr]=dimension(myEllArr)
        outEllArr=getShape(ellArr,modMat)
        minEigArr=mineig(inpEllArr)
        maxEigArr=maxeig(inpEllArr)
        outEllArr=plus(varargin)
        outEllArr=minus(varargin)
        trArr=trace(ellArr)
    end
end