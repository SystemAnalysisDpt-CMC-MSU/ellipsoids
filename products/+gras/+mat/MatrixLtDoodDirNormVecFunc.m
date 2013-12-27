classdef MatrixLtDoodDirNormVecFunc<gras.mat.IMatrixFunction
    properties (Access=protected)
        ltGoodDirMatInterObj
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
        function ltGoodDirNormVec = evaluate(self,timeVec)
            ltGoodDirMat = self.ltGoodDirMatInterObj.evaluate(timeVec);            
            ltGoodDirNormVec=...
                    realsqrt(sum(ltGoodDirMat.*ltGoodDirMat,1));         
            self.mSizeVec = size(ltGoodDirNormVec);
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
        function self=MatrixLtDoodDirNormVecFunc(ltGoodDirMatInterObj,timeVec)
            self.ltGoodDirMatInterObj = ltGoodDirMatInterObj;
            self.evaluate(timeVec);
        end
    end
end