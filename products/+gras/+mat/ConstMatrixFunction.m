classdef ConstMatrixFunction<gras.mat.AConstMatrixFunction
    methods
        function self=ConstMatrixFunction(cVec)
            self=self@gras.mat.AConstMatrixFunction(cVec);
            self.nDims = 2;
        end
    end
end