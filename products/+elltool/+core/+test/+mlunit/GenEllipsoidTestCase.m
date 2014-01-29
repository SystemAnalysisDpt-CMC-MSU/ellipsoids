classdef GenEllipsoidTestCase < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
    end
    methods
        function self=GenEllipsoidTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData',...
                filesep,shortClassName];
            import elltool.core.GenEllipsoid;
        end
        %
        function testDisplaySimple(~)
            ell1=elltool.core.GenEllipsoid([1;1],eye(2));
            ell2=elltool.core.GenEllipsoid([1;0],eye(2));
            ell3=elltool.core.GenEllipsoid([0;1],eye(2));
            ellMat=[ell1,ell2,ell3;ell1,ell2,ell3];
            evalc('display(ellMat)');
        end
        %
        function self = testConstructor(self)
            import elltool.core.GenEllipsoid;
            %
            load(strcat(self.testDataRootDir,filesep,...
                'testNewEllRandM.mat'),...
                'testOrth2Mat','testOrth3Mat',...
                'testOrth20Mat','testOrth50Mat',...
                'testOrth100Mat');
            %
            %Tests#0.1. Negative test, unsymmetric matrix
            qMatStr='eye(3,2)';
            qVecStr='[1; 1]';
            checkNeg(1);
            checkNeg(2);
            qMatStr='[1 1;0 1]';
            checkNeg(1);
            checkNeg(2);
%             self.runAndCheckError('elltool.core.GenEllipsoid(eye(3,2))',...
%                 'wrongInputMat');
%             self.runAndCheckError('elltool.core.GenEllipsoid([1 1;0 1])',...
%                 'wrongInputMat');
%             self.runAndCheckError(...
%                 'elltool.core.GenEllipsoid([1;0],eye(3,2))',...
%                 'wrongInputMat');
%             self.runAndCheckError(...
%                 'elltool.core.GenEllipsoid([1;1],[1 1;0 1])',...
%                 'wrongInputMat');
            %Tests#0.2. Negative test, not positive semi-definite matrix
            qMatStr='[1 2;3 4]';
            checkNeg(1);
            checkNeg(2);
