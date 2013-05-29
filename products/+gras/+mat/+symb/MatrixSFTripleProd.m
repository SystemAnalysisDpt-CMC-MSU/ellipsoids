classdef MatrixSFTripleProd<gras.mat.IMatrixFunction
    properties (Access=private)
        formula1Func
        formula2Func
        formula3Func
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
        function self=MatrixSFTripleProd(formula1CMat,formula2CMat,...
                formula3CMat)
            %
            import modgen.common.type.simple.checkgenext
            import modgen.cell.cellstr2func;
            if nargin==0
                self.formula1Func='';
                self.formula2Func='';
                self.formula3Func='';
                self.nDims=2;
                self.nCols=0;
                self.nRows=0;
                self.mSizeVec=[0,0];
            else                
                checkgenext(['iscellofstring(x1)&&iscellofstring(x2)&&',...
                    'iscellofstring(x3)'], 3, formula1CMat, ...
                    formula2CMat, formula3CMat);
                size1Vec = size(formula1CMat);
                size2Vec = size(formula2CMat);
                size3Vec = size(formula3CMat);
                checkgenext(['((x1(1)==1&&x1(2)==1)||(x2(1)==1&&', ...
                    'x2(2)==1)||(x1(2)==x2(1)))&&((x2(1)==1&&x2(2)==1)',...
                    '||(x3(1)==1&&x3(2)==1)||(x2(2)==x3(1)))'], 3, ...
                    size1Vec, size2Vec, size3Vec);
                %
                if ~(all(size1Vec == 1) || all(size2Vec == 1))
                    sizeVec = [size1Vec(1), size2Vec(2)];
                else
                    sizeVec = max(size1Vec, size2Vec);
                end
                if ~(all(sizeVec == 1) || all(size3Vec == 1))
                    sizeVec = [sizeVec(1), size3Vec(2)];
                else
                    sizeVec = max(sizeVec, size3Vec);
                end
                %
                self.nDims=2-any(sizeVec == 1);
                self.nRows=sizeVec(1);
                self.nCols=sizeVec(2);
                self.mSizeVec=sizeVec;
                %
                self.formula1Func=cellstr2func(formula1CMat,'t');
                self.formula2Func=cellstr2func(formula2CMat,'t');
                self.formula3Func=cellstr2func(formula3CMat,'t');
            end
        end
        function mSize=getMatrixSize(self)
            mSize=self.mSizeVec;
        end
        function resArray=evaluate(self,timeVec)
            import gras.gen.MatVector;
            res1Array=MatVector.fromFunc(self.formula1Func,timeVec);
            res2Array=MatVector.fromFunc(self.formula2Func,timeVec);
            res3Array=MatVector.fromFunc(self.formula3Func,timeVec);
            if numel(timeVec)==1
                resArray=res1Array*res2Array*res3Array;
            else
                resArray=gras.gen.MatVector.rMultiply(res1Array,res2Array,...
                    res3Array);
            end
        end
    end
end