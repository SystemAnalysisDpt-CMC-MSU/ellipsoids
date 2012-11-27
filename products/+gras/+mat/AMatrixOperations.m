classdef AMatrixOperations<gras.mat.IMatrixOperations
    methods(Access=private)
        function isOk = isMatFuncConst(self,varargin)
            isOk = true;
            for iArg = 1:length(varargin)
                if ~isa(varargin{iArg}, 'gras.mat.AConstMatrixFunction')
                    isOk = false;
                    break;
                end
            end
        end
        function obj = constUnaryOperation(self,fHandle,mMatFunc,varargin)
            import gras.mat.ConstMatrixFunctionFactory;
            mMat = mMatFunc.evaluate(0);
            obj = ConstMatrixFunctionFactory.createInstance(...
                fHandle(mMat, varargin{:}));
        end
        function obj = constBinaryOperation(self,fHandle,lMatFunc,...
                rMatFunc,varargin)
            import gras.mat.ConstMatrixFunctionFactory;
            %
            lMat = lMatFunc.evaluate(0);
            rMat = rMatFunc.evaluate(0);
            obj = ConstMatrixFunctionFactory.createInstance(...
                fHandle(lMat, rMat, varargin{:}));
        end
        function obj = constTernaryOperation(self,fHandle,lMatFunc,...
                mMatFunc,rMatFunc,varargin)
            import gras.mat.ConstMatrixFunctionFactory;
            %
            lMat = lMatFunc.evaluate(0);
            mMat = mMatFunc.evaluate(0);
            rMat = rMatFunc.evaluate(0);
            obj = ConstMatrixFunctionFactory.createInstance(...
                fHandle(lMat, mMat, rMat, varargin{:}));
        end        
    end
    methods
        function obj=triu(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj=self.constUnaryOperation(@triu,mMatFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=makeSymmetric(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constUnaryOperation(@(x)0.5*(x+x.'),mMatFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=pinv(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constUnaryOperation(@pinv,mMatFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=transpose(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constUnaryOperation(@transpose,mMatFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=inv(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constUnaryOperation(@inv,mMatFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=sqrtm(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constUnaryOperation(@sqrtm,mMatFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=expm(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constUnaryOperation(@expm,mMatFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=expmt(self,mMatFunc,t0)
            obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
        end
        function obj=rMultiplyByVec(self,lMatFunc,rColFunc)
            if self.isMatFuncConst(lMatFunc,rColFunc)
                obj = self.constBinaryOperation(@mtimes,lMatFunc,rColFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=rMultiply(self,lMatFunc,mMatFunc,rMatFunc)
            if nargin < 4
                if self.isMatFuncConst(lMatFunc,mMatFunc)
                    obj = self.constBinaryOperation(@mtimes,lMatFunc,mMatFunc);
                else
                    obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
                end
            else
                if self.isMatFuncConst(lMatFunc,mMatFunc,rMatFunc)
                    obj = self.constTernaryOperation(@(a,b,c) a*b*c,...
                        lMatFunc,mMatFunc,rMatFunc);
                else
                    obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
                end
            end
        end
        function obj=lrMultiply(self,mMatFunc,lrMatFunc,flag)
            if self.isMatFuncConst(mMatFunc,lrMatFunc)
                if flag == 'L'
                    obj = self.constBinaryOperation(@(a,b) b*a*(b.'),...
                        mMatFunc,lrMatFunc);
                else
                    obj = self.constBinaryOperation(@(a,b) (b.')*a*b,...
                        mMatFunc,lrMatFunc);
                end
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=lrMultiplyByVec(self,mMatFunc,lrColFunc)
            if self.isMatFuncConst(mMatFunc,lrColFunc)
                obj = self.constBinaryOperation(@(a,b) (b.')*a*b,...
                    mMatFunc,lrColFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=lrDivideVec(self,mMatFunc,lrColFunc)
            if self.isMatFuncConst(mMatFunc,lrColFunc)
                obj = self.constBinaryOperation(@(a,b) (b.')*(a\b),...
                    mMatFunc,lrColFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=quadraticFormSqrt(self,mMatFunc,xColFunc)
            obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
        end
        function obj = fromSymbMatrix(self, mCMat)
            import gras.mat.symb.MatrixSymbFormulaBased;
            import gras.mat.ConstMatrixFunctionFactory;
            import gras.mat.symb.iscellofstringconst;
            %
            if iscellofstringconst(mCMat)
                obj = ConstMatrixFunctionFactory.createInstance(mCMat);
            else
                obj = MatrixSymbFormulaBased(mCMat);
            end
        end
        function obj = rSymbMultiply(self, lCMat, mCMat, rCMat)
            import gras.mat.symb.MatrixSFTripleProd;
            import gras.mat.symb.MatrixSFBinaryProd;
            import gras.mat.ConstMatrixFunctionFactory;
            import gras.mat.symb.iscellofstringconst;
            import gras.gen.MatVector;
            %
            if nargin > 3
                if iscellofstringconst({lCMat{:},mCMat{:},rCMat{:}})
                    lMat = MatVector.fromFormulaMat(lCMat,0);
                    mMat = MatVector.fromFormulaMat(mCMat,0);
                    rMat = MatVector.fromFormulaMat(rCMat,0);
                    obj = ConstMatrixFunctionFactory.createInstance(...
                        lMat*mMat*rMat);
                else
                    obj = MatrixSFTripleProd(lCMat,mCMat,rCMat);
                end
            else
                if iscellofstringconst({lCMat{:},mCMat{:}})
                    lMat = MatVector.fromFormulaMat(lCMat,0);
                    mMat = MatVector.fromFormulaMat(mCMat,0);
                    obj = ConstMatrixFunctionFactory.createInstance(...
                        lMat*mMat);
                else
                    obj = MatrixSFBinaryProd(lCMat,mCMat);
                end
            end
        end
        %
        function obj = rSymbMultiplyByVec(self, mCMat, vCVec)
            import gras.mat.symb.MatrixSFBinaryProdByVec;
            import gras.mat.ConstMatrixFunctionFactory;
            import gras.mat.symb.iscellofstringconst;
            import gras.gen.MatVector;
            %
            if iscellofstringconst({mCMat{:},vCVec{:}})
                mMat = MatVector.fromFormulaMat(mCMat,0);
                vVec = MatVector.fromFormulaMat(vCVec,0);
                obj = ConstMatrixFunctionFactory.createInstance(...
                    mMat*vVec);
            else
                obj = MatrixSFBinaryProdByVec(mCMat,vCVec);
            end
        end
    end
end