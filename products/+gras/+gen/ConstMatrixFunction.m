classdef ConstMatrixFunction<handle
    properties (Access=private)
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
            res = self.mMat;
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
        function self=ConstMatrixFunction(mMat)
            self.mMat = mMat;
            %
            if ~ismatrix(mMat)
                modgen.common.throwerror('ConstMatrixFunction:WrongInput', 'Input is not a matrix');
            end
            %
            self.mSizeVec = size(mMat);
            self.nRows = self.mSizeVec(1);
            self.nCols = self.mSizeVec(2);
            %
            if isempty(self.mMat)
                self.nDims = 0;
            elseif self.nRows == 1 || self.nCols == 1
                self.nDims = 1;
            else
                self.nDims = 2;
            end
        end
    end
end
    
    
    
    