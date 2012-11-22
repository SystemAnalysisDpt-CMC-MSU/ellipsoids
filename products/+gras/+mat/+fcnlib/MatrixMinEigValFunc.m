classdef MatrixMinEigValFunc<gras.mat.fcnlib.AMatrixUnaryOpFunc
    methods
        function self=MatrixMinEigValFunc(lMatFunc)
            %
            self=self@gras.mat.fcnlib.AMatrixUnaryOpFunc(lMatFunc,@(x)min(eig(x)));
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