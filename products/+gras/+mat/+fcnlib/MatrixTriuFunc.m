classdef MatrixTriuFunc<gras.mat.fcnlib.AMatrixUnaryOpFunc
    methods
        function self=MatrixTriuFunc(lMatFunc)
            %
            self=self@gras.mat.fcnlib.AMatrixUnaryOpFunc(lMatFunc,@triu);
            %
            self.nRows = lMatFunc.getNRows();
            self.nCols = lMatFunc.getNCols();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
