classdef SuiteBasic < mlunitext.test_case
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function testConstMatrixFunction(self)
            import gras.mat.ConstMatrixFunctionFactory;
            %
            f = ConstMatrixFunctionFactory.createInstance(zeros(1));
            mlunitext.assert_equals(f.getDimensionality,1);
            mlunitext.assert_equals(f.getNRows,1);
            mlunitext.assert_equals(f.getNCols,1);
            mlunitext.assert_equals(all(f.getMatrixSize == [1 1]), true);
            aArrayExpected = repmat(zeros(1), [1 1 3]);
            aArrayObtained = f.evaluate([1 2 3]);
            isOkArray = ( aArrayExpected == aArrayObtained );
            mlunitext.assert_equals(all(isOkArray(:)),true);
            %
            f = ConstMatrixFunctionFactory.createInstance(zeros(2));
            mlunitext.assert_equals(f.getDimensionality,2);
            mlunitext.assert_equals(f.getNRows,2);
            mlunitext.assert_equals(f.getNCols,2);
            mlunitext.assert_equals(all(f.getMatrixSize == [2 2]), true);
            aArrayExpected = repmat(zeros(2), [1 1 5]);
            aArrayObtained = f.evaluate([1 2 3 4 5]);
            isOkArray = ( aArrayExpected == aArrayObtained );
            mlunitext.assert_equals(all(isOkArray(:)),true);
            %
            f = ConstMatrixFunctionFactory.createInstance(zeros(1,2));
            mlunitext.assert_equals(f.getDimensionality,1);
            mlunitext.assert_equals(f.getNRows,1);
            mlunitext.assert_equals(f.getNCols,2);
            mlunitext.assert_equals(all(f.getMatrixSize == [1 2]), true);
            aArrayExpected = repmat(zeros(1,2), [1 1 1]);
            aArrayObtained = f.evaluate(1);
            isOkArray = ( aArrayExpected == aArrayObtained );
            mlunitext.assert_equals(all(isOkArray(:)),true);
            %
            f = ConstMatrixFunctionFactory.createInstance(zeros(2,1));
            mlunitext.assert_equals(f.getDimensionality,1);
            mlunitext.assert_equals(f.getNRows,2);
            mlunitext.assert_equals(f.getNCols,1);
            mlunitext.assert_equals(all(f.getMatrixSize == [2 1]), true);
            aArrayExpected = repmat(zeros(2,1), [1 1 8]);
            aArrayObtained = f.evaluate([1 2 3 4 5 6 7 8]);
            isOkArray = ( aArrayExpected == aArrayObtained );
            mlunitext.assert_equals(all(isOkArray(:)),true);
            %
            f = ConstMatrixFunctionFactory.createInstance(zeros(2,3));
            mlunitext.assert_equals(f.getDimensionality,2);
            mlunitext.assert_equals(f.getNRows,2);
            mlunitext.assert_equals(f.getNCols,3);
            mlunitext.assert_equals(all(f.getMatrixSize == [2 3]), true);
            aArrayExpected = repmat(zeros(2,3), [1 1 2]);
            aArrayObtained = f.evaluate([1 2]);
            isOkArray = ( aArrayExpected == aArrayObtained );
            mlunitext.assert_equals(all(isOkArray(:)),true);
            %
            f = ConstMatrixFunctionFactory.createInstance(zeros(3,2));
            mlunitext.assert_equals(f.getDimensionality,2);
            mlunitext.assert_equals(f.getNRows,3);
            mlunitext.assert_equals(f.getNCols,2);
            mlunitext.assert_equals(all(f.getMatrixSize == [3 2]), true);
            aArrayExpected = repmat(zeros(3,2), [1 1 3]);
            aArrayObtained = f.evaluate([1 2 3]);
            isOkArray = ( aArrayExpected == aArrayObtained );
            mlunitext.assert_equals(all(isOkArray(:)),true);
            %
            self.runAndCheckError([...
                'gras.mat.ConstMatrixFunctionFactory.createInstance', ...
                '([])'], 'CHECKVAR:wrongInput');
            %
            self.runAndCheckError([...
                'gras.mat.ConstMatrixFunctionFactory.createInstance', ...
                '(zeros([2 2 2]))'], 'CHECKVAR:wrongInput');
            %
            self.runAndCheckError([...
                'gras.mat.ConstMatrixFunctionFactory.createInstance', ...
                '({})'], 'CHECKVAR:wrongInput');
            %
            self.runAndCheckError([...
                'gras.mat.ConstMatrixFunctionFactory.createInstance', ...
                '({1,2;3,4})'], 'CHECKVAR:wrongInput');
            %
        end
        function testConstRowFunction(self)
            import gras.mat.fcnlib.ConstRowFunction;
            %
            f = ConstRowFunction(zeros(1));
            mlunitext.assert_equals(f.getDimensionality,1);
            mlunitext.assert_equals(f.getNRows,1);
            mlunitext.assert_equals(f.getNCols,1);
            mlunitext.assert_equals(all(f.getMatrixSize == [1 1]), true);
            aArrayExpected = repmat(zeros(1), [1 1 3]);
            aArrayObtained = f.evaluate([1 2 3]);
            isOkArray = ( aArrayExpected == aArrayObtained );
            mlunitext.assert_equals(all(isOkArray(:)),true);
            %
            f = ConstRowFunction(zeros(1,10));
            mlunitext.assert_equals(f.getDimensionality,1);
            mlunitext.assert_equals(f.getNRows,1);
            mlunitext.assert_equals(f.getNCols,10);
            mlunitext.assert_equals(all(f.getMatrixSize == [1 10]), true);
            aArrayExpected = repmat(zeros(1,10), [1 1 6]);
            aArrayObtained = f.evaluate([1 2 3 4 5 6]);
            isOkArray = ( aArrayExpected == aArrayObtained );
            mlunitext.assert_equals(all(isOkArray(:)),true);
            %
            try
                gras.mat.ConstRowFunction([]);
            catch meObj
                disp(meObj.identifier);
            end
               
            self.runAndCheckError(...
                'gras.mat.fcnlib.ConstRowFunction([])', ...
                'CHECKVAR:wrongInput');
            %
            self.runAndCheckError(...
                'gras.mat.fcnlib.ConstRowFunction(zeros(2))', ...
                'CHECKVAR:wrongInput');
            %
            self.runAndCheckError(...
                'gras.mat.fcnlib.ConstRowFunction(zeros(2,1))', ...
                'CHECKVAR:wrongInput');
            %
            self.runAndCheckError(...
                'gras.mat.fcnlib.ConstRowFunction(zeros([2 2 2]))', ...
                'CHECKVAR:wrongInput');
            %
            self.runAndCheckError(...
                'gras.mat.fcnlib.ConstRowFunction({})', ...
                'CHECKVAR:wrongInput');
            %
            self.runAndCheckError(...
                'gras.mat.fcnlib.ConstRowFunction({1,2;3,4})', ...
                'CHECKVAR:wrongInput');
            %
        end
        function testConstColFunction(self)
            import gras.mat.fcnlib.ConstColFunction;
            %
            f = ConstColFunction(zeros(1));
            mlunitext.assert_equals(f.getDimensionality,1);
            mlunitext.assert_equals(f.getNRows,1);
            mlunitext.assert_equals(f.getNCols,1);
            mlunitext.assert_equals(all(f.getMatrixSize == [1 1]), true);
            aArrayExpected = repmat(zeros(1), [1 1 3]);
            aArrayObtained = f.evaluate([1 2 3]);
            isOkArray = ( aArrayExpected == aArrayObtained );
            mlunitext.assert_equals(all(isOkArray(:)),true);
            %
            f = ConstColFunction(zeros(10,1));
            mlunitext.assert_equals(f.getDimensionality,1);
            mlunitext.assert_equals(f.getNRows,10);
            mlunitext.assert_equals(f.getNCols,1);
            mlunitext.assert_equals(all(f.getMatrixSize == [10 1]), true);
            aArrayExpected = repmat(zeros(10,1), [1 1 6]);
            aArrayObtained = f.evaluate([1 2 3 4 5 6]);
            isOkArray = ( aArrayExpected == aArrayObtained );
            mlunitext.assert_equals(all(isOkArray(:)),true);
            %
            self.runAndCheckError(...
                'gras.mat.fcnlib.ConstColFunction([])', ...
                'CHECKVAR:wrongInput');
            %
            self.runAndCheckError(...
                'gras.mat.fcnlib.ConstColFunction(zeros(2))', ...
                'CHECKVAR:wrongInput');
            %
            self.runAndCheckError(...
                'gras.mat.fcnlib.ConstColFunction(zeros(1,2))', ...
                'CHECKVAR:wrongInput');
            %
            self.runAndCheckError(...
                'gras.mat.fcnlib.ConstColFunction(zeros([2 2 2]))', ...
                'CHECKVAR:wrongInput');
            %
            self.runAndCheckError(...
                'gras.mat.fcnlib.ConstColFunction({})', ...
                'CHECKVAR:wrongInput');
            %
            self.runAndCheckError(...
                'gras.mat.fcnlib.ConstRowFunction({1,2;3,4})', ...
                'CHECKVAR:wrongInput');
            %
        end
        function testConstMatrixFunctionFactory(self)
            import gras.mat.ConstMatrixFunctionFactory;
            import gras.mat.fcnlib.ConstMatrixFunction;
            import gras.mat.fcnlib.ConstRowFunction;
            import gras.mat.fcnlib.ConstColFunction;
            %
            f = gras.mat.ConstMatrixFunctionFactory.createInstance(...
                {'1'});
            mlunitext.assert_equals(isa(f, ...
                'gras.mat.fcnlib.ConstScalarFunction'), true);
            aMatExpected = 1;
            aMatObtained = f.evaluate(0);
            isOkMat = ( aMatExpected == aMatObtained );
            mlunitext.assert_equals(all(isOkMat(:)),true);
            %
            f = gras.mat.ConstMatrixFunctionFactory.createInstance(...
                {'1','2';'3','4'});
            mlunitext.assert_equals(isa(f, ...
                'gras.mat.fcnlib.ConstMatrixFunction'), true);
            aMatExpected = [1 2; 3 4];
            aMatObtained = f.evaluate(0);
            isOkMat = ( aMatExpected == aMatObtained );
            mlunitext.assert_equals(all(isOkMat(:)),true);
            %
            f = gras.mat.ConstMatrixFunctionFactory.createInstance(...
                {'1','2'});
            mlunitext.assert_equals(isa(f, ...
                'gras.mat.fcnlib.ConstRowFunction'), true);
            aMatExpected = [1 2];
            aMatObtained = f.evaluate(0);
            isOkMat = ( aMatExpected == aMatObtained );
            mlunitext.assert_equals(all(isOkMat(:)),true);
            %
            f = gras.mat.ConstMatrixFunctionFactory.createInstance(...
                {'1';'2'});
            mlunitext.assert_equals(isa(f, ...
                'gras.mat.fcnlib.ConstColFunction'), true);
            aMatExpected = [1; 2];
            aMatObtained = f.evaluate(0);
            isOkMat = ( aMatExpected == aMatObtained );
            mlunitext.assert_equals(all(isOkMat(:)),true);
            %
            self.runAndCheckError([...
                'gras.mat.ConstMatrixFunctionFactory.createInstance', ...
                '([])'], 'CHECKVAR:wrongInput');
            %
            self.runAndCheckError([...
                'gras.mat.ConstMatrixFunctionFactory.createInstance', ...
                '({})'], 'CHECKVAR:wrongInput');
            %
            self.runAndCheckError([...
                'gras.mat.ConstMatrixFunctionFactory.createInstance', ...
                '({''t''})'], 'CHECKVAR:wrongInput');
            %
            self.runAndCheckError([...
                'gras.mat.ConstMatrixFunctionFactory.createInstance', ...
                '({1,''t'';1,1})'], 'CHECKVAR:wrongInput');
            %
        end
    end
end