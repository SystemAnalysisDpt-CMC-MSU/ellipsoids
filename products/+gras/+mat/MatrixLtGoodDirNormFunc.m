classdef MatrixLtGoodDirNormFunc<gras.mat.IMatrixFunction
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
            ltGoodDirNormVec=...
                    realsqrt(sum(ltGoodDirMat.*ltGoodDirMat,1));
            isLtTouchVec=ltGoodDirNormVec>self.absTol;
            
            if any(isLtTouchVec)
                helpMatrix = repmat(ltGoodDirNormVec(isLtTouchVec),...
                    size(ltGoodDirMat,1),1);
                ltGoodDirMat(:,isLtTouchVec)=ltGoodDirMat(:,isLtTouchVec)./...
                    helpMatrix;                    
            end
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
        function self=MatrixLtGoodDirNormFunc(ltGoodDirMatInterObj,absTol)
            self.ltGoodDirMatInterObj = ltGoodDirMatInterObj;
            self.absTol = absTol;
            self.mSizeVec = ltGoodDirMatInterObj.getMatrixSize();
            self.nRows = ltGoodDirMatInterObj.getNRows();
            self.nCols = ltGoodDirMatInterObj.getNCols();
            self.nDims = ltGoodDirMatInterObj.getDimensionality();
        end
    end
end