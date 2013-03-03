classdef AMatrixOpFunc<gras.mat.IMatrixFunction
    properties (Access=protected)
        nRows
        nCols
        nDims
    end
    methods
        function mSizeVec = getMatrixSize(self)
            mSizeVec = [self.nRows, self.nCols];
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
end
