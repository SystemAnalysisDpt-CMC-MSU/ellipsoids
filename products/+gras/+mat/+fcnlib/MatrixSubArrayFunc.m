classdef MatrixSubArrayFunc<gras.mat.AMatrixUnaryOpArrayFunc
    methods
        function self=MatrixSubArrayFunc(lMatFunc,indList)
            import gras.gen.sub3dimarray;
            self=self@gras.mat.AMatrixUnaryOpArrayFunc(lMatFunc,...
                @(lArray)sub3dimarray(lArray,indList{:}));
            %
            self.nRows = length(indList{1});
            self.nCols = length(indList{2});
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end