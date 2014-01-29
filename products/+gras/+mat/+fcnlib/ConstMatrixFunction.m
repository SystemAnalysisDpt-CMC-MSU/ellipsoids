classdef ConstMatrixFunction<gras.mat.AConstMatrixFunction
    methods
        function self=ConstMatrixFunction(cMat)
            self=self@gras.mat.AConstMatrixFunction(cMat);
            self.nDims = 2;
        end
    end
end