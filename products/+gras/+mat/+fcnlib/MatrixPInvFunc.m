classdef MatrixPInvFunc<gras.mat.fcnlib.AMatrixUnaryOpFunc
    methods
        function self=MatrixPInvFunc(lMatFunc)
            %
            self=self@gras.mat.fcnlib.AMatrixUnaryOpFunc(lMatFunc,@pinv);
            %
            self.nRows = lMatFunc.getNCols();
            self.nCols = lMatFunc.getNRows();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
