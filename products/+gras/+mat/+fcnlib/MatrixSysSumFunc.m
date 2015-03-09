classdef MatrixSysSumFunc<gras.mat.AMatrixSysBinaryOpFunc
    methods
        function self=MatrixSysSumFunc(lMatFunc,rMatFunc)
            %
            self=self@gras.mat.AMatrixSysBinaryOpFunc(lMatFunc,rMatFunc,...
                @(x,y)(x+y));
            %
            self.nRows = lMatFunc.getNRows();
            self.nCols = lMatFunc.getNCols();
            self.nDims = lMatFunc.getDimensionality();
        end
        
    end
end
