classdef AMatrixBinaryOpArrayFunc<gras.mat.AMatrixOpFunc
    properties (Access=protected)
        lMatFunc
        rMatFunc
        opFuncHandle
    end
    methods
        function resArray=evaluate(self,timeVec)
            %
            lArray = self.lMatFunc.evaluate(timeVec);
            rArray = self.rMatFunc.evaluate(timeVec);
            %
            resArray = self.opFuncHandle(lArray,rArray);
        end
    end
    methods
        function self=AMatrixBinaryOpArrayFunc(lMatFunc, rMatFunc,...
                opFuncHandle)
            %
            modgen.common.type.simple.checkgen(lMatFunc,...
                @(x)isa(x,'gras.mat.IMatrixFunction'));
            modgen.common.type.simple.checkgen(rMatFunc,...
                @(x)isa(x,'gras.mat.IMatrixFunction'));
            modgen.common.type.simple.checkgen(opFuncHandle,...
                @(x)isa(x,'function_handle'));
            %
            self=self@gras.mat.AMatrixOpFunc;
            %
            self.lMatFunc = lMatFunc;
            self.rMatFunc = rMatFunc;
            self.opFuncHandle = opFuncHandle;
        end
    end
end
