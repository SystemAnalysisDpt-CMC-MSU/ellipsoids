classdef MatrixMinEigValFunc<gras.mat.AMatrixUnaryOpFunc
    methods
        function self=MatrixMinEigValFunc(lMatFunc)
            %
            self=self@gras.mat.AMatrixUnaryOpFunc(lMatFunc,...
                @(x)min(eig(x)));
            %
            modgen.common.type.simple.checkgen(lMatFunc.getMatrixSize(),...
                'x(1)==x(2)');
            %
            self.nRows = 1;
            self.nCols = 1;
            self.nDims = 1;
        end
    end
end