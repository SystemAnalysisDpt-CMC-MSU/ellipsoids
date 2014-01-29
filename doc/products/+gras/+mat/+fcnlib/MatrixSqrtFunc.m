classdef MatrixSqrtFunc<gras.mat.AMatrixUnaryOpFunc
    methods
        function self=MatrixSqrtFunc(lMatFunc)
            %
            self=self@gras.mat.AMatrixUnaryOpFunc(lMatFunc,...
                @gras.la.sqrtmpos);
            %
            modgen.common.type.simple.checkgen(lMatFunc.getMatrixSize(),...
                'x(1)==x(2)');
            %
            self.nRows = lMatFunc.getNRows();
            self.nCols = lMatFunc.getNCols();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
