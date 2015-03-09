classdef MatrixSubArrayCauseNormFunc<gras.mat.IMatrixFunction
    properties (Access=protected)
        ltGoodDirMatInterObj
        absTol
        %
        mSizeVec
        nDims
        nRows
        nCols
    end
    methods
        function mSizeVec = getMatrixSize(self)
            mSizeVec = self.mSizeVec;
        end
        function ltGoodDirMat = evaluate(self,timeVec)
            ltGoodDirMat = self.ltGoodDirMatInterObj.evaluate(timeVec);
            ltProjGoodDirNormVec = ...
                            realsqrt(dot(ltGoodDirMat,ltGoodDirMat,1));
            isnLtTouchVec = abs(ltProjGoodDirNormVec-1)>self.absTol;
            ltGoodDirMat(:,isnLtTouchVec)=0;         
            self.mSizeVec = size(ltGoodDirMat);
            self.nRows = self.mSizeVec(1);
            self.nCols = self.mSizeVec(2);
            self.nDims = self.mSizeVec(1);
        end
        function nDims=getDimensionality(self)
            nDims = self.nDims;
        end
        function nCols=getNCols(self)
            nCols = self.nCols;
        end
        function nRows=getNRows(self)
            nRows = self.nRows;
        end
    end
    methods
        function self=MatrixSubArrayCauseNormFunc(ltGoodDirMatInterObj,absTol)
            self.ltGoodDirMatInterObj = ltGoodDirMatInterObj;
            self.absTol = absTol;
        end
    end
end
