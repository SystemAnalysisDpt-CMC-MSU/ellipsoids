classdef MatrixSFBinaryProdByVec<gras.mat.IMatrixFunction
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-12-12$
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %    
    properties (Access=private)
        formula1Func
        formula2Func
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
        function self=MatrixSFBinaryProdByVec(formula1CMat,formula2CMat)
            % MATRIXCUBESPLINE represents a cubic interpolant of
            % matrix-value function
            %
            % Input:
            %   regular:
            %       formula1CMat: cell[nCols,nRows] of char[1,] - formula
            %       array of the matrix depending on t (time)
            %           
            %
            import modgen.common.type.simple.checkgenext
            import modgen.cell.cellstr2func;
            if nargin==0
                self.formula1Func='';
                self.formula2Func='';
                self.nDims=2;
                self.nCols=0;
                self.nRows=0;
                self.mSizeVec=[0,0];
            else
                checkgenext(['iscellofstring(x1)&&ndims(x1)==2&&',...
                    'iscellofstring(x2)&&ndims(x2)==2&&',...
                    'size(x1,2)==size(x2,1)&&size(x2,2)==1'],...
                    2,formula1CMat,formula2CMat);
                %
                sizeVec=[size(formula1CMat,1),size(formula2CMat,2)];
                self.nDims=2-any(sizeVec == 1);
                self.nRows=sizeVec(1);
                self.nCols=sizeVec(2);
                self.mSizeVec=sizeVec;
                self.formula1Func=cellstr2func(formula1CMat,'t');
                self.formula2Func=cellstr2func(formula2CMat,'t');
                
            end
        end
        function mSize=getMatrixSize(self)
            mSize=self.mSizeVec;
        end
        function resArray=evaluate(self,timeVec)
            import gras.gen.MatVector;
            %
            res1Array=MatVector.fromFunc(self.formula1Func,timeVec);
            res2Array=MatVector.fromFunc(self.formula2Func,timeVec);
            %
            if numel(timeVec)==1
                resArray=res1Array*res2Array;
            else
                sizeVec=[size(res2Array,1),size(res2Array,3)];
                resArray=gras.gen.MatVector.rMultiplyByVec(res1Array,...
                    reshape(res2Array,sizeVec));
            end
        end
    end
end