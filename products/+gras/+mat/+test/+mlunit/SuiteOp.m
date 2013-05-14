classdef SuiteOp < mlunitext.test_case
    methods(Static,Access=private)
        function isOk = isMatVecEq(aMatVec, bMatVec)
            MAX_TOL=1e-7;
            aSize = size(aMatVec);
            bSize = size(bMatVec);
            mlunitext.assert_equals(numel(aSize), numel(bSize));
            %
            isSizeEqVec = ( aSize == bSize );
            mlunitext.assert_equals( all(isSizeEqVec), true );
            %
            nMatrices = size(aMatVec, 3);
            errorVec = zeros(1, nMatrices);
            for iMatrix = 1:nMatrices
                errorVec(iMatrix) = norm(...
                    aMatVec(:,:,iMatrix) - bMatVec(:,:,iMatrix));
            end
            %
            maxError = max(errorVec);
            isOk = ( maxError < MAX_TOL);
            mlunitext.assert_equals(isOk, true);
        end
    end
    methods(Access=private)
        function isOk = isMatFunSizeConsistent(self, inpMatFun)
            inpMatSizeVec = inpMatFun.getMatrixSize();
            isOk = self.isMatVecEq([inpMatFun.getNRows(), ...
                inpMatFun.getNCols()], inpMatSizeVec);
            if any(inpMatSizeVec == 1)
                isOk = isOk && (inpMatFun.getDimensionality() == 1);
            end
            mlunitext.assert_equals(isOk, true);
        end
        function isOk = isMatFunSizeEq(self, aMatFun, bMatFun, varargin)
            self.isMatFunSizeConsistent(aMatFun);
            self.isMatFunSizeConsistent(bMatFun);
            aSizeVec = aMatFun.getMatrixSize();
            bSizeVec = bMatFun.getMatrixSize();
            if nargin > 3
                fPostProc = varargin{1};
                bSizeVec = fPostProc(bSizeVec);
            end
            isOk = self.isMatVecEq(aSizeVec, bSizeVec);
        end
        function isOk = isMatFunSizeVecEq(self, inpMatFun, inpMat, varargin)
            self.isMatFunSizeConsistent(inpMatFun);
            inpFunSizeVec = inpMatFun.getMatrixSize();
            inpMatSizeVec = size(inpMat);
            if nargin > 3
                fPostProc = varargin{1};
                inpMatSizeVec = fPostProc(inpMatSizeVec);
            end
            isOk = self.isMatVecEq(inpFunSizeVec, inpMatSizeVec);
        end
        function runTestsForFactory(self, factory)
            import gras.mat.*;
            import gras.mat.fcnlib.*;
            %
            % test triu square
            %
            aMat = magic(4);
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.triu(aMatFun);
            self.isMatFunSizeEq(rMatFun, aMatFun);
            expectedMatVec = triu(aMat);
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test triu not square
            %
            aMat = ones(2,5);
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.triu(aMatFun);
            self.isMatFunSizeEq(rMatFun, aMatFun);
            expectedMatVec = repmat( triu(aMat), [1 1 3] );
            obtainedMatVec = rMatFun.evaluate([0 1 2]);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test makeSymmetric
            %
            aMat = triu(magic(5));
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.makeSymmetric(aMatFun);
            self.isMatFunSizeEq(rMatFun, aMatFun);
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
            % test transpose square
            %
            aMat = triu(magic(5));
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.transpose(aMatFun);
            self.isMatFunSizeEq(rMatFun, aMatFun, @fliplr);
            expectedMatVec = repmat(aMat.', [1 1 3]);
            obtainedMatVec = rMatFun.evaluate([0 1 2]);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test transpose not square
            %
            aMat = ones(3, 2);
            aMat(2,:) = 2;
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.transpose(aMatFun);
            self.isMatFunSizeEq(rMatFun, aMatFun, @fliplr);
            expectedMatVec = repmat(aMat.', [1 1 3]);
            obtainedMatVec = rMatFun.evaluate([0 1 2]);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test inv
            %
            aMat = magic(7);
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.inv(aMatFun);
            self.isMatFunSizeEq(rMatFun, aMatFun);
            expectedMatVec = inv(aMat);
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test sqrtm
            %
            aMat = eye(10)*5;
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.sqrtmpos(aMatFun);
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
            rMatFun = factory.lrMultiplyByVec(mMatFun,lrVecFun);
            expectedMatVec = (lrVec.')*mMat*lrVec;
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test lrDivideVec
            %
            lrVec = ones(4,1);
            mMat = 2*eye(4);
            lrVecFun = ConstMatrixFunction(lrVec);
            mMatFun = ConstMatrixFunction(mMat);
            rMatFun = factory.lrDivideVec(mMatFun,lrVecFun);
            expectedMatVec = 2;
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test quadraticFormSqrt
            %
            xVec = ones(4,1);
            mMat = eye(4);
            xVecFun = ConstMatrixFunction(xVec);
            mMatFun = ConstMatrixFunction(mMat);
            rMatFun = factory.quadraticFormSqrt(mMatFun,xVecFun);
            expectedMatVec = 2*ones(1,20);
            obtainedMatVec = rMatFun.evaluate(1:20);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test expm
            %
            aMat = ones(4);
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.expm(aMatFun);
            self.isMatFunSizeEq(rMatFun, aMatFun);
            expectedMatVec = expm(aMat);
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test expmt
            %
            aMat = ones(4);
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.expmt(aMatFun,0);
            self.isMatFunSizeEq(rMatFun, aMatFun);
            expectedMatVec = cat(3,expm(aMat*0),expm(aMat*0.5), ...
                expm(aMat*1));
            obtainedMatVec = rMatFun.evaluate([0, 0.5, 1]);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test uminus for constant matrices: square
            %
            aMat = triu(magic(5));
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.uminus(aMatFun);
            self.isMatFunSizeEq(rMatFun, aMatFun);
            expectedMatVec = repmat(-aMat, [1 1 3]);
            obtainedMatVec = rMatFun.evaluate([0 1 2]);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test uminus for constant matrices: not square
            %
            aMat = ones(3, 4);
            aMatFun = ConstMatrixFunction(aMat);
            rMatFun = factory.uminus(aMatFun);
            self.isMatFunSizeEq(rMatFun, aMatFun);
            expectedMatVec = repmat(-aMat, [1 1 3]);
            obtainedMatVec = rMatFun.evaluate([0 1 2]);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %            
            % test uminus for symbolic matrices: square
            %
            aCMat={'t','2*t';'3*t','4*t'};
            aMatFun=gras.mat.symb.MatrixSymbFormulaBased(aCMat);  
            rMatFun=factory.uminus(aMatFun);
            self.isMatFunSizeEq(rMatFun, aMatFun);
            aMinusCMat=strrep(aCMat,'t','-t');
            rExpMatFun=gras.mat.symb.MatrixSymbFormulaBased(aMinusCMat);  
            checkIfEqual(rMatFun,rExpMatFun);
            %            
            % test uminus for symbolic matrices: not square
            %
            aCMat={'t','2*t';'3*t','4*t'; '5*t', '6*t'};
            aMatFun=gras.mat.symb.MatrixSymbFormulaBased(aCMat);  
            rMatFun=factory.uminus(aMatFun);
            self.isMatFunSizeEq(rMatFun, aMatFun);
            aMinusCMat=strrep(aCMat,'t','-t');
            rExpMatFun=gras.mat.symb.MatrixSymbFormulaBased(aMinusCMat);  
            checkIfEqual(rMatFun,rExpMatFun);
            function checkIfEqual(rMatFun,rExpMatFun)
                timeVec=[0 1 2 3];
                rMatVec = rMatFun.evaluate(timeVec);
                rExpMatVec = rExpMatFun.evaluate(timeVec);
                self.isMatVecEq(rMatVec, rExpMatVec);
            end
        end
    end
    methods
        function self = SuiteOp(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function testBasicSize(self)
            import gras.mat.fcnlib.*;
            import gras.mat.symb.*;
            %
            aMat = ones(2, 3);
            aMatFun = ConstMatrixFunction(aMat);
            self.isMatFunSizeVecEq(aMatFun, aMat);
            %
            asqMat = eye(2);
            asqMatFun = ConstMatrixFunction(asqMat);
            self.isMatFunSizeVecEq(asqMatFun, asqMat);
            %
            atMat = {'t', '0'; '0', 't'; '0', '0'};
            atMatFun = MatrixSymbFormulaBased(atMat);
            self.isMatFunSizeVecEq(atMatFun, atMat);
            %
            asqtMat = {'cos(t)', '-sin(t)'; 'sin(t)', 'cos(t)'};
            asqtMatFun = MatrixSymbFormulaBased(asqtMat);
            self.isMatFunSizeVecEq(asqtMatFun, asqtMat);
        end
        function testCompositeMatrixOperations(self)
            factory = gras.mat.CompositeMatrixOperations;
            self.runTestsForFactory(factory);
        end
        function testSplineMatrixOperations(self)
            timeVec = linspace(-5,5,10000);
            factory = gras.interp.SplineMatrixOperations(timeVec);
            self.runTestsForFactory(factory);
        end
        function testOtherOperations(self)
            import gras.mat.*;
            import gras.mat.fcnlib.*;
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