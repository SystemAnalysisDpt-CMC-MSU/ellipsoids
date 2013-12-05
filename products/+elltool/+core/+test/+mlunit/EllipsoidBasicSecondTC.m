classdef EllipsoidBasicSecondTC < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
    end    
    properties
        ellFactoryObj
    end
    methods
        function self = testGetBoundary(self)            
            [testEllCVec testNumPointsCVec]  = self.getEllParams(1);
            [bpCMat fCMat] = cellfun(@(x,y)getBoundary(x,y),testEllCVec,...
                testNumPointsCVec, 'UniformOutput', false);
            bpRightCMat = {[1 0; 0.5 sqrt(3) / 2; -0.5 sqrt(3) / 2; -1 0;...
                -0.5 -sqrt(3) / 2; 0.5 -sqrt(3) / 2],...
                [2 0; 1.5 sqrt(3) / 2; 0.5 sqrt(3) / 2; 0 0;...
                0.5 -sqrt(3) / 2; 1.5 -sqrt(3) / 2],...
                [0 0; 0 0; 0 0; 0 0; 0 0; 0 0],...
                [4 1; 3 sqrt(3) + 1; 1 sqrt(3)+1; 0 1; 1 -sqrt(3) + 1;...
                3 -sqrt(3) + 1]};
            fRightCMat = repmat({[1 2; 2 3; 3 4; 4 5; 5 6; 6 1]}, 1, 4);
            isOk = compareCells(bpCMat, fCMat, bpRightCMat, fRightCMat);
            mlunitext.assert(isOk);
            
        end
        function self = set_up_param(self, ellFactoryObj)
            self.ellFactoryObj = ellFactoryObj;
        end
        function self = testGetBoundaryByFactor(self)
          [testEllCVec testNumPointsCVec]  = self.getEllParams(1);         
          [bpCMat fCMat] = cellfun(@(x, y)getBoundaryByFactor(x, y),testEllCVec,...
              testNumPointsCVec, 'UniformOutput', false);
          testNumRightPointsCVec = {1200, 1200, 1200, 1200};
          [bpRightCMat fRightCMat] = cellfun(@(x, y)getBoundary(x, y),...
              testEllCVec, testNumRightPointsCVec, 'UniformOutput', false);
          isOk = compareCells(bpCMat, fCMat, bpRightCMat, fRightCMat);
          mlunitext.assert(isOk);
            
        end
        
        function self = testGetRhoBoundary(self)
            [testEllCVec testNumPointsCVec]  = self.getEllParams(2);
            
            [bpMatCArr fMatCArr supCVec lGridCMat] = cellfun(@(x, y)getRhoBoundary(x, y)...
                ,testEllCVec, testNumPointsCVec, 'UniformOutput', false);
            
            [bpRightMatCArr fRightMatCArr] = cellfun(@(x, y)getBoundary(x, y),...
                testEllCVec, testNumPointsCVec, 'UniformOutput', false);
            
            bpRightMatCArr = {[bpRightMatCArr{1, 1}; bpRightMatCArr{1, 1}(1, :)],...
                [bpRightMatCArr{1, 2}; bpRightMatCArr{1, 2}(1, :)],...
                [bpRightMatCArr{1, 3}; bpRightMatCArr{1, 3}(1, :)],...
                [bpRightMatCArr{1, 4}; bpRightMatCArr{1, 4}(1, :)]};
            
            [supRightCVec lGridRightCMat] = cellfun(@(x, y)rhofun(x, y),...
                testEllCVec, bpRightMatCArr, 'UniformOutput', false);
             
            isOk = isequal([bpMatCArr fMatCArr supCVec lGridCMat],...
                [bpRightMatCArr fRightMatCArr supRightCVec lGridRightCMat]);
            mlunitext.assert(isOk);
            
            function [supRightVec lGridRightMat] = rhofun(testEll, bpRightMat)
                [cenMat, ~] = double(testEll);
                cenMat = repmat(cenMat.', size(bpRightMat, 1), 1);
                lGridRightMat = bpRightMat - cenMat;
                supRightVec = (rho(testEll, lGridRightMat.')).';
            end
            
        end
        
        function self = testGetRhoBoundaryByFactor(self)
            [testEllCVec testNumPointsCVec]  = self.getEllParams(2);
            
            [bpMatCArr fMatCArr supCVec lGridCMat] = cellfun(@(x, y)getRhoBoundaryByFactor(x, y),...
                testEllCVec, testNumPointsCVec, 'UniformOutput', false);
            
            testNumRightPointsCVec = {2000, 4000, 7000, 1000};
            
            [bpRightMatCArr fRightMatCArr, supRightCVec, lGridRightCMat] = ...
                cellfun(@(x, y)getRhoBoundary(x, y), testEllCVec, testNumRightPointsCVec,...
                'UniformOutput', false);
            isOk = isequal([bpMatCArr fMatCArr supCVec lGridCMat],...
                [bpRightMatCArr fRightMatCArr, supRightCVec, lGridRightCMat]);
            mlunitext.assert(isOk);   
            
        end
        
        function self = testNegBoundary(self)
            checkDim(self);
            checkScal(self);
            
            function checkDim (self)
                self.runAndCheckError(@checkDimGB, 'wrongDim');
                self.runAndCheckError(@checkDimGBBF, 'wrongDim');
                self.runAndCheckError(@checkDimGRB, 'wrongDim');
                self.runAndCheckError(@checkDimGRBBF, 'wrongDim');
                
                function checkDimGB()
                    ellObj = self.ellFactoryObj.create(eye(4));
                    getBoundary(ellObj);
                end
                function checkDimGBBF()
                    ellObj = self.ellFactoryObj.create(eye(4));
                    getBoundaryByFactor(ellObj);
                end
                function checkDimGRB()
                    ellObj = self.ellFactoryObj.create(eye(4));
                    getRhoBoundary(ellObj);
                end
                function checkDimGRBBF()
                    ellObj = self.ellFactoryObj.create(eye(4));
                    getRhoBoundaryByFactor(ellObj);
                end
                
            end
            
            function checkScal(self)
                self.runAndCheckError(@checkScalGB, 'wrongInput');
                self.runAndCheckError(@checkScalGBBF, 'wrongInput');
                self.runAndCheckError(@checkScalGRB, 'wrongInput');
                self.runAndCheckError(@checkScalGRBBF, 'wrongInput');
                
                function checkScalGB()
                    ellVec = [self.ellFactoryObj.create([1; 3], eye(2))...
                        self.ellFactoryObj.create([2; 5], [4 1; 1 1])];
                    getBoundary(ellVec);
                end
                function checkScalGBBF()
                    ellVec = [self.ellFactoryObj.create([1; 3], eye(2))...
                        self.ellFactoryObj.create([2; 5], [4 1; 1 1])];
                    getBoundaryByFactor(ellVec);
                end
                function checkScalGRB()
                    ellVec = [self.ellFactoryObj.create([1; 3], eye(2))...
                        self.ellFactoryObj.create([2; 5], [4 1; 1 1])];
                    getRhoBoundary(ellVec);
                end
                function checkScalGRBBF()
                    ellVec = [self.ellFactoryObj.create([1; 3], eye(2))...
                        self.ellFactoryObj.create([2; 5], [4 1; 1 1])];
                    getRhoBoundaryByFactor(ellVec);
                end
            end
        end
        
        
        function self=EllipsoidBasicSecondTC(varargin)
            self=self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData', filesep,shortClassName];
        end
        %
        function self = testUminus(self)
            test1Ell = self.ellFactoryObj.create([0; 0], [1 0; 0 1]);
            test2Ell = self.ellFactoryObj.create([1; 0], [1 0; 0 1]);
            test3Ell = self.ellFactoryObj.create([1; 0], [2 0; 0 1]);
            test4Ell = self.ellFactoryObj.create([0; 0], [0 0; 0 0]);
            test5Ell = self.ellFactoryObj.create([0; 0; 0], [0 0 0 ;0 0 0; 0 0 0]);
            test6Ell = self.ellFactoryObj.create;
            test7Ell = self.ellFactoryObj.create([2; 1], [3 1; 1 1]);
            test8Ell = self.ellFactoryObj.create([1; 1], [1 0; 0 1]);
            %
            checkCenterVecList = {[-1 0]'};
            operationCheckEqFunc(test2Ell, checkCenterVecList,'uminus');
            %
            testEllVec = [test1Ell test2Ell test3Ell];
            checkCenterVecList = {[0; 0], [-1; 0], [-1; 0]};
            operationCheckEqFunc(testEllVec, checkCenterVecList,'uminus');
            %
            testEllMat = [test1Ell test2Ell; test3Ell test4Ell];
            checkCenterVecList = {[0; 0],[-1; 0];[-1; 0],[0; 0]};
            operationCheckEqFunc(testEllMat, checkCenterVecList,'uminus');
            %
            testEllVec = [test1Ell test2Ell test3Ell test4Ell test5Ell ...
                test6Ell test7Ell test8Ell];
            testEllArr = reshape(testEllVec, [2 2 2]);
            checkCenterVecList = cell(2,2,2);
            checkCenterVecList{1,1,1} = [0; 0];
            checkCenterVecList{1,1,2} = [0; 0; 0];
            checkCenterVecList{1,2,1} = [-1; 0];
            checkCenterVecList{1,2,2} = [-2; -1];
            checkCenterVecList{2,1,1} = [-1; 0];
            checkCenterVecList{2,1,2} = [];
            checkCenterVecList{2,2,1} = [0; 0];
            checkCenterVecList{2,2,2} = [-1; -1];
            operationCheckEqFunc(testEllArr, checkCenterVecList, 'uminus');
            %
            testEllCenterVec = zeros(1, 100);
            testEllCenterVec(50) = 1;
            testEllMat = eye(100, 100);
            testEll = self.ellFactoryObj.create(testEllCenterVec', testEllMat);
            testResVec = zeros(1, 100);
            testResVec(50) = -1;
            checkCenterVecList = {testResVec'};
            operationCheckEqFunc(testEll, checkCenterVecList, 'uminus');
            %
            self.emptyTest('uminus',[0,0,2,0]);
        end
        function self = testPlus(self)
            testEllCenterVec = 5;
            testEllMat = 3;
            testEll = self.ellFactoryObj.create(testEllCenterVec, testEllMat);
            testVec = 'a';
            self.runAndCheckError('plus(testEll, testVec)','wrongInput');
            %
            test1EllCenterVec = [5; 7];
            test2EllCenterVec = 2;
            test1EllMat = [3 0; 0 1];
            test2EllMat = 4;
            test1Ell = self.ellFactoryObj.create(test1EllCenterVec, test1EllMat);
            test2Ell = self.ellFactoryObj.create(test2EllCenterVec, test2EllMat);
            testEllVec = [test1Ell, test2Ell];
            testVec = [2; 4];
            self.runAndCheckError('plus(testEllVec, testVec)','wrongInput');
            %
            test1EllCenterVec = [1; 0];
            test2EllCenterVec = [7; 2];
            test1EllMat = [1 0; 0 5];
            test2EllMat = [3 0; 0 2];
            test1Ell = self.ellFactoryObj.create(test1EllCenterVec, test1EllMat);
            test2Ell = self.ellFactoryObj.create(test2EllCenterVec, test2EllMat);
            testEllVec = [test1Ell, test2Ell];
            testVec = [2; 4; 1];
            self.runAndCheckError('plus(testEllVec, testVec)','wrongInput');
            %
            testEllCenterVec = [-1; 5];
            testEllMat = [1 0; 0 1];
            testVec = [5; 3];
            testEll = self.ellFactoryObj.create(testEllCenterVec, testEllMat*testEllMat');
            checkCenterVecList = {[4; 8]};
            operationCheckEqFunc(testEll, checkCenterVecList, 'plus', testVec);
            %
            test1EllCenterVec = 5;
            test1EllMat = 4;
            test1Vec = 3;
            test1Ell = self.ellFactoryObj.create(test1EllCenterVec, test1EllMat*test1EllMat');
            checkCenterVecList = {8};
            operationCheckEqFunc(test1Ell, checkCenterVecList, 'plus', test1Vec);
            %
            test2EllCenterVec = [2; 4; 1];
            test2EllMat = [2 2 1; 7 0 1; 0 1 8];
            test2Vec = [1; 2; 3];
            test2Ell = self.ellFactoryObj.create(test2EllCenterVec, test2EllMat*test2EllMat');
            checkCenterVecList = {[3; 6; 4]};
            operationCheckEqFunc(test2Ell, checkCenterVecList, 'plus', test2Vec);
            %
            test1EllCenterVec = [1; 2];
            test2EllCenterVec = [2; 3];
            test1EllMat = eye(2);
            test2EllMat = [2 0; 0 5];
            testVec = [2; 4];
            test1Ell = self.ellFactoryObj.create(test1EllCenterVec, test1EllMat);
            test2Ell = self.ellFactoryObj.create(test2EllCenterVec, test2EllMat);
            testEllVec = [test1Ell test2Ell];
            checkCenterVecList = {[3; 6], [4; 7]};
            operationCheckEqFunc(testEllVec, checkCenterVecList, 'plus', testVec);
            %
            testEll = self.ellFactoryObj.create(eye(2,2));
            testEllArr = testEll.repMat([2,2,3,4]);
            testVec = [2;1];
            checkCenterVecList = repmat({testVec},[2,2,3,4]);
            operationCheckEqFunc(testEllArr, checkCenterVecList, 'plus', testVec);
            %
            testEllCenterVec = zeros(1, 100);
            testEllCenterVec(50) = 3;
            testEllMat = eye(100);
            testEll = self.ellFactoryObj.create(testEllCenterVec', testEllMat);
            testVec = zeros(1, 100)';
            testVec(100) = 3;
            testCheckVec = zeros(1,100);
            testCheckVec(50) = 3;
            testCheckVec(100) = 3;
            checkCenterVecList = {testCheckVec'};
            operationCheckEqFunc(testEll, checkCenterVecList, 'plus', testVec);
            %
            self.emptyTest('plus',[0,0,2,0],testVec);
        end
        function self = testMinus(self)
            testEllCenterVec = 5;
            testEllMat = 1;
            testEll = self.ellFactoryObj.create(testEllCenterVec, testEllMat);
            testWrongVec = [0; 'a'];
            self.runAndCheckError('minus(testEll, testWrongVec)','wrongInput');
            %
            test1EllCenterVec = [1; 0];
            test2EllCenterVec = 1;
            test1EllMat = [1 0; 0 1];
            test2EllMat = 2;
            test1Ell = self.ellFactoryObj.create(test1EllCenterVec, test1EllMat);
            test2Ell = self.ellFactoryObj.create(test2EllCenterVec, test2EllMat);
            testEllVec = [test1Ell, test2Ell];
            testVec = [1; 2];
            self.runAndCheckError('minus(testEllVec, testVec)','wrongInput');
            %
            test1EllCenterVec = [2; 3];
            test2EllCenterVec = [5; 7];
            test1EllMat = [2 0; 0 2];
            test2EllMat = [1 0; 0 1];
            test1Ell = self.ellFactoryObj.create(test1EllCenterVec, test1EllMat);
            test2Ell = self.ellFactoryObj.create(test2EllCenterVec, test2EllMat);
            testEllVec = [test1Ell, test2Ell];
            testVec = [1; 2; 3];
            self.runAndCheckError('minus(testEllVec, testVec)','wrongInput');
            %
            test1EllCenterVec = [1; 2];
            test2EllCenterVec = [3; 4];
            test1EllMat = eye(2);
            test2EllMat = [2 0; 0 1];
            test1Ell = self.ellFactoryObj.create(test1EllCenterVec, test1EllMat);
            test2Ell = self.ellFactoryObj.create(test2EllCenterVec, test2EllMat);
            testEllVec = [test1Ell test2Ell];
            testVec = [1; 3];
            checkCenterVecList = {[0; -1], [2; 1]};
            operationCheckEqFunc(testEllVec, checkCenterVecList, 'minus', testVec);
            %
            test1EllCenterVec = -10;
            test1ShapeMat = 4;
            test1Vec = 3;
            test1Ell = self.ellFactoryObj.create(test1EllCenterVec, test1ShapeMat*test1ShapeMat');
            checkCenterVecList = {-13};
            operationCheckEqFunc(test1Ell, checkCenterVecList, 'minus', test1Vec);
            %
            test2EllCenterVec = [2; -4; 11];
            test2ShapeMat = [7 2 1; 7 2 2; 5 6 8];
            test2Vec = [0; 2; 1];
            test2Ell = self.ellFactoryObj.create(test2EllCenterVec, test2ShapeMat*test2ShapeMat');
            checkCenterVecList = {[2; -6; 10]};
            operationCheckEqFunc(test2Ell, checkCenterVecList, 'minus', test2Vec);
            %
            testEll = self.ellFactoryObj.create(ones(2,1),eye(2,2));
            testEllArr = testEll.repMat([2,2,3,4]);
            testVec = [1;1];
            checkCenterVecList = repmat({zeros(2,1)},[2,2,3,4]);
            operationCheckEqFunc(testEllArr, checkCenterVecList, 'minus', testVec);
            %
            testEllCenterVec = zeros(1, 100);
            testEllCenterVec(50) = 5;
            testEllMat = eye(100);
            testEll = self.ellFactoryObj.create(testEllCenterVec', testEllMat);
            testVec = zeros(1, 100)';
            testVec(100) = 5;
            testCheckVec = zeros(1,100);
            testCheckVec(50) = 5;
            testCheckVec(100) = -5;
            checkCenterVecList = {testCheckVec'};
            operationCheckEqFunc(testEll, checkCenterVecList, 'minus', testVec);
            %
            self.emptyTest('minus',[0,0,2,0],testVec);
        end
        function self = testInv(self)
            testEllCenterVec = 1;
            testEllMat = 4;
            testEll = self.ellFactoryObj.create(testEllCenterVec, testEllMat);
            checkShapeList = {0.2500};
            operationCheckEqFunc(testEll, checkShapeList, 'inv');
            %
            testEllCenterVec = [-5; 1];
            testEllMat = eye(2);
            testEll = self.ellFactoryObj.create(testEllCenterVec, testEllMat);
            checkShapeList = {eye(2)};
            operationCheckEqFunc(testEll, checkShapeList, 'inv');
            %
            test1EllCenterVec = [1; 0; 1];
            test2EllCenterVec = [1; 2];
            test1EllMat = eye(3);
            test2EllMat = [2 2; 2 3];
            test1Ell = self.ellFactoryObj.create(test1EllCenterVec, test1EllMat);
            test2Ell = self.ellFactoryObj.create(test2EllCenterVec, test2EllMat);
            testEllVec = [test1Ell test2Ell];
            checkShapeList = {eye(3),[1.5 -1; -1 1]};
            operationCheckEqFunc(testEllVec, checkShapeList, 'inv');
            %
            testEllCenterVec = zeros(1, 20);
            testEllMat = eye(20);
            testResMat = eye(20);
            for testCounter = 1:1:size(testEllMat,2)
                testEllMat(testCounter,testCounter) = testCounter;
            end
            testEll = self.ellFactoryObj.create(testEllCenterVec',testEllMat);
            testEllArr = testEll.repMat([2 2 3 4]);
            for testCounter = 1:1:size(testEllMat,2)
                testResMat(testCounter,testCounter) = 1./testCounter;
            end
            checkShapeList = repmat({testResMat},[2 2 3 4]);
            operationCheckEqFunc(testEllArr, checkShapeList, 'inv');
            %
            self.emptyTest('inv',[0,0,2,0]);
        end
        function self = testMove2Origin(self)
            testEllCenterVec = [1; 1];
            testEllMat = [3 1; 1 1];
            testEll = self.ellFactoryObj.create(testEllCenterVec, testEllMat);
            checkCenterVecList = {[0;0]};
            operationCheckEqFunc(testEll, checkCenterVecList, 'move2origin');
            %
            test1EllCenterVec = [1; 1; 0];
            test2EllCenterVec = [1; 2];
            test1EllMat = [3 0 0; 0 2 0; 0 0 1];
            test2EllMat = eye(2);
            test1Ell = self.ellFactoryObj.create(test1EllCenterVec, test1EllMat*test1EllMat');
            test2Ell = self.ellFactoryObj.create(test2EllCenterVec, test2EllMat);
            testEllVec = [test1Ell test2Ell];
            checkCenterVecList = {[0;0;0], [0;0]};
            operationCheckEqFunc(testEllVec, checkCenterVecList, 'move2origin');
            %
            testEll = self.ellFactoryObj.create(ones(2,1),eye(2,2));
            testEllArr = testEll.repMat([2,2,3,4]);
            checkCenterVecList = repmat({zeros(2,1)},[2,2,3,4]);
            operationCheckEqFunc(testEllArr, checkCenterVecList, 'move2origin');
            %
            testEllCenterVec = zeros(20, 1);
            testEllMat = eye(20);
            testEll = self.ellFactoryObj.create(testEllCenterVec, testEllMat);
            checkCenterVecList = {zeros(20, 1)};
            operationCheckEqFunc(testEll, checkCenterVecList, 'move2origin');
            %
            self.emptyTest('move2origin',[0,0,2,0]);
        end
        function self = testShape(self)
            testEllCenterVec = [1; 0];
            testEllMat = eye(2);
            testEll = self.ellFactoryObj.create(testEllCenterVec, testEllMat);
            testVec = [0, 'a'];
            self.runAndCheckError('shape(testEll, testVec)','wrongInput');
            %
            testEllCenterVec = 4;
            testEllMat = 3;
            testMat = 2;
            testEll = self.ellFactoryObj.create(testEllCenterVec, testEllMat);
            checkShapeList = {12};
            operationCheckEqFunc(testEll, checkShapeList, 'shape',testMat);
            %
            test1EllCenterVec = [2; 4];
            test2EllCenterVec = [5; 1];
            test1EllMat = [3 0; 2 4];
            test2EllMat = [4 0; 0 3];
            testMat = [0 1; 2 3];
            testEll1 = self.ellFactoryObj.create(test1EllCenterVec, test1EllMat*test1EllMat');
            testEll2 = self.ellFactoryObj.create(test2EllCenterVec, test2EllMat*test2EllMat');
            testEllVec = [testEll1, testEll2];
            checkShapeList = {[20 72; 72 288], [9 27; 27 145]};
            operationCheckEqFunc(testEllVec, checkShapeList, 'shape',testMat);
            %
            testEllMat = [5 2;2 8];
            testEll = self.ellFactoryObj.create(testEllMat);
            testEllArr = testEll.repMat([2,2,3,4]);
            testMat = [4 2;1 3];
            testResMat = [144 96; 96 89];
            checkCenterVecList = repmat({testResMat},[2,2,3,4]);
            operationCheckEqFunc(testEllArr, checkCenterVecList, 'shape',...
                testMat);
            %
            self.emptyTest('shape',[0,0,2,0],testMat);
        end
        function self = testRho(self)
            %
            dirMat=[1 1;0 0];
            ellObjMat=diag([9 25]);
            ellObjCenVec=[2 0]';
            ellObj=self.ellFactoryObj.create(ellObjCenVec,ellObjMat);
            ellVec=[ellObj, ellObj, ellObj];
            %
            %Check one ell - one dirs
            [supVal bpVec]=rho(ellObj,dirMat(:,1));
            checkRhoRes(supVal,bpVec);
            checkRhoSize(supVal,bpVec,ones(2,1),[1 1]);
            %
            %Check one ell - multiple dirs
            [supArr bpMat]=rho(ellObj,dirMat);
            checkRhoRes(supArr,bpMat);
            checkRhoSize(supArr,bpMat,dirMat,[1 2]);
            %
            %Check multiple ell - one dir
            [supArr bpMat]=rho(ellVec,dirMat(:,1));
            checkRhoRes(supArr,bpMat);
            checkRhoSize(supArr,bpMat,ones(2,3),[1 3]);
            %
            %Check multiple ell - multiple dirs
            arrSizeVec=[2,3,4];
            dirArr=zeros([2,arrSizeVec]);
            dirArr(1,:)=1;
            testEll = self.ellFactoryObj.create(ellObjCenVec,ellObjMat);
            ellArr = testEll.repMat(arrSizeVec);
            [supArr bpArr]=rho(ellArr,dirArr);
            checkRhoRes(supArr,bpArr);
            checkRhoSize(supArr,bpArr,dirArr,arrSizeVec);
            %
            %Check array ell - one dir
            [supArr bpArr]=rho(ellArr,dirMat(:,1));
            checkRhoRes(supArr,bpArr);
            checkRhoSize(supArr,bpArr,dirArr,arrSizeVec);
            %
            %Check one ell - array dir
            [supArr bpArr]=rho(ellObj,dirArr);
            checkRhoRes(supArr,bpArr);
            checkRhoSize(supArr,bpArr,dirArr,arrSizeVec);
            %
            % Negative tests for input
            arr2SizeVec=[2,2,4];
            dir2Arr=ones([2,arr2SizeVec]);
            testEll = self.ellFactoryObj.create(ellObjCenVec, ellObjMat);
            ell2Arr=testEll.repMat(arr2SizeVec);
            self.runAndCheckError('rho(ell2Arr,dirArr)',...
                'wrongInput:wrongSizes');
            self.runAndCheckError('rho(ellArr,dir2Arr)',...
                'wrongInput:wrongSizes');
            ellVec=[ellObj, ellObj, ellObj];
            dirMat=eye(2);
            self.runAndCheckError('rho(ellVec,dirMat)',...
                'wrongInput:wrongSizes');
            ellVec=[ellObj, ellObj, ellObj]';
            dirMat=eye(2);
            self.runAndCheckError('rho(ellVec,dirMat)',...
                'wrongInput:wrongSizes');
            ellEmptArr = self.ellFactoryObj.create.empty([0,0,2,0]);
            self.runAndCheckError('rho(ellEmptArr,dirMat)',...
                'wrongInput:wrongSizes');
        end
        function self = testDisplay(self)
            ellEmptArr = self.ellFactoryObj.create.empty([0,0,2,0]);
            evalc('display(ellEmptArr)');
            %
            centVec = [1;1];
            shapeMat = eye(2);
            ellObj = self.ellFactoryObj.create(centVec,shapeMat);
            evalc('display(ellObj)');
            %
            ellMat = ellObj.repMat([2,2]);
            evalc('display(ellMat)');
            %
            ellArr = ellObj.repMat([2,2,3,4,5]);
            evalc('display(ellArr)');
        end   
        function self = testProjection(self)
            projMat = [1 0 0;0 1 0]';
            centVec = [-2; -1; 4]; 
            shapeMat = [4 -1 0; -1 1 0; 0 0 9];
            self.auxTestProjection('projection',centVec, shapeMat, projMat);
            %
            projMat = [1 0 0; 0 0 1]';
            centVec = [2; 4; 3];
            shapeMat = [3 1 1; 1 4 1; 1 1 8];
            dimVec = [2,2,3,4];
            self.auxTestProjection('projection',centVec, shapeMat, projMat, dimVec);
            %
            dimVec = [0,0,2,0];
            self.auxTestProjection('projection',centVec, shapeMat, projMat, dimVec);
        end
        function self = testGetShape(self)
            ellMat = eye(2);
            testEll = self.ellFactoryObj.create(ellMat);
            testEllArr = testEll.repMat([2 2 3 4]);
            testMat =[2 0;0 2];
            compMat = [4 0;0 4];
            compList = repmat({compMat},[2 2 3 4]);
            operationCheckEqFunc(testEllArr, compList, 'getShape', testMat);
            %
            self.emptyTest('getShape',[0,0,2,0],testMat);
        end 
        function self = testGetInv(self)
            ellMat = [2 0;0 2];
            testEll = self.ellFactoryObj.create(ellMat);
            testEllArr = testEll.repMat([2 2 3 4]);
            testMat = [1/2 0; 0 1/2];
            compList  = repmat({testMat}, [2 2 3 4]);
            operationCheckEqFunc(testEllArr,compList,'getInv');
            %
            self.emptyTest('getInv',[0,0,2,0]);
        end    
        function self = testGetMove2Origin(self)
            ellMat = eye(2);
            ellVec = [2;2];
            testEll = self.ellFactoryObj.create(ellVec,ellMat);
            testEllArr = testEll.repMat([2 2 3 4]);
            compList = repmat({[0;0]},[2 2 3 4]);
            operationCheckEqFunc(testEllArr,compList,'getMove2Origin');
            %
            self.emptyTest('getMove2Origin',[0,0,2,0]);
        end    
        function self = testGetProjection(self)
            projMat = [1 0 0; 0 0 1]';
            centVec = [2; 4; 3];
            shapeMat = [3 1 1; 1 4 1; 1 1 8];
            dimVec = [2,2,3,4];
            self.auxTestProjection('getProjection',centVec, shapeMat, projMat, dimVec);
            %
            dimVec = [0,0,2,0];
            self.auxTestProjection('getProjection',centVec, shapeMat, projMat, dimVec);
        end    
    end
    
    methods
function emptyTest(self, methodName, sizeVec, argument)
    testEllArr = self.ellFactoryObj.create.empty(sizeVec);
    checkCenterVecList = repmat({},sizeVec);
    if nargin < 4
        operationCheckEqFunc(testEllArr, checkCenterVecList, methodName);
    else
        operationCheckEqFunc(testEllArr, checkCenterVecList, methodName,...
            argument);
    end    
end
function auxTestProjection(self, methodName, centVec, shapeMat, projMat, dimVec)
     import modgen.common.throwerror;
     import modgen.cell.cellstr2expression;
     import elltool.conf.Properties;
     absTol = Properties.getAbsTol();
     INP_OBJ_MODIF_LIST = {'projection'};
     INP_OBJ_NOT_MODIF_LIST = {'getProjection'};
     projCentVec = projMat'*centVec;
     projShapeMat = projMat'*shapeMat*projMat;
     ellObj = self.ellFactoryObj.create(centVec, shapeMat);
     compEllObj = self.ellFactoryObj.create(projCentVec, projShapeMat);
     if ismember(methodName, INP_OBJ_MODIF_LIST)
         isInpObjModif = true;
     elseif ismember(methodName, INP_OBJ_NOT_MODIF_LIST)
         ellCopyObj = ellObj.getCopy();
         isInpObjModif = false;
     else
         throwerror('wrongInput:badMethodName',...
             'Allowed method names: %s. Input name: %s',...
             cellstr2expression({INP_OBJ_MODIF_LIST{:}, ...
             INP_OBJ_NOT_MODIF_LIST{:}}), methodName);
     end
     if nargin < 6
        projEllObj = ellObj.(methodName)(projMat); 
        testIsRight1 = isequal(compEllObj, projEllObj);
        if isInpObjModif    
            %additional test for modification of input object
            testIsRight2 = compEllObj.isEqual(ellObj);
        else
            %additional test for absence of input object's modification
            testIsRight2 = ellCopyObj.isEqual(ellObj);
        end    
     else
        ellArr = ellObj.repMat(dimVec);
        if ~isInpObjModif
            ellCopyArr = ellCopyObj.repMat(dimVec);
        end    
        projEllArr = ellArr.(methodName)(projMat);
        compEllArr = compEllObj.repMat(dimVec);
        testIsRight1 = all(compEllArr(:).isEqual(projEllArr(:)));
        if isInpObjModif    
            %additional test for modification of input array
            testIsRight2 = all(compEllArr(:).isEqual(ellArr(:)));
        else
            %additional test for absence of input array's modification
            testIsRight2 = all(ellCopyArr(:).isEqual(ellArr(:)));
        end
     end    
     mlunitext.assert_equals(1, testIsRight1);
     mlunitext.assert_equals(1, testIsRight2);
end 
function [ellCVec pointsCVec] = getEllParams(self, flag)
    if(flag == 1)
        test1Ell = self.ellFactoryObj.create(eye(2));
        test2Ell = self.ellFactoryObj.create([1; 0], [1 0; 0 1]);
        test3Ell = self.ellFactoryObj.create([0; 0], [0 0; 0 0]);
        test4Ell = self.ellFactoryObj.create([2; 1], [4 0; 0 4]);
        pointsCVec = {6 6 6 6};
    else
        test1Ell = self.ellFactoryObj.create(eye(2));
        test2Ell = self.ellFactoryObj.create([1; 3], [3 1; 1 1]);
        test3Ell = self.ellFactoryObj.create([2; 1], [4 -1; -1 1]);
        test4Ell = self.ellFactoryObj.create(eye(3));
        pointsCVec = {10 20 35 [5, 5]};
    end
    ellCVec = {test1Ell, test2Ell, test3Ell, test4Ell};
end
    end
end
%

function isFlag = compareCells(bpCMat, fCMat, bpRightCMat, fRightCMat)
    ABSTOL = 1.0e-12;
    [isEqual1,~,~,~,~] = modgen.common.absrelcompare(cell2mat(bpRightCMat),...
        cell2mat(bpCMat),ABSTOL,ABSTOL,@norm);
    [isEqual2,~,~,~,~] = modgen.common.absrelcompare(cell2mat(fCMat),...
        cell2mat(fRightCMat),ABSTOL,ABSTOL,@norm);
    isFlag = isEqual1 && isEqual2; 
end            
function operationCheckEqFunc(testEllArr, compList, operation,...
    argument)
    OBJ_MODIFICATING_METHODS_LIST = {'inv', 'move2origin',...
        'shape'};
    isObjModifMethod = ismember(operation, OBJ_MODIFICATING_METHODS_LIST);
    if ~isObjModifMethod
        testCopyEllArr = testEllArr.getCopy();
    end    
    if nargin < 4
        testEllResArr = testEllArr.(operation);
    else
        testEllResArr = testEllArr.(operation)(argument);
    end
    checkRes(testEllResArr,compList, operation);
    if isObjModifMethod
        %test for methods which modify the input array
        checkRes(testEllArr,compList, operation);
    else
        %test for absence of input array's modification 
        isNotModif = all(testCopyEllArr(:).isEqual(testEllArr(:)));
        mlunitext.assert_equals(isNotModif, 1);
    end    
end
function checkRes(testEllResArr,compList, operation)
    import modgen.common.throwerror;
    import modgen.cell.cellstr2expression;
    %
    VEC_COMP_METHODS_LIST = {'uminus', 'plus', 'minus', 'move2origin',...
        'getMove2Origin'};
    MAT_COMP_METHODS_LIST = {'inv', 'shape','getInv','getShape'};
    %
    [testEllResCentersVecList, testEllResShapeMatList] = arrayfun(@(x) double(x),...
        testEllResArr, 'UniformOutput', false);
    if ismember(operation, VEC_COMP_METHODS_LIST)
        eqArr = cellfun(@(x,y) isequal(x,y),testEllResCentersVecList,...
            compList);
    elseif ismember(operation, MAT_COMP_METHODS_LIST)
        eqArr = cellfun(@(x,y) isequal(x,y), testEllResShapeMatList,...
            compList);
    else
        throwerror('wrongInput:badMethodName',...
            'Allowed method names: %s. Input name: %s',...
            cellstr2expression({VEC_COMP_METHODS_LIST{:}, ...
            MAT_COMP_METHODS_LIST{:}}), operation);
    end
    testIsRight = all(eqArr(:) == 1);
    mlunitext.assert_equals(testIsRight, 1);
end
%
function checkRhoSize(supArr,bpArr,dirArr,arrSizeVec)
    isRhoOk=all(size(supArr)==arrSizeVec);
    isBPOk=all(size(bpArr)==size(dirArr));
    mlunitext.assert_equals(true,isRhoOk && isBPOk);
end
function checkRhoRes(supArr,bpArr)
    isRhoOk=all(supArr(:)==5);
    isBPOk=all(bpArr(1,:)==5) && all(bpArr(2,:)==0);
    mlunitext.assert_equals(true,isRhoOk && isBPOk);
end
