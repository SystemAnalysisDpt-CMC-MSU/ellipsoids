classdef MatrixReshapeFunc<gras.mat.AMatrixUnaryOpArrayFunc
    methods
        function self=MatrixReshapeFunc(lMatFunc,newSizeVec)
            self=self@gras.mat.AMatrixUnaryOpArrayFunc(lMatFunc,...
                @(lArray,n3Dim)reshape(lArray,[newSizeVec n3Dim]));
            %
            self.nRows = newSizeVec(1);
            self.nCols = newSizeVec(2);
            self.nDims = lMatFunc.getDimensionality();
        end
    end
end