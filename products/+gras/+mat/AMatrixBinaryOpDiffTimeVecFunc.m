classdef AMatrixBinaryOpDiffTimeVecFunc<gras.mat.AMatrixOpFunc
    properties (Access=protected)
        lMatFunc
        rMatFunc
        timePartition
        timePartitionRight
        opFuncHandle
    end
    methods
        function resArray=evaluate(self,timeVec)
            %
            time1Vec = timeVec(timeVec <= self.timePartition);
            time2Vec = timeVec(timeVec > self.timePartitionRight);
            lArray = self.lMatFunc.evaluate(time1Vec);
            rArray = self.rMatFunc.evaluate(time2Vec);
            %
            
            resArray = self.opFuncHandle(lArray,rArray);
        end
    end
    methods
        function self=AMatrixBinaryOpDiffTimeVecFunc(lMatFunc, rMatFunc,...
                opFuncHandle,timePartition,timePartitionRight)
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
            self.timePartition = timePartition;
            self.timePartitionRight = timePartitionRight;
        end
    end
end


