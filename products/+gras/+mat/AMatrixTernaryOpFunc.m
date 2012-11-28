classdef AMatrixTernaryOpFunc<gras.mat.AMatrixOpFunc
    properties (Access=protected)
        lMatFunc
        mMatFunc
        rMatFunc
        opFuncHandle
    end
    methods
        function resArray=evaluate(self,timeVec)
            nTimePoints = numel(timeVec);
            %
            lArray = self.lMatFunc.evaluate(timeVec);
            mArray = self.mMatFunc.evaluate(timeVec);
            rArray = self.rMatFunc.evaluate(timeVec);
            %
            if nTimePoints == 1
                resArray = self.opFuncHandle(lArray,mArray,rArray);
            else
                resArray = zeros( [self.nRows, self.nCols, nTimePoints] );
                for iTimePoint = 1:nTimePoints
                    resArray(:,:,iTimePoint) = self.opFuncHandle(...
                        lArray(:,:,iTimePoint), mArray(:,:,iTimePoint),...
                        rArray(:,:,iTimePoint));
                end
            end
        end
    end
    methods
        function self=AMatrixTernaryOpFunc(lMatFunc, mMatFunc,...
                rMatFunc, opFuncHandle)
            %
            modgen.common.type.simple.checkgen(lMatFunc,...
                @(x)isa(x,'gras.mat.IMatrixFunction'));
            modgen.common.type.simple.checkgen(mMatFunc,...
                @(x)isa(x,'gras.mat.IMatrixFunction'));
            modgen.common.type.simple.checkgen(rMatFunc,...
                @(x)isa(x,'gras.mat.IMatrixFunction'));
            modgen.common.type.simple.checkgen(opFuncHandle,...
                @(x)isa(x,'function_handle'));
            %
            self=self@gras.mat.AMatrixOpFunc;
            %
            self.lMatFunc = lMatFunc;
            self.mMatFunc = mMatFunc;
            self.rMatFunc = rMatFunc;
            self.opFuncHandle = opFuncHandle;
        end
    end
end
