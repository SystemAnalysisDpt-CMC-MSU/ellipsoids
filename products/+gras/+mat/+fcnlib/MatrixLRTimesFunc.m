classdef MatrixLRTimesFunc<gras.mat.AMatrixBinaryOpFunc
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
            self=self@gras.mat.AMatrixBinaryOpFunc(mMatFunc,...
                lrMatFunc,fHandle);
            %
            mSizeVec = mMatFunc.getMatrixSize();
            lrSizeVec = lrMatFunc.getMatrixSize();
            %
            modgen.common.type.simple.checkgen(mSizeVec,'x(1)==x(2)');
            %
            if ~(all(mSizeVec == 1) || all(lrSizeVec == 1))
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
            else
                lrSizeVec = max(mSizeVec, lrSizeVec);
                self.nRows = lrSizeVec(1);
                self.nCols = lrSizeVec(2);
            end
            %
            self.nDims = 2 - any(lrSizeVec == 1);
        end
    end
end
