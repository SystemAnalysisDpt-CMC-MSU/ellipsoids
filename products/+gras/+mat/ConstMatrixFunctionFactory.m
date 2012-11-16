classdef ConstMatrixFunctionFactory
    methods (Static)
        function obj=createInstance(mCMat)
            import modgen.common.type.simple.checkgen;
            import modgen.common.throwerror;
            import gras.gen.MatVector;
            import gras.mat.*;
            import gras.mat.symb.iscellofstringconst;
            %
            checkgen(mCMat,'(isnumeric(x)||iscellofstring(x))&&ismat(x)');
            if isnumeric(mCMat)
                mMat = mCMat;
            else
                checkgen(mCMat,@iscellofstringconst);
                mMat = MatVector.fromFormulaMat(mCMat,0);
            end
            %
            [nRows, nCols] = size(mMat);
            if nCols == 1 && nRows > 1
                obj = ConstColFunction(mMat);
            elseif nRows == 1 && nCols > 1
                obj = ConstRowFunction(mMat);
            else
                obj = ConstMatrixFunction(mMat);
            end
        end
    end
end