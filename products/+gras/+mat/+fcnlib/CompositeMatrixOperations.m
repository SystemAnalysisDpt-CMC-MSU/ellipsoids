classdef CompositeMatrixOperations<gras.mat.fcnlib.AMatrixOperations
    methods
        function obj=triu(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constTriu(mMatFunc);
            else
                obj = gras.mat.fcnlib.MatrixTriuFunc(mMatFunc);
            end
        end
        function obj=makeSymmetric(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constMakeSymmetric(mMatFunc);
            else
                obj = gras.mat.fcnlib.MatrixMakeSymmetricFunc(mMatFunc);
            end
        end
        function obj=pinv(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constPinv(mMatFunc);
            else
                obj = gras.mat.fcnlib.MatrixPInvFunc(mMatFunc);
            end
        end
        function obj=transpose(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constTranspose(mMatFunc);
            else
                obj = gras.mat.fcnlib.MatrixTransposeFunc(mMatFunc);
            end
        end
        function obj=inv(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constInv(mMatFunc);
            else
                obj = gras.mat.fcnlib.MatrixInvFunc(mMatFunc);
            end
        end
        function obj=sqrtm(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constSqrtm(mMatFunc);
            else
                obj = gras.mat.fcnlib.MatrixSqrtFunc(mMatFunc);
            end
        end
        function obj=expm(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constExpm(mMatFunc);
            else
                obj = gras.mat.fcnlib.MatrixExpFunc(mMatFunc);
            end
        end
        function obj=expmt(self,mMatFunc,t0)
            obj = gras.mat.fcnlib.MatrixExpTimeFunc(mMatFunc,t0);
        end
        function obj=rMultiplyByVec(self,lMatFunc,rColFunc)
            if self.isMatFuncConst(lMatFunc,rColFunc)
                obj = self.constRMultiplyByVec(lMatFunc,rColFunc);
            else
                obj = gras.mat.fcnlib.MatrixBinaryTimesFunc(lMatFunc,rColFunc);
            end
        end
        function obj=rMultiply(self,lMatFunc,mMatFunc,rMatFunc)
            if nargin < 4
                if self.isMatFuncConst(lMatFunc,mMatFunc)
                    obj = self.constRMultiply(lMatFunc,mMatFunc);
                else
                    obj = gras.mat.fcnlib.MatrixBinaryTimesFunc(lMatFunc,...
                        mMatFunc);
                end
            else
                if self.isMatFuncConst(lMatFunc,mMatFunc,rMatFunc)
                    obj = self.constRMultiply(lMatFunc,mMatFunc,rMatFunc);
                else
                    obj = gras.mat.fcnlib.MatrixTernaryTimesFunc(lMatFunc,...
                        mMatFunc,rMatFunc);
                end
            end
        end
        function obj=lrMultiply(self,mMatFunc,lrMatFunc,flag)
            if self.isMatFuncConst(mMatFunc,lrMatFunc)
                obj = self.constLrMultiply(mMatFunc,lrMatFunc,flag);
            else
                obj = gras.mat.fcnlib.MatrixLRTimesFunc(mMatFunc,lrMatFunc,...
                    flag);
            end
        end
        function obj=lrMultiplyByVec(self,mMatFunc,lrColFunc)
            if self.isMatFuncConst(mMatFunc,lrColFunc)
                obj = self.constLrMultiplyByVec(mMatFunc,lrColFunc);
            else
                obj = gras.mat.fcnlib.MatrixLRTimesFunc(mMatFunc,lrColFunc,...
                    'R');
            end
        end
        function obj=lrDivideVec(self,mMatFunc,lrColFunc)
            if self.isMatFuncConst(mMatFunc,lrColFunc)
                obj = self.constLrDivideVec(mMatFunc,lrColFunc);
            else
                obj = gras.mat.fcnlib.MatrixLRDivideVecFunc(mMatFunc,...
                    lrColFunc);
            end
        end
        function obj=quadraticFormSqrt(self,mMatFunc,xColFunc)
            obj = gras.mat.fcnlib.QuadraticFormSqrtFunc(mMatFunc,xColFunc);
        end
    end
end