classdef AMatrixUnaryOpFunc<gras.mat.AMatrixOpFunc
    properties (Access=protected)
        lMatFunc
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
            if ~isa(lMatFunc, 'gras.mat.IMatrixFunction')
                modgen.common.throwerror('wrongInput',...
                    'lMatFunc must be of type IMatrixFunction');
            end
            %
            self=self@gras.mat.AMatrixOpFunc(opFuncHandle);
            %
            self.lMatFunc = lMatFunc;
        end
    end
end
