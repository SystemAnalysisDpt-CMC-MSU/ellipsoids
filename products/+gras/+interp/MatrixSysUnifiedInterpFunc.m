classdef MatrixSysUnifiedInterpFunc<gras.mat.IMatrixFunction
    properties(Access=private)
        matrixInterpObjList
    end
    
    methods
        function self = MatrixSysUnifiedInterpFunc(interpObjList)
            self.matrixInterpObjList = interpObjList;
        end
        %
        function varargout = evaluate(self,timeVec)
            import modgen.common.throwerror;
            nInterpObjs = length(self.matrixInterpObjList);
            if(nargout > nInterpObjs)
                throwerror('wrongOutput',['The number of output parameters must '...
                    'be less or equal to the number of interpolation '...
                    'objects'])
            end;
            resArrayList = cell(1,nargout);
            for iInterpObj = 1:nInterpObjs
                resArrayList{iInterpObj} =...
                    self.matrixInterpObjList{iInterpObj}.evaluate(timeVec);
            end
            varargout = resArrayList;
        end
        %
        function mSize = getMatrixSize(self)
            mSize = self.matrixInterpObjList{1}.getMatrixSize();
        end
        function nDims = getDimensionality(self)
            mSize = self.getMatrixSize();
            nDims = mSize(1);
        end
        function nCols = getNCols(self)
            mSize = self.getMatrixSize();
            nCols = mSize(2);
        end
        function nRows = getNRows(self)
            mSize = self.getMatrixSize();
            nRows = mSize(1);
        end
        function nEqs = getNEquations(self)
            nEqs = self.matrixInterpObjList{1}.getNEquations();
        end
        
        function varargout = getInterpObj(self)
            varargout(:) = self.matrixInterpObjList{:};
        end
    end
    
end

