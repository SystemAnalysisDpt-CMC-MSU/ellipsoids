classdef MatrixCatFunc<gras.mat.AMatrixBinaryOpArrayFunc
    methods
        function self=MatrixCatFunc(lMatFunc, rMatFunc,dimCat)
            
            self=self@gras.mat.AMatrixBinaryOpArrayFunc(lMatFunc,...
                rMatFunc,@(leftMatFunc,rightMatFunc)cat(dimCat,leftMatFunc,...
                rightMatFunc));
            %
            lSizeVec = lMatFunc.getMatrixSize();
            rSizeVec = rMatFunc.getMatrixSize();
            %
            modgen.common.type.simple.checkgenext(@isequal, 2, ...
                lSizeVec, rSizeVec);
            %
            self.nRows = lSizeVec(1);
            self.nCols = lSizeVec(2);
            self.nDims = lSizeVec(1);
        end
    end
end
