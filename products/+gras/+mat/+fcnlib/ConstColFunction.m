classdef ConstColFunction<gras.mat.ConstMatrixFunction
    methods
        function self=ConstColFunction(cVec)
            modgen.common.type.simple.checkgen(cVec,'iscol(x)');
            %
            self=self@gras.mat.ConstMatrixFunction(cVec);
            self.nDims = 1;
        end
    end
end
