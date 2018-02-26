classdef AMatrixOperations<gras.mat.IMatrixOperations
    methods(Access=private)
        function isOk = isMatFuncConst(~,varargin)
            isOk = true;
            for iArg = 1:length(varargin)
                if ~isa(varargin{iArg}, 'gras.mat.AConstMatrixFunction')
                    isOk = false;
                    break;
                end
            end
        end
        function obj = constUnaryOperation(~,fHandle,mMatFunc,varargin)
            import gras.mat.ConstMatrixFunctionFactory;
            mMat = mMatFunc.evaluate(0);
            obj = ConstMatrixFunctionFactory.createInstance(...
                fHandle(mMat, varargin{:}));
        end
        function obj = constBinaryOperation(~,fHandle,lMatFunc,...
                rMatFunc,varargin)
            import gras.mat.ConstMatrixFunctionFactory;
            %
            lMat = lMatFunc.evaluate(0);
            rMat = rMatFunc.evaluate(0);
            obj = ConstMatrixFunctionFactory.createInstance(...
                fHandle(lMat, rMat, varargin{:}));
        end
        function obj = constTernaryOperation(~,fHandle,lMatFunc,...
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
        function obj=sqrtmpos(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constUnaryOperation(@gras.la.sqrtmpos,mMatFunc);
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
        function obj=uminus(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constUnaryOperation(@uminus,mMatFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=realsqrt(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constUnaryOperation(@realsqrt,mMatFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=expmt(~,mMatFunc,t0) %#ok<*INUSD>
            obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
        end
        function obj=matdot(self,lMatFunc,rMatFunc)
            import gras.gen.matdot;
            if self.isMatFuncConst(lMatFunc,rMatFunc)
                obj = self.constBinaryOperation(@matdot,lMatFunc,rMatFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=rMultiplyByScalar(self,lMatFunc,rScalFunc)
            if self.isMatFuncConst(lMatFunc,rScalFunc)
                obj = self.constBinaryOperation(@times,lMatFunc,rScalFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
        end
        function obj=rDivideByScalar(self,lMatFunc,rScalFunc)
            if self.isMatFuncConst(lMatFunc,rScalFunc)
                obj = self.constBinaryOperation(@rdivide,lMatFunc,rScalFunc);
            else
                obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
            end
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
        function obj=quadraticFormSqrt(~,mMatFunc,xColFunc)
            obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
        end
        function obj = rSymbMultiply(~, lCMat, mCMat, rCMat)
            import gras.mat.fcnlib.MatrixSFTripleProd;
            import gras.mat.fcnlib.MatrixSFBinaryProd;
            import gras.mat.ConstMatrixFunctionFactory;
            import gras.sym.isdependent;
            import gras.gen.MatVector;
            %
            if nargin > 3
                if isdependent({lCMat{:},mCMat{:},rCMat{:}}) %#ok<*CCAT>
                    lMat = MatVector.fromFormulaMat(lCMat,0);
                    mMat = MatVector.fromFormulaMat(mCMat,0);
                    rMat = MatVector.fromFormulaMat(rCMat,0);
                    obj = ConstMatrixFunctionFactory.createInstance(...
                        lMat*mMat*rMat);
                else
                    obj = MatrixSFTripleProd(lCMat,mCMat,rCMat);
                end
            else
                if isdependent({lCMat{:},mCMat{:}})
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
        function obj = rSymbMultiplyByVec(~, mCMat, vCVec)
            import gras.mat.fcnlib.MatrixSFBinaryProdByVec;
            import gras.mat.ConstMatrixFunctionFactory;
            import gras.sym.isdependent;
            import gras.gen.MatVector;
            %
            if isdependent({mCMat{:},vCVec{:}})
                mMat = MatVector.fromFormulaMat(mCMat,0);
                vVec = MatVector.fromFormulaMat(vCVec,0);
                obj = ConstMatrixFunctionFactory.createInstance(...
                    mMat*vVec);
            else
                obj = MatrixSFBinaryProdByVec(mCMat,vCVec);
            end
        end
    end
    methods(Static)
        function obj = fromSymbMatrix(mCMat)
            import gras.mat.fcnlib.MatrixSymbFormulaBased;
            import gras.mat.ConstMatrixFunctionFactory;
            import gras.sym.isdependent;
            %
            if isdependent(mCMat)
                obj = ConstMatrixFunctionFactory.createInstance(mCMat);
            else
                obj = MatrixSymbFormulaBased(mCMat);
            end
        end
    end
end