classdef MatrixPosReg < gras.mat.IMatrixFunction
    properties (Access = private)
        matFunc
        regTol
    end
    methods
        function self = MatrixPosReg(matFunc, regTol)
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
            resArray = gras.gen.SquareMatVector.evalMFunc(...
                @(x) gras.la.regposdefmat(x, self.regTol), resArray,...
                'UniformOutput', true, 'keepSize', true);
        end
    end
end