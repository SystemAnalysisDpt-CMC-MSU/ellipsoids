classdef SuiteOp < mlunitext.test_case
    properties (Constant, Hidden, Access = private)
        SYMCHECK_MAX_DIM = 5;
    end
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
        %
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
        %
        function isOk = isMatFunSizeEq(aMatFun, bMatFun, varargin)
            import gras.mat.test.mlunit.SuiteOp;
            if any([isa(aMatFun, 'cell'), isa(aMatFun, 'numeric')])
                aSizeVec = size(aMatFun);
            else
                SuiteOp.isMatFunSizeConsistent(aMatFun);
                aSizeVec = aMatFun.getMatrixSize();
            end
            %
            if any([isa(bMatFun, 'cell'), isa(bMatFun, 'numeric')])
                bSizeVec = size(bMatFun);
            else
                SuiteOp.isMatFunSizeConsistent(bMatFun);
                bSizeVec = bMatFun.getMatrixSize();
            end
            %
            if nargin > 2
                fPostProc = varargin{1};
                [aSizeVec, bSizeVec] = fPostProc(aSizeVec, bSizeVec);
            end
            isOk = SuiteOp.isMatVecEq(aSizeVec, bSizeVec);
        end
        %
        function isOk = isOpEqual(opts, expectedMat, timeVec, op, ...
                varargin)
            import gras.mat.AMatrixOperations;
            import gras.mat.ConstMatrixFunctionFactory;
            import gras.mat.test.mlunit.SuiteOp;            
            %
            if isempty(timeVec)
                timeVec = -3:3;
            end
            %
            if ~any(strcmp('symb', opts))
                argFunCMat = cell(1, nargin-4);
                for i = 1:nargin-4
                    if isnumeric(varargin{i})
                        argFunCMat{i} = ...
                            ConstMatrixFunctionFactory.createInstance(...
                            varargin{i});
                    else
                        argFunCMat{i} = AMatrixOperations.fromSymbMatrix(...
                            varargin{i});
                    end
                end
                isExpFunc = (size(expectedMat, 3) == 1);
            else
                argFunCMat = varargin;
                isExpFunc = true;
            end
            %
            if any(strcmp('symmetric', opts)) && (length(varargin) < ...
                    SuiteOp.SYMCHECK_MAX_DIM)
                checkMat = perms(1:length(varargin));
                isOk = true;
                for i = 1:size(checkMat, 1)
                    resMatFun = op(argFunCMat{checkMat(i, :)});
                    isOk = isOk && isEquality();
                    if ~isOk
                        break;
                    end
                end
            else
                resMatFun = op(argFunCMat{:});            
                isOk = isEquality();
            end
            mlunitext.assert_equals(isOk, true);
            %
            function isOk = isEquality()
                import gras.mat.AMatrixOperations;
                import gras.mat.ConstMatrixFunctionFactory;
                import gras.mat.test.mlunit.SuiteOp;
                %
                resultVec = resMatFun.evaluate(timeVec);
                if isExpFunc
                    if isnumeric(expectedMat)
                        expMatFun = ...
                            ConstMatrixFunctionFactory.createInstance(...
                            expectedMat);
                    else
                        expMatFun = ...
                            AMatrixOperations.fromSymbMatrix(expectedMat);
                    end
                    SuiteOp.isMatFunSizeEq(resMatFun, expMatFun);
                    expectedVec = expMatFun.evaluate(timeVec);
                    isOk = SuiteOp.isMatVecEq(resultVec(:), expectedVec(:));
                else
                    SuiteOp.isMatFunSizeEq(resMatFun, expectedMat(:,:,1));
                    isOk = SuiteOp.isMatVecEq(resultVec(:), expectedMat(:));
                end
            end
        end
    end
    methods(Access=private)
        function runTestsForFactory(self, factory)
            import gras.gen.matdot;
            import gras.mat.*;
            %
            % test triu square
            %
            aMat = magic(4);
            self.isOpEqual({}, triu(aMat), [], @factory.triu, aMat);
            %
            % test triu not square
            %
            aMat = ones(2,5);
            self.isOpEqual({}, triu(aMat), [], @factory.triu, aMat);
            %
            % test makeSymmetric
            %
            aMat = triu(magic(5));
            self.isOpEqual({}, 0.5*(aMat+aMat.'), [], ...
                @factory.makeSymmetric, aMat);
            %
            % test pinv
            %
            aMat = [magic(5), magic(5)];
            self.isOpEqual({}, pinv(aMat), [], @factory.pinv, aMat);
            %
            % test transpose square
            %
            aMat = triu(magic(5));
            self.isOpEqual({}, aMat.', [], @factory.transpose, aMat);
            %
            % test transpose not square
            %
            aMat = ones(3, 2);
            aMat(2,:) = 2;
            self.isOpEqual({}, aMat.', [], @factory.transpose, aMat);
            %
            % test inv
            %
            aMat = magic(7);
            self.isOpEqual({}, inv(aMat), [], @factory.inv, aMat);
            %
            % test sqrtm
            %
            aMat = eye(10)*5;
            self.isOpEqual({}, sqrtm(aMat), [], @factory.sqrtmpos, aMat);
            %
            % test realsqrt square
            %
            aMat = magic(8);
            self.isOpEqual({}, realsqrt(aMat), [], @factory.realsqrt, ...
                aMat);
			%
            % test realsqrt not square
            %
            aMat = 5 * ones(3, 2);
            self.isOpEqual({}, realsqrt(aMat), [], @factory.realsqrt, ...
                aMat);
            %
            % test realsqrt #2
            %
            aCMat = {'t^4'};
            aCSqrtMat = {'t^2'};
            self.isOpEqual({}, aCSqrtMat, [], @factory.realsqrt, aCMat);
            %
            isRSqrtBTestEnabled = false;
            if isRSqrtBTestEnabled
                %
                % test realsqrt #3 - bad spline
                %
                aCMat = {'t^2'};
                aCSqrtMat = {'abs(t)'};
                self.isOpEqual({}, aCSqrtMat, [], @factory.realsqrt, ...
                    aCMat);
            end
            %
            % test uminus for constant matrices: square
            %
            aMat = triu(magic(5));
            self.isOpEqual({}, -aMat, [], @factory.uminus, aMat);
            %
            % test uminus for constant matrices: not square
            %
            aMat = ones(3, 4);
            self.isOpEqual({}, -aMat, [], @factory.uminus, aMat);
            %            
            % test uminus for symbolic matrices: square
            %
            aCMat={'t','2*t';'3*t','4*t'};
            aMinusCMat=strrep(aCMat,'t','-t');
            self.isOpEqual({}, aMinusCMat, [], @factory.uminus, aCMat);
            %            
            % test uminus for symbolic matrices: not square
            %
            aCMat={'t','2*t';'3*t','4*t'; '5*t', '6*t'};
            aMinusCMat=strrep(aCMat,'t','-t');
            self.isOpEqual({}, aMinusCMat, [], @factory.uminus, aCMat);
            %
            % test rMultiplyByVec
            %
            aMat = magic(10);
            bVec = ones(10,1);
            self.isOpEqual({}, aMat * bVec, [], ...
                @factory.rMultiplyByVec, aMat, bVec);
            %
            % test rMultiply #1
            %
            aMat = ones(3,4);
            bMat = ones(4,5);
            self.isOpEqual({}, aMat * bMat, [], @factory.rMultiply, ...
                aMat, bMat);
            %
            % test rMultiply #2
            %
            aMat = ones(3,4);
            bMat = ones(4,5);
            cMat = ones(5,6);
            self.isOpEqual({}, aMat * bMat * cMat, [], ...
                @factory.rMultiply, aMat, bMat, cMat);
            %
            % test lrMultiply #1
            %
            lrMat = ones(4,5);
            mMat = ones(5);
            self.isOpEqual({}, lrMat * mMat * (lrMat.'), [], ...
                @(x, y)factory.lrMultiply(x, y, 'L'), mMat, lrMat);
            %
            % test lrMultiply #2
            %
            lrMat = ones(4,5);
            mMat = ones(4);
            self.isOpEqual({}, (lrMat.') * mMat * lrMat, [], ...
                @(x, y)factory.lrMultiply(x, y, 'R'), mMat, lrMat);
            %
            % test rMultiplyByScalar
            %
            aMat = magic(4);
            self.isOpEqual({}, 2 * aMat, [], ...
                @factory.rMultiplyByScalar, aMat, 2);
            %
            % test rMultiplyByScalar #2
            %            
            aCMat = {'1', '-t'; 't', '1'};
            rCScal = {'t + 1'};
            resCMat = {'t + 1', '-t .* (t + 1)'; 't .* (t + 1)', 't + 1'};
            self.isOpEqual({}, resCMat, [], @factory.rMultiplyByScalar, ...
                aCMat, rCScal);
            %
            % test rDivideByScalar
            %
            aMat = magic(4);
            self.isOpEqual({}, aMat / 2, [], @factory.rDivideByScalar, ...
                aMat, 2);
            %
            % test rDivideByScalar #2
            %
            aCMat = {'1', '-t'; 't', '1'};
            rCScal = {'t.^2 + 1'};
            resCMat = {'1./(t.^2 + 1)', '-t./(t.^2 + 1)'; ...
                't./(t.^2 + 1)', '1./(t.^2 + 1)'};
            self.isOpEqual({}, resCMat, [], @factory.rDivideByScalar, ...
                aCMat, rCScal);
            %
            % test lrMultiplyByVec
            %
            lrVec = ones(4,1);
            mMat = ones(4);
            self.isOpEqual({}, (lrVec.') * mMat * lrVec, [], ...
                @factory.lrMultiplyByVec, mMat, lrVec);
            %
            % test lrDivideVec
            %
            lrVec = ones(4,1);
            mMat = 2*eye(4);
            self.isOpEqual({}, 2, [], @factory.lrDivideVec, mMat, lrVec);
            %
            % test quadraticFormSqrt
            %
            xVec = ones(4,1);
            mMat = eye(4);
            self.isOpEqual({}, 2, [], @factory.quadraticFormSqrt, mMat, ...
                xVec);
            %
            % test expm
            %
            aMat = ones(4);
            self.isOpEqual({}, expm(aMat), [], @factory.expm, aMat);
            %
            % test expmt
            %
            aMat = ones(4);
            self.isOpEqual({}, ...
                cat(3,expm(aMat*0),expm(aMat*0.5), expm(aMat)), ...
                [0, 0.5, 1], @(x) factory.expmt(x, 0), aMat);
            %
            % test matdot for constant matrices
            %
            aMat = ones(6);
            bMat = magic(6);
            self.isOpEqual({'symmetric'}, matdot(aMat, bMat), [], ...
                @factory.matdot, aMat, bMat);
            %
            % test matdot for symbolic matrices 
            %
            aCMat = {'cos(t)', '-sin(t)'; 'sin(t)', 'cos(t)'};
            bCMat = strrep(aCMat,'t','-t');
            resCMat = {'cos(2 .* t)'};
            self.isOpEqual({'symmetric'}, resCMat, [], @factory.matdot, ...
                aCMat, bCMat);
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
            atMatFun = AMatrixOperations.fromSymbMatrix(atCMat);
            self.isMatFunSizeEq(atMatFun, atCMat);
            %
            asqtCMat = {'cos(t)', '-sin(t)'; 'sin(t)', 'cos(t)'};
            asqtMatFun = AMatrixOperations.fromSymbMatrix(asqtCMat);
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
            atMatFun = AMatrixOperations.fromSymbMatrix(atCMat);
            self.isMatFunSizeEq(atMatFun, atCMat);
            %
            atCMat = atCMat.';
            atMatFun = AMatrixOperations.fromSymbMatrix(atCMat);
            self.isMatFunSizeEq(atMatFun, atCMat);
            %
            atCMat = {'t'};
            atMatFun = AMatrixOperations.fromSymbMatrix(atCMat);
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
            import gras.mat.AMatrixOperations;
            %
            aScCMat = {'t'};
            bScCMat = {'t + 1'};
            aVecCMat = {'t'; 't.^2'};
            aSqCMat = {'t', '1'; '1', 't'};            
            %
            % MatrixSFBinaryProdByVec: regular test
            %
            resCMat = {'2 .* t.^2'; 't.^3 + t'};
            self.isOpEqual({'symb'}, resCMat, [], ...
                @MatrixSFBinaryProdByVec, aSqCMat, aVecCMat);
            %
            % MatrixSFBinaryProdByVec: scalar result test
            %
            resCMat = {'t.^4 + t.^2'};
            self.isOpEqual({'symb'}, resCMat, [], ...
                @MatrixSFBinaryProdByVec, aVecCMat', aVecCMat);
            %
            % MatrixSFBinaryProd: regular test
            %
            resCMat = {'2 .* t.^2'; 't.^3 + t'};
            self.isOpEqual({'symb'}, resCMat, [], @MatrixSFBinaryProd, ...
                aSqCMat, aVecCMat);
            %
            % MatrixSFBinaryProd: scalar result test
            %
            resCMat = {'t.^4 + t.^2'};
            self.isOpEqual({'symb'}, resCMat, [], @MatrixSFBinaryProd, ...
                aVecCMat', aVecCMat);
            %
            % MatrixSFBinaryProd: scalar argument test #1
            %
            resCMat = {'t.^2', 't'; 't', 't.^2'};  
            self.isOpEqual({'symb', 'symmetric'}, resCMat, [], ...
                @MatrixSFBinaryProd, aScCMat, aSqCMat);
            %
            % MatrixSFBinaryProd: scalar argument test #1
            %
            resCMat = {'t.^2 + t'};  
            self.isOpEqual({'symb', 'symmetric'}, resCMat, [], ...
                @MatrixSFBinaryProd, aScCMat, bScCMat);
            %
            % MatrixSFTripleProd: scalar argument test #1
            %
            resCMat = {'t.^3', 't.^2'; 't.^2', 't.^3'};    
            self.isOpEqual({'symb'}, resCMat, [], ...
                @(x, y)MatrixSFTripleProd(x, x, y), aScCMat, aSqCMat);
            %
            % MatrixSFTripleProd: scalar argument test #2
            %
            resCMat = {'t.^3'; 't.^4'};
            self.isOpEqual({'symb'}, resCMat, [], ...
                @(x, y)MatrixSFTripleProd(x, x, y), aScCMat, aVecCMat);
            %
            % MatrixSFTripleProd: scalar argument test #2
            %
            resCMat = {'t.^3 + t.^2'};
            self.isOpEqual({'symb'}, resCMat, [], ...
                @(x, y)MatrixSFTripleProd(x, x, y), aScCMat, bScCMat);
        end
        function testOtherOperations(self)
            import gras.mat.*;
            import gras.mat.fcnlib.*;
            %
            % test MatrixMinEigValFunc
            %
            aMat = diag([-2 -1 0 1 2]);
            self.isOpEqual({}, -2, [], @MatrixMinEigValFunc, aMat);
            %
            % test MatrixPlusFunc
            %
            aMat = ones(4);
            bMat = 2*ones(4);
            self.isOpEqual({'symmetric'}, 3*ones(4), [], ...
                @MatrixPlusFunc, aMat, bMat);
            %
            % test MatrixMinusFunc
            %
            aMat = ones(4);
            bMat = 2*ones(4);
            self.isOpEqual({}, -ones(4), [], @MatrixMinusFunc, aMat, bMat);
            %
            % test MatrixBinaryTimesFunc: scalar constant
            %
            aMat = magic(5);
            self.isOpEqual({'symmetric'}, 2 * aMat, [], ...
                @MatrixBinaryTimesFunc, aMat, 2);
            %
            self.isOpEqual({'symmetric'}, 6, [], ...
                @MatrixBinaryTimesFunc, 3, 2);
            %
            % test MatrixBinaryTimesFunc: scalar non constant
            %            
            aCMat = {'1', '-t'; 't', '1'};
            rCScal = {'t + 1'};
            resCMat = {'t + 1', '-t.^2 - t'; 't.^2 + t', 't + 1'};
            self.isOpEqual({'symmetric'}, resCMat, [], ...
                @MatrixBinaryTimesFunc, aCMat, rCScal);
            %
            self.isOpEqual({'symmetric'}, {'(t + 1).*(t + 3)'}, [], ...
                @MatrixBinaryTimesFunc, {'t + 1'}, {'t + 3'});
            %
            % test MatrixLRTimesFunc: scalar constant
            %
            aMat = magic(5);
            self.isOpEqual({}, 4 * aMat, [], @MatrixLRTimesFunc, aMat, 2);
            %
            % test MatrixLRTimesFunc: scalar non constant
            %            
            aCMat = {'1', '-t'; 't', '1'};
            rCScal = {'t + 1'};
            resCMat = {'(t + 1).^2', '-t.*((t + 1).^2)'; ...
                't.*((t + 1).^2)', '(t + 1).^2'};
           self.isOpEqual({}, resCMat, [], @MatrixLRTimesFunc, aCMat, ...
               rCScal);
            %
            % test MatrixTernaryTimesFunc: scalar constant
            %
            aMat = ones(2, 3);
            self.isOpEqual({}, 4 * aMat, [], ...
                @(x, y) MatrixTernaryTimesFunc(x, x, y), 2, aMat);
            %
            self.isOpEqual({}, 50, [], ...
                @(x, y) MatrixTernaryTimesFunc(x, x, y), 5, 2);
            %
            % test MatrixTernaryTimesFunc: scalar non constant
            %
            aCMat = {'t', 't + 1'};
            resCMat = {'9 .* t', '9 .* t + 9'};
            self.isOpEqual({}, resCMat, [], ...
                @(x, y) MatrixTernaryTimesFunc(x, x, y), 3, aCMat);
            %
            self.isOpEqual({}, {'12 .* t'}, [], ...
                @(x, y) MatrixTernaryTimesFunc(x, x, y), {'2'}, ...
                {'3 .* t'});
        end
    end
end