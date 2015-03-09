classdef MatrixNormOrigVecFunc<gras.mat.AMatrixFunctionComparable
    properties (Access=protected)
        ltGoodDirNormVecInterObj
        dimProj
        %
        mSizeVec
        nDims
        nRows
        nCols
    end
    methods
        function mSizeVec = getMatrixSize(self)
            mSizeVec = self.mSizeVec;
        end
        function normOrigVecMatrix = evaluate(self,timeVec)
            ltGoodDirNormVec = self.ltGoodDirNormVecInterObj.evaluate(timeVec);            
            normOrigVecMatrix = repmat(ltGoodDirNormVec,self.dimProj,1);          
            self.mSizeVec = size(normOrigVecMatrix);
            self.nRows = self.mSizeVec(1);
            self.nCols = self.mSizeVec(2);
            self.nDims = self.mSizeVec(1);
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
        function dimProj = getdimProj(self)
            dimProj = self.dimProj;
        end
    end
    methods
        function self=MatrixNormOrigVecFunc(ltGoodDirNormVecInterObj,dimProj,timeVec)
            self.ltGoodDirNormVecInterObj = ltGoodDirNormVecInterObj;
            self.dimProj = dimProj;
            self.evaluate(timeVec);
        end
    end
    methods (Access=protected)
         function [SData, SFieldNiceNames, SFieldDescr] = ...
                toStructInternal(self, varargin)
            
            [SData,SFieldNiceNames,SFieldDescr]=toStructInternal@gras.mat.AMatrixComparable(varargin{:});

            MatrixNormOrigVec = self.ltGoodDirNormVecInterObj;
            [dataArray,timeVec] = MatrixNormOrigVec.getKnotDataArray();
            SData.dataArray = dataArray;
            SData.tiveVec = timeVec;
            
            SFieldNiceNames.dataArray = 'dArray';
            SFieldNiceNames.timeVec = 'tVec';
            SFieldNiceNames.dimProj = 'dProj';
            
            SFieldDescr.dataArray = 'Array of data';
            SFieldDescr.timeVec = 'Vector of time moments';
            SFieldDescr.dimProj = 'Dimensionality of projection';            
        end
    end
end