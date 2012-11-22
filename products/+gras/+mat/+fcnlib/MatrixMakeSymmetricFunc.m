classdef MatrixMakeSymmetricFunc<gras.mat.fcnlib.AMatrixUnaryOpFunc
    methods
        function self=MatrixMakeSymmetricFunc(lMatFunc)
            %
            self=self@gras.mat.fcnlib.AMatrixUnaryOpFunc(lMatFunc,...
                @(x) 0.5*(x+x.'));
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
