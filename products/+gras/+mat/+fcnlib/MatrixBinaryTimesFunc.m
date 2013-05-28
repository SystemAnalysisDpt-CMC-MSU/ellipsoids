classdef MatrixBinaryTimesFunc<gras.mat.AMatrixBinaryOpFunc
    methods
        function self=MatrixBinaryTimesFunc(lMatFunc, rMatFunc)
            self=self@gras.mat.AMatrixBinaryOpFunc(lMatFunc,...
                rMatFunc,@mtimes);
            %
            lSizeVec = lMatFunc.getMatrixSize();
            rSizeVec = rMatFunc.getMatrixSize();
            %
            if all([any(lSizeVec ~= 1), any(rSizeVec ~= 1)])
                modgen.common.type.simple.checkgenext('x1(2)==x2(1)', ...
                    2, lSizeVec, rSizeVec);
                sSizeVec = [lSizeVec(1), rSizeVec(2)];
            else
                sSizeVec = max(lSizeVec, rSizeVec);
            end
            %
            self.nRows = sSizeVec(1);
            self.nCols = sSizeVec(2);
            %
            self.nDims = 2 - any(sSizeVec == 1);
        end
    end
end
