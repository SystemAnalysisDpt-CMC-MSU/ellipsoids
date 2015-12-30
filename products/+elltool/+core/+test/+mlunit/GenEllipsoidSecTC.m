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
            test1SRes=struct('diagMat',test1DiagMat,...
                'eigvMat',test1EigvMat,'centerVec',test1CenVec);
            test2SRes=struct('diagMat',test2DiagMat,...
                'eigvMat',test2EigvMat,'centerVec',test2CenVec);
            exp1SRes=struct('diagMat',exp1DiagMat,...
                'eigvMat',exp1EigvMat,'centerVec',expCenVec);
            exp2SRes=struct('diagMat',exp2DiagMat,...
                'eigvMat',exp2EigvMat,'centerVec',expCenVec);
            import modgen.struct.structcompare;
            mlunitext.assert(structcompare(test1SRes,exp1SRes,1e-09));
            mlunitext.assert(structcompare(test2SRes,exp2SRes,1e-09));
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
                [isTestMat,reportStr]=isEqual(resEllArr,expEllArr);
                mlunitext.assert(all(isTestMat(:)),reportStr);
            end
            function binOperWithVecNegativeTest(opName) %#ok<INUSD>
                import elltool.core.GenEllipsoid;
                test1Ell=GenEllipsoid(1,5);
                test2Ell=GenEllipsoid([1;2],[5 1;1 5]); 
                %Check wrong input processing
                self.runAndCheckError('test1Ell.(opName)()',...
                    'wrongInput');
                testCVec={'v',test2Ell,test1Ell};
                testEllCVec={test1Ell,test1Ell,ellipsoid(1,1)};
                arrayfun(@checkWrongInput,testCVec,testEllCVec);
                %Check different dimensions
                testCVec={[1;1],1,[1;1;1]};
                testEllCVec={test1Ell,test2Ell,test2Ell};
                arrayfun(@checkWrongDimensions,testCVec,testEllCVec);
                %
                function checkWrongInput(testVec,testEllipsoid) %#ok<INUSD>
                    self.runAndCheckError(...
                        'testEllipsoid{:}.(opName)(testVec)',...
                        'wrongInput');
                end
                function checkWrongDimensions(testVec,testEllipsoid) %#ok<INUSD>
                    self.runAndCheckError(...
                        'testEllipsoid{:}.(opName)(testVec{:})',...
                        'wrongInput');
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
            import elltool.core.GenEllipsoid;
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
                import modgen.struct.structcompare;
                STestRes=testEllObj.toStruct();
                mlunitext.assert(structcompare(STestRes,SExpRes,1e-09));
            end
        end
        %
        function testFromRepMat(self)
            %Check negative
            testSizeVec={{1},{[-1 2]},{[2;2]},{[2+2i,2]},{[2.5,5.2]}}; 
            arrayfun(@checkNegative,testSizeVec);
            %Check positive
            testSizeCVec={[2,3,3,5],[2,3,3+1i*eps/10,5],[5,4,3]};
            testArgsCVec={{[1;1]},{[1;1]},{[10;11],[4;5],[1,2;3,4]}};
            arrayfun(@checkPositive,testSizeCVec,testArgsCVec);
            %
            function checkPositive(testSizeVec,testArgs)
                import elltool.core.GenEllipsoid;
                testEllipsoid=GenEllipsoid(testArgs{1}{:});
                resEllArr=GenEllipsoid.fromRepMat(testArgs{1}{:},testSizeVec{1});
                [isOkArr,reportStr]=resEllArr.isEqual(testEllipsoid);
                mlunitext.assert(all(isOkArr(:)),reportStr);
            end
            function checkNegative(testSizeVec) %#ok<INUSD>
                self.runAndCheckError(...
                'elltool.core.GenEllipsoid.fromRepMat(testSizeVec)',...
                'wrongInput');
            end
        end
        %
        function testShape(self)
            %Check negative
            import elltool.core.GenEllipsoid;
            testEll=GenEllipsoid([-2;-1],[4,-1;-1,1]);
            testModMatCVec={[1;1],[1,1,1]};
            testEllArrCVec={testEll,testEll};
            cellfun(@checkNegative,testModMatCVec,testEllArrCVec);
            %CheckPositive
            test1Ell=GenEllipsoid([-2;-1],[4;Inf]);
            testModMatCVec={2,[1,2;2,1],[2,0;0,0]};
            testEllArrCVec={GenEllipsoid(2),testEll,test1Ell};
            expEllArrCVec={GenEllipsoid(8),...
                GenEllipsoid([-2;-1],[4,5;5,13]),...
                GenEllipsoid([-2;-1],[16;0])};
            cellfun(@checkPositive,testModMatCVec,testEllArrCVec,...
                expEllArrCVec);
            %
            function checkNegative(testModMat,testEllArr) %#ok<INUSD>
                self.runAndCheckError(...
                'testEllArr.shape(testModMat)',...
                'wrongInput');
            end
            %
            function checkPositive(testModMat,testEllArr,...
                    expEllArr)
                resEllArr=testEllArr.shape(testModMat);
                [isOk,reportStr]=isEqual(resEllArr,expEllArr);
                mlunitext.assert(isOk,reportStr);
            end
        end
        %
        function testGetShape(self) %#ok<MANU>
            ellMat=eye(2);
            testEll=elltool.core.GenEllipsoid(ellMat);
            testEllArr=testEll.repMat([2 2 3 4]);
            testMat=[2 0;0 2];
            resEllArr=testEllArr.getShape(testMat);
            expEll=elltool.core.GenEllipsoid([4;4]);
            expEllArr=expEll.repMat([2 2 3 4]);
            [isOk,reportStr]=isEqual(resEllArr,expEllArr);
            mlunitext.assert(isOk,reportStr);
        end
        %
        function testIsBigger(self)
            import elltool.core.GenEllipsoid;
            testEll=GenEllipsoid([2;1]);
            %Check negative
            checkNegative(testEll);
            checkNegative(GenEllipsoid(),testEll);
            %CheckPositive
            testBiggerEllCVec={GenEllipsoid([1;1]),...
                GenEllipsoid(0.5*[1;1]),GenEllipsoid([1;1],[Inf;10]),...
                GenEllipsoid([1;1],[10;Inf],[1,2;3,4]),...
                GenEllipsoid([1;1],[Inf;10],[1,2;3,4])};
            testSmallerEllCVec={GenEllipsoid(0.5*[1;1]),...
                GenEllipsoid([1;1]),GenEllipsoid([Inf;1]),...
                GenEllipsoid([1;1],[Inf;10],[1,2;3,4]),...
                GenEllipsoid([1;1],[10;Inf],[1,2;3,4])};
            isResVec=cellfun(@checkPositive,testBiggerEllCVec,...
                testSmallerEllCVec);
            isExpVec=[true,false,true,false,false];
            mlunitext.assert(all(isResVec==isExpVec));
            %
            function isBigger=checkPositive(testBiggerEll,testSmallerEll)
                isBigger=testBiggerEll.isbigger(testSmallerEll);
            end
            function checkNegative(test1Ell,test2Ell) %#ok<INUSD>
                if nargin<2
                    self.runAndCheckError(...
                        'test1Ell.isbigger()','wrongInput');
                else
                    self.runAndCheckError(...
                        'test1Ell.isbigger(test2Ell)','wrongInput');
                end
            end
        end
        %
        function testMtimes(self)
            import elltool.core.GenEllipsoid
            testEll=GenEllipsoid([1;1],[10;12]);
            %Check negative
            testMultMatCVec={testEll,'a',[1;1],[1,1]};
            testEllCVec={testEll,testEll,testEll,GenEllipsoid()};
            errTagCVec={'wrongInput','wrongInput','wrongSizes',...
                'wrongInput'};
            cellfun(@checkNegative,testMultMatCVec,testEllCVec,errTagCVec);
            %Check positive
            testMultMatCVec={1,2,[1,1],ones(100,2)};
            expEllCVec={testEll,GenEllipsoid([2;2],[40;48]),...
                GenEllipsoid(2,22),...
                GenEllipsoid(2*ones(100,1),22*ones(100,100))};
            cellfun(@(x,y)checkPositive(x,testEll,y),testMultMatCVec,...
                expEllCVec);
            %Check positive with Inf values
            test2Ell=GenEllipsoid([1;1],[4;Inf]);
            testMultMatCVec={2,[1,1],ones(100,2)};
            SExpResCVec={struct('QMat',[16,0;0,0],'centerVec',[2;2],...
                'QInfMat',[0,0;0,4]),...
                struct('QMat',4,'centerVec',2,...
                'QInfMat',1),...
                struct('QMat',4*ones(100,100),'centerVec',2*ones(100,1),...
                'QInfMat',ones(100,100))};
            cellfun(@(x,y)check2Positive(x,test2Ell,y),testMultMatCVec,...
                SExpResCVec);
            function checkNegative(testMultMat,testEllArr,errTag) %#ok<INUSL>
                self.runAndCheckError('testMultMat*testEllArr',errTag);
            end
            function checkPositive(testMultMat,testEll,expEll)
                resEll=testMultMat*testEll;
                [isOkArr,reportStr]=resEll.isEqual(expEll);
                mlunitext.assert(all(isOkArr(:)),reportStr);
            end
            function check2Positive(testMultMat,testEll,SExpRes)
                resEll=testMultMat*testEll;
                STestRes=resEll.toStruct();
                mlunitext.assert(structcompare(STestRes,SExpRes,1e-09));
                import modgen.struct.structcompare;
            end
        end
        %
        function testVolume(self)
            import elltool.core.GenEllipsoid
            COMP_TOL=1e-4;
            %Check negative
            testEll=GenEllipsoid(); %#ok<NASGU>
            self.runAndCheckError('testEll.volume()',...
                'wrongInput:emptyEllipsoid');
            %Check positive
            testEllCVec={GenEllipsoid(1),GenEllipsoid([2;2]),...
                GenEllipsoid([1;1],[2;2]),...
                GenEllipsoid([1;1],[2;2],[1,2;3,4])};
            expVolVec=[2,2*pi,2*pi,12.5664];
            testResVec=cellfun(@(x)x.volume(),testEllCVec);
            mlunitext.assert(all(abs(testResVec-expVolVec)<COMP_TOL));
            %Check Inf volumes
            testEllCVec={GenEllipsoid([1;Inf]),GenEllipsoid(Inf*ones(5,1))};
            testResVec=cellfun(@(x) x.volume(),testEllCVec);
            mlunitext.assert(all(testResVec==Inf));
        end
        %
        function testProjection(self)
            import elltool.core.GenEllipsoid
            testEll=GenEllipsoid([1;1;1],[2;3;4]);
            %Check negative
            testBasisMatCVec={[0 1 1; 0 0 1]',[0 1 1; 0 0 1],1,'a',...
                ellipsoid(hilb(2))};
            testEllCVec={testEll,testEll,GenEllipsoid(),testEll,testEll};
            cellfun(@checkNegative,testBasisMatCVec,testEllCVec);
            %Check backward compatibility with ellipsoid
            testBasisMatCVec={[0 1 0; 0 0 1]',[3,0;0,2]};
            testEllCVec={testEll,GenEllipsoid([1;1],[2;3])};
            cellfun(@checkBackCompEll,testBasisMatCVec,testEllCVec);
            %Check Inf-contained GenEllipsoids
            testBasisMatCVec={[0 1 0; 0 0 1]',[0 1 0; 0 0 1]',[3,0;0,2]};
            testEllCVec={GenEllipsoid([1;1;1],[Inf;3;4]),...
                GenEllipsoid([1;1;1],[3;Inf;4]),...
                GenEllipsoid([1;1],[Inf;3])};
            expResEllCVec={GenEllipsoid([1;1],[3;4]),...
                GenEllipsoid([1;1],[Inf;4]),...
                GenEllipsoid([1;1],[Inf;3])};
            cellfun(@checkPositive,testBasisMatCVec,testEllCVec,...
                expResEllCVec);
            %
            function checkNegative(testBasisMat,testEll) %#ok<INUSD>
                self.runAndCheckError(...
                    'testEll.projection(testBasisMat)',...
                    'wrongInput');
            end
            function checkBackCompEll(testBasisMat,testEll)
                simpleEll=ellipsoid(testEll.getCenterVec(),...
                    testEll.getShapeMat());
                resEllProj=testEll.projection(testBasisMat);
                simpleEllProj=simpleEll.projection(testBasisMat);
                resSimpleEllProj=ellipsoid(resEllProj.getCenterVec(),...
                    resEllProj.getShapeMat());
                mlunitext.assert(isEqual(simpleEllProj,resSimpleEllProj));
            end
            function checkPositive(testBasisMat,testEll,expEllProj)
                resEllProj=testEll.projection(testBasisMat);
                mlunitext.assert(isEqual(resEllProj,expEllProj));
            end
        end
        %
        function testTrace(self)
            import elltool.core.GenEllipsoid
            %Check negative
            ellObj=elltool.core.GenEllipsoid(); %#ok<NASGU>
            self.runAndCheckError('ellObj.trace()',...
                'wrongInput:emptyEllipsoid');
            %Check positive
            testEllCVec={GenEllipsoid(1),GenEllipsoid([1;1]),...
                GenEllipsoid([1;1],[1;1]),...
                GenEllipsoid([1;1],[1;1],[1,2;3,4])};
            expResValCVec={1,2,2,30};
            cellfun(@checkPositive,testEllCVec,expResValCVec);
            %Check Inf-contained
            testEllCVec={GenEllipsoid(Inf),GenEllipsoid([1;Inf]),...
                GenEllipsoid(ones(100,1),Inf*ones(100,1))};
            cellfun(@checkPosInf,testEllCVec);
            %
            function checkPositive(testEll,expResVal)
                resVal=testEll.trace();
                mlunitext.assert(abs(resVal-expResVal)<...
                    testEll.getAbsTol());
            end
            function checkPosInf(testEll)
                mlunitext.assert(testEll.trace()==Inf);
            end
        end
        %
        function testIsdegenerate(self)
            import elltool.core.GenEllipsoid
            %Check negative
            ellObj=elltool.core.GenEllipsoid(); %#ok<NASGU>
            self.runAndCheckError('ellObj.isdegenerate()',...
                'wrongInput:emptyEllipsoid');
            %Check positive
            testEllCVec={GenEllipsoid(ones(6,1),zeros(6,6)),...
                GenEllipsoid([10,1,-5;1,1,1;-5,1,5]),...
                GenEllipsoid([Inf;3;4]),GenEllipsoid([3;4])};
            expResValCVec={true,true,false,false};
            cellfun(@checkPositive,testEllCVec,expResValCVec);
            %
            function checkPositive(testEll,expResVal)
                mlunitext.assert(testEll.isdegenerate()==expResVal);
            end
        end
    end
end