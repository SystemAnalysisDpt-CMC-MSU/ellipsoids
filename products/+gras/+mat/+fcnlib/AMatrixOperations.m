classdef AMatrixOperations<gras.mat.fcnlib.IMatrixOperations
    methods
        function obj = fromSymbMatrix(self, mCMat)
            import gras.mat.symb.MatrixSymbFormulaBased;
            obj=MatrixSymbFormulaBased(mCMat);
        end
    end
end