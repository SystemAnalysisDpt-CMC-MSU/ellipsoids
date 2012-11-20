classdef MatrixSqrtFunc<gras.mat.AMatrixUnaryOpFunc
    methods
        function self=MatrixSqrtFunc(lMatFunc)
            %
            self=self@gras.mat.AMatrixUnaryOpFunc(lMatFunc,@sqrtm);
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
