classdef MatrixRMultiplyByVecSpecialFunc<gras.mat.AMatrixBinaryOpArrayFunc
    methods
        function self=MatrixRMultiplyByVecSpecialFunc(lMatFunc,rMatFunc,...
                sizeMatrix)
            %
            self=self@gras.mat.AMatrixBinaryOpArrayFunc(lMatFunc,...
                rMatFunc,@(lArray,rArray)gras.gen.MatVector.rMultiplyByVec(lArray,rArray));
            %
            self.nRows = sizeMatrix(1);
            self.nCols = sizeMatrix(2);
            self.nDims = sizeMatrix(1);
        end
    end
end

