classdef MatrixSysTransposeFunc<gras.mat.AMatrixSysUnaryOpFunc
    methods
        function self=MatrixSysTransposeFunc(lMatFunc)
            %
            self=self@gras.mat.AMatrixSysUnaryOpFunc(lMatFunc,...
                @transpose);
            %
            self.nRows = lMatFunc.getNCols();
            self.nCols = lMatFunc.getNRows();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
