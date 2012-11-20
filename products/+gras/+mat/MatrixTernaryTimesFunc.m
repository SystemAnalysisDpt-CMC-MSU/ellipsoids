classdef MatrixTernaryTimesFunc<gras.mat.AMatrixTernaryOpFunc
    methods
        function self=MatrixTernaryTimesFunc(lMatFunc, mMatFunc,...
                rMatFunc)
            %
            self=self@gras.mat.AMatrixTernaryOpFunc(lMatFunc, mMatFunc,...
                rMatFunc, @(a,b,c) a*b*c);
            %
            lSizeVec = lMatFunc.getMatrixSize();
            mSizeVec = mMatFunc.getMatrixSize();
            rSizeVec = rMatFunc.getMatrixSize();
            %
            if lSizeVec(2) ~= mSizeVec(1) || mSizeVec(2) ~= rSizeVec(1)
                modgen.common.throwerror('wrongInput',...
                    'Inner matrix dimensions must agree');
            end
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
