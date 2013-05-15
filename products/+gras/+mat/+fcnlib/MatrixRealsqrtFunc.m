classdef MatrixRealsqrtFunc<gras.mat.AMatrixUnaryOpFunc
    methods
        function self=MatrixRealsqrtFunc(lMatFunc)
            %
            self=self@gras.mat.AMatrixUnaryOpFunc(lMatFunc,...
                @realsqrt);
            %
            self.nRows = lMatFunc.getNRows();
            self.nCols = lMatFunc.getNCols();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
