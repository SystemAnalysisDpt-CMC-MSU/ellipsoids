classdef MatrixFlipdimFunc<gras.mat.AMatrixUnaryOpArrayFunc
    methods
        function self=MatrixFlipdimFunc(lMatFunc,dimFlip)
            %
            self=self@gras.mat.AMatrixUnaryOpArrayFunc(lMatFunc,...
                @(lArray)flipdim(lArray,dimFlip));
            %
            self.nRows = lMatFunc.getNRows();
            self.nCols = lMatFunc.getNCols();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
