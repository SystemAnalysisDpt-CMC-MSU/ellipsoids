classdef AMatrixUnaryOpFunc<gras.mat.AMatrixOpFunc
    properties (Access=protected)
        lMatFunc
        opFuncHandle
    end
    methods
        function resArray=evaluate(self,timeVec)
            nTimePoints = numel(timeVec);
            %
            lArray = self.lMatFunc.evaluate(timeVec);
            %
            if nTimePoints == 1
                resArray = self.opFuncHandle(lArray);
            else
                resArray = zeros( [self.nRows, self.nCols, nTimePoints] );
                for iTimePoint = 1:nTimePoints
                    resArray(:,:,iTimePoint) = self.opFuncHandle(...
                        lArray(:,:,iTimePoint));
                end
            end
        end
    end
    methods
        function self=AMatrixUnaryOpFunc(lMatFunc, opFuncHandle)
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
