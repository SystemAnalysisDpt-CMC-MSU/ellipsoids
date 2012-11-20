classdef MatrixMinusFunc<gras.mat.AMatrixBinaryOpFunc
    methods
        function self=MatrixMinusFunc(lMatFunc, rMatFunc)
            %
            self=self@gras.mat.AMatrixBinaryOpFunc(lMatFunc, rMatFunc,...
                @minus);
            %
            lSizeVec = lMatFunc.getMatrixSize();
            rSizeVec = rMatFunc.getMatrixSize();
            %
            if ~(lSizeVec(1)==rSizeVec(1) && lSizeVec(2) == rSizeVec(2))
                modgen.common.throwerror('wrongInput',...
                    'Matrix dimensions must agree');
            end
            %
            self.nRows = lMatFunc.getNRows();
            self.nCols = lMatFunc.getNCols();
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end
