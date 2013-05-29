classdef MatrixTernaryTimesFunc<gras.mat.AMatrixTernaryOpFunc
    methods
        function self=MatrixTernaryTimesFunc(lMatFunc, mMatFunc,...
                rMatFunc)
            %
            self=self@gras.mat.AMatrixTernaryOpFunc(lMatFunc,...
                mMatFunc, rMatFunc, @(a,b,c) a*b*c);
            %
            lSizeVec = lMatFunc.getMatrixSize();
            mSizeVec = mMatFunc.getMatrixSize();
            rSizeVec = rMatFunc.getMatrixSize();
            %
            modgen.common.type.simple.checkgenext([...
                '((x1(1)==1 && x1(2)==1) || (x2(1)==1 && x2(2)==1) || ', ...
                '(x1(2)==x2(1))) && ((x2(1)==1 && x2(2)==1) || ', ...
                '(x3(1)==1 && x3(2)==1) || x2(2)==x3(1))'], ...
                3, lSizeVec, mSizeVec,...
                rSizeVec);
            %
            if all(lSizeVec == 1) || all(mSizeVec == 1)
                resSizeVec = max(lSizeVec, mSizeVec);
            else
                resSizeVec = [lSizeVec(1), mSizeVec(2)];
            end
            if all(resSizeVec == 1) || all(rSizeVec == 1)
                resSizeVec = max(resSizeVec, rSizeVec);
            else
                resSizeVec = [resSizeVec(1), rSizeVec(2)];
            end 
            self.nRows = resSizeVec(1);
            self.nCols = resSizeVec(2);
            self.nDims = 2 - any(resSizeVec == 1);
        end
    end
end
