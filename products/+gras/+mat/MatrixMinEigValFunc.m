classdef MatrixMinEigValFunc<gras.mat.AMatrixUnaryOpFunc
    methods
        function self=MatrixMinEigValFunc(lMatFunc)
            %
            self=self@gras.mat.AMatrixUnaryOpFunc(lMatFunc,@(x)min(eig(x)));
            %
            lSizeVec = lMatFunc.getMatrixSize();
            %
            if lSizeVec(1)~=lSizeVec(2)
                modgen.common.throwerror('wrongInput',...
                    'Matrix must be square');
            end
            %
            self.nRows = 1;
            self.nCols = 1;
            self.nDims = 1;
        end
    end
end