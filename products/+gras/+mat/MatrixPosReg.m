classdef MatrixPosReg < gras.mat.IMatrixFunction
    properties (Access = private)
        matFunc
        regTol
    end
    methods (Access = private)
        function regMat = getRegMat(self, inpMat)
            [vMat, dMat] = eig(inpMat, 'nobalance');
            mMat = diag(max(diag(dMat), self.regTol));
            mMat = vMat * mMat * transpose(vMat);
            regMat = 0.5 * (mMat + mMat.');
        end
    end
    methods
        function self = MatrixPosReg(matFunc, regTol)
            modgen.common.type.simple.checkgen(matFunc,...
                @(x)isa(x,'gras.mat.IMatrixFunction'));
            self.matFunc = matFunc;
            self.regTol = regTol;
        end
        function mSizeVec = getMatrixSize(self)
            mSizeVec = self.matFunc.getMatrixSize();
        end
        function nDims=getDimensionality(self)
            nDims = self.matFunc.getDimensionality();
        end
        function nCols=getNCols(self)
            nCols = self.matFunc.getNCols();
        end
        function nRows=getNRows(self)
            nRows = self.matFunc.getNRows();
        end
        function resArray=evaluate(self, timeVec)
            resArray = self.matFunc.evaluate(timeVec);
            nTimePoints = numel(timeVec);
            for iTimePoint = 1 : nTimePoints
                currMat = resArray(:, :, iTimePoint);
                if ~gras.la.ismatposdef(currMat)
                    resArray(:, :, iTimePoint) =...
                        self.getRegMat(currMat);
                end
            end
        end
    end
end