classdef MatrixSqrtFunc<gras.mat.fcnlib.AMatrixUnaryOpFunc
    methods
        function self=MatrixSqrtFunc(lMatFunc)
            %
            self=self@gras.mat.fcnlib.AMatrixUnaryOpFunc(lMatFunc,@sqrtm);
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
