classdef AMatrixUnaryOpArrayFunc<gras.mat.AMatrixOpFunc
    properties (Access=protected)
        lMatFunc
        opFuncHandle
    end
    methods
        function resArray=evaluate(self,timeVec)
            %
            lArray = self.lMatFunc.evaluate(timeVec);
            %
            resArray = self.opFuncHandle(lArray);
        end
    end
    methods
        function self=AMatrixUnaryOpArrayFunc(lMatFunc, opFuncHandle)
            %
            modgen.common.type.simple.checkgen(lMatFunc,...
                @(x)isa(x,'gras.mat.IMatrixFunction'));
            modgen.common.type.simple.checkgen(opFuncHandle,...
                @(x)isa(x,'function_handle'));
            %
            self=self@gras.mat.AMatrixOpFunc;
            %
            self.lMatFunc = lMatFunc;
            self.opFuncHandle = opFuncHandle;
        end
    end
end