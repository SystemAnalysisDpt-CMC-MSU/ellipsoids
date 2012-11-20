classdef MatrixExpTimeFunc<gras.mat.AMatrixUnaryOpFunc
    methods
        % redefine evaluate since opFuncHandle depend on t
        function resArray=evaluate(self,timeVec)
            nTimePoints = numel(timeVec);
            %
            lArray = self.lMatFunc.evaluate(timeVec);
            %
            resArray = zeros( [self.nRows, self.nCols, nTimePoints] );
            for iTimePoint = 1:nTimePoints
                resArray(:,:,iTimePoint) = self.opFuncHandle(...
                    lArray(:,:,iTimePoint), timeVec(iTimePoint));
            end
        end
    end
    methods
        function self=MatrixExpTimeFunc(lMatFunc)
            %
            self=self@gras.mat.AMatrixUnaryOpFunc(lMatFunc,...
                @(mMat, t) expm(mMat*t));
            %
            lSizeVec = lMatFunc.getMatrixSize();
            %
            if lSizeVec(1)~=lSizeVec(2)
                modgen.common.throwerror('wrongInput',...
                    'Matrix must be square');
            end
            %
            self.nRows = lMatFunc.getNRows();
            self.nCols = lMatFunc.getNCols();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
