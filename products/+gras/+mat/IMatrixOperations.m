classdef IMatrixOperations
    methods (Abstract)
        obj=triu(self,mMat)
        obj=makeSymmetric(self,mMat)
        obj=pinv(self,mMat)
        obj=transpose(self,mMat)
        obj=rMultiplyByVec(self,lMat,rVec)
        obj=rMultiply(self,lMat,mMat,rMat)
        %
        obj=inv(self,mMat)
        obj=sqrtm(self,mMat)
        obj=lrMultiply(self,mMat,lrMat,flag)
        obj=lrMultiplyByVec(self,mMat,lrVec)
        obj=lrDivideVec(self,mMat,lrVec)
    end
end