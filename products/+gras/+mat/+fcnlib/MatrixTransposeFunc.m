classdef MatrixTransposeFunc<gras.mat.fcnlib.AMatrixUnaryOpFunc
    methods
        function self=MatrixTransposeFunc(lMatFunc)
            %
            self=self@gras.mat.fcnlib.AMatrixUnaryOpFunc(lMatFunc,@transpose);
            %
            self.nRows = lMatFunc.getNCols();
            self.nCols = lMatFunc.getNRows();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
