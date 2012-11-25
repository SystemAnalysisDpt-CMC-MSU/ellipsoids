classdef MatrixBinaryTimesFunc<gras.mat.fcnlib.AMatrixBinaryOpFunc
    methods
        function self=MatrixBinaryTimesFunc(lMatFunc, rMatFunc)
            %
            self=self@gras.mat.fcnlib.AMatrixBinaryOpFunc(lMatFunc,...
                rMatFunc,@mtimes);
            %
            lSizeVec = lMatFunc.getMatrixSize();
            rSizeVec = rMatFunc.getMatrixSize();
            %
            modgen.common.type.simple.checkgenext('x1(2)==x2(1)', 2,...
                lSizeVec, rSizeVec);
            %
            self.nRows = lSizeVec(1);
            self.nCols = rSizeVec(2);
            %
            if self.nRows == 1 || self.nCols == 1
                self.nDims = 1;
            else
                self.nDims = 2;
            end
        end
    end
end
