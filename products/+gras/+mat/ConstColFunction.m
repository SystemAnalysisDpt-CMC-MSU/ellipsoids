classdef ConstColFunction<gras.mat.AConstMatrixFunction
    methods
        function self=ConstColFunction(cVec)
            modgen.common.type.simple.checkgen(cVec,'iscol(x)');
            %
            self=self@gras.mat.AConstMatrixFunction(cVec);
            self.nDims = 1;
        end
    end
end
