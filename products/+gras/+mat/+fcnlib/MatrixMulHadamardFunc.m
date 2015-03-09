classdef MatrixMulHadamardFunc<gras.mat.AMatrixBinaryOpArrayFunc
    methods
        function self=MatrixMulHadamardFunc(lMatFunc,rMatFunc)
            
            self=self@gras.mat.AMatrixBinaryOpArrayFunc(lMatFunc,rMatFunc,@(x,y)x.*y);
            %
            lSizeVec = lMatFunc.getMatrixSize();
            %
            self.nRows = lSizeVec(1);
            self.nCols = lSizeVec(2);
            self.nDims = lSizeVec(1);
            
            
            
        end
    end
end
