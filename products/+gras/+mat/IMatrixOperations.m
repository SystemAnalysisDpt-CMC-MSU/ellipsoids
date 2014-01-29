classdef IMatrixOperations<handle
    methods (Abstract)
        obj=triu(self,mMatFunc)
        obj=makeSymmetric(self,mMatFunc)
        obj=pinv(self,mMatFunc)
        obj=transpose(self,mMatFunc)
        obj=rMultiplyByVec(self,lMatFunc,rVecFunc)
        obj=rMultiply(self,lMatFunc,mMatFunc,rMatFunc)
        %
        obj=inv(self,mMatFunc)
        obj=sqrtmpos(self,mMatFunc)
        obj=expm(self,mMatFunc)
        obj=expmt(self,mMatFunc,t0)
        obj=lrMultiply(self,mMatFunc,lrMatFunc,flag)
        obj=lrMultiplyByVec(self,mMatFunc,lrVecFunc)
        obj=lrDivideVec(self,mMatFunc,lrVecFunc)
        obj=quadraticFormSqrt(self,mMatFunc,xVecFunc)
        %
        obj=rSymbMultiply(self,lCMat,mCMat,rCMat)
        obj=rSymbMultiplyByVec(self,mCMat,vCVec)
    end
    methods (Abstract,Static)
        obj=fromSymbMatrix(mCMat)
    end
end