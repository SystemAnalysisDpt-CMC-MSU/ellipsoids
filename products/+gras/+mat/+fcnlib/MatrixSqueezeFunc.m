classdef MatrixSqueezeFunc<gras.mat.AMatrixUnaryOpArrayFunc
    methods
        function self=MatrixSqueezeFunc(lMatFunc)
            %
            self=self@gras.mat.AMatrixUnaryOpArrayFunc(lMatFunc,...
                @(lArray)squeeze(lArray));
            
            %
            self.nCols = NaN;
            self.nRows = lMatFunc.getNRows();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end