%             self.runAndCheckError('elltool.core.GenEllipsoid([1 2; 3 4])',...
%                 'wrongInputMat');
%             self.runAndCheckError(...
%                 'elltool.core.GenEllipsoid([1;1],[1 2; 3 4])',...
%                 'wrongInputMat');
            % Test#1. GenEllipsoid(q,D,W)
            wMat=[1 1;1 2];
            dMat=[Inf 1].';
            resEllipsoid=GenEllipsoid([0,0].',dMat,wMat);
            ansVMat=[-1 1; 1 1];
            ansVMat=ansVMat/norm(ansVMat);
            ansDMat=[0.5 Inf].';
            ansCenVec=[0 0].';
            %
            check();
            %
            % Test#2. GenEllipsoid(q,D,W)
            wMat=[1 2;1 2];
            dMat=[1 Inf].';
            resEllipsoid=GenEllipsoid([0,0].',dMat,wMat);
            %
            ansVMat=[-1 1; 1 1];
            ansVMat=ansVMat/norm(ansVMat);
            ansDMat=[0 Inf].';
            ansCenVec=[0 0].';
            %
            check();
            % Test#3. GenEllipsoid(q,D,W)
            wMat=testOrth2Mat;
            dMat=[5 Inf].';
            resEllipsoid=GenEllipsoid([1,2].',dMat,wMat);
            %
            ansVMat=testOrth2Mat;
            ansDMat=[5 Inf].';
            ansCenVec=[1 2].';
            %
            check();
            %
            % Test#4. GenEllipsoid(q,D,W) 3d-case.
            % Orthogonal Matrix. Finite eigenvalues.
            nDims=3;
            wMat=testOrth3Mat;
            dMat=(1:nDims).';
            resEllipsoid=GenEllipsoid(ones(nDims,1),dMat,wMat);
            %
            ansVMat=testOrth3Mat;
            ansDMat=(1:nDims).';
            ansCenVec=ones(nDims,1);
            %
            check();
            %
            % Test#5. GenEllipsoid(q,D,W)
            % 100-d case. Orthogonal matrix. Infinite eigenvalues.
            nDims=100;
            wMat=testOrth100Mat;
            dMat=[ Inf; Inf; (0:(nDims-4)).'; Inf];
            resEllipsoid=GenEllipsoid(ones(nDims,1),dMat,wMat);
            %
            ansVMat=testOrth100Mat;
            ansDMat=[ Inf; Inf; (0:(nDims-4)).'; Inf];
            ansCenVec=ones(nDims,1);
            %
            check();
            % Test#6. GenEllipsoid(q,D,W)
            wMat=[1 0;2 0];
            dMat=[0 1].';
            resEllipsoid=GenEllipsoid([0,0].',dMat,wMat);
            ansVMat=[-1 0; 0 -1];
            ansVMat=ansVMat/norm(ansVMat);
            ansDMat=[0 0].';
            ansCenVec=[0 0].';
            %
            function check()
                mlunitext.assert_equals(true,isEqElM(resEllipsoid,...
                    ansVMat,ansDMat,ansCenVec));
            end
            function checkNeg(typeNum)
                if typeNum==1
                    self.runAndCheckError(...
                        strcat('elltool.core.GenEllipsoid(',qMatStr,')'),...
                        'wrongInputMat');
                else
                    self.runAndCheckError(...
                        strcat('elltool.core.GenEllipsoid(',...
                        qVecStr,',',qMatStr,')'),...
                        'wrongInputMat');
                end
            end
        end
        %
        function self = testInv(self)
            import elltool.core.GenEllipsoid;
            %
            load(strcat(self.testDataRootDir,filesep,...
                'testNewEllRandM.mat'),...
                'testOrth2Mat','testOrth3Mat',...
                'testOrth20Mat','testOrth50Mat',...
                'testOrth100Mat');
            %import elltool.core.GenEllipsoid;
            %Test#1.
            nDim=100;
            cenVec=zeros(nDim,1);
            ellMat=testOrth100Mat*diag(1:nDim)*testOrth100Mat.';
            ellMat=0.5*(ellMat+ellMat.');
            testEll=GenEllipsoid(cenVec,ellMat);
            resInvEll=testEll.inv();
            ansEll=ellipsoid(cenVec,ellMat);
            ansInvEll=inv(ansEll);
            [ansCenVec ansMat]=double(ansInvEll);
            %
            compEll(resInvEll,ansCenVec,ansMat);
            %Test#2.
            testEll=GenEllipsoid([0 5 Inf].');
            resInvEll=testEll.inv();
            compEll(resInvEll,[Inf 0.2 0].');
            %
            function compEll(ellObj,varargin)
                import elltool.core.GenEllipsoid;
                ellSecObj=GenEllipsoid(varargin{:});
                [isOk,reportStr]=eq(ellObj,ellSecObj);
                mlunitext.assert_equals(true,isOk,reportStr);
            end
            
        end
        %
        function self = testMinkSumEa(self)
            import elltool.core.GenEllipsoid;
            import elltool.conf.Properties;
            %
            load(strcat(self.testDataRootDir,filesep,'testNewEll.mat'),...
                'testEll2x2Mat','testEll2x3Mat','testEll10x2Mat',...
                'testEll10x3Mat','testEll10x20Mat',...
                'testEll10x50Mat','testEll10x100Mat');
            %
            
            % Test#1. Two non-degenerate ellipsoids. Zero centers.
            %Simple diagonal matrices. Simple direction. 2D case.
            q1Mat=[1 0;0 1];
            q2Mat=[9 0;0 9];
            dirVec=[1, 0].';
            cen1Vec=[0;0];
            cen2Vec=[0;0];
            
            checkWOld(dirVec);
            %
            %Test#2. Two ellipses. Non-degenerate. Non-zero centers.
            %Simple diagonal matrices. Simple direction. 2D case.
            q1Mat=[1 0;0 1];
            q2Mat=[9 0;0 9];
            cen1Vec=[1,-5].';
            cen2Vec=[10,20].';
            dirVec=[1, 0].';
            checkWOld(dirVec);
            %
            %Test#3. Two ellipses. Non-degenerate. Non-zero centers.
            % Diagonal matrices.
            % Simple direction. Ellipses, not circles. 2D case.
            q1Mat=[1 0;0 25];
            q2Mat=[9 0;0 16];
            cen1Vec=[5,-7].';
            cen2Vec=[1,1.55].';
            dirVec=[1, 0].';
            checkWOld(dirVec);
            %
            nDir=20;
            angleSt=2*pi/nDir;
            angleVec=0:angleSt:2*pi-angleSt;
            dirMat=[cos(angleVec); sin(angleVec)];
            %
            %Test#4. Two ellipsoids. Non-degenerate. Non-zero centers.
            % Diagonal matrices. Multiple various directions.
            % Ellipses, not circles. 2D case.
            q1Mat=[1 0;0 25];
            q2Mat=[9 0;0 16];
            cen1Vec=[5,-7].';
            cen2Vec=[1,1.55].';
            checkWOld(dirMat);
            %
            %Test#5. Two ellipsoids. Non-degenerate. Non-zero centers.
            % Random matrices.
            % Multiple various directions. Ellipses, not circles. 2D case.
            q1Mat=testEll2x2Mat{1};
            q2Mat=testEll2x2Mat{2};
            cen1Vec=[1,2].';
            cen2Vec=[-5,10].';
            checkWOld(dirMat);
            %
            %Test#6. Ten ellipsoids. Non-degenerate. Non-zero centers.
            % Non-diagonal matrices. Random matrices.
            % Multiple various directions. Ellipses, not circles. 3D case.
            checkMellMdir(testEll10x3Mat,10,3);
            %
            % Test#7. Ten ellipsoids. Non-degenerate. Non-zero centers.
            % Non-diagonal matrices. Random matrices.
            % A lot of multiple various directions. Ellipses, not circles.
            % 20D case.
            checkMellMdir(testEll10x20Mat,10,20);
            %
            % Test#8. Two ellipsoids. Degenerate case.
            % Bounded result.
            testEllVec(1)=GenEllipsoid([1 0; 0 1]);
            testEllVec(2)=GenEllipsoid([1 0; 0 0]);
            testDirVec=[1 0].';
            ansEllObj=GenEllipsoid([4 0; 0 2]);
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#8. Two ellipsoids. Degenerate case.
            % Unbounded result.
            testEllVec(1)=GenEllipsoid([1 0; 0 1]);
            testEllVec(2)=GenEllipsoid([1 0; 0 0]);
            testDirVec=[0 1].';
            ansEllObj=GenEllipsoid([Inf 1].');
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#9. Two ellipsoids. Degenerate case.
            % Zero Matrix.
            testEllVec(1)=GenEllipsoid([1 2; 2 5]);
            testEllVec(2)=GenEllipsoid([0 0; 0 0]);
            testDirVec=[cos(0.7) sin(0.7)].';
            ansEllObj=GenEllipsoid([1 2;2 5].');
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#10. Two ellipsoids. Degenerate case.
            % Two directions. 2D case.
            testEllVec(1)=GenEllipsoid([10 0; 0 0]);
            testEllVec(2)=GenEllipsoid([0 0; 0 20]);
            testDirMat=[0,1;1,0];
            ansEllVec=[ GenEllipsoid([Inf 0; 0 20]), ...
                GenEllipsoid([10 0; 0 Inf])];
            checkAns(@minkSumEa,testEllVec,ansEllVec,testDirMat);
            clear testEllVec
            %
            % Test#11. Three ellipsoids. Degenerate case.
            % One directions. 3D case.
            testEllVec(1)=GenEllipsoid([10;25;30]);
            testEllVec(2)=GenEllipsoid([2 0 0;0 0 0;0 0 0]);
            testEllVec(3)=GenEllipsoid([0 0 0;0 9 0;0 0 0]);
            testDirVec=[0,1,0].';
            ansEllObj=GenEllipsoid([Inf 0 0; 0 64 0;0 0 48]);
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#12. Two. Infinite, non-degenerate case.
            % One directions. 2D case.
            testEllVec(1)=GenEllipsoid([1;Inf]);
            testEllVec(2)=GenEllipsoid([1 1].');
            testDirVec=[1,1].';
            testDirVec=testDirVec/norm(testDirVec);
            ansEllObj=GenEllipsoid([4 0; 0 Inf]);
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#13. Two. Infinite, degenerate case.
            % One directions. 2D case.
            testEllVec(1)=GenEllipsoid([0;Inf]);
            testEllVec(2)=GenEllipsoid([1 1].');
            testDirVec=[1,1].';
            testDirVec=testDirVec/norm(testDirVec);
            ansEllObj=GenEllipsoid([1 0; 0 Inf]);
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#14. Two. Infinite, degenerate case.
            % One directions. 2D case. Another direction
            testEllVec(1)=GenEllipsoid([0;Inf]);
            testEllVec(2)=GenEllipsoid([1 1].');
            testDirVec=[1,0].';
            testDirVec=testDirVec/norm(testDirVec);
            ansEllObj=GenEllipsoid([1 0; 0 Inf]);
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#15. Two. Infinite, degenerate case.
            % One directions. 3D case.
            testEllVec(1)=GenEllipsoid([0;Inf;1]);
            testEllVec(2)=GenEllipsoid([3 2 1].');
            testDirVec=[1,1,1].';
            testDirVec=testDirVec/norm(testDirVec);
            ansEllObj=GenEllipsoid([4.5; Inf; 4.5]);
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#16. Two. Infinite, degenerate case.
            % One directions. 3D case. Degenerate direction
            testEllVec(1)=GenEllipsoid([0;Inf;1]);
            testEllVec(2)=GenEllipsoid([3 2 1].');
            testDirVec=[0,1,0].';
            testDirVec=testDirVec/norm(testDirVec);
            ansEllObj=GenEllipsoid([Inf; Inf; Inf]);
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            function checkWOld(dirMat)
                %Compare to old function
                import elltool.core.GenEllipsoid;
                ellNew1Obj=GenEllipsoid(cen1Vec,q1Mat);
                ellNew2Obj=GenEllipsoid(cen2Vec,q2Mat);
                resNewEllVec=minkSumEa([ellNew1Obj,ellNew2Obj],dirMat);
                resOldEllVec=minksum_ea([ellipsoid(cen1Vec,q1Mat),...
                    ellipsoid(cen2Vec,q2Mat)],dirMat);
                isOkVec=arrayfun(@isEllNewOldEqual,resNewEllVec,...
                    resOldEllVec);
                isOk=all(isOkVec);
                mlunitext.assert(isOk);
            end
            %
            function checkMellMdir(testEllMat,nElems,nDim)
                %check multiple directions and multiple ellipsoids
                import elltool.core.GenEllipsoid;
                testEllNewVec(nElems)=GenEllipsoid();
                testEllOldVec(nElems)=ellipsoid();
                for iElem=1:nElems
                    centerVec=iElem*(1:nDim).';
                    qMat=testEllMat{iElem};
                    testEllNewVec(iElem)=GenEllipsoid(centerVec,qMat);
                    testEllOldVec(iElem)=ellipsoid(centerVec,qMat);
                end
                nDirs=5;
                angleStep=2*pi/nDirs;
                phiAngle=0:angleStep:2*pi-angleStep;
                dirsMat=[cos(phiAngle); sin(phiAngle); ...
                    zeros(nDim-2,nDirs)];
                resNewEllVec=minkSumEa(testEllNewVec,dirsMat);
                resOldEllVec=minksum_ea(testEllOldVec,dirsMat);
                isOkVec=arrayfun(@isEllNewOldEqual,resNewEllVec,...
                    resOldEllVec);
                isOk=all(isOkVec);
                mlunitext.assert(isOk);
            end
        end
        %
        %
        %
        function self = testMinkDiffIa(self)
            import elltool.core.GenEllipsoid;
            %
            load(strcat(self.testDataRootDir,filesep,'testNewEll.mat'),...
                'testEll2x2Mat','testEll2x3Mat','testEll10x2Mat',...
                'testEll10x3Mat','testEll10x20Mat',...
                'testEll10x50Mat','testEll10x100Mat');
            %
            load(strcat(self.testDataRootDir,filesep,...
                'testNewEllRandM.mat'),...
                'testOrth2Mat','testOrth3Mat',...
                'testOrth20Mat','testOrth50Mat',...
                'testOrth100Mat');
            %
            %Simple.
            q1Mat=2*eye(2);
            q2Mat=[1 0; 0 0.1];
            cen1Vec=[10;0];
            cen2Vec=[0;0];
            dirVec=[1,0].';
            checkWOld(dirVec);
            %
            %Difference between sphere and random ellipse.
            q1Mat=2*eye(2);
            q2Mat=[1 0; 0 0.1];
            q2Mat=testOrth2Mat*q2Mat*testOrth2Mat.';
            cen1Vec=[10;0];
            cen2Vec=[0;0];
            phi=pi/6;
            dirVec=[cos(phi) sin(phi) ].';
            checkWOld(dirVec);
            %
            %Difference between 3-dimension ellipsoids.
            checkHighDim(3,testOrth3Mat,1);
            %
            %Difference between high dimension ellipsoids. 100D case.
            checkHighDim(100,testOrth100Mat,1);
            %
            %Difference between high dimension ellipsoids. 100D case.
            %Non-zero centers.
            checkHighDim(100,testOrth100Mat,0);
            %
            %Difference between 3-dimension ellipsoids.
            %Degenerate case
            test1Mat=diag([1;2;0]);
            test2Mat=diag([0.5;1;0]);
            testEllipsoid1=GenEllipsoid(test1Mat);
            testEllipsoid2=GenEllipsoid(test2Mat);
            phi=pi/2.1;
            dirVec=[cos(phi);sin(phi);zeros(1,1)];
            resOldEllipsoid=minkdiff_ia(ellipsoid(test1Mat(1:2,1:2)),...
                ellipsoid(test2Mat(1:2,1:2)),dirVec(1:2));
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            [eigOMat diaOMat]=eig(oldQMat);
            ansWMat=zeros(3);
            ansWMat(1:2,1:2)=eigOMat;
            ansWMat(3,3)=1;
            ansDMat=zeros(3);
            ansDMat(1:2,1:2)=diaOMat;
            ansEllObj=GenEllipsoid([oldCenVec; 0],ansDMat,ansWMat);
            %
            checkAns(@(x,y)minkDiffIa(x(1),x(2),y),...
                [testEllipsoid1,testEllipsoid2],ansEllObj,dirVec);
            %
            
            %Difference between 3-dimension ellipsoids.
            %Infinite case. Rotated.
            test1Mat=diag([Inf;5;5]);
            test2Mat=diag([Inf;1;1]);
            cenVec=zeros(3,1);
            testEllipsoid1=GenEllipsoid(cenVec,test1Mat,testOrth3Mat);
            testEllipsoid2=GenEllipsoid(cenVec,test2Mat,testOrth3Mat);
            dirVec=[0;10;-1];
            dirVec=dirVec/norm(dirVec);
            dirVec=testOrth3Mat*dirVec;
            resEllipsoid=minkDiffIa(testEllipsoid1,...
                testEllipsoid2, dirVec);
            resOldEllipsoid=minkdiff_ia(ellipsoid(test1Mat(2:3,2:3)),...
                ellipsoid(test2Mat(2:3,2:3)),dirVec(2:3));
            [~, oldQMat]=double(resOldEllipsoid);
            [~, diaOMat]=eig(oldQMat);
            ansDMat=zeros(3);
            ansDMat(1,1)=Inf;
            ansDMat(2:3,2:3)=diaOMat;
            %
            compEll(GenEllipsoid(resEllipsoid.getDiagMat()),ansDMat);
            %
            %Difference between 3-dimension ellipsoids.
            %Infinite and degenerate
            test1Mat=diag([Inf;Inf;1]);
            test2Mat=diag([1;1;0]);
            cenVec=zeros(3,1);
            testEllipsoid1=GenEllipsoid(cenVec,test1Mat,testOrth3Mat.');
            testEllipsoid2=GenEllipsoid(cenVec,test2Mat,testOrth3Mat.');
            dirVec=[1;1;1];
            dirVec=dirVec/norm(dirVec);
            ansEllObj=GenEllipsoid([0;0;0], diag([Inf,Inf,1]),testOrth3Mat.');
            checkAns(@(x,y)minkDiffIa(x(1),x(2),y),...
                [testEllipsoid1,testEllipsoid2],ansEllObj,dirVec);
            %
            function compEll(ellObj,varargin)
                import elltool.core.GenEllipsoid;
                ellSecObj=GenEllipsoid(varargin{:});
                [isOk,reportStr]=eq(ellObj,ellSecObj);
                mlunitext.assert_equals(true,isOk,reportStr);
            end
            function checkWOld(dirMat)
                %Compare with old function
                import elltool.core.GenEllipsoid;
                ellNew1Obj=GenEllipsoid(cen1Vec,q1Mat);
                ellNew2Obj=GenEllipsoid(cen2Vec,q2Mat);
                resNewEllVec=minkDiffIa(ellNew1Obj,ellNew2Obj,dirMat);
                resOldEllVec=minkdiff_ia(ellipsoid(cen1Vec,q1Mat),...
                    ellipsoid(cen2Vec,q2Mat),dirMat);
                isOkVec=arrayfun(@isEllNewOldEqual,resNewEllVec,...
                    resOldEllVec);
                isOk=all(isOkVec);
                mlunitext.assert(isOk);
            end
            %
            function checkHighDim(nDim, oMat, isZeroCenter)
                q1Mat=rotateM(10*diag(1:nDim),oMat);
                q2Mat=rotateM(diag(1:nDim),oMat);
                if isZeroCenter
                    cen1Vec=zeros(nDim,1);
                    cen2Vec=zeros(nDim,1);
                else
                    cen1Vec=(1:nDim)';
                    cen2Vec=(-floor(nDim/2)+1:floor(nDim/2)).';
                end
                angle=pi/6;
                dirsVec=[cos(angle);sin(angle);zeros(nDim-2,1)];
                dirsVec=oMat*dirsVec;
                checkWOld(dirsVec);
            end
        end
        %
        %
        %
        function self = testMinkSumIa(self)
            import elltool.core.GenEllipsoid;
            %
            load(strcat(self.testDataRootDir,filesep,'testNewEll.mat'),...
                'testEll2x2Mat','testEll2x3Mat','testEll10x2Mat',...
                'testEll10x3Mat','testEll10x20Mat',...
                'testEll10x50Mat','testEll10x100Mat');
            %
            load(strcat(self.testDataRootDir,filesep,...
                'testNewEllRandM.mat'),...
                'testOrth2Mat','testOrth3Mat',...
                'testOrth20Mat','testOrth50Mat',...
                'testOrth100Mat');
            %
            %(o2)Infinite+nondegenerate.
            test1WMat=[1 -1;1 1];
            test1WMat=test1WMat/norm(test1WMat);
            test1DVec=[Inf 0].';
            test2DVec=[1 1].';
            testEllipsoid1=GenEllipsoid([0,0].',test1DVec,test1WMat);
            testEllipsoid2=GenEllipsoid(test2DVec);
            dirVec=[1 10].';
            dirVec=dirVec/norm(dirVec);
            %
            ansDiagVec=[Inf 1].';
            ansEigvMat=[1 -1; 1 1];
            ansEigvMat=ansEigvMat/norm(ansEigvMat);
            ansCenVec=[0 0].';
            ansEllipsoid=GenEllipsoid(ansCenVec,ansDiagVec,ansEigvMat);
            %
            checkAns(@minkSumIa,[testEllipsoid1, testEllipsoid2],...
                ansEllipsoid,dirVec);
            %
            %Infinite+nondegenerate. Direction is collinear
            %to inf eigenvector. Result - R^2.
            test1WMat=[1 -1;1 1];
            test1WMat=test1WMat/norm(test1WMat);
            test1DVec=[Inf 0].';
            test2DVec=[1 1].';
            testEllipsoid1=GenEllipsoid([0,0].',test1DVec,test1WMat);
            testEllipsoid2=GenEllipsoid(test2DVec);
            dirVec=[1 1].';
            dirVec=dirVec/norm(dirVec);
            %
            ansDiagVec=[Inf Inf].';
            ansEigvMat=[1 0; 0 1];
            ansCenVec=[0 0].';
            ansEllipsoid=GenEllipsoid(ansCenVec,ansDiagVec,ansEigvMat);
            %
            checkAns(@minkSumIa,[testEllipsoid1, testEllipsoid2],...
                ansEllipsoid,dirVec);
            %
            %(o3)Infinite+nondegenerate. 3d-case
            nDim=3;
            test1WMat=eye(nDim);
            test1DVec=[1 2 Inf].';
            test2DVec=[3 4 5].';
            testEllipsoid1=GenEllipsoid([0,0,0].',test1DVec,test1WMat);
            testEllipsoid2=GenEllipsoid(test2DVec);
            dirVec=[1 1 0].';
            dirVec=dirVec/norm(dirVec);
            %
            %compute result for projections by old method
            auxEll1=ellipsoid(diag([1 2].'));
            auxEll2=ellipsoid(diag([3 4].'));
            dirAuxVec=dirVec(1:2);
            auxEll=minksum_ia([auxEll1,auxEll2],dirAuxVec);
            [auxCenVec auxQMat]=double(auxEll);
            [auxEigvMat auxDiagMat]=eig(auxQMat);
            ansCenVec=[auxCenVec; 0];
            ansEigvMat=eye(nDim);
            ansDiagVec=zeros(nDim,1);
            ansEigvMat(1:2, 1:2)=auxEigvMat;
            ansDiagVec(1:2)=diag(auxDiagMat);
            ansDiagVec(3)=Inf;
            ansEllipsoid=GenEllipsoid(ansCenVec,ansDiagVec,ansEigvMat);
            %
            checkAns(@minkSumIa,[testEllipsoid1, testEllipsoid2],...
                ansEllipsoid,dirVec);
            %
            %(o5)Infinite,nondegenerate+Infinite,nondegenerate.
            test1WMat=[1 -1;1 1];
            test1WMat=test1WMat/norm(test1WMat);
            test1DVec=[Inf 0].';
            test2WMat=[1 -10; 10 1];
            test2WMat=test2WMat/norm(test2WMat);
            test2DVec=[Inf 1].';
            testEllipsoid1=GenEllipsoid([0,0].',test1DVec,test1WMat);
            testEllipsoid2=GenEllipsoid([0,0].',test2DVec,test2WMat);
            dirVec=[-1 10].';
            dirVec=dirVec/norm(dirVec);
            %
            ansDiagVec=[Inf Inf].';
            ansEigvMat=[1 0; 0 1];
            ansCenVec=[0 0].';
            ansEllipsoid=GenEllipsoid(ansCenVec,ansDiagVec,ansEigvMat);
            %
            checkAns(@minkSumIa,[testEllipsoid1, testEllipsoid2],...
                ansEllipsoid,dirVec);
            %
            %(o7)Two degenerate. 3d-case
            test1QMat=[1 0 0;0 0 0;0 0 0];
            test2QMat=[0 0 0;0 2 0;0 0 0];
            cen1Vec=[1 1 1].';
            cen2Vec=[1 -1 10].';
            testEllipsoid1=GenEllipsoid(cen1Vec,test1QMat);
            testEllipsoid2=GenEllipsoid(cen2Vec,test2QMat);
            dirVec=[1 0 0].';
            dirVec=dirVec/norm(dirVec);
            %
            ansCenVec=[2; 0; 11];
            ansEigvMat=eye(3);
            ansDiagVec=diag([1 0 0]);
            ansEllipsoid=GenEllipsoid(ansCenVec,ansDiagVec,ansEigvMat);
            %
            checkAns(@minkSumIa,[testEllipsoid1, testEllipsoid2],...
                ansEllipsoid,dirVec);
        end
        %
        function self = testMinkDiffEa(self)
            %
            import elltool.core.GenEllipsoid;
            %
            load(strcat(self.testDataRootDir,filesep,'testNewEll.mat'),...
                'testEll2x2Mat','testEll2x3Mat','testEll10x2Mat',...
                'testEll10x3Mat','testEll10x20Mat',...
                'testEll10x50Mat','testEll10x100Mat');
            %
            load(strcat(self.testDataRootDir,filesep,...
                'testNewEllRandM.mat'),...
                'testOrth2Mat','testOrth3Mat',...
                'testOrth20Mat','testOrth50Mat',...
                'testOrth100Mat');
            %
            %Simple.
            q1Mat=2*eye(2);
            q2Mat=[1 0; 0 0.1];
            cen1Vec=[0;0];
            cen2Vec=[0;0];
            dirVec=[1,0].';
            checkWOld(dirVec);
            %
            %Difference between sphere and  ellipse.
            q1Mat=2*eye(2);
            q2Mat=rotateM([1 0; 0 0.1],testOrth2Mat);
            cen1Vec=[0;0];
            cen2Vec=[0;0];
            phi=pi/6;
            dirVec=[cos(phi) sin(phi) ].';
            checkWOld(dirVec);
            %
            %Difference between 3-dimension ellipsoids.
            checkHighDim(3,testOrth3Mat,1);
            %Difference between high dimension ellipsoids. 100D case.
            checkHighDim(100,testOrth100Mat,1);
            %
            %Difference between high dimension ellipsoids. 100D case.
            %Non-zero centers.
            checkHighDim(100,testOrth100Mat,0);
            %
            %Difference between 3-dimension ellipsoids.
            %Degenerate case
            test1Mat=diag([1;2;0]);
            test2Mat=diag([0.5;1;0]);
            testEllipsoid1=GenEllipsoid(test1Mat);
            testEllipsoid2=GenEllipsoid(test2Mat);
            phi=pi/2.1;
            dirVec=[cos(phi);sin(phi);zeros(1,1)];
            %
            resOldEllipsoid=minkdiff_ea(ellipsoid(test1Mat(1:2,1:2)),...
                ellipsoid(test2Mat(1:2,1:2)),dirVec(1:2));
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            [eigOMat diaOMat]=eig(oldQMat);
            ansWMat=zeros(3);
            ansWMat(1:2,1:2)=eigOMat;
            ansWMat(3,3)=1;
            ansDMat=zeros(3);
            ansDMat(1:2,1:2)=diaOMat;
            ansEllipsoid=GenEllipsoid([oldCenVec; 0],ansDMat,ansWMat);
            checkAns(@(x,y)minkDiffEa(x(1),x(2),y),...
                [testEllipsoid1,testEllipsoid2],ansEllipsoid,dirVec);
            %
            %Difference between 3-dimension ellipsoids.
            %Infinite case. Rotated.
            test1Mat=diag([Inf;5;5]);
            test2Mat=diag([Inf;1;1]);
            cenVec=zeros(3,1);
            testEllipsoid1=GenEllipsoid(cenVec,test1Mat,testOrth3Mat);
            testEllipsoid2=GenEllipsoid(cenVec,test2Mat,testOrth3Mat);
            dirVec=[0;10;-1];
            dirVec=dirVec/norm(dirVec);
            dirVec=testOrth3Mat*dirVec;
            resEllipsoid=minkDiffEa(testEllipsoid1, testEllipsoid2,...
                dirVec);
            resOldEllipsoid=minkdiff_ea(ellipsoid(test1Mat(2:3,2:3)),...
                ellipsoid(test2Mat(2:3,2:3)),dirVec(2:3));
            [~, oldQMat]=double(resOldEllipsoid);
            [~, diaOMat]=eig(oldQMat);
            ansDMat=zeros(3);
            ansDMat(1,1)=Inf;
            ansDMat(2:3,2:3)=diaOMat;
           %
            compEll(GenEllipsoid(resEllipsoid.getDiagMat()),ansDMat);
            %
            %Difference between 3-dimension ellipsoids.
            %Infinite and degenerate
            test1Mat=diag([Inf;Inf;1]);
            test2Mat=diag([1;1;0.1]);
            cenVec=zeros(3,1);
            testEllipsoid1=GenEllipsoid(cenVec,test1Mat);
            testEllipsoid2=GenEllipsoid(cenVec,test2Mat);
            dirVec=[1;0;0];
            dirVec=dirVec/norm(dirVec);
            %FIXME - this doesn't seem to be correct
            ansEllObj=GenEllipsoid(diag([Inf;Inf;Inf]));
            %
            checkAns(@(x,y)minkDiffEa(x(1),x(2),y),...
                [testEllipsoid1,testEllipsoid2],ansEllObj,dirVec);
            %
            function compEll(ellObj,varargin)
                import elltool.core.GenEllipsoid;
                ellSecObj=GenEllipsoid(varargin{:});
                [isOk,reportStr]=eq(ellObj,ellSecObj);
                mlunitext.assert_equals(true,isOk,reportStr);
            end
            function checkHighDim(nDim, oMat, isZeroCenter)
                q1Mat=rotateM(10*diag(1:nDim),oMat);
                q2Mat=rotateM(diag(1:nDim),oMat);
                if isZeroCenter
                    cen1Vec=zeros(nDim,1);
                    cen2Vec=zeros(nDim,1);
                else
                    cen1Vec=(1:nDim)';
                    cen2Vec=(-floor(nDim/2)+1:floor(nDim/2)).';
                end
                angle=pi/6;
                dirsVec=[cos(angle);sin(angle);zeros(nDim-2,1)];
                dirsVec=oMat*dirsVec;
                checkWOld(dirsVec);
            end
            %
            function checkWOld(dirMat)
                %Compare to old function
                import elltool.core.GenEllipsoid;
                ellNew1Obj=GenEllipsoid(cen1Vec,q1Mat);
                ellNew2Obj=GenEllipsoid(cen2Vec,q2Mat);
                resNewEllVec=minkDiffEa(ellNew1Obj,ellNew2Obj,dirMat);
                resOldEllVec=minkdiff_ea(ellipsoid(cen1Vec,q1Mat),...
                    ellipsoid(cen2Vec,q2Mat),dirMat);
                isOkVec=arrayfun(@isEllNewOldEqual,resNewEllVec,...
                    resOldEllVec);
                isOk=all(isOkVec);
                mlunitext.assert(isOk);
            end
        end
        %
        function testRotation(~)
            d1Vec=[0 0 Inf 0 2 3];
            d2Vec=[1 Inf 0 0 2 Inf];
            nDims=numel(d1Vec);
            lVec=rand(nDims,1);
            [oMat,~]=qr(rand(nDims,nDims));
            %
            check(oMat,@minkSumIa,lVec);
            check(oMat,@minkSumEa,lVec);
            %
            d1Vec=[1   Inf 0 2 2 0];
            d2Vec=[0.5 Inf 0 0 2 0];
            %
            check(oMat,@(x,y)minkDiffIa(x(1),x(2),y),lVec);
            check(oMat,@(x,y)minkDiffEa(x(1),x(2),y),lVec);
            %
            function check(oMat,fMethod,lVec)
                ell1Apx=build(oMat,fMethod,oMat*lVec);
                ell2Apx=build(eye(numel(lVec)),fMethod,lVec);
                [isEqual,reportStr]=eq(ell1Apx, ell2Apx);
                mlunitext.assert(isEqual,reportStr);
            end
            function ellApx=build(oMat,fMethod,lVec)
                import elltool.core.GenEllipsoid;
                ell1=GenEllipsoid(zeros(nDims,1),diag(d1Vec),oMat);
                ell2=GenEllipsoid(zeros(nDims,1),diag(d2Vec),oMat);
                ellVec=[ell1,ell2];
                ellApx=fMethod(ellVec,lVec);
                eigVMat=ellApx.getEigvMat();
                if ~isempty(eigVMat)
                    eigVMat=oMat.'*eigVMat;
                    ellApx=GenEllipsoid(ellApx.getCenter(),ellApx.getDiagMat(),...
                        eigVMat);
                end
            end
        end
        %
        function testDirections(self)
            load(strcat(self.testDataRootDir,filesep,...
                'testNewEllRandM.mat'),'testOrth50Mat',...
                'testOrth20Mat','testOrth100Mat','testOrth3Mat',...
                'testOrth2Mat');
            import elltool.core.GenEllipsoid;
            load(strcat(self.testDataRootDir,filesep,...
                'testEllEllRMat.mat'),'testOrth3Mat');
            %Test1.
            testEllipsoid1=GenEllipsoid([4;3]);
            testEllipsoid2=GenEllipsoid([1;0]);
            dirVec=[0,1].';
            dirVec=dirVec/norm(dirVec);
            checkRes();
            %
            %Test2.
            testEllipsoid1=GenEllipsoid([0;0;0],[4;3;4],testOrth3Mat.');
            testEllipsoid2=GenEllipsoid([0;0;0],[1;0;0],testOrth3Mat.');
            dirVec=testOrth3Mat.'*[0,0,1].';
            dirVec=dirVec/norm(dirVec);
            checkRes();
            %
            %Test3.
            %q1Mat=[
            delta1=pi/2-atan(4);
            delta2=atan(3);
            nDir=10;
            nDim=20;
            angleBadVec=pi/2-delta1:2*delta1/(nDir-1):pi/2+delta1;
            angleGoodVec=-delta2:2*delta2/(nDir-1):delta2;
            %
            badDirMat=[cos(angleBadVec);sin(angleBadVec);...
                zeros(nDim-2,nDir)];
            goodDirMat=[cos(angleGoodVec);sin(angleGoodVec);...
                zeros(nDim-2,nDir)];
            badDirMat=testOrth20Mat*badDirMat;
            goodDirMat=testOrth20Mat*goodDirMat;
            %
            testEllipsoid1=GenEllipsoid(zeros(nDim,1),...
                [16;3;Inf;(1:17)'],testOrth20Mat);
            testEllipsoid2=GenEllipsoid(zeros(nDim,1),...
                [4;0;0.1*(1:18)'],testOrth20Mat);
            %
            ell1Vec=minkDiffEa(testEllipsoid1,testEllipsoid2,badDirMat);
            ell2Vec=minkDiffEa(testEllipsoid1,testEllipsoid2,goodDirMat);
            %
            fCheckGood=@(ellObj)checkEllEmpty(ellObj,1);
            fCheckBad=@(ellObj)checkEllEmpty(ellObj,0);
            arrayfun(fCheckGood,ell1Vec);
            arrayfun(fCheckBad,ell2Vec);
            function checkEllEmpty(ellObj,isCheckEmpty)
                import elltool.core.GenEllipsoid;
                [isOk,reportStr]=eq(ellObj,GenEllipsoid());
                if ~isCheckEmpty
                    isOk=~isOk;
                end
                mlunitext.assert(isOk,reportStr);
            end
            function checkRes()
                resEll=minkDiffEa(testEllipsoid1,testEllipsoid2,dirVec);
                checkEllEmpty(resEll,1);
            end
        end
        
        function testAllDirRand(self)
            import elltool.core.test.mlunit.GenEllipsoidTestCase;
            import elltool.core.GenEllipsoid;
            load(strcat(self.testDataRootDir,filesep,...
                'testEllEllRMat.mat'),'testOrth50Mat',...
                'testOrth100Mat','testOrth3Mat','testOrth2Mat');
            %
            import elltool.core.GenEllipsoid;
            nEllObj=10;
            nDim=50;
            nDir=10;
            dirRandMat=zeros(nDim,nDir);
            for iDir=1:nDir
                dirVec=rand(nDim,1);
                dirVec=dirVec/norm(dirVec);
                dirRandMat(:,iDir)=dirVec;
            end
            GenEllipsoidTestCase.auxCheckAllbV(nEllObj,nDim,...
                dirRandMat,testOrth50Mat);
        end
        function testAllDirFixed(self)
            import elltool.core.test.mlunit.GenEllipsoidTestCase;
            import elltool.core.GenEllipsoid;
            load(strcat(self.testDataRootDir,filesep,...
                'testNewEllRandM.mat'),'testOrth50Mat',...
                'testOrth20Mat','testOrth100Mat','testOrth3Mat',...
                'testOrth2Mat');
            %
            load(strcat(self.testDataRootDir,filesep,'testNewDirM.mat'),...
                'test10x50DirMat','test10x100DirMat',...
                'test30x50DirMat','test50x50DirMat',...
                'test50x100DirMat','test30x50nDirMat','test20x50DirMat');
            %
            nEllObj=10;
            nDim=50;
            %
            GenEllipsoidTestCase.auxCheckAllbV(nEllObj,nDim,...
                test10x50DirMat,testOrth50Mat);
        end
    end
    methods(Static)
        function auxCheckAllbV(nEllObj,nDim,dirMat,oMat)
            import elltool.core.GenEllipsoid;
            %Massives of ellipsoid size of nEllObj
            %For Sum
            ellNINDCSumVec=buildNINDCSum(); %Non-Infinite Non-Degenerate Case
            ellNIDCSumVec=buildNIDCSum();   %Non-Infinite Degenerate Case
            ellINDCSumVec=buildINDCSum();   %Infinite Non-Degenerate Case
            ellIDCSumVec=buildIDCSum();     %Infinite Degenerate Case
            %For Diff
            ellNINDCDiffVec=buildDiff('NINDC');%Non-Infinite Non-Degenerate Case
            ellNIDCDiffVec=buildDiff('NIDC');  %Non-Infinite Degenerate Case
            ellINDCDiffVec=buildDiff('INDC');  %Infinite Non-Degenerate Case
            ellIDCDiffVec=buildDiff('IDC');    %Infinite Degenerate Case
            %Check for rotation matrices O,O^2,...O^nDeg.
            curOrthMat=eye(size(oMat));
            nDir=size(dirMat,2);
            dirCMat=mat2cell(dirMat,nDim,ones(1,nDir));
            nDeg=10;
            for iDeg=1:nDeg
                curOrthMat=curOrthMat*oMat;
                checkDir=@(dirCVec)checkAll(dirCVec{:},curOrthMat);
                arrayfun(checkDir,dirCMat);
            end
            %
            function checkAll(dirVec,oMat)
                checkM(@minkSumIa,ellNINDCSumVec,dirVec,oMat)
                checkM(@minkSumIa,ellINDCSumVec,dirVec,oMat)
                checkM(@minkSumIa,ellNIDCSumVec,dirVec,oMat)
                checkM(@minkSumIa,ellIDCSumVec,dirVec,oMat)
                %
                checkM(@minkDiffIa,ellNINDCDiffVec,dirVec,oMat)
                checkM(@minkDiffIa,ellNIDCDiffVec,dirVec,oMat)
                checkM(@minkDiffIa,ellINDCDiffVec,dirVec,oMat)
                checkM(@minkDiffIa,ellIDCDiffVec,dirVec,oMat)
                %
                checkM(@minkDiffEa,ellNINDCDiffVec,dirVec,oMat)
                checkM(@minkDiffEa,ellNIDCDiffVec,dirVec,oMat)
                checkM(@minkDiffEa,ellINDCDiffVec,dirVec,oMat)
                checkM(@minkDiffEa,ellIDCDiffVec,dirVec,oMat)
                %
                checkM(@minkSumEa,ellNINDCSumVec,dirVec,oMat)
                checkM(@minkSumEa,ellINDCSumVec,dirVec,oMat)
                checkM(@minkSumEa,ellNIDCSumVec,dirVec,oMat)
                checkM(@minkSumEa,ellIDCSumVec,dirVec,oMat)
                %
            end
            %
            function checkM(fMethod,ellVec,dirVec,oMat)
                if isequal(fMethod,@minkDiffIa) || isequal(fMethod,...
                        @minkDiffEa)
                    isOk=isDiffCorrect(fMethod,ellVec,dirVec,oMat);
                else
                    isOk=isSumCorrect(fMethod,ellVec,dirVec,oMat);
                end
                mlunitext.assert(isOk);
            end
            %
            function [isEqual,reportStr]=isSumCorrect(fMethod,ellVec,dirVec,oMat)
                import elltool.core.GenEllipsoid;
                resR1Ell=fMethod(ellVec,dirVec);
                checkSumTight(resR1Ell,ellVec,dirVec)
                ellObjRotVec(nEllObj)=GenEllipsoid();
                for iEll=1:nEllObj
                    ellObjRotVec(iEll)=rotateEll(ellVec(iEll),oMat);
                end
                resR2Ell=fMethod(ellObjRotVec,oMat*dirVec);
                checkSumTight(resR2Ell,ellObjRotVec,oMat*dirVec);
                resR3Ell=rotateEll(resR2Ell,oMat.');
                [isEqual,reportStr]=eq(resR1Ell,resR3Ell);
            end
            function [isEqual,reportStr]=isDiffCorrect(fMethod,ellVec,dirVec,oMat)
                import elltool.core.GenEllipsoid;
                resR1Ell=fMethod(ellVec(1),ellVec(2),dirVec);
                if getIsGoodDir(ellVec(1),ellVec(2),dirVec)
                    checkDiffTight(resR1Ell,ellVec,dirVec)
                end
                ellObjRotVec(nEllObj)=GenEllipsoid();
                for iEll=1:2
                    ellObjRotVec(iEll)=rotateEll(ellVec(iEll),oMat);
                end
                rotDirVec=oMat*dirVec;
                resR2Ell=fMethod(ellObjRotVec(1),ellObjRotVec(2),...
                    rotDirVec);
                if  getIsGoodDir(ellVec(1),ellVec(2),rotDirVec)
                    checkDiffTight(resR2Ell,ellObjRotVec,rotDirVec)
                end
                if (~isempty(resR2Ell.getDiagMat()))
                    resR3Ell=rotateEll(resR2Ell,oMat.');
                    [isEqual,reportStr]=eq(resR1Ell,resR3Ell);
                else
                    if (isempty(resR1Ell.getDiagMat()))
                        isEqual=true;
                    else
                        isEqual=false;
                    end
                end
            end
            function [ellVec]=buildNINDCSum()
                import elltool.core.GenEllipsoid;
                ellVec(nEllObj)=GenEllipsoid();
                cenVec=zeros(nDim,1);
                for iEll=1:nEllObj
                    diagVec=(1:nDim).'*iEll/10;
                    ellVec(iEll)=GenEllipsoid(cenVec,diagVec);
                end
            end
            function [ellVec]=buildNIDCSum()
                import elltool.core.GenEllipsoid;
                ellVec(nEllObj)=GenEllipsoid();
                cenVec=zeros(nDim,1);
                for iEll=1:nEllObj
                    diagVec=(1:nDim).'*iEll/10;
                    diagVec(max(1,floor(nDim*iEll/nEllObj)))=0;
                    ellVec(iEll)=GenEllipsoid(cenVec,diagVec);
                end
            end
            function [ellVec]=buildINDCSum()
                import elltool.core.GenEllipsoid;
                ellVec(nEllObj)=GenEllipsoid();
                cenVec=zeros(nDim,1);
                diagVec=(1:nDim).'/10;
                diagVec(1)=Inf;
                ellVec(1)=GenEllipsoid(cenVec,diagVec);
                diagVec=(1:nDim).'/10;
                diagVec(end)=Inf;
                ellVec(end)=GenEllipsoid(cenVec,diagVec);
                for iEll=2:(nEllObj-1)
                    diagVec=(1:nDim).'*iEll/10;
                    ellVec(iEll)=GenEllipsoid(cenVec,diagVec);
                end
            end
            %
            function [ellVec]=buildIDCSum()
                import elltool.core.GenEllipsoid;
                ellVec(nEllObj)=GenEllipsoid();
                cenVec=zeros(nDim,1);
                diagVec=(1:nDim).'/10;
                diagVec(1)=Inf;
                ellVec(1)=GenEllipsoid(cenVec,diagVec);
                diagVec=(1:nDim).'/10;
                diagVec(end)=Inf;
                ellVec(end)=GenEllipsoid(cenVec,diagVec);
                for iEll=2:(nEllObj-1)
                    diagVec=(1:nDim).'*iEll/10;
                    diagVec(max(1,floor(nDim*iEll/nEllObj)))=0;
                    ellVec(iEll)=GenEllipsoid(cenVec,diagVec);
                end
            end
            %
            function ellVec=buildDiff(complStr)
                import elltool.core.GenEllipsoid;
                diag1Vec=(1:nDim).';
                diag2Vec=(1:nDim).'/3;
                cen1Vec=ones(nDim,1);
                cen2Vec=5*ones(nDim,1);
                if strcmp(complStr,'NIDC')
                    diag1Vec(1)=0;
                    diag2Vec(end-10:end)=0;
                    diag2Vec(1)=0;
                elseif strcmp(complStr,'INDC')
                    diag1Vec(2)=Inf;
                    diag1Vec(end-7:end)=Inf;
                    diag2Vec(2)=Inf;
                elseif strcmp(complStr,'IDC')
                    diag1Vec(1)=Inf;
                    diag1Vec(end-2:end-1)=Inf;
                    diag1Vec(2)=0;
                    diag2Vec(2)=0;
                    diag2Vec(end-3:end)=0;
                end
                ellVec(1)=GenEllipsoid(cen1Vec,diag1Vec);
                ellVec(2)=GenEllipsoid(cen2Vec,diag2Vec);
            end
        end
    end
end

function resEllObj=rotateEll(ellObj,oMat)
import elltool.core.GenEllipsoid;
eigvMat=ellObj.getEigvMat();
newVMat=oMat*eigvMat;
resEllObj=GenEllipsoid(ellObj.getCenter(),ellObj.getDiagMat(),newVMat);
end
%
function isEqual=isEqM( objMat1, objMat2,absTol)
isEqual=all(all(abs(objMat1-objMat2)<absTol));
end
%
function isEqual=isEqV( objVec1, objVec2,absTol)
isInf1Vec=objVec1==Inf;
isInf2Vec=objVec2==Inf;
isEqualInf=all(isInf1Vec==isInf2Vec);
isEqualFin=all(abs(objVec1(~isInf1Vec)-objVec2(~isInf2Vec))<absTol);
isEqual=isEqualInf && isEqualFin;
end
%
function isEqual=isEqElM(resEllipsoid,ansVMat,ansDVec,ansCenVec)
import elltool.core.GenEllipsoid;
absTol=GenEllipsoid.getCheckTol();
eigvMat=resEllipsoid.getEigvMat();
diagVec=diag(resEllipsoid.getDiagMat());
cenVec=resEllipsoid.getCenter();
%sort in increasing eigenvalue order
[diagVec indVec]=sort(diagVec);
eigvMat=eigvMat(:,indVec);
[ansDVec indVec]=sort(ansDVec);
ansVMat=ansVMat(:,indVec);
isEqual=isEqV(diagVec,ansDVec,absTol)&&...
    isEqV(cenVec,ansCenVec,absTol)&&...
    isEqM(eigvMat,ansVMat,absTol);
end
%
function [isEqual,reportStr]=isEllNewOldEqual(ellNewObj, ellOldObj)
import elltool.core.GenEllipsoid;
[cenOldVec qOldMat]=double(ellOldObj);
[isEqual,reportStr]=ellNewObj.eq(GenEllipsoid(cenOldVec, qOldMat));
end
%
function resMat=rotateM(qMat, oMat)
resMat=oMat*qMat*oMat.';
resMat=0.5*(resMat+resMat.');
end
%
function checkAns(fMethod,testEllVec,ansEllObj,testDirObj)
resEllObj=fMethod(testEllVec,testDirObj);
[isOkCVec,reportCVec]=arrayfun(@eq,resEllObj,ansEllObj,...
    'UniformOutput',false);
isOkVec=[isOkCVec{:}];
reportBadCVec=reportCVec(~isOkVec);
isOk=all(isOkVec);
if ~isOk
    reportStr=reportBadCVec{1};
else
    reportStr='';
end
mlunitext.assert_equals(true,isOk,reportStr);
if (isequal(fMethod,@minkSumIa) || isequal(fMethod,@minkSumEa))
    checkSumTight(ansEllObj,testEllVec,testDirObj(:,1));
else
    checkDiffTight(ansEllObj,testEllVec,testDirObj(:,1));
end
end
%
function checkSumTight(ellResObj, ellVec, dirVec)
import elltool.core.GenEllipsoid;
absTol=GenEllipsoid.getCheckTol();
nEll=length(ellVec);
sumOfRho=0;
for iEll=1:nEll;
    sumOfRho=sumOfRho+rho(ellVec(iEll),dirVec);
end
rhoOfSum=rho(ellResObj,dirVec);
isInf=(sumOfRho==Inf) && (rhoOfSum==Inf);
if ~isInf
    isTight=abs(rhoOfSum-sumOfRho)<absTol;
else
    isTight=isInf;
end
mlunitext.assert(isTight);
end
function checkDiffTight(ellResObj, ellVec, dirVec)
import elltool.core.GenEllipsoid;
absTol=GenEllipsoid.getCheckTol();
rho1=rho(ellVec(1),dirVec);
rho2=rho(ellVec(2),dirVec);
if rho1==Inf
    diffOfRho=Inf;
else
    diffOfRho=rho1-rho2;
end
rhoOfDiff=rho(ellResObj,dirVec);
isInf=(diffOfRho==Inf) && (rhoOfDiff==Inf);
if ~isInf
    isTight=abs(rhoOfDiff-diffOfRho)<absTol;
else
    isTight=isInf;
end
mlunitext.assert(isTight);
end
