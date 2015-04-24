classdef MatrixLtDoodDirNormVecFunc<gras.mat.AMatrixFunctionComparable
    properties (Access=protected)
        ltGoodDirMatInterObj
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
        function ltGoodDirNormVec = evaluate(self,timeVec)
            ltGoodDirMat = self.ltGoodDirMatInterObj.evaluate(timeVec);            
            ltGoodDirNormVec=...
                    realsqrt(sum(ltGoodDirMat.*ltGoodDirMat,1));         
            self.mSizeVec = size(ltGoodDirNormVec);
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
        function ltGoodDirMatInterObj = getltGoodDirMatInterObj(self)
            ltGoodDirMatInterObj = self.ltGoodDirMatInterObj;
        end
    end
    methods
        function self=MatrixLtDoodDirNormVecFunc(ltGoodDirMatInterObj,timeVec)
            self.ltGoodDirMatInterObj = ltGoodDirMatInterObj;
            self.evaluate(timeVec);
        end
        
        function SData = toStructInternal(self,isPropIncluded)
            SData = toStructInternalMatDoodDirNormVecFun(self, isPropIncluded);
        end
    end
    
    methods
        function [SDataArr, SFieldNiceNames, SFieldDescr] = ...
                toStructInternalMatDoodDirNormVecFun(MatObj, isPropIncluded)
            
            if (nargin < 2)
                isPropIncluded = false;
            end
            
            SEll = struct('ltGoodDirMatInterObj', MatObj.getltGoodDirMatInterObj());
            if (isPropIncluded)
                SEll.absTol = MatObj.getAbsTol();
                SEll.relTol = MatObj.getRelTol();
            end
            
            SDataArr = SEll;
            SFieldNiceNames = struct('ltGoodDirMatInterObj','ltGDMIO');
            SFieldDescr = struct('ltGoodDirMatInterObj','ltGoodDirMatInterObj');
            
            if (isPropIncluded)
                SFieldNiceNames.absTol = 'absTol';
                SFieldNiceNames.relTol = 'relTol';
                
                SFieldDescr.absTol = 'Absolute tolerance.';
                SFieldDescr.relTol = 'Relative tolerance.';
            end
            
        end

    end
end