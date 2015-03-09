classdef ConstRowFunction<gras.mat.ConstMatrixFunction
    methods
        function self=ConstRowFunction(cVec)
            modgen.common.type.simple.checkgen(cVec,'isrow(x)');
            %
            self=self@gras.mat.ConstMatrixFunction(cVec);
            self.nDims = 1;
        end
    end
end