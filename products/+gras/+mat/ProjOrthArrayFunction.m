classdef ProjOrthArrayFunction<gras.mat.AMatrixFunctionComparable
    properties (Access=protected)
        projArrayFunc
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
        function projOrthArray = evaluate(self,timeVec)
            import gras.gen.SquareMatVector;
            projArray = self.projArrayFunc.evaluate(timeVec);
            projOrthArray = SquareMatVector.evalMFunc(...
                        @(x)transpose(gras.la.matorthcol(transpose(x))),...
                        projArray,'keepSize',true);
            sizeArray = size(projOrthArray);
            self.mArray = projOrthArray;
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
        function mArray = getmArray(self)
            mArray = self.mArray;
        end
        function projArrayFunc = getprojArrayFunc(self)
            projArrayFunc = self.projArrayFunc;
        end
    end
    methods
        function self=ProjOrthArrayFunction(projArrayFunc,timeVec)
            self.projArrayFunc = projArrayFunc;
            self.evaluate(timeVec);
        end
        function SData = toStructInternal(self,isPropIncluded)
            SData = toStructInternalProjOrthArray(self,isPropIncluded);
        end
    end
    methods
        function [SDataArr, SFieldNiceNames, SFieldDescr] =...
                toStructInternalProjOrthArray(MatObj,isPropIncluded)
            
            if (nargin < 2)
                isPropIncluded = false;
            end
            
            SEll = struct('mArray', MatObj.getmArray(),...
                'projArrayFunc',MatObj.getprojArrayFunc());
            if (isPropIncluded)
                SEll.absTol = MatObj.getAbsTol();
                SEll.relTol = MatObj.getRelTol();
            end
            
            SDataArr = SEll;
            SFieldNiceNames = struct('mArray','mA','projArrayFunc','pAF');
            SFieldDescr = struct('mArray','mArray','projArrayFunc','projArrayFunc');
            
            if (isPropIncluded)
                SFieldNiceNames.absTol = 'absTol';
                SFieldNiceNames.relTol = 'relTol';
                
                SFieldDescr.absTol = 'Absolute tolerance.';
                SFieldDescr.relTol = 'Relative tolerance.';
            end

        end
    end
end