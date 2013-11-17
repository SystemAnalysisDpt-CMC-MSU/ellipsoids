classdef MatrixODE45ScalarTimeInterpFunc < gras.mat.IMatrixFunction
    properties(Access=private)
        dataMatrixArray
        timeVec
    end
    methods
        function self = MatrixODE45ScalarTimeInterpFunc(dataMatrix,timeVec)
            if(length(timeVec) ~= 1)
                import modgen.common.throwerror;
                throwerror('wrongInput','timeVec shoud be scalar');
            else
                self.dataMatrixArray = dataMatrix;
                self.timeVec = timeVec;
            end;            
        end
        function resMatrixArray = evaluate(self,timeVec)
            import modgen.common.throwerror;
%             if(length(timeVec) > 1)
%                 throwerror('wrongInput',['method ' ...
%                 'MatrixODE45ScalarTimeInterpFunc.evaluate(timeVec) can'...
%                 ' work only with scalar timeVec']);
%             end;
            if(timeVec ~= self.timeVec(1))
                throwerror('wrongInput',['method ' ...
                'MatrixODE45ScalarTimeInterpFunc.evaluate(timeVec) can'...
                ' evaluate matrix only one fixed time point']);
            else
                resMatrixArray = self.dataMatrixArray;
            end
        end
        function mSize = getMatrixSize(self)
            mSize = size(self.dataMatrixArray);
        end
        function nDims = getDimensionality(self)
            nDims = size(self.dataMatrixArray,1);
        end
        function nCols = getNCols(self)
            nCols = size(self.dataMatrixArray,2);
        end
        function nRows = getNRows(self)
            nRows = self.getDimensionality();
        end
    end
    
end

