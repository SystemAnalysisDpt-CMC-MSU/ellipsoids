classdef ConstArrayFunction<gras.mat.AMatrixFunctionComparable
    properties (Access=protected)
        mSizeVec
        nDims
        nRows
        nCols
    end
    methods
        function mSizeVec = getMatrixSize(self)
            mSizeVec = self.mSizeVec;
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
        function self=ConstArrayFunction(mArray)
            %
            modgen.common.type.simple.checkgen(mArray,...
                'isnumeric(x)&&~isempty(x)');
            %
            sizeArray = size(mArray);
            self.mSizeVec = sizeArray(1:2);
            self.nRows = self.mSizeVec(1);
            self.nCols = self.mSizeVec(2);
        end
    end
    methods (Access=protected)
        function [SData, SFieldNiceNames, SFieldDescr] = toStructInternal(self,varargin)
            
            [SData,SFieldNiceNames,SFieldDescr]=toStructInternal@gras.mat.AMatrixComparable(varargin{:});
            SData.constArray = self;
            SFieldNiceNames.constArray ='cArray';
            SFieldDescr.constArray = 'The constant array';
            
        end
    end
end