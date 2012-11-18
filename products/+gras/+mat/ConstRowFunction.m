classdef ConstRowFunction<gras.mat.AConstMatrixFunction
    methods
        function self=ConstRowFunction(cVec)
            modgen.common.type.simple.checkgen(cVec,'isrow(x)');
            %
            self=self@gras.mat.AConstMatrixFunction(cVec);
            self.nDims = 1;
        end
    end
end