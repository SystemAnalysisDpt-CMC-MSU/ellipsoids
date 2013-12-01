classdef AConstArrayFunction<gras.mat.IMatrixFunction
    properties (Access=protected)
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
        function res=evaluate(self,timeVec)
            res = self.mArray;
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
        function self=AConstArrayFunction(mArray)
            %
            modgen.common.type.simple.checkgen(mArray,...
                'isnumeric(x)&&~isempty(x)');
            %
            sizeArray = size(mArray);
            self.mArray = mArray;
            self.mSizeVec = sizeArray(1:2);
            self.nRows = self.mSizeVec(1);
            self.nCols = self.mSizeVec(2);
        end
    end
end