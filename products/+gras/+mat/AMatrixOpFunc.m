classdef AMatrixOpFunc<gras.mat.IMatrixFunction
    properties (Access=protected)
        nRows
        nCols
        nDims
        opFuncHandle
    end
    methods
        function mSizeVec = getMatrixSize(self)
            mSizeVec = [self.nRows, self.nCols];
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
        function self=AMatrixOpFunc(opFuncHandle)
            %
            if ~isa(opFuncHandle, 'function_handle')
                modgen.common.throwerror('wrongInput',...
                    'opFuncHandle must be of type function_handle');
            end
            %
            self.opFuncHandle = opFuncHandle;
        end
    end
end
