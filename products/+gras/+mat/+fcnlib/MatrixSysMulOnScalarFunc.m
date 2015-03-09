classdef MatrixSysMulOnScalarFunc<gras.mat.AMatrixSysUnaryOpFunc
    methods
        function self=MatrixSysMulOnScalarFunc(lMatFunc,scalarValue)
            %
            self=self@gras.mat.AMatrixSysUnaryOpFunc(lMatFunc,...
                @(x)scalarValue.*x);
            %
            self.nRows = lMatFunc.getNRows();
            self.nCols = lMatFunc.getNCols();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end