classdef MatrixSubArrayCauseNormFunc<gras.mat.AMatrixComparable
    properties (Access=protected)
        ltGoodDirMatInterObj
        absTol
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
        function ltGoodDirMat = evaluate(self,timeVec)
            ltGoodDirMat = self.ltGoodDirMatInterObj.evaluate(timeVec);
            ltProjGoodDirNormVec = ...
                            realsqrt(dot(ltGoodDirMat,ltGoodDirMat,1));
            isnLtTouchVec = abs(ltProjGoodDirNormVec-1)>self.absTol;
            ltGoodDirMat(:,isnLtTouchVec)=0;         
            self.mSizeVec = size(ltGoodDirMat);
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
    end
    methods
        function self=MatrixSubArrayCauseNormFunc(ltGoodDirMatInterObj,absTol)
            self.ltGoodDirMatInterObj = ltGoodDirMatInterObj;
            self.absTol = absTol;
        end
    end
    methods (Access=protected)
         function [SDataArr, SFieldNiceNames, SFieldDescr] = ...
                toStructInternal(self, isPropIncluded)
            
            if (nargin < 2)
                isPropIncluded = false;
            end
            MatInterObj =  self.ltGoodDirMatInterObj;
            [dataArray,timeVec]=MatInterObj.getKnotDataArray();
            SEll = struct('dataArray', dataArray, 'timeVec', timeVec);
            if (isPropIncluded)
                SEll.absTol = self.getAbsTol();
                SEll.relTol = self.getRelTol();
            end
            
            SDataArr = SEll;
            SFieldNiceNames = struct('dataArray','dArray','timeVec','tVec');
            SFieldDescr = struct('data Array', 'Array of data', 'timeVec',...
                'Vector of time moments');
            
            if (isPropIncluded)
                SFieldNiceNames.absTol = 'absTol';
                SFieldNiceNames.relTol = 'relTol';
                
                SFieldDescr.absTol = 'Absolute tolerance.';
                SFieldDescr.relTol = 'Relative tolerance.';
            end
            
        end
    end
end
