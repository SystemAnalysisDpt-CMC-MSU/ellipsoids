classdef MatrixPlusFunc<gras.mat.AMatrixBinaryOpFunc
    methods
        function self=MatrixPlusFunc(lMatFunc, rMatFunc)
            %
            self=self@gras.mat.AMatrixBinaryOpFunc(lMatFunc,...
                rMatFunc,@plus);
            %
            modgen.common.type.simple.checkgenext(...
                'x1(1)==x2(1)&&x1(2)==x2(2)', 2,...
                lMatFunc.getMatrixSize(), rMatFunc.getMatrixSize());
            %
            self.nRows = lMatFunc.getNRows();
            self.nCols = lMatFunc.getNCols();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
