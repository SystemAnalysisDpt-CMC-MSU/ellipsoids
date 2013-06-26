classdef MatrixSymbFormulaBased<gras.mat.IMatrixFunction
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-12-12$
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $    
    properties (Access=private)
        formulaFunc
        nDims
        nCols
        nRows
        mSizeVec
    end
    methods
        function nDims=getDimensionality(self)
            nDims=self.nDims;
        end
        function nCols=getNCols(self)
            nCols=self.nCols;
        end
        function nRows=getNRows(self)
            nRows=self.nRows;
        end        
        function self=MatrixSymbFormulaBased(formulaCMat)
            % MATRIXCUBESPLINE represents a cubic interpolant of
            % matrix-value function
            %
            % Input:
            %   regular:
            %       formulaCMat: cell[nCols,nRows] of char[1,] - formula
            %       array of the matrix depending on t (time)
            %           
            %
            import modgen.common.type.simple.checkgen;
            import modgen.cell.cellstr2func;
            if nargin==0
                self.formulaStr='';
                self.nDims=2;
                self.nCols=0;
                self.nRows=0;
                self.mSizeVec=[0,0];
            else
                checkgen(formulaCMat,...
                    'iscellofstring(x)&&ndims(x)==2');
                sizeVec=size(formulaCMat);
                self.nDims=2-any(sizeVec == 1);
                self.nRows=sizeVec(1);
                self.nCols=sizeVec(2);
                self.mSizeVec=sizeVec;
                self.formulaFunc=cellstr2func(formulaCMat,'t');
            end
        end
        function mSize=getMatrixSize(self)
            mSize=self.mSizeVec;
        end
        function resArray=evaluate(self,timeVec)
            import gras.gen.MatVector;
            resArray=MatVector.fromFunc(self.formulaFunc,timeVec);
        end
    end
end