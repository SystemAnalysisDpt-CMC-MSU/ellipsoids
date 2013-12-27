classdef MatrixSysUnifiedInterpFunc<gras.mat.IMatrixFunction
    properties(Access=private)
        matrixInterpObj
    end
    
    methods
        function self = MatrixSysUnifiedInterpFunc(interpObj)
            self.matrixInterpObj = interpObj;
        end
        %
        function varargout = evaluate(self,timeVec)
            resList = cell(1,nargout);
            [resList{:}] = self.matrixInterpObj.evaluate(timeVec);
            varargout = resList; 
        end
        %
        function mSize = getMatrixSize(self)
            mSize = self.matrixInterpObj.getMatrixSize();
        end
        function nDims = getDimensionality(self)
            mSize = self.getMatrixSize();
            nDims = mSize(1);
        end
        function nCols = getNCols(self)
            mSize = self.getMatrixSize();
            nCols = mSize(2);
        end
        function nRows = getNRows(self)
            mSize = self.getMatrixSize();
            nRows = mSize(1);
        end
        function nEqs = getNEquations(self)
            nEqs = self.matrixInterpObj.getNEquations();
        end
        
        function interpObj = getInterpObj(self)
            interpObj = self.matrixInterpObj;
        end
    end
    
end

