classdef MatrixSubArrayInitFunc<gras.mat.AMatrixUnaryOpArrayFunc
    methods
        function self=MatrixSubArrayInitFunc(lMatFunc,indList,valueArray)
            import gras.gen.sub3dimarrayinit;
            self=self@gras.mat.AMatrixUnaryOpArrayFunc(lMatFunc,...
                @(lArray)sub3dimarrayinit(lArray,indList{:},valueArray));
            %
            self.nRows = length(indList{1});
            self.nCols = length(indList{2});
            self.nDims = length(indList{1});
        end
    end
end