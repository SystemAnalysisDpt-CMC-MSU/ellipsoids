classdef MatrixBinaryTimesFunc<gras.mat.AMatrixBinaryOpFunc
    methods
        function self=MatrixBinaryTimesFunc(lMatFunc, rMatFunc)
            %
            self=self@gras.mat.AMatrixBinaryOpFunc(lMatFunc, rMatFunc,...
                @mtimes);
            %
            lSizeVec = lMatFunc.getMatrixSize();
            rSizeVec = rMatFunc.getMatrixSize();
            %
            if lSizeVec(2) ~= rSizeVec(1)
                modgen.common.throwerror('wrongInput',...
                    'Inner matrix dimensions must agree');
            end
            %
            self.nRows = lSizeVec(1);
            self.nCols = rSizeVec(2);
            %
            if self.nRows == 1 || self.nCols == 1
                self.nDims = 1;
            else
                self.nDims = 2;
            end
        end
    end
end
