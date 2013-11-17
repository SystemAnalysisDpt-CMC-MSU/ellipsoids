classdef MatrixReshapeFunc<gras.mat.AMatrixUnaryOpArrayFunc
    methods
        function self=MatrixReshapeFunc(lMatFunc,newSizeVec)
            %
            self=self@gras.mat.AMatrixUnaryOpArrayFunc(lMatFunc,...
                @(lArray)reshape(lArray,newSizeVec));
            %
            self.nRows = newSizeVec(1);
            self.nCols = newSizeVec(2);
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end