classdef AMatrixBinaryOpFunc<gras.mat.AMatrixOpFunc
    properties (Access=protected)
        lMatFunc
        rMatFunc
        opFuncHandle
    end
    methods
        function resArray=evaluate(self,timeVec)
            nTimePoints = numel(timeVec);
            %
            lArray = self.lMatFunc.evaluate(timeVec);
            rArray = self.rMatFunc.evaluate(timeVec);
            %
            if nTimePoints == 1
                resArray = self.opFuncHandle(lArray,rArray);
            else
                resArray = zeros( [self.nRows, self.nCols, nTimePoints] );
                for iTimePoint = 1:nTimePoints
                    resArray(:,:,iTimePoint) = self.opFuncHandle(...
                        lArray(:,:,iTimePoint), rArray(:,:,iTimePoint));
                end
            end
        end
    end
    methods
        function self=AMatrixBinaryOpFunc(lMatFunc, rMatFunc, opFuncHandle)
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
