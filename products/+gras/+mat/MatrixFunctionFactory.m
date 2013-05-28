classdef MatrixFunctionFactory
    methods (Static)
        function obj=createInstance(mCMat)
            import modgen.common.type.simple.checkgen;
            import gras.mat.symb.iscellofstringconst;
            import gras.mat.symb.MatrixSymbFormulaBased;
            import gras.mat.ConstMatrixFunctionFactory;
            %
            checkgen(mCMat,'(isnumeric(x)||iscellofstring(x))&&ismat(x)');
            if isnumeric(mCMat) || iscellofstringconst(mCMat)
                obj = ConstMatrixFunctionFactory.createInstance(mCMat);
            else
                checkgen(mCMat,@iscellstr);
                obj = MatrixSymbFormulaBased(mCMat);
            end
        end
        %
        function obj=createEmptyInstance()
            obj=createEmptyInstance@gras.mat.ConstMatrixFunctionFactory;
        end
    end
end