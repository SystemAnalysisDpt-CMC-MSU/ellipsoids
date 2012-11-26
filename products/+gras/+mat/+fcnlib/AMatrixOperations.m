classdef AMatrixOperations<gras.mat.fcnlib.IMatrixOperations
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