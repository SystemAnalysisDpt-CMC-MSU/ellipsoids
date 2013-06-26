classdef ConstMatrixFunctionFactory
    methods (Static)
        function obj=createInstance(mCMat)
            import modgen.common.type.simple.checkgen;
            import modgen.common.throwerror;
            import gras.gen.MatVector;
            import gras.mat.fcnlib.*;
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
            if any([nRows, nCols] == 1)
                if nRows > 1
                    obj = ConstColFunction(mMat);
                elseif nCols > 1
                    obj = ConstRowFunction(mMat);
                else
                    obj = ConstScalarFunction(mMat);
                end
            else
                obj = ConstMatrixFunction(mMat);
            end
        end
        %
        function obj=createEmptyInstance()
            obj=gras.mat.fcnlib.ConstMatrixFunction.empty(0,1);
        end
    end
end