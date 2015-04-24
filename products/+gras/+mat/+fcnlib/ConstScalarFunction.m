classdef ConstScalarFunction<gras.mat.ConstMatrixFunction
    methods
        function self=ConstScalarFunction(cVec)
            modgen.common.type.simple.checkgen(cVec,'isscalar(x)');
            %
            self=self@gras.mat.ConstMatrixFunction(cVec);
            self.nDims = 1;
        end
    end
end