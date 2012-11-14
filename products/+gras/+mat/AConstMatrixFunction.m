classdef AConstMatrixFunction<gras.mat.IMatrixFunction
    properties (Access=protected)
        mMat
        mSizeVec
        nDims
        nRows
        nCols
    end
    methods
        function mSizeVec = getMatrixSize(self)
            mSizeVec = self.mSizeVec;
        end
        function res=evaluate(self,timeVec)
            res = repmat(self.mMat,[1,1,numel(timeVec)]);
        end
        function nDims=getDimensionality(self)
            nDims = self.nDims;
        end
        function nCols=getNCols(self)
            nCols = self.nCols;
        end
        function nRows=getNRows(self)
            nRows = self.nRows;
        end
    end
    methods
        function self=AConstMatrixFunction(mMat)
            %
            modgen.common.type.simple.checkgen(mMat,...
                'isnumeric(x)&&ismat(x)&&~isempty(x)');
            %
            self.mMat = mMat;
            self.mSizeVec = size(mMat);
            self.nRows = self.mSizeVec(1);
            self.nCols = self.mSizeVec(2);
        end
    end
end
