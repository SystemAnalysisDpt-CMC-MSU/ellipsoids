classdef AMatrixOperations<gras.mat.fcnlib.IMatrixOperations
    methods
        function obj = fromSymbMatrix(self, mCMat)
            import gras.mat.symb.MatrixSymbFormulaBased;
            obj=MatrixSymbFormulaBased(mCMat);
        end
        function obj = rSymbMultiply(self, lCMat, mCMat, rCMat)
            import gras.mat.symb.MatrixSFTripleProd;
            import gras.mat.symb.MatrixSFBinaryProd;
            %
            if nargin > 3
                obj = MatrixSFTripleProd(lCMat,mCMat,rCMat);
            else
                obj = MatrixSFBinaryProd(lCMat,mCMat);            
            end
        end  
        function obj = rSymbMultiplyByVec(self, mCMat, vCVec)
            import gras.mat.symb.MatrixSFBinaryProdByVec;
            obj = MatrixSFBinaryProdByVec(mCMat,vCVec);
        end      
    end
end