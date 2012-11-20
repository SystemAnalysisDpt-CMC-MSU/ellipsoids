classdef MatrixLRTimesFunc<gras.mat.AMatrixBinaryOpFunc
    methods
        function self=MatrixLRTimesFunc(mMatFunc, lrMatFunc, flag)
            %
            if nargin < 3
                flag = 'R';
            end
            %
            if flag ~= 'L' && flag ~= 'R'
                modgen.common.throwerror('wrongInput',...
                    'Incorrect flag value');
            end
            %
            if flag == 'R'
                fHandle = @(mMat,lrMat) (lrMat.')*mMat*lrMat;
            else
                fHandle = @(mMat,lrMat) lrMat*mMat*(lrMat.');
            end
            %
            self=self@gras.mat.AMatrixBinaryOpFunc(mMatFunc, lrMatFunc,...
                fHandle);
            %
            mSizeVec = mMatFunc.getMatrixSize();
            lrSizeVec = lrMatFunc.getMatrixSize();
            %
            if flag == 'R'
                if ~(mSizeVec(1)==mSizeVec(2)&&mSizeVec(2)==lrSizeVec(1))
                    modgen.common.throwerror('wrongInput',...
                        'Inner matrix dimensions must agree');
                end
                %
                self.nRows = lrSizeVec(2);
                self.nCols = lrSizeVec(2);
            else
                if ~(mSizeVec(1)==mSizeVec(2)&&lrSizeVec(2)==mSizeVec(1))
                    modgen.common.throwerror('wrongInput',...
                        'Inner matrix dimensions must agree');
                end
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
