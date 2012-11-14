classdef IMatrixFunction<handle
    methods (Abstract)
        mSize=getMatrixSize(self)
        res=evaluate(self,timeVec)
        nDims=getDimensionality(self)
        nCols=getNCols(self)
        nRows=getNRows(self)
    end
end