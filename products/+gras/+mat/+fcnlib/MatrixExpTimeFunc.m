classdef MatrixExpTimeFunc<gras.mat.AMatrixOpFunc
    properties (Access=protected)
        lMatFunc
        t0
    end
    methods
        function resArray=evaluate(self,timeVec)
            nTimePoints = numel(timeVec);
            %
            lArray = self.lMatFunc.evaluate(timeVec);
            %
            if nTimePoints == 1
                resArray = expm(lArray*(timeVec-self.t0));
            else
                resArray = zeros( [self.nRows, self.nCols, nTimePoints] );
                for iTimePoint = 1:nTimePoints
                    resArray(:,:,iTimePoint) = expm(...
                        lArray(:,:,iTimePoint)*(timeVec(iTimePoint)-self.t0));
                end
            end
        end
    end
    methods
        function self=MatrixExpTimeFunc(lMatFunc, t0)
            %
            modgen.common.type.simple.checkgen(lMatFunc,...
                @(x)isa(x,'gras.mat.IMatrixFunction'));
            %
            modgen.common.type.simple.checkgen(lMatFunc.getMatrixSize(),...
                'x(1)==x(2)');
            %
            self=self@gras.mat.AMatrixOpFunc;
            %
            self.lMatFunc = lMatFunc;
            self.t0 = t0;
            self.nRows = lMatFunc.getNRows();
            self.nCols = lMatFunc.getNCols();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
