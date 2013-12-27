classdef MatrixNormOrigVecFunc<gras.mat.IMatrixFunction
    properties (Access=protected)
        ltGoodDirNormVecInterObj
        dimProj
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
        function normOrigVecMatrix = evaluate(self,timeVec)
            ltGoodDirNormVec = self.ltGoodDirNormVecInterObj.evaluate(timeVec);            
            normOrigVecMatrix = repmat(ltGoodDirNormVec,self.dimProj,1);          
            self.mSizeVec = size(normOrigVecMatrix);
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
        function self=MatrixNormOrigVecFunc(ltGoodDirNormVecInterObj,dimProj,timeVec)
            self.ltGoodDirNormVecInterObj = ltGoodDirNormVecInterObj;
            self.dimProj = dimProj;
            self.evaluate(timeVec);
        end
    end
end