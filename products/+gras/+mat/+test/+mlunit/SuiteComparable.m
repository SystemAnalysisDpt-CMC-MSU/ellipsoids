classdef SuiteComparable < mlunitext.test_case
    
    properties
    end
    
    methods
        function self = SuiteComparable(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function testMatrixFunctionComparableConstMatrix(self)
            %
            m1 = [1 2; 3 0];
            m2 = [1 2; 3 0];
            actSolution = isequal(m1,m2);
            expSolution = 1;
            mlunitext.assert_equals(actSolution,expSolution);
            %
            m1 = [1 3; 9 1];
            m2 = [2 6; 3 1];
            actSolution = isequal(m1,m2);
            expSolution = 0;
            mlunitext.assert_equals(actSolution,expSolution);
            %
            m1 = ones(3);
            m2 = ones(2);
            actSolution = isequal(m1,m2);
            expSolution = 0;
            mlunitext.assert_equals(actSolution,expSolution);            
            
        end
        
        function testMatrixFunctionComparableConstArray(self)
            %
            a1 = [1 3 4 6 20 183];
            a2 = [1 3 4 6 20 183];
            actSolution = isequal(a1,a2);
            expSolution = 1;
            mlunitext.assert_equals(actSolution,expSolution);
            
            %
            s1 = ['s' 'a'];
            s2 = ['s' 'a'];
            actSolution = isequal(a1,a2);
            expSolution = 1;
            mlunitext.assert_equals(actSolution,expSolution);
        end
        
        function testProjArrayFunction(self)
            import gras.mat.ProjArrayFunction;
            timeVec = 0:0.1:2;
            fProjFunction = @(x) x.^2;
            projMat = ones(2);
            sTime = 1;
            dim = 2;
            indSTime = 1;
            
            m1 = ProjArrayFunction(projMat,timeVec,sTime,dim,...
                indSTime,fProjFunction);
            m2 = ProjArrayFunction(projMat,timeVec,sTime,dim,...
                indSTime,fProjFunction);
            actSolution = isequal(m1,m2);
            expSolution = 1;
            mlunitext.assert_equals(actSolution,expSolution);
            
        end
        
        function testProjOrthArrayFunction(self)
            import gras.mat.ProjOrthArrayFunction;
            timeVec1 = 0:0.1:2;
            projArrayFunc1 = @(x) x.^2;
            m1 = ProjOrthArrayFunction(projArrayFunc1,timeVec1);
            m2 = ProjOrthArrayFunction(projArrayFunc1,timeVec1);
            actSolution = isequal(m1,m2);
            expSolution = 1;
            mlunitext.assert_equals(actSolution,expSolution);
        end
        
        function testMatrixLtGoodDirNormFunc(self)
            absTol = 1e-10;
           import gras.mat.MatrixLtGoodDirNormFunc;
           inpArray(:,:,1)=[1 2;3 4];
           inpArray(:,:,2)=inpArray(:,:,1)*2;
           inpArray(:,:,3)=inpArray(:,:,1)*3;
           timeVec=[-1 3 7]+0.1;
           intObj=gras.mat.interp.MatrixInterpolantFactory.createInstance(...
                'linear',inpArray,timeVec);
           m1 = MatrixLtGoodDirNormFunc(intObj,absTol);
           m2 = MatrixLtGoodDirNormFunc(intObj,absTol);
           actSolution = isequal(m1,m2);
           expSolution = 1;
           mlunitext.assert_equals(actSolution,expSolution);
        end
    end
    
end

