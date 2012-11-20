classdef AMatrixTernaryOpFunc<gras.mat.AMatrixOpFunc
    properties (Access=protected)
        lMatFunc
        mMatFunc
        rMatFunc
    end
    methods
        function resArray=evaluate(self,timeVec)
            nTimePoints = numel(timeVec);
            %
            lArray = self.lMatFunc.evaluate(timeVec);
            mArray = self.mMatFunc.evaluate(timeVec);
            rArray = self.rMatFunc.evaluate(timeVec);
            %
            resArray = zeros( [self.nRows, self.nCols, nTimePoints] );
            for iTimePoint = 1:nTimePoints
                resArray(:,:,iTimePoint) = self.opFuncHandle(...
                    lArray(:,:,iTimePoint), mArray(:,:,iTimePoint),...
                    rArray(:,:,iTimePoint));
            end
        end
    end
    methods
        function self=AMatrixTernaryOpFunc(lMatFunc, mMatFunc,...
                rMatFunc, opFuncHandle)
            %
            if ~isa(lMatFunc, 'gras.mat.IMatrixFunction')
                modgen.common.throwerror('wrongInput',...
                    'lMatFunc must be of type IMatrixFunction');
            end
            %
            if ~isa(mMatFunc, 'gras.mat.IMatrixFunction')
                modgen.common.throwerror('wrongInput',...
                    'mMatFunc must be of type IMatrixFunction');
            end
            %
            if ~isa(rMatFunc, 'gras.mat.IMatrixFunction')
                modgen.common.throwerror('wrongInput',...
                    'rMatFunc must be of type IMatrixFunction');
            end
            %
            self=self@gras.mat.AMatrixOpFunc(opFuncHandle);
            %
            self.lMatFunc = lMatFunc;
            self.mMatFunc = mMatFunc;
            self.rMatFunc = rMatFunc;
        end
    end
end
