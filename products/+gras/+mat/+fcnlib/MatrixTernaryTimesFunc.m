classdef MatrixTernaryTimesFunc<gras.mat.fcnlib.AMatrixTernaryOpFunc
    methods
        function self=MatrixTernaryTimesFunc(lMatFunc, mMatFunc,...
                rMatFunc)
            %
            self=self@gras.mat.fcnlib.AMatrixTernaryOpFunc(lMatFunc, mMatFunc,...
                rMatFunc, @(a,b,c) a*b*c);
            %
            lSizeVec = lMatFunc.getMatrixSize();
            mSizeVec = mMatFunc.getMatrixSize();
            rSizeVec = rMatFunc.getMatrixSize();
            %
            modgen.common.type.simple.checkgenext('x1(2)==x2(1)&&x2(2)==x3(1)', 3,...
                lSizeVec, mSizeVec, rSizeVec);
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
