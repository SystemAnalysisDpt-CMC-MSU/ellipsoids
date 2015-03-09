classdef SuiteComparable < mlunitext.test_case
    
    properties
    end
    
    methods
        function self = SuiteComparable(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function testMatrixFunctionComparableConstMatrix(self)
            %
            mMat = [1 2; 3 0];
            otherMat = [1 2; 3 0];
            isOk = isequal(mMat,otherMat);
            expSolution = true;
            mlunitext.assert_equals(isOk,expSolution);
            %
            mMat = [1 3; 9 1];
            otherMat = [2 6; 3 1];
            isOk = isequal(mMat,otherMat);
            expSolution = false;
            mlunitext.assert_equals(isOk,expSolution);
            %
            mMat = ones(3);
            otherMat = ones(2);
            isOk = isequal(mMat,otherMat);
            expSolution = false;
            mlunitext.assert_equals(isOk,expSolution);            
            
        end
        
        function testMatrixFunctionComparableConstArray(self)
            %
            aVec = [1 3 4 6 20 183];
            otherVec = [1 3 4 6 20 183];
            isOk = isequal(aVec,otherVec);
            expSolution = true;
            mlunitext.assert_equals(isOk,expSolution);
            
            %
            sVec = ['s' 'a'];
            otherVec = ['s' 'a'];
            isOk = isequal(sVec,otherVec);
            expSolution = true;
            mlunitext.assert_equals(isOk,expSolution);
        end
        
        function testProjArrayFunction(self)
            import gras.mat.ProjArrayFunction;
            timeVec = 0:0.1:2;
            fProjFunc = @(x) x.^2;
            projMat = ones(2);
            sTime = 1;
            dimNum = 2;
            indSTime = 1;
            
            mMat = ProjArrayFunction(projMat,timeVec,sTime,dimNum,...
                indSTime,fProjFunc);
            otherMat = ProjArrayFunction(projMat,timeVec,sTime,dimNum,...
                indSTime,fProjFunc);
            isOk = isequal(mMat,otherMat);
            expSolution = true;
            mlunitext.assert_equals(isOk,expSolution);
            
        end
        
        function testProjOrthArrayFunction(self)
            import gras.mat.ProjOrthArrayFunction;
            timeVec = 0:0.1:2;
            projArrayFunc1 = @(x) x.^2;
            mMat = ProjOrthArrayFunction(projArrayFunc1,timeVec);
            otherMat = ProjOrthArrayFunction(projArrayFunc1,timeVec);
            isOk = isequal(mMat,otherMat);
            expSolution = true;
            mlunitext.assert_equals(isOk,expSolution);
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
           mMat = MatrixLtGoodDirNormFunc(intObj,absTol);
           otherMat = MatrixLtGoodDirNormFunc(intObj,absTol);
           isOk = isequal(mMat,otherMat);
           expSolution = true;
           mlunitext.assert_equals(isOk,expSolution);
        end
    end
    
end

