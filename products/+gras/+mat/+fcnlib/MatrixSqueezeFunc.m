classdef MatrixSqueezeFunc<gras.mat.AMatrixUnaryOpArrayFunc
    methods
        function self=MatrixSqueezeFunc(lMatFunc,nTimePoints)
            %
            self=self@gras.mat.AMatrixUnaryOpArrayFunc(lMatFunc,...
                @(lArray)squeeze(lArray));
            
            %
            self.nRows = lMatFunc.getNRows();
            self.nCols = nTimePoints;
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end