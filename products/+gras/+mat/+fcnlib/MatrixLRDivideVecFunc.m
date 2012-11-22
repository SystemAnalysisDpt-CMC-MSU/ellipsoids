classdef MatrixLRDivideVecFunc<gras.mat.fcnlib.AMatrixBinaryOpFunc
    methods
        function self=MatrixLRDivideVecFunc(mMatFunc, lrVecFunc)
            fHandle = @(mMat,lrVec) (lrVec.')*(mMat\lrVec);
            %
            self=self@gras.mat.fcnlib.AMatrixBinaryOpFunc(mMatFunc, lrVecFunc,...
                fHandle);
            %
            modgen.common.type.simple.checkgenext(...
                'x1(1)==x1(2)&&x1(2)==x2(1)', 2,...
                mMatFunc.getMatrixSize(), lrVecFunc.getMatrixSize());
            %
            self.nRows = 1;
            self.nCols = 1;
            self.nDims = 1;
        end
    end
end
