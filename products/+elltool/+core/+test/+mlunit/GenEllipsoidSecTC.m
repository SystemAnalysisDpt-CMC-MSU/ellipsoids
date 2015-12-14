classdef GenEllipsoidSecTC < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
    end
    methods
        function self=GenEllipsoidSecTC(varargin)
            self=self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData',...
                filesep,shortClassName];
            import elltool.core.GenEllipsoid;
        end
        %
        function testParameters(~)
            import elltool.core.GenEllipsoid;
            %Empty ellipsoid
            testEllipsoid=GenEllipsoid();
            [testCenterVec,testDiagMat,testEigvMat]=...
                testEllipsoid.parameters();
            isTestRes=isempty(testCenterVec)&&isempty(testDiagMat)&&...
                isempty(testEigvMat);
            mlunitext.assert(isTestRes);
            %Check for one output argument
            testEllipsoid=GenEllipsoid(-ones(5,1),eye(5,5));
            testDiagMat=testEllipsoid.parameters();
            isTestEyeMat=testDiagMat==eye(5,5);
            isTestRes=all(isTestEyeMat(:));
            mlunitext.assert(isTestRes);
            %Check for two output arguments
            testEllipsoid=GenEllipsoid(-ones(5,1),eye(5,5));
            [testDiagMat, testCenVec]=testEllipsoid.parameters();
            isTestMat=[testDiagMat==eye(5,5),testCenVec==-ones(5,1)];
            isTestRes=all(isTestMat(:));
            mlunitext.assert(isTestRes);
            %Check for three output arguments
            test1qMat=diag([Inf;Inf;1]);
            test2dMat=diag([1;1;0.1]);
            test2wMat=[1,0,0;0,2,0;0,0,1];
            cenVec=zeros(3,1);
            test1Ellipsoid=GenEllipsoid(cenVec,test1qMat);
            test2Ellipsoid=GenEllipsoid(cenVec,test2dMat,test2wMat);
            [test1DiagMat,test1CenVec,test1EigvMat]=...
                test1Ellipsoid.parameters();
            [test2DiagMat,test2CenVec,test2EigvMat]=...
                test2Ellipsoid.parameters();
            expCenVec=cenVec;
            exp1DiagMat=test1qMat;
            exp1EigvMat=eye(3);
            exp2DiagMat=diag([0.1,1,4]);
            exp2EigvMat=[0,-1,0;0,0,-1;-1,0,0];
            isTestMat=[isequal(test1DiagMat,exp1DiagMat),...
                isequal(test1CenVec,expCenVec),...
                isequal(test1EigvMat,exp1EigvMat);
                isequal(test2DiagMat,exp2DiagMat),...
                isequal(test2CenVec,expCenVec),...
                isequal(test2EigvMat,exp2EigvMat)];
            isTestRes=all(isTestMat(:));
            mlunitext.assert(isTestRes);
        end
        %
        function testPlus(self)
            import elltool.core.GenEllipsoid;
            testResVec=[GenEllipsoid(6,5),GenEllipsoid(11,10),...
                GenEllipsoid([Inf;2],[5;6],[1,2;3,4]),...
                GenEllipsoid([Inf;-4],[Inf;1],[0.1,0.1;0.2,0]),...
                GenEllipsoid([NaN;Inf],[1;2])];
            self.plusMinusTest('plus',testResVec);
        end
        %
        function testMinus(self)
            import elltool.core.GenEllipsoid;
            testResVec=[GenEllipsoid(-4,5),GenEllipsoid(1,10),...
                GenEllipsoid([-Inf;0],[5;6],[1,2;3,4]),...
                GenEllipsoid([-Inf;-6],[Inf;1],[0.1,0.1;0.2,0]),...
                GenEllipsoid([-Inf;Inf],[1;2])];
            self.plusMinusTest('minus',testResVec);
        end
        %
        function plusMinusTest(self,opName,testResVec)
            %Chech negative
            binOperWithVecNegativeTest(opName);
            %Chech positive
            import elltool.core.GenEllipsoid;
            test1EllObj=GenEllipsoid(1,5);
            test2EllObj=GenEllipsoid(6,10);
            test1Vec=5;
            exp1EllObj=testResVec(1);
            exp2EllObj=testResVec(2);
            binOperCheckRes(test1EllObj,test1Vec,opName,exp1EllObj);
            binOperCheckRes([test1EllObj,test2EllObj],test1Vec,...
                opName,[exp1EllObj,exp2EllObj]);
            %
            test1EllObj=GenEllipsoid([1;1],[5;6],[1,2;3,4]);
            test2EllObj=GenEllipsoid([-10;-5],[Inf;1],[0.1,0.1;0.2,0]);
            test3EllObj=GenEllipsoid([-Inf;Inf],[1;2]);
            test1Vec=[Inf;1];
            exp1EllObj=testResVec(3);
            exp2EllObj=testResVec(4);
            exp3EllObj=testResVec(5);
            binOperCheckRes(test1EllObj,test1Vec,opName,exp1EllObj);
            binOperCheckRes([test1EllObj,test2EllObj,test3EllObj],...
                test1Vec,opName,[exp1EllObj,exp2EllObj,exp3EllObj]);
            %
            function binOperCheckRes(testEllArr,testVec,...
                    opName,expEllArr)
                resEllArr=testEllArr.(opName)(testVec);
                isTestMat=isEqual(resEllArr,expEllArr);
                mlunitext.assert(all(isTestMat(:)));
            end
            function binOperWithVecNegativeTest(opName)
                import elltool.core.GenEllipsoid;
                test1Ellipsoid=GenEllipsoid(1,5);
                test2Ellipsoid=GenEllipsoid([1;2],[5 1;1 5]);
                %Check wrong input processing
                checkWrongInput('v',test1Ellipsoid,opName);
                checkWrongInput(test2Ellipsoid,test1Ellipsoid,opName);
                self.runAndCheckError('test1Ellipsoid.(opName)()',...
                    'wrongInput');
                checkWrongInput(test1Ellipsoid,ellipsoid(1,1),opName);
                %Check different dimensions
                checkWrongDimensions([1;1],test1Ellipsoid,opName);
                checkWrongDimensions(1,test2Ellipsoid,opName);
                checkWrongDimensions([1;1;1],test2Ellipsoid,opName);
                %
                function checkWrongInput(testVec,testEllipsoid,opName) %#ok<INUSD>
                    self.runAndCheckError('testEllipsoid.(opName)(testVec)',...
                        'wrongInput');
                end
                function checkWrongDimensions(testVec,testEllipsoid,opName) %#ok<INUSD>
                    self.runAndCheckError('testEllipsoid.(opName)(testVec)',...
                        'wrongDimensions');
                end
            end
        end
        %
        function testIsEmpty(~)
            import elltool.core.GenEllipsoid;
            %Check really empty
            test1Ellipsoid=GenEllipsoid();
            mlunitext.assert(test1Ellipsoid.isEmpty());
            %Check non-empty
            test2Ellipsoid=GenEllipsoid(eye(10,1),eye(10,10));
            mlunitext.assert(~test2Ellipsoid.isEmpty());
            %Check arrays
            testEllVec=[GenEllipsoid(diag(1:22)),...
                GenEllipsoid((0:0.1:1.4).',diag(1:15)),...
                GenEllipsoid(),GenEllipsoid(zeros(40,40)),...
                GenEllipsoid(ones(100,1),Inf*ones(100,1))];
            isTestResVec=testEllVec.isEmpty();
            isExpResVec=[false,false,true,true,false];
            mlunitext.assert(isExpResVec==isTestResVec);
        end
        %
        function testMinEig(self)
            test3Mat=[1 1 -1; 1 4 -4; -1 -4 9];
            testResVec=[1.5,Inf,min(eig(test3Mat)),Inf,[1,12,5,1,NaN]];
            self.minMaxEig('mineig',testResVec);
        end
        function testMaxEig(self)
            test3Mat=[1 1 -1; 1 4 -4; -1 -4 9];
            testResVec=[5,Inf,max(eig(test3Mat)),Inf,[1,100,205,1,NaN]];
            self.minMaxEig('maxeig',testResVec);
        end
        %
        function minMaxEig(self,opName,testResVec)
            import elltool.core.GenEllipsoid;
            eps=GenEllipsoid().getAbsTol();
            %Check negative
            negativeEig(opName);
            %Check positive
            test1Ellipsoid=GenEllipsoid(diag(5:-0.1:1.5));
            test1Res=test1Ellipsoid.(opName)();
            exp1Res=testResVec(1);
            mlunitext.assert(exp1Res==test1Res);
            test2Ellipsoid=GenEllipsoid(Inf);
            exp2Res=testResVec(2);
            mlunitext.assert(test2Ellipsoid.(opName)()==exp2Res);
            %
            test3Mat=[1 1 -1; 1 4 -4; -1 -4 9];
            test3Ellipsoid=GenEllipsoid(test3Mat);
            test3Res=test3Ellipsoid.(opName)();
            exp3Res=testResVec(3);
            mlunitext.assert(exp3Res-test3Res<=eps);
            %
            test4Ellipsoid=GenEllipsoid([-10;-5],[Inf;1],[1,1;1,1]);
            test4Res=test4Ellipsoid.(opName)();
            exp4Res=testResVec(4);
            mlunitext.assert(exp4Res==test4Res);
            %Check arrays
            test5EllVec=[GenEllipsoid(1),GenEllipsoid(diag(100:-0.1:12)),...
                GenEllipsoid((-100:100)', diag(5:205)),...
                GenEllipsoid((0:100)', eye(101)),...
                GenEllipsoid(ones(100,1), Inf*ones(100, 1))];
            test5ResVec=test5EllVec.(opName)();
            exp5ResVec=testResVec(5:9);
            isTestResVec=isequaln(exp5ResVec,test5ResVec);
            mlunitext.assert(all(isTestResVec(:)));
            %
            function negativeEig(func) %#ok<INUSD>
                import elltool.core.GenEllipsoid;
                testEllipsoid=GenEllipsoid(); %#ok<NASGU>
                self.runAndCheckError('testEllipsoid.(func)',...
                    'wrongInput');
            end
        end
        %
        function testToStruct(~)
            testEllVec=[GenEllipsoid(1),...
                GenEllipsoid([1;1],[100,0;0,100]),...
                GenEllipsoid([1;1],[5;1],[1,2;3,4]),...
                GenEllipsoid((1:10)',Inf*ones(10,1),ones(10))];
            SExpResVec=[struct('QMat',1,'centerVec',0,'QInfMat',0),...
                struct('QMat',[100,0;0,100],'centerVec',[1;1],...
                'QInfMat',zeros(2)),...
                struct('QMat',[9,23;23,61],'centerVec',[1;1],...
                'QInfMat',zeros(2)),...
                struct('QMat',zeros(10),'centerVec',(1:10)',...
                'QInfMat',0.1*ones(10))];
            arrayfun(@singleTestToStruct,testEllVec,SExpResVec);
            
            function singleTestToStruct(testEllObj,SExpRes)
                import elltool.core.GenEllipsoid;
                import modgen.struct.structcompare;
                STestRes=testEllObj.toStruct();
                mlunitext.assert(structcompare(STestRes,SExpRes,1e-09));
            end
        end
        %
        function testFromRepMat(self)
            import elltool.core.GenEllipsoid;
            %Check negative
            test1SizeVec=1; %#ok<NASGU>
            self.runAndCheckError(...
                'elltool.core.GenEllipsoid.fromRepMat(test1SizeVec)',...
                'wrongInput');
            test2SizeVec=[-1 2]; %#ok<NASGU>
            self.runAndCheckError(...
                'elltool.core.GenEllipsoid.fromRepMat(test2SizeVec)',...
                'wrongInput');
            test3SizeVec=[2;2]; %#ok<NASGU>
            self.runAndCheckError(...
                'elltool.core.GenEllipsoid.fromRepMat(test3SizeVec)',...
                'wrongInput');
            test4SizeVec=[2+2i,2]; %#ok<NASGU>
            self.runAndCheckError(...
                'elltool.core.GenEllipsoid.fromRepMat(test4SizeVec)',...
                'wrongInput');
            test5SizeVec=[2.5,5.2]; %#ok<NASGU>
            self.runAndCheckError(...
                'elltool.core.GenEllipsoid.fromRepMat(test5SizeVec)',...
                'wrongInput');
            %Check positive
            test6SizeVec=[2,3,3,5];
            test6EllArr=ellipsoid.fromRepMat(test6SizeVec);
            isOk6Arr=test6EllArr.isEmpty();
            mlunitext.assert(all(isOk6Arr(:)));
            test7SizeVec=[2,3,3+1i*eps/10,5];
            test7EllArr=ellipsoid.fromRepMat(test7SizeVec);
            isOk7Arr=test7EllArr.isEmpty();
            mlunitext.assert(all(isOk7Arr(:)));
            test8centerVec=[4;5];
            test8dVec=[10;11];
            test8wMat=[1,2;3,4];
            test8SizeVec=[5,4,3];
            test8Ellipsoid=GenEllipsoid(test8centerVec,test8dVec,...
                test8wMat);
            res8EllArr=GenEllipsoid.fromRepMat(test8centerVec,test8dVec,...
                test8wMat,test8SizeVec);
            [isOkArr8,reportStr]=res8EllArr.isEqual(test8Ellipsoid);
            mlunitext.assert(all(isOkArr8(:)),reportStr);
        end
    end
end