classdef MatrixUMinusFunc<gras.mat.AMatrixUnaryOpFunc
    methods
        function self=MatrixUMinusFunc(lMatFunc)
            %
            self=self@gras.mat.AMatrixUnaryOpFunc(lMatFunc,...
                @uminus);
            %
            self.nRows = lMatFunc.getNRows();
            self.nCols = lMatFunc.getNCols();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
