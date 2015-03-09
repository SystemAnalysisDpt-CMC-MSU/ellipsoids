classdef CompositeMatrixSysOperations<gras.mat.AMatrixSysOperations
    methods
        function obj=rMultiply(self,lMatFunc,mMatFunc,rMatFunc)
            if nargin < 4
                obj=rMultiply@gras.mat.AMatrixSysOperations(...
                    self,lMatFunc,mMatFunc);
                if isempty(obj)
                    obj = gras.mat.fcnlib.MatrixSysBinaryTimesFunc(lMatFunc,...
                        mMatFunc);
                end
            else
                obj=rMultiply@gras.mat.AMatrixSysOperations(...
                    self,lMatFunc,mMatFunc,rMatFunc);
                if isempty(obj)
                    obj = gras.mat.fcnlib.MatrixSysTernaryTimesFunc(lMatFunc,...
                        mMatFunc,rMatFunc);
                end
            end
        end
        %
        function obj=sum(self,lMatFunc,rMatFunc)
            obj=sum@gras.mat.AMatrixSysOperations(self,lMatFunc,rMatFunc);
            if isempty(obj)
                obj=gras.mat.fcnlib.MatrixSysSumFunc(lMatFunc,rMatFunc);
            end
        end 
        %
        function obj=mulOnScalar(self,lMatFunc,scalarValue)
            obj=mulOnScalar@gras.mat.AMatrixSysOperations(self,lMatFunc,scalarValue);
            if isempty(obj)
                obj=gras.mat.fcnlib.MatrixSysMulOnScalarFunc(lMatFunc,scalarValue);
            end
        end 
        %
        function obj=transpose(self,mMatFunc)
            obj=transpose@gras.mat.AMatrixSysOperations(self,mMatFunc);
            if isempty(obj)
                obj=gras.mat.fcnlib.MatrixSysTransposeFunc(mMatFunc);
            end
        end
    end
end
