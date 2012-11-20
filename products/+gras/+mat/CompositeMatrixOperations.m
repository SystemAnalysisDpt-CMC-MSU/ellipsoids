classdef CompositeMatrixOperations<gras.mat.IMatrixOperations
    methods
        function obj=triu(self,mMatFunc)
            obj = gras.mat.MatrixTriuFunc(mMatFunc);
        end
        function obj=makeSymmetric(self,mMatFunc)
            obj = gras.mat.MatrixMakeSymmetricFunc(mMatFunc);
        end
        function obj=pinv(self,mMatFunc)
            obj = gras.mat.MatrixPinvFunc(mMatFunc);
        end
        function obj=transpose(self,mMatFunc)
            obj = gras.mat.MatrixTransposeFunc(mMatFunc);
        end
        function obj=inv(self,mMatFunc)
            obj = gras.mat.MatrixInvFunc(mMatFunc);
        end
        function obj=sqrtm(self,mMatFunc)
            obj = gras.mat.MatrixSqrtFunc(mMatFunc);
        end
        function obj=rMultiplyByVec(self,lMatFunc,rColFunc)
            obj = gras.mat.MatrixBinaryTimesFunc(lMatFunc,rColFunc);
        end
        function obj=rMultiply(self,lMatFunc,mMatFunc,rMatFunc)
            if nargin > 3
                obj = gras.mat.MatrixTernaryTimesFunc(lMatFunc,mMatFunc,rMatFunc);
            else
                obj = gras.mat.MatrixBinaryTimesFunc(lMatFunc,mMatFunc);
            end
        end
        function obj=lrMultiply(self,mMatFunc,lrMatFunc,flag)
            obj = gras.mat.MatrixLRTimesFunc(mMatFunc,lrMatFunc,flag);
        end
        function obj=lrMultiplyByVec(self,mMatFunc,lrColFunc)
            obj = gras.mat.MatrixLRTimesFunc(mMatFunc,lrColFunc,'R');
        end
    end
end