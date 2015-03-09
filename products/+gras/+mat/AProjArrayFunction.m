classdef AProjArrayFunction<gras.mat.IMatrixFunction
    properties (Access=protected)
        fProjFunction
        % parameters for fProjFunction
        projMat
        sTime
        dim
        indSTime
        %
        mArray
        mSizeVec
        nDims
        nRows
        nCols
    end
    methods
        function mSizeVec = getMatrixSize(self)
            mSizeVec = self.mSizeVec;
        end
        function projArray = evaluate(self,timeVec)
            [projArray,~] = self.fProjFunction(self.projMat,timeVec,...
                self.sTime,self.dim,self.indSTime);
            sizeArray = size(projArray);
            self.mArray = projArray;
            self.mSizeVec = sizeArray(1:2);
            self.nRows = self.mSizeVec(1);
            self.nCols = self.mSizeVec(2);
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
        function self=AProjArrayFunction(projMat,timeVec,sTime,dim,...
                indSTime,fProjFunction)
            %
            modgen.common.type.simple.checkgen(projMat,...
                'isnumeric(x)&&~isempty(x)');
            %
            self.projMat = projMat;
            self.sTime = sTime;
            self.dim = dim;
            self.indSTime = indSTime;
            self.fProjFunction = fProjFunction;
            self.evaluate(timeVec);
        end
    end
end