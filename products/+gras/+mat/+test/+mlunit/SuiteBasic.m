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
            fMatCArr = cellfun(@(x)ConstMatrixFunctionFactory.createInstance(x),...
                testCMat, 'UniformOutput', false);
            testCNumGetDim = {1, 2, 1, 1, 2, 2};
            testCNumGetNRows = {1, 2, 1, 2, 2, 3};
            testCNumGetNCols = {1, 2, 2, 1, 3, 2};
            testRepCVec = {[1 1 3], [1 1 5], [1 1 1], [1 1 8], [1 1 2],...
                [1 1 3]};
            testEvalCVec = {[1 2 3], [1 2 3 4 5], 1, [1 2 3 4 5 6 7 8],...
                [1 2], [1 2 3]};
            aMatCArrExpected = cellfun(@(x, y)repmat(x, y), testCMat, ...
                testRepCVec, 'UniformOutput', false);
            cellfun(@(x, y, z, w, q, v)compareAllSize(x, y, z, w, q, v),...
                fMatCArr, testCNumGetDim, testCNumGetNRows,...
                testCNumGetNCols, testEvalCVec, aMatCArrExpected,...
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
            fMatCArr = cellfun(@(x)ConstRowFunction(x),...
                testCMat, 'UniformOutput', false);
            testCNumGetDim = {1, 1};
            testCNumGetNRows = {1, 1};
            testCNumGetNCols = {1, 10};
            testRepCVec = {[1 1 3], [1 1 6]};
            testEvalCVec = {[1 2 3], [1 2 3 4 5 6]};
            aMatCArrExpected = cellfun(@(x, y)repmat(x, y), testCMat, ...
                testRepCVec, 'UniformOutput', false);
            cellfun(@(x, y, z, w, q, v)compareAllSize(x, y, z, w, q, v),...
                fMatCArr, testCNumGetDim, testCNumGetNRows,...
                testCNumGetNCols, testEvalCVec, aMatCArrExpected,...
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
            fMatCArr = cellfun(@(x)ConstColFunction(x),...
                testCMat, 'UniformOutput', false);
            testCNumGetDim = {1, 1};
            testCNumGetNRows = {1, 10};
            testCNumGetNCols = {1, 1};
            testRepCVec = {[1 1 3], [1 1 6]};
            testEvalCVec = {[1 2 3], [1 2 3 4 5 6]};
            aMatCArrExpected = cellfun(@(x, y)repmat(x, y), testCMat, ...
                testRepCVec, 'UniformOutput', false);
            cellfun(@(x, y, z, w, q, v)compareAllSize(x, y, z, w, q, v),...
                fMatCArr, testCNumGetDim, testCNumGetNRows,...
                testCNumGetNCols, testEvalCVec, aMatCArrExpected,...
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
            
            testCVec = {{'1'}, {'1','2';'3','4'}, {'1','2'}, {'1';'2'}};
            fMatCArr = cellfun(@(x)gras.mat.ConstMatrixFunctionFactory.createInstance(x),...
                testCVec, 'UniformOutput', false);
            aMatExpectedCVec = {1, [1 2; 3 4], [1 2], [1; 2]};
            flagCVec = {1, 2, 3, 4};
            cellfun(@(x, y, z)compareFun(x, y, z), fMatCArr, aMatExpectedCVec,...
                flagCVec, 'UniformOutput', false);
            
            argCVec = {'([])', '({})', '({''t''})', '({1,''t'';1,1})'}; 
            cellfun(@(x)self.runAndCheckError(['gras.mat.ConstMatrixFunctionFactory.createInstance',...
                x], 'CHECKVAR:wrongInput'), argCVec, 'UniformOutput', false);
           
        end
        
    end
end
function compareAllSize(f, nDim, nRows, nCols, evalVec, aArrayExpected)
    mlunitext.assert_equals(f.getDimensionality, nDim);
    mlunitext.assert_equals(f.getNRows, nRows);
    mlunitext.assert_equals(f.getNCols, nCols);
    mlunitext.assert_equals(all(f.getMatrixSize == [nRows nCols]),...
        true);
    aArrayObtained = f.evaluate(evalVec);
    isOkArray = ( aArrayExpected == aArrayObtained );
    mlunitext.assert_equals(all(isOkArray(:)),true);

end

function compareFun(f, aMatExpected, flag)
    if(flag == 1)
        mlunitext.assert_equals(isa(f, ...
            'gras.mat.fcnlib.ConstScalarFunction'), true);
    elseif(flag == 2)
        mlunitext.assert_equals(isa(f, ...
            'gras.mat.fcnlib.ConstMatrixFunction'), true);
    elseif(flag == 3)
        mlunitext.assert_equals(isa(f, ...
            'gras.mat.fcnlib.ConstRowFunction'), true);
    else
        mlunitext.assert_equals(isa(f, ...
            'gras.mat.fcnlib.ConstColFunction'), true);
    end
    aMatObtained = f.evaluate(0);
    isOkMat = ( aMatExpected == aMatObtained );
    mlunitext.assert_equals(all(isOkMat(:)),true);
end