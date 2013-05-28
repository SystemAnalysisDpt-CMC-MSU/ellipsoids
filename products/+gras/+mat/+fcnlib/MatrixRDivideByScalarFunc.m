classdef MatrixRDivideByScalarFunc<gras.mat.AMatrixBinaryOpFunc
    methods
        function self=MatrixRDivideByScalarFunc(mMatFunc, rScalFunc)
            fHandle = @(mMat,rScal) mMat ./ rScal;
            %
            self=self@gras.mat.AMatrixBinaryOpFunc(mMatFunc,...
                rScalFunc,fHandle);
            %
            modgen.common.type.simple.checkgenext(...
                'x1(1)==1&&x1(2)==1', 1,...
                rScalFunc.getMatrixSize());
            %
            self.nRows = mMatFunc.getNRows();
            self.nCols = mMatFunc.getNCols();
            self.nDims = mMatFunc.getDimensionality();
        end
    end
end
