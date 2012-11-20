classdef MatrixLRDivideVecFunc<gras.mat.AMatrixBinaryOpFunc
    methods
        function self=MatrixLRDivideVecFunc(mMatFunc, lrVecFunc)
            fHandle = @(mMat,lrVec) (lrVec.')*(mMat\lrVec);
            %
            self=self@gras.mat.AMatrixBinaryOpFunc(mMatFunc, lrVecFunc,...
                fHandle);
            %
            mSizeVec = mMatFunc.getMatrixSize();
            lrSizeVec = lrVecFunc.getMatrixSize();
            %
            if ~(mSizeVec(1)==mSizeVec(2)&&mSizeVec(2)==lrSizeVec(1))
                modgen.common.throwerror('wrongInput',...
                    'Inner matrix dimensions must agree');
            end
            %
            self.nRows = 1;
            self.nCols = 1;
            self.nDims = 1;
        end
    end
end
