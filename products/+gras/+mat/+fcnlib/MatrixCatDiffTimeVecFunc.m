classdef MatrixCatDiffTimeVecFunc<gras.mat.AMatrixBinaryOpDiffTimeVecFunc
    methods
        function self=MatrixCatDiffTimeVecFunc(lMatFunc,rMatFunc,dimCat,...
                timePartition,timePartitionRight)
            
            self=self@gras.mat.AMatrixBinaryOpDiffTimeVecFunc(lMatFunc,...
                rMatFunc,@(leftMatFunc,rightMatFunc)cat(dimCat,leftMatFunc,...
                rightMatFunc),timePartition,timePartitionRight);
            %
            lSizeVec = lMatFunc.getMatrixSize();
            rSizeVec = rMatFunc.getMatrixSize();
            %
            modgen.common.type.simple.checkgenext(@isequal, 2, ...
                lSizeVec, rSizeVec);
            %
            if(dimCat == 1)   
                self.nRows = lSizeVec(1) + rSizeVec(1);
                self.nCols = lSizeVec(2);
                self.nDims = lSizeVec(1);
            end;
            if(dimCat == 2)
                self.nRows = lSizeVec(1);
                self.nCols = lSizeVec(2) + rSizeVec(2);
                self.nDims = lSizeVec(1);
            end
            if(dimCat == 3)
                self.nRows = lSizeVec(1);
                self.nCols = lSizeVec(2);
                self.nDims = lSizeVec(1);
            end
            
            
        end
    end
end
