classdef MatrixSymbInterpFactory
    methods (Static)
        function obj=rMultiply(inp1CMat,inp2CMat,inp3CMat)
            import gras.mat.MatrixSFBinaryProd;
            import gras.mat.MatrixSFTripleProd;
            import modgen.common.throwerror;
            if nargin==2
                obj=MatrixSFBinaryProd(inp1CMat,inp2CMat);
            elseif nargin==3
                obj=MatrixSFTripleProd(inp1CMat,inp2CMat,inp3CMat);
            else
                throwerror('wrongInput',...
                    'at lest 2 input arguments are expected');
            end
        end
        function obj=rMultiplyByVec(inp1CMat,inp2CMat)
            import gras.mat.MatrixSFBinaryProdByVec;
            obj=MatrixSFBinaryProdByVec(inp1CMat,inp2CMat);
        end
        function obj=single(inpCMat)
            import gras.mat.MatrixSymbFormulaBased;
            obj=MatrixSymbFormulaBased(inpCMat);
        end
    end
end