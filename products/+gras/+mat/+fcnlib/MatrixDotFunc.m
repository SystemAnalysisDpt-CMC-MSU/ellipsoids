classdef MatrixDotFunc<gras.mat.AMatrixBinaryOpFunc
    methods
        function self=MatrixDotFunc(lMatFunc, rMatFunc)
            %
            import gras.gen.matdot;
            %
            self=self@gras.mat.AMatrixBinaryOpFunc(lMatFunc,...
                rMatFunc,@matdot);
            %
            lSizeVec = lMatFunc.getMatrixSize();
            rSizeVec = rMatFunc.getMatrixSize();
            %
            modgen.common.type.simple.checkgenext(@isequal, 2, ...
                lSizeVec, rSizeVec);
            %
            self.nRows = 1;
            self.nCols = 1;
            self.nDims = 1;
        end
    end
end
