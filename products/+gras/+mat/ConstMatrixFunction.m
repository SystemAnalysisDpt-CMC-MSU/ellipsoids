classdef ConstMatrixFunction<gras.mat.AMatrixFunctionComparable
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
        function self = ConstMatrixFunction(mMat)
            %
            modgen.common.type.simple.checkgen(mMat,...
                'isnumeric(x)&&ismat(x)&&~isempty(x)');
            %
            self.mMat = mMat;
            self.mSizeVec = size(mMat);
            self.nRows = self.mSizeVec(1);
            self.nCols = self.mSizeVec(2);
        end
        function SData = toStructInternal(self,isPropIncluded)
             SData = toStructInternalConst(self,isPropIncluded);
        end
        
    end
    methods     
        function [SDataArr, SFieldNiceNames, SFieldDescr] = ...
                toStructInternalConst(ConstMat, isPropIncluded)
            
            if (nargin < 2)
                isPropIncluded = false;
            end
            
            SEll = struct('mArray', ConstMat);
            if (isPropIncluded)
                SEll.absTol = ConstMat.getAbsTol();
                SEll.relTol = ConstMat.getRelTol();
            end
            
            SDataArr = SEll;
            SFieldNiceNames = struct('mArray','mA');
            SFieldDescr = struct('mArray','mArray');
            
            if (isPropIncluded)
                SFieldNiceNames.absTol = 'absTol';
                SFieldNiceNames.relTol = 'relTol';
                
                SFieldDescr.absTol = 'Absolute tolerance.';
                SFieldDescr.relTol = 'Relative tolerance.';
            end
            
        end

    end
end
