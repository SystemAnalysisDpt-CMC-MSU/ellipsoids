classdef SuiteOp < mlunitext.test_case
    methods(Static,Access=private)
        function isOk = isMatFunSizeConsistent(inpMatFun)
            inpMatSizeVec = inpMatFun.getMatrixSize();
            inpMatDimensionality = inpMatFun.getDimensionality();
            expectedDim = 2 - any(inpMatSizeVec == 1);
            isOk = isequal(inpMatDimensionality, expectedDim);
            %
            inpMatSizeRVec = [inpMatFun.getNRows(), inpMatFun.getNCols()];
            isOk = isOk && isequal(inpMatSizeVec, inpMatSizeRVec);
            %
            mlunitext.assert_equals(isOk, true);
        end
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
        function isOk = isMatFunSizeEq(self, aMatFun, bMatFun, varargin)
            if any([isa(aMatFun, 'cell'), isa(aMatFun, 'numeric')])
                aSizeVec = size(aMatFun);
            else
                self.isMatFunSizeConsistent(aMatFun);
                aSizeVec = aMatFun.getMatrixSize();
            end
            %
            if any([isa(bMatFun, 'cell'), isa(bMatFun, 'numeric')])
                bSizeVec = size(bMatFun);
            else
                self.isMatFunSizeConsistent(bMatFun);
                bSizeVec = bMatFun.getMatrixSize();
            end
            %
            if nargin > 3
                fPostProc = varargin{1};
                [aSizeVec, bSizeVec] = fPostProc(aSizeVec, bSizeVec);
            end
            isOk = self.isMatVecEq(aSizeVec, bSizeVec);
        end
        function isOk = isUnaryOpEqual(self, op, argMat, expectedMat, ...
                varargin)
            import gras.mat.MatrixFunctionFactory;
            %
            timeVec = -3:3;
            if nargin > 4
                if ~isempty(varargin{1})
                    timeVec = varargin{1};
                end
            end
            %
            resMatFun = op(MatrixFunctionFactory.createInstance(argMat));
            resultVec = resMatFun.evaluate(timeVec);
            %
            isExpFunc = (size(expectedMat, 3) == 1);
            if isExpFunc
                expMatFun = MatrixFunctionFactory.createInstance(...
                    expectedMat);
                self.isMatFunSizeEq(resMatFun, expMatFun);
                expectedVec = expMatFun.evaluate(timeVec);
                isOk = self.isMatVecEq(resultVec(:), expectedVec(:));
            else
                self.isMatFunSizeEq(resMatFun, expectedMat(:,:,1));
                isOk = self.isMatVecEq(resultVec(:), expectedMat(:));
            end
            mlunitext.assert_equals(isOk, true);
        end
        function isOk = isBinaryOpEqual(self, op, arg1Mat, arg2Mat, ...
                expectedMat, varargin)
            import gras.mat.MatrixFunctionFactory;
            %
            timeVec = -3:3;
            if nargin > 5
                if ~isempty(varargin{1})
                    timeVec = varargin{1};
                end   
            end
            %
            arg1MatFun = MatrixFunctionFactory.createInstance(arg1Mat);
            arg2MatFun = MatrixFunctionFactory.createInstance(arg2Mat);
            resMatFun = op(arg1MatFun, arg2MatFun);
            %
            isExpFunc = (size(expectedMat, 3) == 1);
            % ToFix: row splines returns [nxt] vector, while const returns
            % [nx1xt]
            isOk = isEquality();
            if nargin > 5
                if any(strcmp('symmetric', varargin))
                    resMatFun = op(arg2MatFun, arg1MatFun);
                    isOk = isOk && isEquality();
                end
            end
            mlunitext.assert_equals(isOk, true);
            %
            function isOk = isEquality()
                import gras.mat.MatrixFunctionFactory;
                resultVec = resMatFun.evaluate(timeVec);
                if isExpFunc
                    expMatFun = MatrixFunctionFactory.createInstance(...
                        expectedMat);
                    self.isMatFunSizeEq(resMatFun, expMatFun);
                    expectedVec = expMatFun.evaluate(timeVec);
                    isOk = self.isMatVecEq(resultVec(:), expectedVec(:));
                else
                    self.isMatFunSizeEq(resMatFun, expectedMat(:,:,1));
                    isOk = self.isMatVecEq(resultVec(:), expectedMat(:));
                end
            end
        end
        function runTestsForFactory(self, factory)
            import gras.gen.matdot;
            import gras.mat.*;
            %
            % test triu square
            %
            aMat = magic(4);
            self.isUnaryOpEqual(@factory.triu, aMat, triu(aMat));
            %
            % test triu not square
            %
            aMat = ones(2,5);
            self.isUnaryOpEqual(@factory.triu, aMat, triu(aMat));
            %
            % test makeSymmetric
            %
            aMat = triu(magic(5));
            self.isUnaryOpEqual(@factory.makeSymmetric, aMat, ...
                0.5*(aMat+aMat.'));
            %
            % test pinv
            %
            aMat = [magic(5), magic(5)];
            self.isUnaryOpEqual(@factory.pinv, aMat, pinv(aMat));
            %
            % test transpose square
            %
            aMat = triu(magic(5));
            self.isUnaryOpEqual(@factory.transpose, aMat, aMat.');
            %
            % test transpose not square
            %
            aMat = ones(3, 2);
            aMat(2,:) = 2;
            self.isUnaryOpEqual(@factory.transpose, aMat, aMat.');
            %
            % test inv
            %
            aMat = magic(7);
            self.isUnaryOpEqual(@factory.inv, aMat, inv(aMat));
            %
            % test sqrtm
            %
            aMat = eye(10)*5;
            self.isUnaryOpEqual(@factory.sqrtmpos, aMat, sqrtm(aMat));
            %
            % test realsqrt square
            %
            aMat = magic(8);
            self.isUnaryOpEqual(@factory.realsqrt, aMat, realsqrt(aMat));
			%
            % test realsqrt not square
            %
            aMat = 5 * ones(3, 2);
            self.isUnaryOpEqual(@factory.realsqrt, aMat, realsqrt(aMat));
            %
            % test realsqrt #2
            %
            aCMat = {'t^4'};
            aCSqrtMat = {'t^2'};
            self.isUnaryOpEqual(@factory.realsqrt, aCMat, aCSqrtMat);
            %
            isRSqrtBTestEnabled = false;
            if isRSqrtBTestEnabled
                %
                % test realsqrt #3 - bad spline
                %
                aCMat = {'t^2'};
                aCSqrtMat = {'abs(t)'};
                self.isUnaryOpEqual(@factory.realsqrt, aCMat, aCSqrtMat);
            end
            %
            % test uminus for constant matrices: square
            %
            aMat = triu(magic(5));
            self.isUnaryOpEqual(@factory.uminus, aMat, -aMat);
            %
            % test uminus for constant matrices: not square
            %
            aMat = ones(3, 4);
            self.isUnaryOpEqual(@factory.uminus, aMat, -aMat);
            %            
            % test uminus for symbolic matrices: square
            %
            aCMat={'t','2*t';'3*t','4*t'};
            aMinusCMat=strrep(aCMat,'t','-t');
            self.isUnaryOpEqual(@factory.uminus, aCMat, aMinusCMat);
            %            
            % test uminus for symbolic matrices: not square
            %
            aCMat={'t','2*t';'3*t','4*t'; '5*t', '6*t'};
            aMinusCMat=strrep(aCMat,'t','-t');
            self.isUnaryOpEqual(@factory.uminus, aCMat, aMinusCMat);
            %
            % test rMultiplyByVec
            %
            aMat = magic(10);
            bVec = ones(10,1);
            self.isBinaryOpEqual(@factory.rMultiplyByVec, aMat, bVec, ...
                aMat * bVec);
            %
            % test rMultiply #1
            %
            aMat = ones(3,4);
            bMat = ones(4,5);
            self.isBinaryOpEqual(@factory.rMultiply, aMat, bMat, ...
                aMat * bMat);
            %
            % test rMultiply #2
            %
            aMat = ones(3,4);
            bMat = ones(4,5);
            cMat = ones(5,6);
            aMatFun = ConstMatrixFunctionFactory.createInstance(aMat);
            bMatFun = ConstMatrixFunctionFactory.createInstance(bMat);
            cMatFun = ConstMatrixFunctionFactory.createInstance(cMat);
            rMatFun = factory.rMultiply(aMatFun,bMatFun,cMatFun);
            expectedMatVec = aMat*bMat*cMat;
            obtainedMatVec = rMatFun.evaluate(0);
            self.isMatVecEq(expectedMatVec, obtainedMatVec);
            %
            % test lrMultiply #1
            %
            lrMat = ones(4,5);
            mMat = ones(5);
            self.isBinaryOpEqual(@(x, y)factory.lrMultiply(x, y, 'L'), ...
                mMat, lrMat, lrMat*mMat*(lrMat.'));
            %
            % test lrMultiply #2
            %
            lrMat = ones(4,5);
            mMat = ones(4);
            self.isBinaryOpEqual(@(x, y)factory.lrMultiply(x, y, 'R'), ...
                mMat, lrMat, (lrMat.')*mMat*lrMat);
            %
            % test rMultiplyByScalar
            %
            aMat = magic(4);
            self.isBinaryOpEqual(@factory.rMultiplyByScalar, aMat, 2, ...
                2 * aMat);
            %
            % test rMultiplyByScalar #2
            %            
            aCMat = {'1', '-t'; 't', '1'};
            rCScal = {'t + 1'};
            resCMat = {'t + 1', '-t .* (t + 1)'; 't .* (t + 1)', 't + 1'};
            self.isBinaryOpEqual(@factory.rMultiplyByScalar, aCMat, ...
                rCScal, resCMat);
            %
            % test rDivideByScalar
            %
            aMat = magic(4);
            self.isBinaryOpEqual(@factory.rDivideByScalar, aMat, 2, ...
                aMat / 2);
            %
            % test rDivideByScalar #2
            %
            aCMat = {'1', '-t'; 't', '1'};
            rCScal = {'t.^2 + 1'};
            resCMat = {'1./(t.^2 + 1)', '-t./(t.^2 + 1)'; ...
                't./(t.^2 + 1)', '1./(t.^2 + 1)'};
            self.isBinaryOpEqual(@factory.rDivideByScalar, aCMat, ...
                rCScal, resCMat);
            %
            % test lrMultiplyByVec
            %
            lrVec = ones(4,1);
            mMat = ones(4);
            self.isBinaryOpEqual(@factory.lrMultiplyByVec, mMat, lrVec, ...
                (lrVec.')*mMat*lrVec);
            %
            % test lrDivideVec
            %
            lrVec = ones(4,1);
            mMat = 2*eye(4);
            self.isBinaryOpEqual(@factory.lrDivideVec, mMat, lrVec, 2);
            %
            % test quadraticFormSqrt
            %
            xVec = ones(4,1);
            mMat = eye(4);
            self.isBinaryOpEqual(@factory.quadraticFormSqrt, mMat, ...
                xVec, 2);
            %
            % test expm
            %
            aMat = ones(4);
            self.isUnaryOpEqual(@factory.expm, aMat, expm(aMat));
            %
            % test expmt
            %
            aMat = ones(4);
            self.isUnaryOpEqual(@(x) factory.expmt(x, 0), aMat, ...
                cat(3,expm(aMat*0),expm(aMat*0.5), expm(aMat*1)), ...
                [0, 0.5, 1]);
            %
            % test matdot for constant matrices
            %
            aMat = ones(6);
            bMat = magic(6);
            self.isBinaryOpEqual(@factory.matdot, aMat, ...
                bMat, matdot(aMat, bMat), [], 'symmetric');
            %
            % test matdot for symbolic matrices 
            %
            aCMat = {'cos(t)', '-sin(t)'; 'sin(t)', 'cos(t)'};
            bCMat = strrep(aCMat,'t','-t');
            resCMat = {'cos(2 .* t)'};
            self.isBinaryOpEqual(@factory.matdot, aCMat, ...
                bCMat, resCMat, [], 'symmetric');
        end
    end
    methods
        function self = SuiteOp(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function testSize(self)
            import gras.mat.*
            %
            % basic size tests
            %
            aMat = ones(2, 3);
            aMatFun = ConstMatrixFunctionFactory.createInstance(aMat);
            self.isMatFunSizeEq(aMatFun, aMat);
            %
            asqMat = eye(2);
            asqMatFun = ConstMatrixFunctionFactory.createInstance(asqMat);
            self.isMatFunSizeEq(asqMatFun, asqMat);
            %
            atCMat = {'t', '0'; '0', 't'; '0', '0'};
            atMatFun = MatrixFunctionFactory.createInstance(atCMat);
            self.isMatFunSizeEq(atMatFun, atCMat);
            %
            asqtCMat = {'cos(t)', '-sin(t)'; 'sin(t)', 'cos(t)'};
            asqtMatFun = MatrixFunctionFactory.createInstance(asqtCMat);
            self.isMatFunSizeEq(asqtMatFun, asqtCMat);
            %
            % dimensionality tests
            %
            aMat = ones(2, 1);
            aMatFun = ConstMatrixFunctionFactory.createInstance(aMat);
            self.isMatFunSizeEq(aMatFun, aMat);
            %
            aMat = aMat.';
            aMatFun = ConstMatrixFunctionFactory.createInstance(aMat);
            self.isMatFunSizeEq(aMatFun, aMat);
            %
            aMat = 1;
            aMatFun = ConstMatrixFunctionFactory.createInstance(aMat);
            self.isMatFunSizeEq(aMatFun, aMat);
            %
            atCMat = {'t', '0'};
            atMatFun = MatrixFunctionFactory.createInstance(atCMat);
            self.isMatFunSizeEq(atMatFun, atCMat);
            %
            atCMat = atCMat.';
            atMatFun = MatrixFunctionFactory.createInstance(atCMat);
            self.isMatFunSizeEq(atMatFun, atCMat);
            %
            atCMat = {'t'};
            atMatFun = MatrixFunctionFactory.createInstance(atCMat);
            self.isMatFunSizeEq(atMatFun, atCMat);
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
        function testSymbMatrixOperations(self)
            import gras.mat.symb.*
            import gras.mat.MatrixFunctionFactory;
            %
            aScCMat = {'t'};
            bScCMat = {'t + 1'};
            aVecCMat = {'t'; 't.^2'};
            aSqCMat = {'t', '1'; '1', 't'};            
            %
            % MatrixSFBinaryProdByVec: regular test
            %
            resCMat = {'2 .* t.^2'; 't.^3 + t'};
            isBinarySymbOpEqual(@MatrixSFBinaryProdByVec, aSqCMat, ...
                aVecCMat, resCMat);
            %
            % MatrixSFBinaryProdByVec: scalar result test
            %
            resCMat = {'t.^4 + t.^2'};
            isBinarySymbOpEqual(@MatrixSFBinaryProdByVec, aVecCMat', ...
                aVecCMat, resCMat);
            %
            % MatrixSFBinaryProd: regular test
            %
            resCMat = {'2 .* t.^2'; 't.^3 + t'};
            isBinarySymbOpEqual(@MatrixSFBinaryProd, aSqCMat, ...
                aVecCMat, resCMat);
            %
            % MatrixSFBinaryProd: scalar result test
            %
            resCMat = {'t.^4 + t.^2'};
            isBinarySymbOpEqual(@MatrixSFBinaryProd, aVecCMat', ...
                aVecCMat, resCMat);
            %
            % MatrixSFBinaryProd: scalar argument test #1
            %
            resCMat = {'t.^2', 't'; 't', 't.^2'};  
            isBinarySymbOpEqual(@MatrixSFBinaryProd, aScCMat, ...
                aSqCMat, resCMat, [], 'symmetric');
            %
            % MatrixSFBinaryProd: scalar argument test #1
            %
            resCMat = {'t.^2 + t'};  
            isBinarySymbOpEqual(@MatrixSFBinaryProd, aScCMat, ...
                bScCMat, resCMat, [], 'symmetric');
            %
            % MatrixSFTripleProd: scalar argument test #1
            %
            resCMat = {'t.^3', 't.^2'; 't.^2', 't.^3'};    
            isBinarySymbOpEqual(@(x, y)MatrixSFTripleProd(x, x, y), ...
                aScCMat, aSqCMat, resCMat);
            %
            % MatrixSFTripleProd: scalar argument test #2
            %
            resCMat = {'t.^3'; 't.^4'};  
            isBinarySymbOpEqual(@(x, y)MatrixSFTripleProd(x, x, y), ...
                aScCMat, aVecCMat, resCMat);
            %
            % MatrixSFTripleProd: scalar argument test #2
            %
            resCMat = {'t.^3 + t.^2'};
            isBinarySymbOpEqual(@(x, y)MatrixSFTripleProd(x, x, y), ...
                aScCMat, bScCMat, resCMat);
            %
            function isOk = isBinarySymbOpEqual(op, arg1CMat, ...
                    arg2CMat, expectedCMat, varargin)
                timeVec = -3:3;
                if nargin > 5
                    if ~isempty(varargin{1})
                        timeVec = varargin{1};
                    end   
                end
                %
                resMatFun = op(arg1CMat, arg2CMat);
                %
                isOk = isEquality();
                if nargin > 5
                    if any(strcmp('symmetric', varargin))
                        resMatFun = op(arg2CMat, arg1CMat);
                        isOk = isOk && isEquality();
                    end
                end
                mlunitext.assert_equals(isOk, true);
                %
                function isOk = isEquality()
                    import gras.mat.MatrixFunctionFactory;
                    resultVec = resMatFun.evaluate(timeVec);
                    expMatFun = MatrixFunctionFactory.createInstance(...
                        expectedCMat);
                    self.isMatFunSizeEq(resMatFun, expMatFun);
                    expectedVec = expMatFun.evaluate(timeVec);
                    isOk = self.isMatVecEq(resultVec(:), expectedVec(:));
                end
            end
        end
        function testOtherOperations(self)
            import gras.mat.*;
            import gras.mat.fcnlib.*;
            %
            % test MatrixMinEigValFunc
            %
            aMat = diag([-2 -1 0 1 2]);
            self.isUnaryOpEqual(@MatrixMinEigValFunc, aMat, -2);
            %
            % test MatrixPlusFunc
            %
            aMat = ones(4);
            bMat = 2*ones(4);
            self.isBinaryOpEqual(@MatrixPlusFunc, aMat, bMat, ...
                3*ones(4), [], 'symmetric');
            %
            % test MatrixMinusFunc
            %
            aMat = ones(4);
            bMat = 2*ones(4);
            self.isBinaryOpEqual(@MatrixMinusFunc, aMat, bMat, -ones(4));
            %
            % test MatrixBinaryTimesFunc: scalar constant
            %
            aMat = magic(5);
            self.isBinaryOpEqual(@MatrixBinaryTimesFunc, aMat, 2, ...
                2 * aMat, [], 'symmetric');
            %
            self.isBinaryOpEqual(@MatrixBinaryTimesFunc, 3, 2, 6, [], ...
                'symmetric');
            %
            % test MatrixBinaryTimesFunc: scalar non constant
            %            
            aCMat = {'1', '-t'; 't', '1'};
            rCScal = {'t + 1'};
            resCMat = {'t + 1', '-t.^2 - t'; 't.^2 + t', 't + 1'};
            self.isBinaryOpEqual(@MatrixBinaryTimesFunc, aCMat, rCScal, ...
               resCMat, [], 'symmetric');
            %
            self.isBinaryOpEqual(@MatrixBinaryTimesFunc, {'t + 1'}, ...
                {'t + 3'}, {'(t + 1).*(t + 3)'}, [], 'symmetric');
            %
            % test MatrixLRTimesFunc: scalar constant
            %
            aMat = magic(5);
            self.isBinaryOpEqual(@MatrixLRTimesFunc, aMat, 2, ...
                4 * aMat);
            %
            % test MatrixLRTimesFunc: scalar non constant
            %            
            aCMat = {'1', '-t'; 't', '1'};
            rCScal = {'t + 1'};
            resCMat = {'(t + 1).^2', '-t.*((t + 1).^2)'; ...
                't.*((t + 1).^2)', '(t + 1).^2'};
            self.isBinaryOpEqual(@MatrixLRTimesFunc, aCMat, rCScal, ...
               resCMat);
            %
            % test MatrixTernaryTimesFunc: scalar constant
            %
            aMat = ones(2, 3);
            self.isBinaryOpEqual(@(x, y) MatrixTernaryTimesFunc(x, x, y), ...
                2, aMat, 4 * aMat);
            %
            self.isBinaryOpEqual(@(x, y) MatrixTernaryTimesFunc(x, x, y), ...
                5, 2, 50);
            %
            % test MatrixTernaryTimesFunc: scalar non constant
            %
            aCMat = {'t', 't + 1'};
            resCMat = {'9 .* t', '9 .* t + 9'};
            self.isBinaryOpEqual(@(x, y) MatrixTernaryTimesFunc(x, x, y), ...
                3, aCMat, resCMat);
            %
            self.isBinaryOpEqual(@(x, y) MatrixTernaryTimesFunc(x, x, y), ...
                {'2'}, {'3 .* t'}, {'12 .* t'});
        end
    end
end