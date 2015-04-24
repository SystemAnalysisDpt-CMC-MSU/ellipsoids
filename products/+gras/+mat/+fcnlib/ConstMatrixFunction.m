classdef ConstMatrixFunction<gras.mat.ConstMatrixFunction
    methods
        function self=ConstMatrixFunction(cMat)
            self=self@gras.mat.ConstMatrixFunction(cMat);
            self.nDims = 2;
        end
    end
end