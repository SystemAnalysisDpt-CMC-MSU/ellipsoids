classdef MatrixODE45InterpFunc < gras.mat.IMatrixFunction
    properties(Access=private)
        objMatrixSysReshapeOde45RegInterp
        isInverseTime
    end
    methods
        function self = MatrixODE45InterpFunc(interpObj, varargin)
            self.objMatrixSysReshapeOde45RegInterp = interpObj;
            if nargin > 1
                self.isInverseTime = varargin{1};
            end
        end
        function [varargout] = evaluate(self,timeVec)
            resList = cell(1,nargout);
            if self.countdown
                timeVec = -flipdim(timeVec, 2);
            end
            [~,resList{:}] = ...
             self.objMatrixSysReshapeOde45RegInterp.evaluate(timeVec);
            varargout = resList;
        end
        function mSize = getMatrixSize(self)
            sizeEqList = ...
                self.objMatrixSysReshapeOde45RegInterp.getSizeEqList();
            mSize = sizeEqList{1};
            mSize = mSize([1 2]);
        end
        function nDims = getDimensionality(self)
            sizeEqList = ...
                self.objMatrixSysReshapeOde45RegInterp.getSizeEqList();
            mSize = sizeEqList{1};
            nDims = mSize(1);
            
        end
        function nCols = getNCols(self)
            sizeEqList = ...
                self.objMatrixSysReshapeOde45RegInterp.getSizeEqList();
            mSize = sizeEqList{1};
            nCols = mSize(2);
        end
        function nRows = getNRows(self)
            nRows = self.getDimensionality();
        end
        function nEqs = getNEquations(self)
            nEqs=length(...
                self.objMatrixSysReshapeOde45RegInterp.getSizeEqList());
        end
    end
    
end

