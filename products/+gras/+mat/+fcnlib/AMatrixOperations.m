classdef AMatrixOperations<gras.mat.fcnlib.IMatrixOperations
    methods(Access=protected)
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
        function obj=constTriu(self,mMatFunc)
            obj = self.constUnaryOperation(@triu,mMatFunc);
        end
        function obj=constMakeSymmetric(self,mMatFunc)
            obj = self.constUnaryOperation(@(x)0.5*(x+x.'),mMatFunc);
        end
        function obj=constPinv(self,mMatFunc)
            obj = self.constUnaryOperation(@pinv,mMatFunc);
        end
        function obj=constTranspose(self,mMatFunc)
            obj = self.constUnaryOperation(@transpose,mMatFunc);
        end
        function obj=constInv(self,mMatFunc)
            obj = self.constUnaryOperation(@inv,mMatFunc);
        end
        function obj=constSqrtm(self,mMatFunc)
            obj = self.constUnaryOperation(@sqrtm,mMatFunc);
        end
        function obj=constExpm(self,mMatFunc)
            obj = self.constUnaryOperation(@expm,mMatFunc);
        end
        function obj=constRMultiplyByVec(self,lMatFunc,rColFunc)
            obj = self.constBinaryOperation(@mtimes,lMatFunc,rColFunc);
        end
        function obj=constRMultiply(self,lMatFunc,mMatFunc,rMatFunc)
            if nargin < 4
                obj = self.constBinaryOperation(@mtimes,lMatFunc,mMatFunc);
            else
                obj = self.constTernaryOperation(@(a,b,c) a*b*c,...
                    lMatFunc,mMatFunc,rMatFunc);
            end
        end
        function obj=constLrMultiply(self,mMatFunc,lrMatFunc,flag)
            if flag == 'L'
                obj = self.constBinaryOperation(@(a,b) b*a*(b.'),...
                    mMatFunc,lrMatFunc);
            else
                obj = self.constBinaryOperation(@(a,b) (b.')*a*b,...
                    mMatFunc,lrMatFunc);
            end
        end
        function obj=constLrMultiplyByVec(self,mMatFunc,lrColFunc)
            obj = self.constBinaryOperation(@(a,b) (b.')*a*b,...
                mMatFunc,lrColFunc);
        end
        function obj=constLrDivideVec(self,mMatFunc,lrColFunc)
            obj = self.constBinaryOperation(@(a,b) (b.')*(a\b),...
                mMatFunc,lrColFunc);
        end
    end
    methods
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