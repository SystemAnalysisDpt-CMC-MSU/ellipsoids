classdef SuiteBasic < mlunitext.test_case
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function testConstMatrixFunction(self)
            import gras.mat.ConstMatrixFunctionFactory;
            %
            testCMat = {zeros(1), zeros(2), zeros(1, 2), zeros(2, 1),...
                zeros(2, 3), zeros(3, 2)};
            fCMat = cellfun(@(x)ConstMatrixFunctionFactory.createInstance(x),...
                testCMat, 'UniformOutput', false);
            testNumGetDimCVec = {1, 2, 1, 1, 2, 2};
            testNumGetNRowsCVec = {1, 2, 1, 2, 2, 3};
            testNumGetNColsCVec = {1, 2, 2, 1, 3, 2};
            testRepCVec = {[1 1 3], [1 1 5], [1 1 1], [1 1 8], [1 1 2],...
                [1 1 3]};
            testEvalCVec = {[1 2 3], [1 2 3 4 5], 1, [1 2 3 4 5 6 7 8],...
                [1 2], [1 2 3]};
            aExpectedCMat = cellfun(@(x, y)repmat(x, y), testCMat, ...
                testRepCVec, 'UniformOutput', false);
            cellfun(@(x, y, z, w, q, v)compareAllSize(x, y, z, w, q, v),...
                fCMat, testNumGetDimCVec, testNumGetNRowsCVec,...
                testNumGetNColsCVec, testEvalCVec, aExpectedCMat,...
                'UniformOutput', false);
            
            argCVec = {'gras.mat.ConstMatrixFunctionFactory.createInstance([])',...
                'gras.mat.ConstMatrixFunctionFactory.createInstance(zeros([2 2 2]))',...
                'gras.mat.ConstMatrixFunctionFactory.createInstance({})',...
                'gras.mat.ConstMatrixFunctionFactory.createInstance({1 2; 3 4})',}; 
            cellfun(@(x)self.runAndCheckError(x, 'CHECKVAR:wrongInput'),...
                argCVec, 'UniformOutput', false);
            
        end
        %
        function testConstRowFunction(self)
            import gras.mat.fcnlib.ConstRowFunction;
            %
            testCMat = {zeros(1), zeros(1, 10)};
            fCMat = cellfun(@(x)ConstRowFunction(x),...
                testCMat, 'UniformOutput', false);
            testNumGetDimCVec = {1, 1};
            testNumGetNRowsCVec = {1, 1};
            testNumGetNColsCVec = {1, 10};
            testRepCVec = {[1 1 3], [1 1 6]};
            testEvalCVec = {[1 2 3], [1 2 3 4 5 6]};
            aExpectedCMat = cellfun(@(x, y)repmat(x, y), testCMat, ...
                testRepCVec, 'UniformOutput', false);
            cellfun(@(x, y, z, w, q, v)compareAllSize(x, y, z, w, q, v),...
                fCMat, testNumGetDimCVec, testNumGetNRowsCVec,...
                testNumGetNColsCVec, testEvalCVec, aExpectedCMat,...
                'UniformOutput', false);
            
            try
                gras.mat.ConstRowFunction([]);
            catch meObj
                disp(meObj.identifier);
            end
            
            argCVec = {'gras.mat.fcnlib.ConstRowFunction([])',...
                'gras.mat.fcnlib.ConstRowFunction(zeros(2))',...
                'gras.mat.fcnlib.ConstRowFunction(zeros(2, 1))',...
                'gras.mat.fcnlib.ConstRowFunction(zeros([2 2 2]))',...
                'gras.mat.fcnlib.ConstRowFunction({})',...
                'gras.mat.fcnlib.ConstRowFunction({1, 2; 3, 4})'}; 
            cellfun(@(x)self.runAndCheckError(x, 'CHECKVAR:wrongInput'),...
                argCVec, 'UniformOutput', false);
               
        end
        %
        function testConstColFunction(self)
            import gras.mat.fcnlib.ConstColFunction;
            %
            testCMat = {zeros(1), zeros(10, 1)};
            fCMat = cellfun(@(x)ConstColFunction(x),...
                testCMat, 'UniformOutput', false);
            testNumGetDimCVec = {1, 1};
            testNumGetNRowsCVec = {1, 10};
            testNumGetNColsCVec = {1, 1};
            testRepCVec = {[1 1 3], [1 1 6]};
            testEvalCVec = {[1 2 3], [1 2 3 4 5 6]};
            aExpectedCMat = cellfun(@(x, y)repmat(x, y), testCMat, ...
                testRepCVec, 'UniformOutput', false);
            cellfun(@(x, y, z, w, q, v)compareAllSize(x, y, z, w, q, v),...
                fCMat, testNumGetDimCVec, testNumGetNRowsCVec,...
                testNumGetNColsCVec, testEvalCVec, aExpectedCMat,...
                'UniformOutput', false);
            argCVec = {'gras.mat.fcnlib.ConstColFunction([])',...
                'gras.mat.fcnlib.ConstColFunction(zeros(2))',...
                'gras.mat.fcnlib.ConstColFunction(zeros(1,2))',...
                'gras.mat.fcnlib.ConstColFunction(zeros([2 2 2]))',...
                'gras.mat.fcnlib.ConstColFunction({})',...
                'gras.mat.fcnlib.ConstColFunction({1, 2; 3, 4})'}; 
            cellfun(@(x)self.runAndCheckError(x, 'CHECKVAR:wrongInput'),...
                argCVec, 'UniformOutput', false);
            
        end
        %
        function testConstMatrixFunctionFactory(self)
            import gras.mat.ConstMatrixFunctionFactory;
            import gras.mat.fcnlib.ConstMatrixFunction;
            import gras.mat.fcnlib.ConstRowFunction;
            import gras.mat.fcnlib.ConstColFunction;
            %
            
            testCMat = {{'1'}, {'1','2';'3','4'}, {'1','2'}, {'1';'2'}};
            fCMat = cellfun(@(x)gras.mat.ConstMatrixFunctionFactory.createInstance(x),...
                testCMat, 'UniformOutput', false);
            aExpectedCMat = {1, [1 2; 3 4], [1 2], [1; 2]};
            flagCVec = {1, 2, 3, 4};
            cellfun(@(x, y, z)compareFun(x, y, z), fCMat, aExpectedCMat,...
                flagCVec, 'UniformOutput', false);
            
            argCVec = {'([])', '({})', '({''t''})', '({1,''t'';1,1})'}; 
            cellfun(@(x)self.runAndCheckError(['gras.mat.ConstMatrixFunctionFactory.createInstance',...
                x], 'CHECKVAR:wrongInput'), argCVec, 'UniformOutput', false);
           
        end
        
    end
