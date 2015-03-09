classdef MatrixDivHadamardFunc<gras.mat.AMatrixUnaryOpArrayFunc
    methods
        function self=MatrixDivHadamardFunc(lMatFunc,rMatrix)
            %
            self=self@gras.mat.AMatrixUnaryOpArrayFunc(lMatFunc,...
                @(x)x./rMatrix);
            %
            self.nRows = lMatFunc.getNRows();
            self.nCols = lMatFunc.getNCols();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end

