classdef ABasicEllipsoid < handle
    properties (Access=protected)
        centerVec    
        absTol
        relTol
        nPlot2dPoints
        nPlot3dPoints
    end
    %
    methods(Access=protected)
        [isEqualArr,reportStr]=isEqualInternal(ellFirstArr,...
            ellSecArr,isPropIncluded)
        polar=getScalarPolarInternal(self,isRobustMethod)
        [propArr,propVal]=getProperty(ellArr,propName,fPropFun)
    end
    methods(Static)
        ellArr=fromRepMatInternal(ellObj,sizeVec)
        checkIsMeInternal(objType,ellArr,varargin)
    end
    methods (Access=protected,Abstract)
        checkIsMeVirtual(ellArr,varargin)
        copyEllObj=getSingleCopy(ellObj)
        ellObj=ellFactory(self)
    end
    methods 
        [absTolArr,absTolVal]=getAbsTol(ellArr,varargin)
        [relTolArr,relTolVal]=getRelTol(ellArr,varargin)
        copyEllArr=getCopy(ellArr)
        isPositiveArr=isEmpty(myEllArr)
    end
end