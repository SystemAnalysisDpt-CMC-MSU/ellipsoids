classdef MatrixLRTimesFunc<gras.mat.fcnlib.AMatrixBinaryOpFunc
    methods
        function self=MatrixLRTimesFunc(mMatFunc, lrMatFunc, flag)
            %
            if nargin < 3
                flag = 'R';
            end
            modgen.common.type.simple.checkgen(flag,@(x) x=='L'||x=='R');
            %
            if flag == 'R'
                fHandle = @(mMat,lrMat) (lrMat.')*mMat*lrMat;
            else
                fHandle = @(mMat,lrMat) lrMat*mMat*(lrMat.');
            end
            %
            self=self@gras.mat.fcnlib.AMatrixBinaryOpFunc(mMatFunc, lrMatFunc,...
                fHandle);
            %
            mSizeVec = mMatFunc.getMatrixSize();
            lrSizeVec = lrMatFunc.getMatrixSize();
            %
            modgen.common.type.simple.checkgen(mSizeVec,'x(1)==x(2)');
            %
            if flag == 'R'
                modgen.common.type.simple.checkgenext('x1(2)==x2(1)',2,...
                    mSizeVec, lrSizeVec);
                %
                self.nRows = lrSizeVec(2);
                self.nCols = lrSizeVec(2);
            else
                modgen.common.type.simple.checkgenext('x2(2)==x1(1)',2,...
                    mSizeVec, lrSizeVec);
                %
                self.nRows = lrSizeVec(1);
                self.nCols = lrSizeVec(1);
            end
            %
            if self.nRows == 1 || self.nCols == 1
                self.nDims = 1;
            else
                self.nDims = 2;
            end
        end
    end
end
