classdef MatrixExpTimeFunc<gras.mat.fcnlib.AMatrixOpFunc
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
                resArray(:,:,iTimePoint) = expm(...
                    lArray(:,:,iTimePoint)*timeVec(iTimePoint));
            end
        end
    end
    methods
        function self=MatrixExpTimeFunc(lMatFunc)
            %
            modgen.common.type.simple.checkgen(lMatFunc,...
                @(x)isa(x,'gras.mat.IMatrixFunction'));
            %
            modgen.common.type.simple.checkgen(lMatFunc.getMatrixSize(),...
                'x(1)==x(2)');
            %
            self=self@gras.mat.fcnlib.AMatrixOpFunc;
            %
            self.lMatFunc = lMatFunc;
            self.nRows = lMatFunc.getNRows();
            self.nCols = lMatFunc.getNCols();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
