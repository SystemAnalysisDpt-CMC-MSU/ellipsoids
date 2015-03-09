classdef IMatrixSysOperations<handle
    methods (Abstract)
        obj=rMultiply(self,lMatFunc,mMatFunc,rMatFunc);
        obj=sum(self,lMatFunc,rMatFunc);
        obj=mulOnScalar(self,lMatFunc,scalarValue);
        obj=transpose(self,mMatFunc);
    end
end