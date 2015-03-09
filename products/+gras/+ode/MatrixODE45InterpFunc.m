classdef MatrixODE45InterpFunc < gras.mat.IMatrixFunction
    properties(Access=private)
        objMatrixSysReshapeOde45RegInterp
    end
    methods
        function self = MatrixODE45InterpFunc(interpObj)
            self.objMatrixSysReshapeOde45RegInterp = interpObj;
        end
        function [varargout] = evaluate(self,timeVec)
            resList = cell(1,nargout);
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

