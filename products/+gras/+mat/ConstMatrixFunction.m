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
        
    end
    methods (Access=protected)
        function [SData, SFieldNiceNames, SFieldDescr] = ...
                toStructInternal(self,varargin)

            [SData,SFieldNiceNames,SFieldDescr]=toStructInternal@gras.mat.AMatrixComparable(varargin{:});
            SData.constMat = self;
            SFieldNiceNames.constMat = 'cMat';
            SFieldDescr.cMat = 'The constant matrix';
           
        end

    end
end
