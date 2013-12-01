classdef MatrixRMultiplyByVecSpecialFunc<gras.mat.AMatrixUnaryOpArrayFunc
    methods
        function self=MatrixRMultiplyByVecSpecialFunc(lMatFunc,aArray,...
                sizeMatrix)
            %
            self=self@gras.mat.AMatrixUnaryOpArrayFunc(lMatFunc,...
                @(lArray)gras.gen.MatVector.rMultiplyByVec(aArray,lArray));
            %
            self.nRows = sizeMatrix(1);
            self.nCols = sizeMatrix(2);
            self.nDims = sizeMatrix(1);
        end
    end
end

