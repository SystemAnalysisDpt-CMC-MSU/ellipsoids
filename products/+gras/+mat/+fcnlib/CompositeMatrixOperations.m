classdef CompositeMatrixOperations<gras.mat.fcnlib.AMatrixOperations
    methods
        function obj=triu(self,mMatFunc)
            obj = gras.mat.fcnlib.MatrixTriuFunc(mMatFunc);
        end
        function obj=makeSymmetric(self,mMatFunc)
            obj = gras.mat.fcnlib.MatrixMakeSymmetricFunc(mMatFunc);
        end
        function obj=pinv(self,mMatFunc)
            obj = gras.mat.fcnlib.MatrixPInvFunc(mMatFunc);
        end
        function obj=transpose(self,mMatFunc)
            obj = gras.mat.fcnlib.MatrixTransposeFunc(mMatFunc);
        end
        function obj=inv(self,mMatFunc)
            obj = gras.mat.fcnlib.MatrixInvFunc(mMatFunc);
        end
        function obj=sqrtm(self,mMatFunc)
            obj = gras.mat.fcnlib.MatrixSqrtFunc(mMatFunc);
        end
        function obj=rMultiplyByVec(self,lMatFunc,rColFunc)
            obj = gras.mat.fcnlib.MatrixBinaryTimesFunc(lMatFunc,rColFunc);
        end
        function obj=rMultiply(self,lMatFunc,mMatFunc,rMatFunc)
            if nargin > 3
                obj = gras.mat.fcnlib.MatrixTernaryTimesFunc(lMatFunc,...
                    mMatFunc,rMatFunc);
            else
                obj = gras.mat.fcnlib.MatrixBinaryTimesFunc(lMatFunc,...
                    mMatFunc);
            end
        end
        function obj=lrMultiply(self,mMatFunc,lrMatFunc,flag)
            obj = gras.mat.fcnlib.MatrixLRTimesFunc(mMatFunc,lrMatFunc,...
                flag);
        end
        function obj=lrMultiplyByVec(self,mMatFunc,lrColFunc)
            obj = gras.mat.fcnlib.MatrixLRTimesFunc(mMatFunc,lrColFunc,...
                'R');
        end
        function obj=lrDivideVec(self,mMatFunc,lrColFunc)
            obj = gras.mat.fcnlib.MatrixLRDivideVecFunc(mMatFunc,...
                lrColFunc);
        end
        function obj=quadraticFormSqrt(self,mMatFunc,xColFunc)
            obj = gras.mat.fcnlib.QuadraticFormSqrtFunc(mMatFunc,xColFunc);
        end
    end
end