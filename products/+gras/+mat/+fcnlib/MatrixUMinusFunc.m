classdef MatrixUMinusFunc<gras.mat.AMatrixUnaryOpFunc
    methods
        function self=MatrixUMinusFunc(lMatFunc)
            %
            self=self@gras.mat.AMatrixUnaryOpFunc(lMatFunc,...
                @uminus);
            %
            self.nRows = lMatFunc.getNCols();
            self.nCols = lMatFunc.getNRows();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
