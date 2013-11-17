classdef MatrixSubArrayFunc<gras.mat.AMatrixUnaryOpArrayFunc
    methods
        function self=MatrixSubArrayFunc(lMatFunc,indexesList)
            %
            import import gras.gen.sub3DimArray;
            self=self@gras.mat.AMatrixUnaryOpArrayFunc(lMatFunc,...
                @(lArray)sub3DimArray(lArray,indexesList{:}));
            %
            self.nRows = length(indexesList{1});
            self.nCols = length(indexesList{2});
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end