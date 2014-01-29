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
            import gras.mat.*;
            import gras.gen.matdot;
            
            aMat = ones(3, 2);
            aMat(2,:) = 2;
            aCMat = {magic(4), ones(2, 5), triu(magic(5)),...
                [magic(5), magic(5)], triu(magic(5)),...
                aMat, magic(7), eye(10)*5, magic(8),...
                5 * ones(3, 2), {'t^4'}, triu(magic(5)), ones(3, 4),...
                {'t','2*t';'3*t','4*t'}, {'t','2*t';'3*t','4*t'; '5*t', '6*t'},...
                ones(4)};
            cCMat = {triu(magic(4)), triu(ones(2, 5)),...
                0.5*( triu(magic(5)) +  triu(magic(5)).'),...
                pinv([magic(5), magic(5)]),(triu(magic(5))).', aMat.',...
                inv(magic(7)), sqrtm(eye(10)*5), realsqrt(magic(8)),...
                realsqrt(5 * ones(3, 2)), {'t^2'}, -triu(magic(5)),...
                -ones(3, 4), strrep({'t','2*t';'3*t','4*t'},'t','-t'),...
                strrep({'t','2*t';'3*t','4*t'; '5*t', '6*t'},'t','-t'),...
                expm(ones(4))};
            matrixFunCVec = {@factory.triu, @factory.triu,...
                @factory.makeSymmetric, @factory.pinv, @factory.transpose,...
                @factory.transpose, @factory.inv, @factory.sqrtmpos,...
                @factory.realsqrt, @factory.realsqrt, @factory.realsqrt,...
                @factory.uminus, @factory.uminus, @factory.uminus,...
                @factory.uminus, @factory.expm};
            
            cellfun(@(x, y, z)self.isOpEqual({}, x, [], y, z),...
                cCMat, matrixFunCVec, aCMat,...
                'UniformOutput', false);
            
           
           aCMat = {magic(10), ones(3,4), ones(5), ones(4), magic(4),...
               {'1', '-t'; 't', '1'}, magic(4), {'1', '-t'; 't', '1'},...
               ones(4), 2 * eye(4), eye(4)};
           bCMat = {ones(10,1), ones(4,5), ones(4, 5), ones(4, 5), 2,...
               {'t + 1'}, 2, {'t.^2 + 1'}, ones(4, 1), ones(4, 1), ones(4, 1)};
           cCMat = {magic(10) * ones(10, 1), ones(3, 4) * ones(4, 5),...
               ones(4, 5) * ones(5) * (ones(4, 5).'),...
               (ones(4, 5).') * ones(4) * ones(4, 5), 2 * magic(4),...
               {'t + 1', '-t .* (t + 1)'; 't .* (t + 1)', 't + 1'}, ...
               magic(4) / 2, {'1./(t.^2 + 1)', '-t./(t.^2 + 1)'; ...
               't./(t.^2 + 1)', '1./(t.^2 + 1)'}, ...
               (ones(4, 1).') * ones(4) * ones(4, 1), 2, 2};
           matrixFunCVec = {@factory.rMultiplyByVec, @factory.rMultiply,...
               @(x, y)factory.lrMultiply(x, y, 'L'),...
               @(x, y)factory.lrMultiply(x, y, 'R'),...
               @factory.rMultiplyByScalar, @factory.rMultiplyByScalar,...
               @factory.rDivideByScalar, @factory.rDivideByScalar,...
               @factory.lrMultiplyByVec, @factory.lrDivideVec,...
               @factory.quadraticFormSqrt};
           
           cellfun(@(x, y, z, w)self.isOpEqual({}, x, [], y, z, w),...
                cCMat, matrixFunCVec, aCMat, bCMat,...
                'UniformOutput', false);
            
           
           aMat = ones(3, 4);
           bMat = ones(4, 5);
           dMat = ones(5, 6);
           cMat = ones(3, 4) * ones(4, 5) * ones(5, 6);
           
           self.isOpEqual({}, cMat, [], @factory.rMultiply, aMat, bMat, dMat);
           
            isRSqrtBTestEnabled = false;
            if isRSqrtBTestEnabled
                self.isOpEqual({}, 'abs(t)', [], @factory.realsqrt,...
                    't^2');
            end 
            
            aMat = ones(4);
            cMat = cat(3,expm(ones(4) * 0), expm(ones(4) * 0.5),...
                        expm(ones(4)));
            bVec = [0, 0.5, 1];
            self.isOpEqual({}, cMat, bVec, @(a) factory.expmt(a, 0), aMat);
            
            
            aCMat = {ones(6), {'cos(t)', '-sin(t)'; 'sin(t)', 'cos(t)'}};
            bCMat = {magic(6),...
                        strrep({'cos(t)', '-sin(t)'; 'sin(t)', 'cos(t)'},...
                        't','-t')};
            cCMat = {matdot(ones(6), magic(6)), {'cos(2 .* t)'}};
            cellfun(@(x, y, z)self.isOpEqual({'symmetric'}, x, [],...
                @factory.matdot, y, z), cCMat, aCMat, bCMat,...
                'UniformOutput', false);
            
            
        end
    end
    methods
        function self = SuiteOp(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function testSize(self)
            aCMat = {ones(2, 3), eye(2), {'t', '0'; '0', 't'; '0', '0'},...
                {'cos(t)', '-sin(t)'; 'sin(t)', 'cos(t)'}, ones(2, 1),...
                ones(1, 2), 1, {'t', '0'}, {'t'; '0'}, {'t'}};
            flagCVec = {1, 1, 2, 2, 1, 1, 1, 2, 2, 2};
            cellfun(@(x, y)sizeEq(x, y, self), aCMat, flagCVec,...
                 'UniformOutput', false);
        end
        function testCompositeMatrixOperations(self)
            factory = gras.mat.CompositeMatrixOperations;
            self.runTestsForFactory(factory);
        end
        function testSplineMatrixOperations(self)
            timeVec = linspace(-5,5,10000);
            factory = gras.mat.interp.SplineMatrixOperations(timeVec);
            self.runTestsForFactory(factory);
        end
        function testSymbMatrixOperations(self)
            import gras.mat.fcnlib.*
            import gras.mat.AMatrixOperations;
            %
            aScC = {'t'};
            bScC = {'t + 1'};
            aCVec = {'t'; 't.^2'};
            aSqCMat = {'t', '1'; '1', 't'};
            
            sCMat = {aSqCMat, aCVec', aSqCMat, aCVec'};
            resCVec = {{'2 .* t.^2'; 't.^3 + t'}, {'t.^4 + t.^2'},...
                {'2 .* t.^2'; 't.^3 + t'}, {'t.^4 + t.^2'}};
            cellfun(@(x, y)self.isOpEqual({'symb'}, x, [],...
                @MatrixSFBinaryProdByVec, y, aCVec), resCVec,...
                sCMat, 'UniformOutput', false);
            
            sCMat = {aSqCMat, aCVec, bScC};
            resCMat = {{'t.^3', 't.^2'; 't.^2', 't.^3'}, {'t.^3'; 't.^4'},...
                {'t.^3 + t.^2'}};
            cellfun(@(x, y)self.isOpEqual({'symb'}, x, [],...
                @(z, w)MatrixSFTripleProd(z, z, w), aScC, y), resCMat,...
                sCMat, 'UniformOutput', false);
            
            sCMat = {aSqCMat, bScC};
            resCMat = {{'t.^2', 't'; 't', 't.^2'}, {'t.^2 + t'}};
            cellfun(@(x, y)self.isOpEqual({'symb', 'symmetric'}, x, [],...
                @MatrixSFBinaryProd, aScC, y), resCMat,...
                sCMat, 'UniformOutput', false);
        end
        function testOtherOperations(self)
            import gras.mat.*;
            import gras.mat.fcnlib.*;
            aCMat = {ones(4), ones(4),...
                magic(5), 3, {'1', '-t'; 't', '1'}, {'t + 1'},...
                magic(5), {'1', '-t'; 't', '1'}, 2, 5, 3, {'2'}};
            bCMat = {2*ones(4),  2*ones(4), 2, 2, {'t + 1'},...
                {'t + 3'}, 2, {'t + 1'}, ones(2, 3), 2, {'t', 't + 1'},...
                {'3 .* t'}};
            cCMat = {3*ones(4), -ones(4), 2 * magic(5), 6,...
                {'t + 1', '-t.^2 - t'; 't.^2 + t', 't + 1'}, {'(t + 1).*(t + 3)'},...
                4 * magic(5), {'(t + 1).^2', '-t.*((t + 1).^2)'; ...
                't.*((t + 1).^2)', '(t + 1).^2'}, 4 * ones(2, 3), 50,...
                {'9 .* t', '9 .* t + 9'}, {'12 .* t'}};
            matrixFunCVec = {@MatrixPlusFunc,...
                @MatrixMinusFunc, @MatrixBinaryTimesFunc,...
                @MatrixBinaryTimesFunc, @MatrixBinaryTimesFunc,...
                @MatrixBinaryTimesFunc, @MatrixLRTimesFunc,...
                @MatrixLRTimesFunc, @(a, b) MatrixTernaryTimesFunc(a, a, b),...
                @(a, b) MatrixTernaryTimesFunc(a, a, b),...
                @(a, b) MatrixTernaryTimesFunc(a, a, b),...
                @(a, b) MatrixTernaryTimesFunc(a, a, b)};
            firstArgCVec = {{'symmetric'}, {}, {'symmetric'},...
                {'symmetric'}, {'symmetric'}, {'symmetric'}, {},...
                {}, {}, {}, {}, {}};
            
            cellfun(@(x, y, z, w, v)self.isOpEqual(x, y, [], z, w, v),firstArgCVec,...
                cCMat, matrixFunCVec, aCMat, bCMat,...
                'UniformOutput', false);
            self.isOpEqual({}, -2, [], @MatrixMinEigValFunc,...
                diag([-2 -1 0 1 2]));
            
        end
    end
end

function sizeEq(aMat, flag, self)
    import gras.mat.*
    if(flag == 1)
        aMatFun = ConstMatrixFunctionFactory.createInstance(aMat);
    else
        aMatFun = AMatrixOperations.fromSymbMatrix(aMat);
    end
    self.isMatFunSizeEq(aMatFun, aMat);
end