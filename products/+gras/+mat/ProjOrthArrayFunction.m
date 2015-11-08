classdef ProjOrthArrayFunction<gras.mat.AMatrixFunctionComparable
    properties (Access=protected)
        projArrayFunc
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
        function projOrthArray = evaluate(self,timeVec)
            import gras.gen.SquareMatVector;
            projArray = self.projArrayFunc.evaluate(timeVec);
            projOrthArray = SquareMatVector.evalMFunc(...
                        @(x)transpose(gras.la.matorthcol(transpose(x))),...
                        projArray,'keepSize',true);
            sizeArray = size(projOrthArray);
            self.mSizeVec = sizeArray(1:2);
            self.nRows = self.mSizeVec(1);
            self.nCols = self.mSizeVec(2);
            self.nDims = self.nRows;
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
        function self=ProjOrthArrayFunction(projArrayFunc,timeVec)
            self.projArrayFunc = projArrayFunc;
            self.evaluate(timeVec);
        end
    end
    methods (Access=protected)
        function [SData, SFieldNiceNames, SFieldDescr] =...
                toStructInternal(self,varargin)
            [SData,SFieldNiceNames,SFieldDescr]=toStructInternal@...
                gras.mat.AMatrixComparable(varargin{:});
            SData.projArrayFunc = func2str(self.projArrayFunc);
            SFieldNiceNames.projArrayFunc = 'pArrayFunc';
            SFieldDescr.projArrayFunc = 'Array of functions';

        end
    end
end