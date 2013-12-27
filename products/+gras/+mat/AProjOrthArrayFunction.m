classdef AProjOrthArrayFunction<gras.mat.IMatrixFunction
    properties (Access=protected)
        projArrayFunc
        %
        mArray
        mSizeVec
        nDims
        nRows
        nCols
    end
    methods
        function mSizeVec = getMatrixSize(self)
            mSizeVec = self.mSizeVec;
        end
        function projOrthArray = evaluate(self,timeVec)
            import gras.gen.SquareMatVector;
            projArray = self.projArrayFunc.evaluate(timeVec);
            projOrthArray = SquareMatVector.evalMFunc(...
                        @(x)transpose(gras.la.matorthcol(transpose(x))),...
                        projArray,'keepSize',true);
            sizeArray = size(projOrthArray);
            self.mArray = projOrthArray;
            self.mSizeVec = sizeArray(1:2);
            self.nRows = self.mSizeVec(1);
            self.nCols = self.mSizeVec(2);
            self.nDims = self.nRows;
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
        function self=AProjOrthArrayFunction(projArrayFunc,timeVec)
            self.projArrayFunc = projArrayFunc;
            self.evaluate(timeVec);
        end
    end
end