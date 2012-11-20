classdef SuiteOp < mlunitext.test_case
    methods(Static,Access=private)
        function isOk = isMatVecEq(aMatVec, bMatVec)
            aSize = size(aMatVec);
            bSize = size(bMatVec);
            mlunit.assert_equals(numel(aSize), numel(bSize));
            %
            isSizeEqVec = ( aSize == bSize );
            mlunit.assert_equals( all(isSizeEqVec), true );
            %
            nMatrices = size(aMatVec, 3);
            errorVec = zeros(1, nMatrices);
            for iMatrix = 1:nMatrices
                errorVec(iMatrix) = norm(...
                    aMatVec(:,:,iMatrix) - bMatVec(:,:,iMatrix));
            end
            %
            maxError = max(errorVec);
            isOk = ( maxError < elltool.conf.Properties.getAbsTol() );
            mlunit.assert_equals(isOk, true);
        end
    end
    methods(Access=private)
        function runTestsForFactory(self,factory)
            import gras.mat.*;
            %
            % test triu square
            %
            aMat = magic(4);
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.triu(aMatFun);
            expectedMatVec = triu(aMat);
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test triu not square
            %
            aMat = ones(2,5);
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.triu(aMatFun);
            expectedMatVec = repmat( triu(aMat), [1 1 3] );
            obtainedMatVec = rMatFun.evaluate([0 1 2]);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test makeSymmetric
            %
            aMat = triu(magic(5));
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.makeSymmetric(aMatFun);
            expectedMatVec = 0.5*(aMat+aMat.');
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test pinv
            %
            aMat = [magic(5), magic(5)];
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.pinv(aMatFun);
            expectedMatVec = pinv(aMat);
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test transpose
            %
            aMat = triu(magic(5));
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.transpose(aMatFun);
            expectedMatVec = repmat(aMat.', [1 1 3]);
            obtainedMatVec = rMatFun.evaluate([0 1 2]);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test inv
            %
            aMat = magic(7);
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.inv(aMatFun);
            expectedMatVec = inv(aMat);
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test sqrtm
            %
            aMat = eye(10)*5;
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.sqrtm(aMatFun);
            expectedMatVec = sqrtm(aMat);
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test rMultiplyByVec
            %
            aMat = magic(10);
            bVec = ones(10,1);
            aMatFun = ConstMatrixFunction(aMat);
            bMatFun = ConstMatrixFunction(bVec);
            rMatFun = factory.rMultiplyByVec(aMatFun,bMatFun);
            expectedMatVec = aMat*bVec;
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test rMultiply #1
            %
            aMat = ones(3,4);
            bMat = ones(4,5);
            aMatFun = ConstMatrixFunction(aMat);
            bMatFun = ConstMatrixFunction(bMat);
            rMatFun = factory.rMultiply(aMatFun,bMatFun);
            expectedMatVec = aMat*bMat;
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test rMultiply #2
            %
            aMat = ones(3,4);
            bMat = ones(4,5);
            cMat = ones(5,6);
            aMatFun = ConstMatrixFunction(aMat);
            bMatFun = ConstMatrixFunction(bMat);
            cMatFun = ConstMatrixFunction(cMat);
            rMatFun = factory.rMultiply(aMatFun,bMatFun,cMatFun);
            expectedMatVec = aMat*bMat*cMat;
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test lrMultiply #1
            %
            lrMat = ones(4,5);
            mMat = ones(5);
            lrMatFun = ConstMatrixFunction(lrMat);
            mMatFun = ConstMatrixFunction(mMat);
            rMatFun = factory.lrMultiply(mMatFun,lrMatFun,'L');
            expectedMatVec = lrMat*mMat*(lrMat.');
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test lrMultiply #2
            %
            lrMat = ones(4,5);
            mMat = ones(4);
            lrMatFun = ConstMatrixFunction(lrMat);
            mMatFun = ConstMatrixFunction(mMat);
            rMatFun = factory.lrMultiply(mMatFun,lrMatFun,'R');
            expectedMatVec = (lrMat.')*mMat*lrMat;
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test lrMultiplyByVec
            %
            lrVec = ones(4,1);
            mMat = ones(4);
            lrVecFun = ConstMatrixFunction(lrVec);
            mMatFun = ConstMatrixFunction(mMat);
            rMatFun = factory.lrMultiply(mMatFun,lrVecFun,'R');
            expectedMatVec = (lrVec.')*mMat*lrVec;
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
        end
    end
    methods
        function self = SuiteOp(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function testCompositeMatrixOperations(self)
            factory = gras.mat.CompositeMatrixOperations;
            self.runTestsForFactory(factory);
        end
        function testSplineMatrixOperations(self)
            timeVec = linspace(-5,5,1000);
            factory = gras.mat.SplineMatrixOperations(timeVec);
            self.runTestsForFactory(factory);
        end
        function testOtherOperations(self)
            import gras.mat.*;
            %
            % test MatrixExpFunc
            %
            aMat = ones(4);
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = MatrixExpFunc(aMatFun);
            expectedMatVec = expm(aMat);
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test MatrixExpTimeFunc
            %
            aMat = ones(4);
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = MatrixExpTimeFunc(aMatFun);
            expectedMatVec = cat(3,...
                expm(aMat*0),expm(aMat*1),expm(aMat*2),expm(aMat*3));
            obtainedMatVec = rMatFun.evaluate([0 1 2 3]);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test MatrixMinEigValFunc
            %
            aMat = diag([-2 -1 0 1 2]);
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = MatrixMinEigValFunc(aMatFun);
            expectedMatVec = -2;
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test MatrixPlusFunc
            %
            aMat = ones(4);
            bMat = 2*ones(4);
            aMatFun = ConstMatrixFunction(aMat);
            bMatFun = ConstMatrixFunction(bMat);
            rMatFun = MatrixPlusFunc(aMatFun,bMatFun);
            expectedMatVec = 3*ones(4);
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test MatrixMinusFunc
            %
            aMat = ones(4);
            bMat = 2*ones(4);
            aMatFun = ConstMatrixFunction(aMat);
            bMatFun = ConstMatrixFunction(bMat);
            rMatFun = MatrixMinusFunc(aMatFun,bMatFun);
            expectedMatVec = -ones(4);
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
        end
    end
end