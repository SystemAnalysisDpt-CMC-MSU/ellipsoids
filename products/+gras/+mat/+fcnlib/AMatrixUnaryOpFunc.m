classdef AMatrixUnaryOpFunc<gras.mat.fcnlib.AMatrixOpFunc
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
            resArray = zeros( [self.nRows, self.nCols, nTimePoints] );
            for iTimePoint = 1:nTimePoints
                resArray(:,:,iTimePoint) = self.opFuncHandle(...
                    lArray(:,:,iTimePoint));
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
            self=self@gras.mat.fcnlib.AMatrixOpFunc;
            %
            self.lMatFunc = lMatFunc;
            self.opFuncHandle = opFuncHandle;
        end
    end
end
