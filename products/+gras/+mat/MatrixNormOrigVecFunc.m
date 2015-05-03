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
        function ltGoodDirNormVecInterObj = getltGoodDirNormVecInterObj(self)
            ltGoodDirNormVecInterObj = self.ltGoodDirNormVecInterObj;
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
         function [SDataArr, SFieldNiceNames, SFieldDescr] = ...
                toStructInternal(MatObj, isPropIncluded)
            
            if (nargin < 2)
                isPropIncluded = false;
            end
            MatrixNormOrigVec = MatObj.getltGoodDirNormVecInterObj();
            [dataArray,timeVec]=MatrixNormOrigVec.getKnotDataArray();
            SEll = struct('dataArray', dataArray, 'timeVec', timeVec);
            if (isPropIncluded)
                SEll.absTol = MatObj.getAbsTol();
                SEll.relTol = MatObj.getRelTol();
            end
            
            SDataArr = SEll;
            SFieldNiceNames = struct('dataArray','dA','timeVec','tV','dimProj','dP');
            SFieldDescr = struct('data Array', 'Array of data', 'timeVec',...
                'Vector of time moments', 'dimProj', 'Dimensionality of projection');
            
            if (isPropIncluded)
                SFieldNiceNames.absTol = 'absTol';
                SFieldNiceNames.relTol = 'relTol';
                
                SFieldDescr.absTol = 'Absolute tolerance.';
                SFieldDescr.relTol = 'Relative tolerance.';
            end
            
        end
    end
end