end
function compareAllSize(fMat, nDim, nRows, nCols, evalVec, aExpectedMat)
    mlunitext.assert_equals(fMat.getDimensionality, nDim);
    mlunitext.assert_equals(fMat.getNRows, nRows);
    mlunitext.assert_equals(fMat.getNCols, nCols);
    mlunitext.assert_equals(all(fMat.getMatrixSize == [nRows nCols]),...
        true);
    aArrayObtained = fMat.evaluate(evalVec);
    isOkArray = ( aExpectedMat == aArrayObtained );
    mlunitext.assert_equals(all(isOkArray(:)),true);

end

function compareFun(fMat, aExpectedMat, flag)
    if(flag == 1)
        mlunitext.assert_equals(isa(fMat, ...
            'gras.mat.fcnlib.ConstScalarFunction'), true);
    elseif(flag == 2)
        mlunitext.assert_equals(isa(fMat, ...
            'gras.mat.fcnlib.ConstMatrixFunction'), true);
    elseif(flag == 3)
        mlunitext.assert_equals(isa(fMat, ...
            'gras.mat.fcnlib.ConstRowFunction'), true);
    else
        mlunitext.assert_equals(isa(fMat, ...
            'gras.mat.fcnlib.ConstColFunction'), true);
    end
    aMatObtained = fMat.evaluate(0);
    isOkMat = ( aExpectedMat == aMatObtained );
    mlunitext.assert_equals(all(isOkMat(:)),true);
end