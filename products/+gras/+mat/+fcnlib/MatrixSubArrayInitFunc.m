classdef MatrixSubArrayInitFunc<gras.mat.AMatrixUnaryOpArrayFunc
    methods
        function self=MatrixSubArrayInitFunc(lMatFunc,indexesList,valueArray)
            %
            import import gras.gen.sub3DimArrayInit;
            self=self@gras.mat.AMatrixUnaryOpArrayFunc(lMatFunc,...
                @(lArray)sub3DimArrayInit(lArray,indexesList{:},valueArray));
            %
            self.nRows = length(indexesList{1});
            self.nCols = length(indexesList{2});
            self.nDims = length(indexesList{1});
        end
    end
end