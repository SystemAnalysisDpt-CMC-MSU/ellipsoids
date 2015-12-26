classdef AEllipsoid < elltool.core.ABasicEllipsoid
    properties(SetAccess=protected,GetAccess=public)
        nPlot2dPoints
        nPlot3dPoints
    end
    %
    properties(Access=protected)
        centerVec
    end
    methods
        function ellObj=AEllipsoid(varargin)
            ellObj=ellObj@elltool.core.ABasicEllipsoid();
        end
        ellArr=projection(ellArr,basisMat)
        centerVec=getCenterVec(self)
        nPlot2dPointsArr=getNPlot2dPoints(ellArr)
        nPlot3dPointsArr=getNPlot3dPoints(ellArr)
        outEllArr=mtimes(multMat,inpEllArr)
        ellArr=shape(ellArr, modMat)
    end
    methods(Access=protected)
        volVal=ellSingleVolume(ellObj)
    end
    methods(Abstract)
        shapeMat=getShapeMat(self)
        [SDataArr,SFieldNiceNames,SFieldDescr,SFieldTransformFunc]=...
            toStruct(ellArr,isPropIncluded,absTol)
        polar=getScalarPolarInternal(self,isRobustMethod)
    end
    methods(Abstract,Access=protected)
        ellObj=changeShapeMatInternal(ellObj,isModScal,modMat)
        fSingleProjection(ellObj,ortBasisMat)
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