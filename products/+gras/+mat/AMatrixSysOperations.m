classdef AMatrixSysOperations<gras.mat.IMatrixSysOperations
    methods
        function obj=rMultiply(self,lMatFunc,mMatFunc,rMatFunc)
            obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
        end
        %
        function obj=sum(self,lMatFunc,rMatFunc)
            obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
        end 
        %
        function obj=mulOnScalar(self,lMatFunc,scalarValue)
            obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();
        end 
        %
        function obj=transpose(self,mMatFunc)
            obj=gras.mat.ConstMatrixFunctionFactory.createEmptyInstance();    
        end
    end
end