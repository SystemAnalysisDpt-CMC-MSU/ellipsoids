classdef MatrixPosCheck < gras.mat.IMatrixFunction
    properties (Access = private)
        matFunc
    end
    methods
        function self = MatrixPosCheck(matFunc)
            modgen.common.type.simple.checkgen(matFunc,...
                @(x)isa(x,'gras.mat.IMatrixFunction'));
            self.matFunc = matFunc;
        end
        function mSizeVec = getMatrixSize(self)
            mSizeVec = self.matFunc.getMatrixSize();
        end
        function nDims=getDimensionality(self)
            nDims = self.matFunc.getDimensionality();
        end
        function nCols=getNCols(self)
            nCols = self.matFunc.getNCols();
        end
        function nRows=getNRows(self)
            nRows = self.matFunc.getNRows();
        end
        function resArray=evaluate(self, timeVec)
            resArray = self.matFunc.evaluate(timeVec);
            nTimePoints = numel(timeVec);
            for iTimePoint = 1 : nTimePoints
                modgen.common.type.simple.checkgen(...
                    resArray(:, :, iTimePoint), @gras.la.ismatposdef);
            end
        end
    end
end