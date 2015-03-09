classdef MatrixSysNearestInterp < gras.mat.IMatrixSysFunction
    properties(Access=private)
        matrixArrayList
    end
    
    methods
        function self = MatrixSysNearestInterp(inMatrixArrayList,timeVec)
            nEqs = length(inMatrixArrayList);
            for indEqn = 1:nEqs
                self.matrixArrayList{indEqn} = ...
                    gras.interp.MatrixNearestInterp(...
                    inMatrixArrayList{indEqn},timeVec);
            end
        end
        function varargout = evaluate(self,newTimeVec)
            import modgen.common.throwerror;
            if(nargout > length(self.matrixArrayList))
                throwerror('wrongInput:wrongOurput',...
                    ['Number output arguments should be <= that ' ...
                    'size of self.matrixArrayList']);
            end
            resList = cell(1,nargout);
            for indEqn = 1:nargout
                resList{indEqn} =...
                    self.matrixArrayList{indEqn}.evaluate(newTimeVec);
            end
            varargout = resList;
        end
        function nEqs = getNEquations(self)
            nEqs=length(self.matrixArrayList);
        end
        function mSize = getMatrixSize(self)
            mSize = self.matrixArrayList{1}.getMatrixSize();
        end
        function nRows = getNRows(self)
            mSize = self.matrixArrayList{1}.getMatrixSize();
            nRows = mSize(1);
        end
        function nCols = getNCols(self)
            mSize = self.matrixArrayList{1}.getMatrixSize();
            nCols = mSize(2);
        end
        function nDims = getDimensionality(self)
            nDims = self.getNRows();
        end
    end
end

