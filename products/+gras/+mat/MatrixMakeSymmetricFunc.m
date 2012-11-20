classdef MatrixMakeSymmetricFunc<gras.mat.AMatrixUnaryOpFunc
    methods
        function self=MatrixMakeSymmetricFunc(lMatFunc)
            %
            self=self@gras.mat.AMatrixUnaryOpFunc(lMatFunc,...
                @(x) 0.5*(x+x.'));
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
