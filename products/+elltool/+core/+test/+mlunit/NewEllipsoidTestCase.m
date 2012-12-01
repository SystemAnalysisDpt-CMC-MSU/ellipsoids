classdef NewEllipsoidTestCase < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
    end
    methods
        function self=NewEllipsoidTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData',...
                filesep,shortClassName];
            import elltool.core.Ellipsoid;
        end
        function self = testConstructor(self)
            import elltool.core.Ellipsoid;
            %
            load(strcat(self.testDataRootDir,filesep,...
                'testNewEllRandM.mat'),...
                'testOrth2Mat','testOrth3Mat',...
                'testOrth20Mat','testOrth50Mat',...
                'testOrth100Mat');
            %
            % Test#1. Ellipsoid(q,D,W)
            wMat=[1 1;1 2];
            dMat=[Inf 1].';
            resEllipsoid=Ellipsoid([0,0].',dMat,wMat);
            ansVMat=[-1 1; 1 1];
            ansVMat=ansVMat/norm(ansVMat);
            ansDMat=[0.5 Inf].';
            ansCenVec=[0 0].';
            %
            mlunit.assert_equals(1,isEqElM(resEllipsoid,...
                ansVMat,ansDMat,ansCenVec));
            %
            % Test#2. Ellipsoid(q,D,W)
            wMat=[1 2;1 2];
            dMat=[1 Inf].';
            resEllipsoid=Ellipsoid([0,0].',dMat,wMat);
            %
            ansVMat=[-1 1; 1 1];
            ansVMat=ansVMat/norm(ansVMat);
            ansDMat=[0 Inf].';
            ansCenVec=[0 0].';
            %
            mlunit.assert_equals(1,isEqElM(resEllipsoid,...
                ansVMat,ansDMat,ansCenVec));
            %
            % Test#3. Ellipsoid(q,D,W)
            wMat=testOrth2Mat;
            dMat=[5 Inf].';
            resEllipsoid=Ellipsoid([1,2].',dMat,wMat);
            %
            ansVMat=testOrth2Mat;
            ansDMat=[5 Inf].';
            ansCenVec=[1 2].';
            %
            mlunit.assert_equals(1,isEqElM(resEllipsoid,...
                ansVMat,ansDMat,ansCenVec));
            %
            % Test#4. Ellipsoid(q,D,W) 3d-case.
            % Orthogonal Matrix. Finite eigenvalues.
            nDims=3;
            wMat=testOrth3Mat;
            dMat=(1:nDims).';
            resEllipsoid=Ellipsoid(ones(nDims,1),dMat,wMat);
            %
            ansVMat=testOrth3Mat;
            ansDMat=(1:nDims).';
            ansCenVec=ones(nDims,1);
            %
            mlunit.assert_equals(1,isEqElM(resEllipsoid,...
                ansVMat,ansDMat,ansCenVec));
            %
            % Test#5. Ellipsoid(q,D,W)
            % 100-d case. Orthogonal matrix. Infinite eigenvalues.
            nDims=100;
            wMat=testOrth100Mat;
            dMat=[ Inf; Inf; (0:(nDims-4)).'; Inf];
            resEllipsoid=Ellipsoid(ones(nDims,1),dMat,wMat);
            %
            ansVMat=testOrth100Mat;
            ansDMat=[ Inf; Inf; (0:(nDims-4)).'; Inf];
            ansCenVec=ones(nDims,1);
            %
            mlunit.assert_equals(1,isEqElM(resEllipsoid,...
                ansVMat,ansDMat,ansCenVec));
            % Test#6. Ellipsoid(q,D,W)
            wMat=[1 0;2 0];
            dMat=[0 1].';
            resEllipsoid=Ellipsoid([0,0].',dMat,wMat);
            ansVMat=[-1 0; 0 -1];
            ansVMat=ansVMat/norm(ansVMat);
            ansDMat=[0 0].';
            ansCenVec=[0 0].';
            %
            mlunit.assert_equals(1,isEqElM(resEllipsoid,...
                ansVMat,ansDMat,ansCenVec));
        end
        %
        function self = testInv(self)
            import elltool.core.Ellipsoid;
            %
            load(strcat(self.testDataRootDir,filesep,...
                'testNewEllRandM.mat'),...
                'testOrth2Mat','testOrth3Mat',...
                'testOrth20Mat','testOrth50Mat',...
                'testOrth100Mat');
            %import elltool.core.Ellipsoid;
            %Test#1.
            nDim=100;
            cenVec=zeros(nDim,1);
            ellMat=testOrth100Mat*diag(1:nDim)*testOrth100Mat.';
            ellMat=0.5*(ellMat+ellMat.');
            testEll=Ellipsoid(cenVec,ellMat);
            resInvEll=testEll.inv();
            ansEll=ellipsoid(cenVec,ellMat);
            ansInvEll=inv(ansEll);
            [ansCenVec ansMat]=double(ansInvEll);
            %
            mlunit.assert_equals(1,isEllEll2Equal(resInvEll,...
                Ellipsoid(ansCenVec,ansMat)));
            %Test#2.
            testEll=Ellipsoid([0 5 Inf].');
            resInvEll=testEll.inv();
            mlunit.assert_equals(1,isEllEll2Equal(resInvEll,...
                Ellipsoid([Inf 0.2 0].')));
            
        end
        %
        function self = testMinkSumEa(self)
            import elltool.core.Ellipsoid;
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
            testEllVec(1)=Ellipsoid([1 0; 0 1]);
            testEllVec(2)=Ellipsoid([1 0; 0 0]);
            testDirVec=[1 0].';
            ansEllObj=Ellipsoid([4 0; 0 2]);
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#8. Two ellipsoids. Degenerate case.
            % Unbounded result.
            testEllVec(1)=Ellipsoid([1 0; 0 1]);
            testEllVec(2)=Ellipsoid([1 0; 0 0]);
            testDirVec=[0 1].';
            ansEllObj=Ellipsoid([Inf 1].');
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#9. Two ellipsoids. Degenerate case.
            % Zero Matrix.
            testEllVec(1)=Ellipsoid([1 2; 2 5]);
            testEllVec(2)=Ellipsoid([0 0; 0 0]);
            testDirVec=[cos(0.7) sin(0.7)].';
            ansEllObj=Ellipsoid([1 2;2 5].');
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#10. Two ellipsoids. Degenerate case.
            % Two directions. 2D case.
            testEllVec(1)=Ellipsoid([10 0; 0 0]);
            testEllVec(2)=Ellipsoid([0 0; 0 20]);
            testDirMat=[0,1;1,0];
            ansEllVec=[ Ellipsoid([Inf 0; 0 20]), ...
                Ellipsoid([10 0; 0 Inf])];
            checkAns(@minkSumEa,testEllVec,ansEllVec,testDirMat);
            clear testEllVec
            %
            % Test#11. Three ellipsoids. Degenerate case.
            % One directions. 3D case.
            testEllVec(1)=Ellipsoid([10;25;30]);
            testEllVec(2)=Ellipsoid([2 0 0;0 0 0;0 0 0]);
            testEllVec(3)=Ellipsoid([0 0 0;0 9 0;0 0 0]);
            testDirVec=[0,1,0].';
            ansEllObj=Ellipsoid([Inf 0 0; 0 64 0;0 0 48]);
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#12. Two. Infinite, non-degenerate case.
            % One directions. 2D case.
            testEllVec(1)=Ellipsoid([1;Inf]);
            testEllVec(2)=Ellipsoid([1 1].');
            testDirVec=[1,1].';
            testDirVec=testDirVec/norm(testDirVec);
            ansEllObj=Ellipsoid([4 0; 0 Inf]);
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#13. Two. Infinite, degenerate case.
            % One directions. 2D case.
            testEllVec(1)=Ellipsoid([0;Inf]);
            testEllVec(2)=Ellipsoid([1 1].');
            testDirVec=[1,1].';
            testDirVec=testDirVec/norm(testDirVec);
            ansEllObj=Ellipsoid([1 0; 0 Inf]);
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#14. Two. Infinite, degenerate case.
            % One directions. 2D case. Another direction
            testEllVec(1)=Ellipsoid([0;Inf]);
            testEllVec(2)=Ellipsoid([1 1].');
            testDirVec=[1,0].';
            testDirVec=testDirVec/norm(testDirVec);
            ansEllObj=Ellipsoid([1 0; 0 Inf]);
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#15. Two. Infinite, degenerate case.
            % One directions. 3D case.
            testEllVec(1)=Ellipsoid([0;Inf;1]);
            testEllVec(2)=Ellipsoid([3 2 1].');
            testDirVec=[1,1,1].';
            testDirVec=testDirVec/norm(testDirVec);
            ansEllObj=Ellipsoid([4.5; Inf; 4.5]);
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            % Test#16. Two. Infinite, degenerate case.
            % One directions. 3D case. Degenerate direction
            testEllVec(1)=Ellipsoid([0;Inf;1]);
            testEllVec(2)=Ellipsoid([3 2 1].');
            testDirVec=[0,1,0].';
            testDirVec=testDirVec/norm(testDirVec);
            ansEllObj=Ellipsoid([Inf; Inf; Inf]);
            checkAns(@minkSumEa,testEllVec,ansEllObj,testDirVec);
            clear testEllVec
            %
            function checkWOld(dirMat)
                %Compare to old function
                import elltool.core.Ellipsoid;
                ellNew1Obj=Ellipsoid(cen1Vec,q1Mat);
                ellNew2Obj=Ellipsoid(cen2Vec,q2Mat);
                resNewEllVec=minkSumEa([ellNew1Obj,ellNew2Obj],dirMat);
                resOldEllVec=minksum_ea([ellipsoid(cen1Vec,q1Mat),...
                    ellipsoid(cen2Vec,q2Mat)],dirMat);
                isOkVec=arrayfun(@isEllNewOldEqual,resNewEllVec,...
                    resOldEllVec);
                isOk=all(isOkVec);
                mlunit.assert(isOk);
            end
            %
            function checkMellMdir(testEllMat,nElems,nDim)
                %check multiple directions and multiple ellipsoids
                import elltool.core.Ellipsoid;
                testEllNewVec(nElems)=Ellipsoid();
                testEllOldVec(nElems)=ellipsoid();
                for iElem=1:nElems
                    centerVec=iElem*(1:nDim).';
                    qMat=testEllMat{iElem};
                    testEllNewVec(iElem)=Ellipsoid(centerVec,qMat);
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
                mlunit.assert(isOk);
            end
        end
        %
        %
        %
        function self = testMinkDiffIa(self)
            import elltool.core.Ellipsoid;
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
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
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
            ansEllObj=Ellipsoid([oldCenVec; 0],ansDMat,ansWMat);
            %
            checkAns(@(x,y)minkDiffIa(x(1),x(2),y),...
                [testEllipsoid1,testEllipsoid2],ansEllObj,dirVec);
            %
            
            %Difference between 3-dimension ellipsoids.
            %Infinite case. Rotated.
            test1Mat=diag([Inf;5;5]);
            test2Mat=diag([Inf;1;1]);
            cenVec=zeros(3,1);
            testEllipsoid1=Ellipsoid(cenVec,test1Mat,testOrth3Mat);
            testEllipsoid2=Ellipsoid(cenVec,test2Mat,testOrth3Mat);
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
            mlunit.assert_equals(1,isEllEll2Equal...
                (Ellipsoid(resEllipsoid.diagMat),...
                Ellipsoid(ansDMat)));
            %
            %Difference between 3-dimension ellipsoids.
            %Infinite and degenerate
            test1Mat=diag([Inf;Inf;1]);
            test2Mat=diag([1;1;0]);
            cenVec=zeros(3,1);
            testEllipsoid1=Ellipsoid(cenVec,test1Mat,testOrth3Mat.');
            testEllipsoid2=Ellipsoid(cenVec,test2Mat,testOrth3Mat.');
            dirVec=[1;1;1];
            dirVec=dirVec/norm(dirVec);
            ansEllObj=Ellipsoid([0;0;0], diag([Inf,Inf,1]),testOrth3Mat.');
            checkAns(@(x,y)minkDiffIa(x(1),x(2),y),...
                [testEllipsoid1,testEllipsoid2],ansEllObj,dirVec);
            %
            function checkWOld(dirMat)
                %Compare with old function
                import elltool.core.Ellipsoid;
                ellNew1Obj=Ellipsoid(cen1Vec,q1Mat);
                ellNew2Obj=Ellipsoid(cen2Vec,q2Mat);
                resNewEllVec=minkDiffIa(ellNew1Obj,ellNew2Obj,dirMat);
                resOldEllVec=minkdiff_ia(ellipsoid(cen1Vec,q1Mat),...
                    ellipsoid(cen2Vec,q2Mat),dirMat);
                isOkVec=arrayfun(@isEllNewOldEqual,resNewEllVec,...
                    resOldEllVec);
                isOk=all(isOkVec);
                mlunit.assert(isOk);
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
            import elltool.core.Ellipsoid;
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
            testEllipsoid1=Ellipsoid([0,0].',test1DVec,test1WMat);
            testEllipsoid2=Ellipsoid(test2DVec);
            dirVec=[1 10].';
            dirVec=dirVec/norm(dirVec);
            %
            ansDiagVec=[Inf 1].';
            ansEigvMat=[1 -1; 1 1];
            ansEigvMat=ansEigvMat/norm(ansEigvMat);
            ansCenVec=[0 0].';
            ansEllipsoid=Ellipsoid(ansCenVec,ansDiagVec,ansEigvMat);
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
            testEllipsoid1=Ellipsoid([0,0].',test1DVec,test1WMat);
            testEllipsoid2=Ellipsoid(test2DVec);
            dirVec=[1 1].';
            dirVec=dirVec/norm(dirVec);
            %
            ansDiagVec=[Inf Inf].';
            ansEigvMat=[1 0; 0 1];
            ansCenVec=[0 0].';
            ansEllipsoid=Ellipsoid(ansCenVec,ansDiagVec,ansEigvMat);
            %
            checkAns(@minkSumIa,[testEllipsoid1, testEllipsoid2],...
                ansEllipsoid,dirVec);
            %
            %(o3)Infinite+nondegenerate. 3d-case
            nDim=3;
            test1WMat=eye(nDim);
            test1DVec=[1 2 Inf].';
            test2DVec=[3 4 5].';
            testEllipsoid1=Ellipsoid([0,0,0].',test1DVec,test1WMat);
            testEllipsoid2=Ellipsoid(test2DVec);
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
            ansEllipsoid=Ellipsoid(ansCenVec,ansDiagVec,ansEigvMat);
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
            testEllipsoid1=Ellipsoid([0,0].',test1DVec,test1WMat);
            testEllipsoid2=Ellipsoid([0,0].',test2DVec,test2WMat);
            dirVec=[-1 10].';
            dirVec=dirVec/norm(dirVec);
            %
            ansDiagVec=[Inf Inf].';
            ansEigvMat=[1 0; 0 1];
            ansCenVec=[0 0].';
            ansEllipsoid=Ellipsoid(ansCenVec,ansDiagVec,ansEigvMat);
            %
            checkAns(@minkSumIa,[testEllipsoid1, testEllipsoid2],...
                ansEllipsoid,dirVec);
            %
            %(o7)Two degenerate. 3d-case
            test1QMat=[1 0 0;0 0 0;0 0 0];
            test2QMat=[0 0 0;0 2 0;0 0 0];
            cen1Vec=[1 1 1].';
            cen2Vec=[1 -1 10].';
            testEllipsoid1=Ellipsoid(cen1Vec,test1QMat);
            testEllipsoid2=Ellipsoid(cen2Vec,test2QMat);
            dirVec=[1 0 0].';
            dirVec=dirVec/norm(dirVec);
            %
            ansCenVec=[2; 0; 11];
            ansEigvMat=eye(3);
            ansDiagVec=diag([1 0 0]);
            ansEllipsoid=Ellipsoid(ansCenVec,ansDiagVec,ansEigvMat);
            %
            checkAns(@minkSumIa,[testEllipsoid1, testEllipsoid2],...
                ansEllipsoid,dirVec);
        end
        %
        function self = testMinkDiffEa(self)
            %
            import elltool.core.Ellipsoid;
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
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
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
            ansEllipsoid=Ellipsoid([oldCenVec; 0],ansDMat,ansWMat);
            checkAns(@(x,y)minkDiffEa(x(1),x(2),y),...
                [testEllipsoid1,testEllipsoid2],ansEllipsoid,dirVec);
            %
            %Difference between 3-dimension ellipsoids.
            %Infinite case. Rotated.
            test1Mat=diag([Inf;5;5]);
            test2Mat=diag([Inf;1;1]);
            cenVec=zeros(3,1);
            testEllipsoid1=Ellipsoid(cenVec,test1Mat,testOrth3Mat);
            testEllipsoid2=Ellipsoid(cenVec,test2Mat,testOrth3Mat);
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
            mlunit.assert_equals(1,isEllEll2Equal...
                (Ellipsoid(resEllipsoid.diagMat),...
                Ellipsoid(ansDMat)));
            %
            %Difference between 3-dimension ellipsoids.
            %Infinite and degenerate
            test1Mat=diag([Inf;Inf;1]);
            test2Mat=diag([1;1;0.1]);
            cenVec=zeros(3,1);
            testEllipsoid1=Ellipsoid(cenVec,test1Mat);
            testEllipsoid2=Ellipsoid(cenVec,test2Mat);
            dirVec=[1;0;0];
            dirVec=dirVec/norm(dirVec);
            ansEllObj=Ellipsoid(diag([Inf;Inf;Inf]));
            checkAns(@(x,y)minkDiffIa(x(1),x(2),y),...
                [testEllipsoid1,testEllipsoid2],ansEllObj,dirVec);
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
            %
            function checkWOld(dirMat)
                %Compare to old function
                import elltool.core.Ellipsoid;
                ellNew1Obj=Ellipsoid(cen1Vec,q1Mat);
                ellNew2Obj=Ellipsoid(cen2Vec,q2Mat);
                resNewEllVec=minkDiffEa(ellNew1Obj,ellNew2Obj,dirMat);
                resOldEllVec=minkdiff_ea(ellipsoid(cen1Vec,q1Mat),...
                    ellipsoid(cen2Vec,q2Mat),dirMat);
                isOkVec=arrayfun(@isEllNewOldEqual,resNewEllVec,...
                    resOldEllVec);
                isOk=all(isOkVec);
                mlunit.assert(isOk);
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
                isEqual=isEllEll2Equal(ell1Apx, ell2Apx);
                mlunitext.assert(isEqual);
            end
            function ellApx=build(oMat,fMethod,lVec)
                import elltool.core.Ellipsoid;
                ell1=Ellipsoid(zeros(nDims,1),diag(d1Vec),oMat);
                ell2=Ellipsoid(zeros(nDims,1),diag(d2Vec),oMat);
                ellVec=[ell1,ell2];
                ellApx=fMethod(ellVec,lVec);
                eigVMat=ellApx.eigvMat;
                if ~isempty(eigVMat)
                    eigVMat=oMat.'*eigVMat;
                    ellApx=Ellipsoid(ellApx.centerVec,ellApx.diagMat,...
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
            import elltool.core.Ellipsoid;
            load(strcat(self.testDataRootDir,filesep,...
                'testEllEllRMat.mat'),'testOrth3Mat');
            %Test1.
            testEllipsoid1=Ellipsoid([4;3]);
            testEllipsoid2=Ellipsoid([1;0]);
            dirVec=[0,1].';
            dirVec=dirVec/norm(dirVec);
            checkRes();
            %
            %Test2.
            testEllipsoid1=Ellipsoid([0;0;0],[4;3;4],testOrth3Mat.');
            testEllipsoid2=Ellipsoid([0;0;0],[1;0;0],testOrth3Mat.');
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
            testEllipsoid1=Ellipsoid(zeros(nDim,1),...
                [16;3;Inf;(1:17)'],testOrth20Mat);
            testEllipsoid2=Ellipsoid(zeros(nDim,1),...
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
                import elltool.core.Ellipsoid;
                isOk=isEllEll2Equal(ellObj,Ellipsoid());
                if ~isCheckEmpty
                    isOk=~isOk;
                end
                mlunitext.assert(isOk);
            end
            function checkRes()
                resEll=minkDiffEa(testEllipsoid1,testEllipsoid2,dirVec);
                checkEllEmpty(resEll,1);
            end
        end
        
        function testAllDirRand(self)
            import elltool.core.test.mlunit.NewEllipsoidTestCase;
            import elltool.core.Ellipsoid;
            load(strcat(self.testDataRootDir,filesep,...
                'testEllEllRMat.mat'),'testOrth50Mat',...
                'testOrth100Mat','testOrth3Mat','testOrth2Mat');
            %
            import elltool.core.Ellipsoid;
            nEllObj=10;
            nDim=50;
            nDir=10;
            dirRandMat=zeros(nDim,nDir);
            for iDir=1:nDir
                dirVec=rand(nDim,1);
                dirVec=dirVec/norm(dirVec);
                dirRandMat(:,iDir)=dirVec;
            end
            NewEllipsoidTestCase.auxCheckAllbV(nEllObj,nDim,...
                dirRandMat,testOrth50Mat);
        end
        function testAllDirFixed(self)
            import elltool.core.test.mlunit.NewEllipsoidTestCase;
            import elltool.core.Ellipsoid;
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
            NewEllipsoidTestCase.auxCheckAllbV(nEllObj,nDim,...
                test10x50DirMat,testOrth50Mat);
        end
    end
    methods(Static)
        function auxCheckAllbV(nEllObj,nDim,dirMat,oMat)
            import elltool.core.Ellipsoid;
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
            function isEqual=isSumCorrect(fMethod,ellVec,dirVec,oMat)
                import elltool.core.Ellipsoid;
                resR1Ell=fMethod(ellVec,dirVec);
                checkSumTight(resR1Ell,ellVec,dirVec)
                ellObjRotVec(nEllObj)=Ellipsoid();
                for iEll=1:nEllObj
                    ellObjRotVec(iEll)=rotateEll(ellVec(iEll),oMat);
                end
                resR2Ell=fMethod(ellObjRotVec,oMat*dirVec);
                checkSumTight(resR2Ell,ellObjRotVec,oMat*dirVec);
                resR3Ell=rotateEll(resR2Ell,oMat.');
                isEqual=isEllEll2Equal(resR1Ell,resR3Ell);
            end
            function isEqual=isDiffCorrect(fMethod,ellVec,dirVec,oMat)
                import elltool.core.Ellipsoid;
                resR1Ell=fMethod(ellVec(1),ellVec(2),dirVec);
                if findIsGoodDir(ellVec(1),ellVec(2),dirVec)
                    checkDiffTight(resR1Ell,ellVec,dirVec)
                end
                ellObjRotVec(nEllObj)=Ellipsoid();
                for iEll=1:2
                    ellObjRotVec(iEll)=rotateEll(ellVec(iEll),oMat);
                end
                rotDirVec=oMat*dirVec;
                resR2Ell=fMethod(ellObjRotVec(1),ellObjRotVec(2),...
                    rotDirVec);
                if  findIsGoodDir(ellVec(1),ellVec(2),rotDirVec)
                    checkDiffTight(resR2Ell,ellObjRotVec,rotDirVec)
                end
                if (~isempty(resR2Ell.diagMat))
                    resR3Ell=rotateEll(resR2Ell,oMat.');
                    isEqual=isEllEll2Equal(resR1Ell,resR3Ell);
                else
                    if (isempty(resR1Ell.diagMat))
                        isEqual=true;
                    else
                        isEqual=false;
                    end
                end
            end
            function [ellVec]=buildNINDCSum()
                import elltool.core.Ellipsoid;
                ellVec(nEllObj)=Ellipsoid();
                cenVec=zeros(nDim,1);
                for iEll=1:nEllObj
                    diagVec=(1:nDim).'*iEll/10;
                    ellVec(iEll)=Ellipsoid(cenVec,diagVec);
                end
            end
            function [ellVec]=buildNIDCSum()
                import elltool.core.Ellipsoid;
                ellVec(nEllObj)=Ellipsoid();
                cenVec=zeros(nDim,1);
                for iEll=1:nEllObj
                    diagVec=(1:nDim).'*iEll/10;
                    diagVec(max(1,floor(nDim*iEll/nEllObj)))=0;
                    ellVec(iEll)=Ellipsoid(cenVec,diagVec);
                end
            end
            function [ellVec]=buildINDCSum()
                import elltool.core.Ellipsoid;
                ellVec(nEllObj)=Ellipsoid();
                cenVec=zeros(nDim,1);
                diagVec=(1:nDim).'/10;
                diagVec(1)=Inf;
                ellVec(1)=Ellipsoid(cenVec,diagVec);
                diagVec=(1:nDim).'/10;
                diagVec(end)=Inf;
                ellVec(end)=Ellipsoid(cenVec,diagVec);
                for iEll=2:(nEllObj-1)
                    diagVec=(1:nDim).'*iEll/10;
                    ellVec(iEll)=Ellipsoid(cenVec,diagVec);
                end
            end
            %
            function [ellVec]=buildIDCSum()
                import elltool.core.Ellipsoid;
                ellVec(nEllObj)=Ellipsoid();
                cenVec=zeros(nDim,1);
                diagVec=(1:nDim).'/10;
                diagVec(1)=Inf;
                ellVec(1)=Ellipsoid(cenVec,diagVec);
                diagVec=(1:nDim).'/10;
                diagVec(end)=Inf;
                ellVec(end)=Ellipsoid(cenVec,diagVec);
                for iEll=2:(nEllObj-1)
                    diagVec=(1:nDim).'*iEll/10;
                    diagVec(max(1,floor(nDim*iEll/nEllObj)))=0;
                    ellVec(iEll)=Ellipsoid(cenVec,diagVec);
                end
            end
            %
            function ellVec=buildDiff(complStr)
                import elltool.core.Ellipsoid;
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
                ellVec(1)=Ellipsoid(cen1Vec,diag1Vec);
                ellVec(2)=Ellipsoid(cen2Vec,diag2Vec);
            end
        end
    end
end

function resEllObj=rotateEll(ellObj,oMat)
import elltool.core.Ellipsoid;
eigvMat=ellObj.eigvMat;
newVMat=oMat*eigvMat;
resEllObj=Ellipsoid(ellObj.centerVec,ellObj.diagMat,newVMat);
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
import elltool.core.Ellipsoid;
absTol=Ellipsoid.getCheckTol();
eigvMat=resEllipsoid.eigvMat;
diagVec=diag(resEllipsoid.diagMat);
cenVec=resEllipsoid.centerVec;
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
function isEqual=isEllNewOldEqual(ellNewObj, ellOldObj)
import elltool.core.Ellipsoid;
[cenOldVec qOldMat]=double(ellOldObj);
isEqual=isEllEll2Equal(ellNewObj,Ellipsoid(cenOldVec, qOldMat));
end
function isEqual=isEllEll2Equal(ellObj1, ellObj2)
% eig vectors corresponding to the same eig values are collinear
import elltool.core.Ellipsoid;
absTol=Ellipsoid.getCheckTol();
eigv1Mat=ellObj1.eigvMat;
diag1Vec=diag(ellObj1.diagMat);
cen1Vec=ellObj1.centerVec;
eigv2Mat=ellObj2.eigvMat;
diag2Vec=diag(ellObj2.diagMat);
isEmpt1=isempty(diag1Vec);
isEmpt2=isempty(diag2Vec);
if isEmpt1 && isEmpt2
    isEqual=true;
elseif isEmpt1 || isEmpt2
    isEqual=false;
else
    cen2Vec=ellObj2.centerVec;
    isInf1Vec=diag1Vec==Inf;
    isInf2Vec=diag2Vec==Inf;
    eigvFin1Mat=eigv1Mat(:,~isInf1Vec);
    eigvFin2Mat=eigv2Mat(:,~isInf2Vec);
    ellQ1Mat=eigvFin1Mat*diag(diag1Vec(~isInf1Vec))*eigvFin1Mat.';
    ellQ2Mat=eigvFin2Mat*diag(diag2Vec(~isInf2Vec))*eigvFin2Mat.';
    isEqual=isEqM(ellQ1Mat,ellQ2Mat,absTol)...
        && isEqV(cen1Vec,cen2Vec,absTol);
end
end
function resMat=rotateM(qMat, oMat)
resMat=oMat*qMat*oMat.';
resMat=0.5*(resMat+resMat.');
end
%
function checkAns(fMethod,testEllVec,ansEllObj,testDirObj)
resEllObj=fMethod(testEllVec,testDirObj);
isOkVec=arrayfun(@isEllEll2Equal,resEllObj,ansEllObj);
mlunit.assert_equals(1,all(isOkVec));
if (isequal(fMethod,@minkSumIa) || isequal(fMethod,@minkSumEa))
    checkSumTight(ansEllObj,testEllVec,testDirObj(:,1));
else
    checkDiffTight(ansEllObj,testEllVec,testDirObj(:,1));
end
end

function checkSumTight(ellResObj, ellVec, dirVec)
import elltool.core.Ellipsoid;
absTol=Ellipsoid.getCheckTol();
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
import elltool.core.Ellipsoid;
absTol=Ellipsoid.getCheckTol();
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
function resRho=rho(ellObj,dirVec)
import elltool.core.Ellipsoid;
absTol=Ellipsoid.getCheckTol();
eigvMat=ellObj.eigvMat;
diagMat=ellObj.diagMat;
diagVec=diag(diagMat);
cenVec=ellObj.centerVec;
isInfVec=diagVec==Inf;
dirInfProjVec=0;
if ~all(~isInfVec)
    nDimSpace=length(diagVec);
    allInfDirMat=eigvMat(:,isInfVec);
    [orthBasMat rangInf]=findBasRang(allInfDirMat,absTol);
    infIndVec=1:rangInf;
    finIndVec=(rangInf+1):nDimSpace;
    infBasMat = orthBasMat(:,infIndVec);
    finBasMat = orthBasMat(:,finIndVec);
    diagVec(isInfVec)=0;
    curEllMat=eigvMat*diag(diagVec)*eigvMat.';
    resProjQMat=finBasMat.'*curEllMat*finBasMat;
    ellQMat=0.5*(resProjQMat+resProjQMat.');
    dirInfProjVec=infBasMat.'*dirVec;
    dirVec=finBasMat.'*dirVec;
    cenVec=finBasMat.'*cenVec;
else
    ellQMat=eigvMat*diag(diagVec)*eigvMat.';
    ellQMat=0.5*(ellQMat+ellQMat);
end
if ~all(abs(dirInfProjVec)<absTol)
    resRho=Inf;
else
    dirVec=dirVec/norm(dirVec);
    resRho=cenVec.'*dirVec+sqrt(dirVec.'*ellQMat*dirVec);
end
end
function [orthBasMat rang]=findBasRang(qMat,absTol)
[orthBasMat rBasMat]=qr(qMat);
if size(rBasMat,2)==1
    isNeg=rBasMat(1)<0;
    orthBasMat(:,isNeg)=-orthBasMat(:,isNeg);
else
    isNegVec=diag(rBasMat)<0;
    orthBasMat(:,isNegVec)=-orthBasMat(:,isNegVec);
end
tolerance = absTol*norm(qMat,'fro');
rang = sum(abs(diag(rBasMat)) > tolerance);
rang = rang(1); %for case where rBasZMat is vector.
end
function isOk=findIsGoodDir(ellObj1,ellObj2,curDirVec)
import elltool.core.Ellipsoid;
absTol=Ellipsoid.getCheckTol();
eigv1Mat=ellObj1.eigvMat;
eigv2Mat=ellObj2.eigvMat;
diag1Vec=diag(ellObj1.diagMat);
diag2Vec=diag(ellObj2.diagMat);
isInf1Vec=diag1Vec==Inf;
if ~all(~isInf1Vec)
    %Infinite case
    allInfDirMat=eigv1Mat(:,isInf1Vec);
    [orthBasMat rangInf]=findBasRang(allInfDirMat,absTol);
    %    infIndVec=1:rangInf;
    nDimSpace=length(diag1Vec);
    finIndVec=(rangInf+1):nDimSpace;
    finBasMat = orthBasMat(:,finIndVec);
    %Find projections on nonInf directions
    isInf2Vec=diag(ellObj2.diagMat)==Inf;
    diag1Vec(isInf1Vec)=0;
    diag2Vec(isInf2Vec)=0;
    curEllMat=eigv1Mat*diag(diag1Vec)*eigv1Mat.';
    ellQ1Mat=finBasMat.'*curEllMat*finBasMat;
    ellQ1Mat=0.5*(ellQ1Mat+ellQ1Mat.');
    curEllMat=eigv2Mat*diag(diag2Vec)*eigv2Mat.';
    ellQ2Mat=finBasMat.'*curEllMat*finBasMat;
    ellQ2Mat=0.5*(ellQ2Mat+ellQ2Mat.');
    curDirVec=finBasMat.'*curDirVec;
    [eigv1Mat diag1Mat]=eig(ellQ1Mat);
    diag1Vec=diag(diag1Mat);
else
    ellQ1Mat=eigv1Mat*diag(diag1Vec)*eigv1Mat.';
    ellQ2Mat=eigv2Mat*diag(diag2Vec)*eigv2Mat.';
end
if all(abs(curDirVec)<absTol)
    isOk=true;
else
    %find projection on nonzero space for ell1
    isZeroVec=abs(diag1Vec)<absTol;
    if ~all(~isZeroVec)
        zeroDirMat=eigv1Mat(:,isZeroVec);
        % Find basis in all space
        [orthBasMat rangZ]=findBasRang(zeroDirMat,absTol);
        %rangZ>0 since there is at least one zero e.v. Q1
        %zeroIndVec=1:rangZ;
        nDimSpace=length(diag1Vec);
        nonZeroIndVec=(rangZ+1):nDimSpace;
        nonZeroBasMat = orthBasMat(:,nonZeroIndVec);
        curDirVec=nonZeroBasMat.'*curDirVec;
        ellQ1Mat=nonZeroBasMat.'*ellQ1Mat*nonZeroBasMat;
        ellQ2Mat=nonZeroBasMat.'*ellQ2Mat*nonZeroBasMat;
        ellQ1Mat=0.5*(ellQ1Mat+ellQ1Mat.');
        ellQ2Mat=0.5*(ellQ2Mat+ellQ2Mat.');
    end
    ellInvQ1Mat=ellQ1Mat\eye(size(ellQ1Mat));
    [~,diagMat]=eig(ellQ2Mat*ellInvQ1Mat);
    lamMax=max(diag(diagMat));
    %
    p1Par=sqrt(curDirVec.'*ellQ1Mat*curDirVec);
    p2Par=sqrt(curDirVec.'*ellQ2Mat*curDirVec);
    pPar=p2Par/p1Par;
    isOk=(pPar>lamMax) && (pPar<1);
end
end