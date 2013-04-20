classdef MatrixPosCheck < gras.mat.IMatrixFunction
    properties (Access = private)
        matFunc
        regTol
    end
    methods
        function self = MatrixPosCheck(matFunc, regTol)
            modgen.common.type.simple.checkgen(matFunc,...
                @(x)isa(x,'gras.mat.IMatrixFunction'));
            self.matFunc = matFunc;
            self.regTol = regTol;
        end
        function mSizeVec = getMatrixSize(self)
            mSizeVec = self.matFunc.getMatrixSize();
        end
        function nDims=getDimensionality(self)
            nDims = self.matFunc.getDimensionality();
        end
        function nCols=getNCols(self)
            nCols = self.matFunc.getNCols();
        end
        function nRows=getNRows(self)
            nRows = self.matFunc.getNRows();
        end
        function resArray=evaluate(self, timeVec)
            resArray = self.matFunc.evaluate(timeVec);
            isPosDefArray = gras.gen.SquareMatVector.evalMFunc(...
                @(x) gras.la.ismatposdef(x, self.regTol), resArray);
            modgen.common.type.simple.checkgen(isPosDefArray, 'all(x)');
        end
    end
end