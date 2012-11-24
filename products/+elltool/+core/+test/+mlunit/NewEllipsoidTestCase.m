classdef NewEllipsoidTestCase < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
    end
    methods
        function self=NewEllipsoidTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
            import elltool.core.Ellipsoid;
        end
        function self = testConstructor(self)
            import elltool.core.Ellipsoid;
            %
            load(strcat(self.testDataRootDir,filesep,'testNewEllRandM.mat'),...
                'testOrth2Mat','testOrth3Mat',...
                'testOrth20Mat','testOrth50Mat',...
                'testOrth100Mat');
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
        
        %         function self = testInv(self)
        %             import elltool.core.Ellipsoid;
        %             ell1Obj=Ellipsoid([1 5 10].');
        %             ellInv1Obj=ell1Obj.inv();
        %             ell2Obj=Ellipsoid([0 5 Inf].');
        %             ellInv2Obj=ell2Obj.inv();
        %         end
        function self = testMinksum_ea(self)
            import elltool.core.Ellipsoid;
            import elltool.conf.Properties;
            %
            load(strcat(self.testDataRootDir,filesep,'testNewEll.mat'),...
                'testEll2x2Mat','testEll2x3Mat','testEll10x2Mat',...
                'testEll10x3Mat','testEll10x20Mat',...
                'testEll10x50Mat','testEll10x100Mat');
            CHECK_TOL=1e-9;
            % Test#1. Two non-degenerate ellipsoids. Zero centers.
            %Simple diagonal matrices. Simple direction. 2D case.
            q1Mat=[1 0;0 1];
            q2Mat=[9 0;0 9];
            dirVec=[1, 0].';
            ellNew1Obj=Ellipsoid(q1Mat);
            ellNew2Obj=Ellipsoid(q2Mat);
            resNewEll=minksumEa([ellNew1Obj,ellNew2Obj],dirVec);
            resOldEll=minksum_ea([ellipsoid(q1Mat),ellipsoid(q2Mat)],dirVec);
            newQMat=resNewEll.eigvMat*resNewEll.diagMat*resNewEll.eigvMat.';
            [~, oldQMat]=double(resOldEll);
            mlunit.assert_equals(1, all(all(abs(newQMat-oldQMat)<...
                CHECK_TOL)));
            %
            %Test#2. Two ellipses. Non-degenerate. Non-zero centers.
            %Simple diagonal matrices. Simple direction. 2D case.
            q1Mat=[1 0;0 1];
            q2Mat=[9 0;0 9];
            cen1Vec=[1,-5].';
            cen2Vec=[10,20].';
            dirVec=[1, 0].';
            ellNew1Obj=Ellipsoid(cen1Vec,q1Mat);
            ellNew2Obj=Ellipsoid(cen2Vec,q2Mat);
            resNewEll=minksumEa([ellNew1Obj,ellNew2Obj],dirVec);
            resOldEll=minksum_ea([ellipsoid(cen1Vec,q1Mat),ellipsoid(cen2Vec,q2Mat)],dirVec);
            newQMat=resNewEll.eigvMat*resNewEll.diagMat*resNewEll.eigvMat.';
            newQCenVec=resNewEll.centerVec;
            [oldQCenVec oldQMat]=double(resOldEll);
            mlunit.assert_equals(1, all(all(abs(newQMat-oldQMat)<...
                CHECK_TOL))&& all(oldQCenVec-newQCenVec)<CHECK_TOL);
            %
            %Test#3. Two ellipses. Non-degenerate. Non-zero centers. Diagonal matrices.
            % Simple direction. Ellipses, not circles. 2D case.
            q1Mat=[1 0;0 25];
            q2Mat=[9 0;0 16];
            cen1Vec=[5,-7].';
            cen2Vec=[1,1.55].';
            dirVec=[1, 0].';
            ellNew1Obj=Ellipsoid(cen1Vec,q1Mat);
            ellNew2Obj=Ellipsoid(cen2Vec,q2Mat);
            resNewEll=minksumEa([ellNew1Obj,ellNew2Obj],dirVec);
            resOldEll=minksum_ea([ellipsoid(cen1Vec,q1Mat),ellipsoid(cen2Vec,q2Mat)],dirVec);
            newQMat=resNewEll.eigvMat*resNewEll.diagMat*resNewEll.eigvMat.';
            newQCenVec=resNewEll.centerVec;
            [oldQCenVec oldQMat]=double(resOldEll);
            mlunit.assert_equals(1, all(all(abs(newQMat-oldQMat)<...
                CHECK_TOL))&& all((oldQCenVec-newQCenVec)<CHECK_TOL));
            %
            %Test#4. Two ellipsoids. Non-degenerate. Non-zero centers.
            % Diagonal matrices. Multiple various directions.
            % Ellipses, not circles. 2D case.
            q1Mat=[1 0;0 25];
            q2Mat=[9 0;0 16];
            cen1Vec=[5,-7].';
            cen2Vec=[1,1.55].';
            nDirs=20;
            angleStep=2*pi/nDirs;
            phiAngle=0:angleStep:2*pi-angleStep;
            dirMat=[cos(phiAngle); sin(phiAngle)];
            isStillCorrect=true;
            iDir=1;
            ellNew1Obj=Ellipsoid(cen1Vec,q1Mat);
            ellNew2Obj=Ellipsoid(cen2Vec,q2Mat);
            resNewEllVec=minksumEa([ellNew1Obj,ellNew2Obj],dirMat);
            resOldEllVec=minksum_ea([ellipsoid(cen1Vec,q1Mat),ellipsoid(cen2Vec,q2Mat)],dirMat);
            while (iDir<nDirs) && isStillCorrect
                newQMat=resNewEllVec(iDir).eigvMat*resNewEllVec(iDir).diagMat*...
                    resNewEllVec(iDir).eigvMat.';
                newQCenVec=resNewEllVec(iDir).centerVec;
                [oldQCenVec oldQMat]=double(resOldEllVec(iDir));
                iDir=iDir+1;
                isStillCorrect=all(all(abs(newQMat-oldQMat)<...
                    CHECK_TOL))&& all((oldQCenVec-newQCenVec)<CHECK_TOL);
            end
            mlunit.assert_equals(1, isStillCorrect);
            %
            %Test#5. Two ellipsoids. Non-degenerate. Non-zero centers.
            % Random matrices.
            % Multiple various directions. Ellipses, not circles. 2D case.
            q1Mat=testEll2x2Mat{1};
            q2Mat=testEll2x2Mat{2};
            cen1Vec=[1,2].';
            cen2Vec=[-5,10].';
            nDirs=5;
            angleStep=2*pi/nDirs;
            phiAngle=0:angleStep:2*pi-angleStep;
            dirMat=[cos(phiAngle); sin(phiAngle)];
            ellNew1Obj=Ellipsoid(cen1Vec,q1Mat);
            ellNew2Obj=Ellipsoid(cen2Vec,q2Mat);
            resNewEllVec=minksumEa([ellNew1Obj,ellNew2Obj],dirMat);
            resOldEllVec=minksum_ea([ellipsoid(cen1Vec,q1Mat),ellipsoid(cen2Vec,q2Mat)],...
                dirMat);
            isStillCorrect=true;
            iDir=1;
            while (iDir<nDirs) && isStillCorrect
                newQMat=resNewEllVec(iDir).eigvMat*resNewEllVec(iDir).diagMat*...
                    resNewEllVec(iDir).eigvMat.';
                newQCenVec=resNewEllVec(iDir).centerVec;
                [oldQCenVec oldQMat]=double(resOldEllVec(iDir));
                iDir=iDir+1;
                isStillCorrect=all(all(abs(newQMat-oldQMat)<...
                    CHECK_TOL))&& all((oldQCenVec-newQCenVec)<CHECK_TOL);
            end
            mlunit.assert_equals(1, isStillCorrect);
            %
            %Test#6. Ten ellipsoids. Non-degenerate. Non-zero centers.
            % Non-diagonal matrices. Random matrices.
            % Multiple various directions. Ellipses, not circles. 3D case.
            nElems=10;
            testEllNewVec(nElems)=Ellipsoid();
            testEllOldVec(nElems)=ellipsoid();
            for iElem=1:nElems
                centerVec=iElem*(1:3).';
                qMat=testEll10x3Mat{iElem};
                testEllNewVec(iElem)=Ellipsoid(centerVec,qMat);
                testEllOldVec(iElem)=ellipsoid(centerVec,qMat);
            end
            nDirs=5;
            angleStep=2*pi/nDirs;
            phiAngle=0:angleStep:2*pi-angleStep;
            dirMat=[cos(phiAngle); sin(phiAngle); zeros(1,nDirs)];
            resNewEllVec=minksumEa(testEllNewVec,dirMat);
            resOldEllVec=minksum_ea(testEllOldVec,dirMat);
            isStillCorrect=true;
            iDir=1;
            while (iDir<nDirs) && isStillCorrect
                newQMat=resNewEllVec(iDir).eigvMat*resNewEllVec(iDir).diagMat*...
                    resNewEllVec(iDir).eigvMat.';
                newQCenVec=resNewEllVec(iDir).centerVec;
                [oldQCenVec oldQMat]=double(resOldEllVec(iDir));
                iDir=iDir+1;
                isStillCorrect=all(all(abs(newQMat-oldQMat)<...
                    CHECK_TOL))&& all((oldQCenVec-newQCenVec)<CHECK_TOL);
            end
            mlunit.assert_equals(1, isStillCorrect);
            %
            % Test#7. Ten ellipsoids. Non-degenerate. Non-zero centers.
            % Non-diagonal matrices. Random matrices.
            % A lot of multiple various directions. Ellipses, not circles.
            % 20D case.
            nElems=10;
            testEllNewVec(nElems)=Ellipsoid();
            testEllOldVec(nElems)=ellipsoid();
            for iElem=1:nElems
                centerVec=iElem*(1:20).';
                qMat=testEll10x20Mat{iElem};
                testEllNewVec(iElem)=Ellipsoid(centerVec,qMat);
                testEllOldVec(iElem)=ellipsoid(centerVec,qMat);
            end
            nDirs=50;
            angleStep=2*pi/nDirs;
            phiAngle=0:angleStep:2*pi-angleStep;
            dirMat=[cos(phiAngle); sin(phiAngle); zeros(18,nDirs)];
            resNewEllVec=minksumEa(testEllNewVec,dirMat);
            resOldEllVec=minksum_ea(testEllOldVec,dirMat);
            isStillCorrect=true;
            iDir=1;
            while (iDir<nDirs) && isStillCorrect
                newQMat=resNewEllVec(iDir).eigvMat*resNewEllVec(iDir).diagMat*...
                    resNewEllVec(iDir).eigvMat.';
                newQCenVec=resNewEllVec(iDir).centerVec;
                [oldQCenVec oldQMat]=double(resOldEllVec(iDir));
                iDir=iDir+1;
                isStillCorrect=all(all(abs(newQMat-oldQMat)<...
                    CHECK_TOL))&& all((oldQCenVec-newQCenVec)<CHECK_TOL);
            end
            mlunit.assert_equals(1, isStillCorrect);
            %
            % Test#8. Two ellipsoids. Degenerate case.
            % Bounded result.
            testEllipsoid1=Ellipsoid([1 0; 0 1]);
            testEllipsoid2=Ellipsoid([1 0; 0 0]);
            testDirVec=[1 0].';
            resEllObj=minksumEa([testEllipsoid1,testEllipsoid2],testDirVec);
            resEllMat=resEllObj.eigvMat*resEllObj.diagMat*resEllObj.eigvMat.';
            testAnswerMat=[4 0; 0 2];
            mlunit.assert_equals(1,all(all(abs(resEllMat-testAnswerMat)<...
                CHECK_TOL)))
            % Test#8. Two ellipsoids. Degenerate case.
            % Unbounded result.
            testEllipsoid1=Ellipsoid([1 0; 0 1]);
            testEllipsoid2=Ellipsoid([1 0; 0 0]);
            testDirVec=[0 1].';
            resEllObj=minksumEa([testEllipsoid1,testEllipsoid2],testDirVec);
            %resEllMat=resEllObj.diagMat;
            %testAnswerMat=[Inf 0; 0 1];
            ansEllObj=Ellipsoid([Inf 1].');
            mlunit.assert_equals(1,isEllEll2Equal(resEllObj,ansEllObj));
            % Test#9. Two ellipsoids. Degenerate case.
            % Zero Matrix.
            testEllipsoid1=Ellipsoid([1 2; 2 5]);
            testEllipsoid2=Ellipsoid([0 0; 0 0]);
            testDirVec=[cos(0.7) sin(0.7)].';
            resEllObj=minksumEa([testEllipsoid1,testEllipsoid2],testDirVec);
            ansEllObj=Ellipsoid([1 2;2 5].');
            mlunit.assert_equals(1,isEllEll2Equal(resEllObj,ansEllObj));
            %
            % Test#10. Two ellipsoids. Degenerate case.
            % Two directions. 2D case.
            testEllipsoid1=Ellipsoid([10 0; 0 0]);
            testEllipsoid2=Ellipsoid([0 0; 0 20]);
            testDirMat=[0,1;1,0];
            resEllObjVec=minksumEa([testEllipsoid1,testEllipsoid2],testDirMat);
            mlunit.assert_equals(1,isEllEll2Equal(resEllObjVec(1),Ellipsoid([Inf 0; 0 20]))&&...
                isEllEll2Equal(resEllObjVec(2),Ellipsoid([10 0; 0 Inf])));
            %
            % Test#11. Three ellipsoids. Degenerate case.
            % One directions. 3D case.
            testEllipsoid1=Ellipsoid([10;25;30]);
            testEllipsoid2=Ellipsoid([2 0 0;0 0 0;0 0 0]);
            testEllipsoid3=Ellipsoid([0 0 0;0 9 0;0 0 0]);
            testDirVec=[0,1,0].';
            testEllVec=[testEllipsoid1,testEllipsoid2,testEllipsoid3];
            resEllObj=minksumEa(testEllVec,testDirVec);
            mlunit.assert_equals(1,isEllEll2Equal(resEllObj,...
                Ellipsoid([Inf 0 0; 0 64 0;0 0 48])));
            %
            % Test#12. Two. Infinite, non-degenerate case.
            % One directions. 2D case.
            testEllipsoid1=Ellipsoid([1;Inf]);
            testEllipsoid2=Ellipsoid([1 1].');
            testDirVec=[1,1].';
            testDirVec=testDirVec/norm(testDirVec);
            testEllVec=[testEllipsoid1,testEllipsoid2];
            resEllObj=minksumEa(testEllVec,testDirVec);
            mlunit.assert_equals(1,isEllEll2Equal(resEllObj,...
                Ellipsoid([4 0; 0 Inf])));
            %
            % Test#13. Two. Infinite, degenerate case.
            % One directions. 2D case.
            testEllipsoid1=Ellipsoid([0;Inf]);
            testEllipsoid2=Ellipsoid([1 1].');
            testDirVec=[1,1].';
            testDirVec=testDirVec/norm(testDirVec);
            testEllVec=[testEllipsoid1,testEllipsoid2];
            resEllObj=minksumEa(testEllVec,testDirVec);
            mlunit.assert_equals(1,isEllEll2Equal(resEllObj,...
                Ellipsoid([1 0; 0 Inf])));
            %
            % Test#14. Two. Infinite, degenerate case.
            % One directions. 2D case. Another direction
            testEllipsoid1=Ellipsoid([0;Inf]);
            testEllipsoid2=Ellipsoid([1 1].');
            testDirVec=[1,0].';
            testDirVec=testDirVec/norm(testDirVec);
            testEllVec=[testEllipsoid1,testEllipsoid2];
            resEllObj=minksumEa(testEllVec,testDirVec);
            mlunit.assert_equals(1,isEllEll2Equal(resEllObj,...
                Ellipsoid([1 0; 0 Inf])));
            %
            % Test#15. Two. Infinite, degenerate case.
            % One directions. 3D case.
            testEllipsoid1=Ellipsoid([0;Inf;1]);
            testEllipsoid2=Ellipsoid([3 2 1].');
            testDirVec=[1,1,1].';
            testDirVec=testDirVec/norm(testDirVec);
            testEllVec=[testEllipsoid1,testEllipsoid2];
            resEllObj=minksumEa(testEllVec,testDirVec);
            mlunit.assert_equals(1,isEllEll2Equal(resEllObj,...
                Ellipsoid([4.5; Inf; 4.5])));
            %
            % Test#16. Two. Infinite, degenerate case.
            % One directions. 3D case. Degenerate direction
            testEllipsoid1=Ellipsoid([0;Inf;1]);
            testEllipsoid2=Ellipsoid([3 2 1].');
            testDirVec=[0,1,0].';
            testDirVec=testDirVec/norm(testDirVec);
            testEllVec=[testEllipsoid1,testEllipsoid2];
            resEllObj=minksumEa(testEllVec,testDirVec);
            mlunit.assert_equals(1,isEllEll2Equal(resEllObj,...
                Ellipsoid([Inf; Inf; Inf])));
            
        end
        %
        %
        %
        function self = testMinkdiff_ia(self)
            import elltool.core.Ellipsoid;
            %
            load(strcat(self.testDataRootDir,filesep,'testNewEll.mat'),...
                'testEll2x2Mat','testEll2x3Mat','testEll10x2Mat',...
                'testEll10x3Mat','testEll10x20Mat',...
                'testEll10x50Mat','testEll10x100Mat');
            %
            load(strcat(self.testDataRootDir,filesep,'testNewEllRandM.mat'),...
                'testOrth2Mat','testOrth3Mat',...
                'testOrth20Mat','testOrth50Mat',...
                'testOrth100Mat');
            %
            %Test#1. Simple.
            test1Mat=2*eye(2);
            test2Mat=[1 0; 0 0.1];
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
            dirVec=[1,0].';
            resEllipsoid=minkdiffIa(testEllipsoid1, testEllipsoid2, dirVec);
            resOldEllipsoid=minkdiff_ia(ellipsoid(test1Mat), ellipsoid(test2Mat),...
                dirVec);
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            mlunit.assert_equals(1,isEllEqual(resEllipsoid,...
                Ellipsoid(oldCenVec,oldQMat)));
            %
            %Test#2. Where old method doenst work.
            testEllipsoid1=Ellipsoid(2*eye(2));
            testEllipsoid2=Ellipsoid([1 0; 0 0.1]);
            phi=pi/2;
            dirVec=[cos(phi) sin(phi) ].';
            resEllipsoid=minkdiffIa(testEllipsoid1, testEllipsoid2, dirVec);
            mlunit.assert_equals(1,isEllEqual(resEllipsoid,Ellipsoid([0 0; 0 0.9])));
            %
            %Test#3. Difference between sphere and random ellipse.
            test1Mat=2*eye(2);
            %test1Mat=testOrth2Mat*test1Mat*testOrth2Mat.';
            test2Mat=[1 0; 0 0.1];
            test2Mat=testOrth2Mat*test2Mat*testOrth2Mat.';
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
            phi=pi/6;
            dirVec=[cos(phi) sin(phi) ].';
            resEllipsoid=minkdiffIa(testEllipsoid1, testEllipsoid2, dirVec);
            resOldEllipsoid=minkdiff_ia(ellipsoid(test1Mat), ellipsoid(test2Mat),...
                dirVec);
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            mlunit.assert_equals(1,isEllEqual(resEllipsoid,...
                Ellipsoid(oldCenVec,oldQMat)));
            %
            %Test#4. Difference between 3-dimension ellipsoids.
            test1Mat=10*diag(1:3);
            test1Mat=testOrth3Mat*test1Mat*testOrth3Mat.';
            test1Mat=0.5*(test1Mat+test1Mat.');
            test2Mat=diag(1:3);
            test2Mat=testOrth3Mat*test2Mat*testOrth3Mat.';
            test2Mat=0.5*(test2Mat+test2Mat.');
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
            phi=pi/6;
            dirVec=[cos(phi);sin(phi);zeros(1,1)];
            dirVec=testOrth3Mat*dirVec;
            resEllipsoid=minkdiffIa(testEllipsoid1, testEllipsoid2, dirVec);
            resOldEllipsoid=minkdiff_ia(ellipsoid(test1Mat), ellipsoid(test2Mat),...
                dirVec);
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            mlunit.assert_equals(1,isEllEqual(resEllipsoid,...
                Ellipsoid(oldCenVec,oldQMat)));
            %
            %Test#5. Difference between high dimension ellipsoids. 100D case.
            test1Mat=10*diag(1:100);
            test1Mat=testOrth100Mat*test1Mat*testOrth100Mat.';
            test1Mat=0.5*(test1Mat+test1Mat.');
            test2Mat=diag(1:100);
            test2Mat=testOrth100Mat*test2Mat*testOrth100Mat.';
            test2Mat=0.5*(test2Mat+test2Mat.');
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
            phi=pi/6;
            dirVec=[cos(phi);sin(phi);zeros(98,1)];
            dirVec=testOrth100Mat*dirVec;
            resEllipsoid=minkdiffIa(testEllipsoid1, testEllipsoid2, dirVec);
            resOldEllipsoid=minkdiff_ia(ellipsoid(test1Mat), ellipsoid(test2Mat),...
                dirVec);
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            mlunit.assert_equals(1,isEllEqual(resEllipsoid,...
                Ellipsoid(oldCenVec,oldQMat)));
            
            %Test#6. Difference between high dimension ellipsoids. 100D case.
            % Non-zero centers.
            nDims=100;
            testCen1Vec=(1:nDims)';
            testCen2Vec=(-49:50).';
            test1Mat=10*diag(1:nDims);
            test1Mat=testOrth100Mat*test1Mat*testOrth100Mat.';
            test1Mat=0.5*(test1Mat+test1Mat.');
            test2Mat=diag(1:nDims);
            test2Mat=testOrth100Mat*test2Mat*testOrth100Mat.';
            test2Mat=0.5*(test2Mat+test2Mat.');
            testEllipsoid1=Ellipsoid(testCen1Vec,test1Mat);
            testEllipsoid2=Ellipsoid(testCen2Vec,test2Mat);
            phi=pi/6;
            dirVec=[cos(phi);sin(phi);zeros(98,1)];
            dirVec=testOrth100Mat*dirVec;
            resEllipsoid=minkdiffIa(testEllipsoid1, testEllipsoid2, dirVec);
            resOldEllipsoid=minkdiff_ia(ellipsoid(testCen1Vec,test1Mat),...
                ellipsoid(testCen2Vec,test2Mat),dirVec);
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            mlunit.assert_equals(1,isEllEqual(resEllipsoid,...
                Ellipsoid(oldCenVec,oldQMat)));
            %
            %Test#7. Difference between 3-dimension ellipsoids.
            % Degenerate case
            test1Mat=diag([1;2;0]);
            test2Mat=diag([0.5;1;0]);
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
            phi=pi/2.1;
            dirVec=[cos(phi);sin(phi);zeros(1,1)];
            resEllipsoid=minkdiffIa(testEllipsoid1, testEllipsoid2, dirVec);
            resOldEllipsoid=minkdiff_ia(ellipsoid(test1Mat(1:2,1:2)),...
                ellipsoid(test2Mat(1:2,1:2)),dirVec(1:2));
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            [eigOMat diaOMat]=eig(oldQMat);
            ansWMat=zeros(3);
            ansWMat(1:2,1:2)=eigOMat;
            ansWMat(3,3)=1;
            ansDMat=zeros(3);
            ansDMat(1:2,1:2)=diaOMat;
            ansEllipsoid=Ellipsoid([oldCenVec; 0],ansDMat,ansWMat);
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,...
                ansEllipsoid));
            %
            %Test#8. Difference between 3-dimension ellipsoids.
            % Infinite case. Rotated.
            test1Mat=diag([Inf;5;5]);
            test2Mat=diag([Inf;1;1]);
            cenVec=zeros(3,1);
            testEllipsoid1=Ellipsoid(cenVec,test1Mat,testOrth3Mat);
            testEllipsoid2=Ellipsoid(cenVec,test2Mat,testOrth3Mat);
            dirVec=[0;10;-1];
            dirVec=dirVec/norm(dirVec);
            dirVec=testOrth3Mat*dirVec;
            resEllipsoid=minkdiffIa(testEllipsoid1, testEllipsoid2, dirVec);
            resOldEllipsoid=minkdiff_ia(ellipsoid(test1Mat(2:3,2:3)),...
                ellipsoid(test2Mat(2:3,2:3)),dirVec(2:3));
            [~, oldQMat]=double(resOldEllipsoid);
            [~, diaOMat]=eig(oldQMat);
            ansDMat=zeros(3);
            ansDMat(1,1)=Inf;
            ansDMat(2:3,2:3)=diaOMat;
            mlunit.assert_equals(1,isEllEll2Equal(Ellipsoid(resEllipsoid.diagMat),...
                Ellipsoid(ansDMat)));
            %
            %Test#9. Difference between 3-dimension ellipsoids.
            % Infinite and degenerate
            test1Mat=diag([Inf;Inf;1]);
            %test1Mat=testOrth3Mat*test1Mat*testOrth3Mat.';
            %test1Mat=0.5*(test1Mat+test1Mat.');
            test2Mat=diag([1;1;0]);
            %test2Mat=testOrth3Mat*test2Mat*testOrth3Mat.';
            %test2Mat=0.5*(test2Mat+test2Mat.');
            cenVec=zeros(3,1);
            testEllipsoid1=Ellipsoid(cenVec,test1Mat,testOrth3Mat.');
            testEllipsoid2=Ellipsoid(cenVec,test2Mat,testOrth3Mat.');
            dirVec=[1;1;1];
            dirVec=dirVec/norm(dirVec);
            resEllipsoid=minkdiffIa(testEllipsoid1, testEllipsoid2, dirVec);
            %
            ansDMat=diag([Inf;Inf;1]);
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,...
                Ellipsoid(cenVec,ansDMat,testOrth3Mat.')));
        end
        %
        %
        %
        function self = testMinksum_ia(self)
            import elltool.core.Ellipsoid;
            %
            load(strcat(self.testDataRootDir,filesep,'testNewEll.mat'),...
                'testEll2x2Mat','testEll2x3Mat','testEll10x2Mat',...
                'testEll10x3Mat','testEll10x20Mat',...
                'testEll10x50Mat','testEll10x100Mat');
            %
            load(strcat(self.testDataRootDir,filesep,'testNewEllRandM.mat'),...
                'testOrth2Mat','testOrth3Mat',...
                'testOrth20Mat','testOrth50Mat',...
                'testOrth100Mat');
            % Test#1. Simple.
            test1Mat=2*eye(2);
            test2Mat=[1 0; 0 2];
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
            dirVec=[1,0].';
            resEllipsoid=minksumIa([testEllipsoid1, testEllipsoid2], dirVec);
            resOldEllipsoid=minksum_ia([ellipsoid(test1Mat), ellipsoid(test2Mat)],...
                dirVec);
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,...
                Ellipsoid(oldCenVec,oldQMat)));
            %
            % Test#2. Ten ellipsoids. Non-degenerate. Non-zero centers.
            % Non-diagonal matrices. Random matrices.
            % A lot of multiple various directions.
            % 50D case.
            nElems=10;
            nDim=50;
            testEllNewVec(nElems)=Ellipsoid();
            testEllOldVec(nElems)=ellipsoid();
            for iElem=1:nElems
                centerVec=iElem*(1:nDim).';
                qMat=testEll10x50Mat{iElem};
                testEllNewVec(iElem)=Ellipsoid(centerVec,qMat);
                testEllOldVec(iElem)=ellipsoid(centerVec,qMat);
            end
            nDirs=48;
            angleStep=2*pi/nDirs;
            phiAngle=0:angleStep:2*pi-angleStep;
            dirMat=[cos(phiAngle); sin(phiAngle); zeros(nDim-2,nDirs)];
            resNewEllVec=minksumIa(testEllNewVec,dirMat);
            resOldEllVec=minksum_ia(testEllOldVec,dirMat);
            isStillCorrect=true;
            iDir=1;
            while (iDir<nDirs) && isStillCorrect
                newQMat=resNewEllVec(iDir).eigvMat*resNewEllVec(iDir).diagMat*...
                    resNewEllVec(iDir).eigvMat.';
                newQMat=0.5*(newQMat+newQMat.');
                newQCenVec=resNewEllVec(iDir).centerVec;
                [oldQCenVec oldQMat]=double(resOldEllVec(iDir));
                iDir=iDir+1;
                isStillCorrect=isEllEll2Equal(Ellipsoid(newQCenVec,newQMat),...
                    Ellipsoid(oldQCenVec,oldQMat));
            end
            mlunit.assert_equals(1, isStillCorrect);
            %
            %Test#3(o2). Infinite+nondegenerate.
            test1WMat=[1 -1;1 1];
            test1WMat=test1WMat/norm(test1WMat);
            test1DVec=[Inf 0].';
            test2DVec=[1 1].';
            testEllipsoid1=Ellipsoid([0,0].',test1DVec,test1WMat);
            testEllipsoid2=Ellipsoid(test2DVec);
            dirVec=[1 10].';
            dirVec=dirVec/norm(dirVec);
            resEllipsoid=minksumIa([testEllipsoid1, testEllipsoid2], dirVec);
            %
            ansDiagVec=[Inf 1].';
            ansEigvMat=[1 -1; 1 1];
            ansEigvMat=ansEigvMat/norm(ansEigvMat);
            ansCenVec=[0 0].';
            ansEllipsoid=Ellipsoid(ansCenVec,ansDiagVec,ansEigvMat);
            %
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,ansEllipsoid));
            %
            %Test#4. Infinite+nondegenerate. Direction is collinear
            %to inf eigenvector. Result - R^2.
            test1WMat=[1 -1;1 1];
            test1WMat=test1WMat/norm(test1WMat);
            test1DVec=[Inf 0].';
            test2DVec=[1 1].';
            testEllipsoid1=Ellipsoid([0,0].',test1DVec,test1WMat);
            testEllipsoid2=Ellipsoid(test2DVec);
            dirVec=[1 1].';
            dirVec=dirVec/norm(dirVec);
            resEllipsoid=minksumIa([testEllipsoid1, testEllipsoid2], dirVec);
            %
            ansDiagVec=[Inf Inf].';
            ansEigvMat=[1 0; 0 1];
            ansCenVec=[0 0].';
            ansEllipsoid=Ellipsoid(ansCenVec,ansDiagVec,ansEigvMat);
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,ansEllipsoid));
            %
            % Test#5.
            test1Mat=[2 0;0 1];
            test2Mat=[4 0;0 3];
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
            dirVec=[1,1].';
            dirVec=dirVec/norm(dirVec);
            resEllipsoid=minksumIa([testEllipsoid1, testEllipsoid2], dirVec);
            resOldEllipsoid=minksum_ia([ellipsoid(test1Mat), ellipsoid(test2Mat)],...
                dirVec);
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            %
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,...
                Ellipsoid(oldCenVec,oldQMat)));
            
            %Test#6(o3). Infinite+nondegenerate. 3d-case
            nDim=3;
            test1WMat=eye(nDim);
            test1DVec=[1 2 Inf].';
            test2DVec=[3 4 5].';
            testEllipsoid1=Ellipsoid([0,0,0].',test1DVec,test1WMat);
            testEllipsoid2=Ellipsoid(test2DVec);
            dirVec=[1 1 0].';
            dirVec=dirVec/norm(dirVec);
            resEllipsoid=minksumIa([testEllipsoid1, testEllipsoid2], dirVec);
            %
            %compute result for projections by old method
            auxEll1=ellipsoid(diag([1 2].'));
            auxEll2=ellipsoid(diag([3 4].'));
            dirVec=dirVec(1:2);
            auxEll=minksum_ia([auxEll1,auxEll2],dirVec);
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
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,ansEllipsoid));
            %
            %Test#7(o5). Infinite,nondegenerate+Infinite,nondegenerate.
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
            resEllipsoid=minksumIa([testEllipsoid1, testEllipsoid2], dirVec);
            %
            ansDiagVec=[Inf Inf].';
            ansEigvMat=[1 0; 0 1];
            ansCenVec=[0 0].';
            ansEllipsoid=Ellipsoid(ansCenVec,ansDiagVec,ansEigvMat);
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,ansEllipsoid));
            %
            %Test#8(o7). Two degenerate. 3d-case
            test1QMat=[1 0 0;0 0 0;0 0 0];
            test2QMat=[0 0 0;0 2 0;0 0 0];
            cen1Vec=[1 1 1].';
            cen2Vec=[1 -1 10].';
            testEllipsoid1=Ellipsoid(cen1Vec,test1QMat);
            testEllipsoid2=Ellipsoid(cen2Vec,test2QMat);
            dirVec=[1 0 0].';
            dirVec=dirVec/norm(dirVec);
            resEllipsoid=minksumIa([testEllipsoid1, testEllipsoid2], dirVec);
            %
            ansCenVec=[2; 0; 11];
            ansEigvMat=eye(3);
            ansDiagVec=diag([1 0 0]);
            ansEllipsoid=Ellipsoid(ansCenVec,ansDiagVec,ansEigvMat);
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,ansEllipsoid));
            %
            %
        end
        function self = testMinkdiff_ea(self)
            %
            import elltool.core.Ellipsoid;
            %
            load(strcat(self.testDataRootDir,filesep,'testNewEll.mat'),...
                'testEll2x2Mat','testEll2x3Mat','testEll10x2Mat',...
                'testEll10x3Mat','testEll10x20Mat',...
                'testEll10x50Mat','testEll10x100Mat');
            %
            load(strcat(self.testDataRootDir,filesep,'testNewEllRandM.mat'),...
                'testOrth2Mat','testOrth3Mat',...
                'testOrth20Mat','testOrth50Mat',...
                'testOrth100Mat');
            %
            %Test#1. Simple.
            test1Mat=2*eye(2);
            test2Mat=[1 0; 0 0.1];
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
            dirVec=[1,0].';
            resEllipsoid=minkdiffEa(testEllipsoid1, testEllipsoid2, dirVec);
            resOldEllipsoid=minkdiff_ea(ellipsoid(test1Mat), ellipsoid(test2Mat),...
                dirVec);
            %
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,...
                Ellipsoid(oldCenVec,oldQMat)));
            %
            %Test#2. Difference between sphere and random ellipse.
            test1Mat=2*eye(2);
            %test1Mat=testOrth2Mat*test1Mat*testOrth2Mat.';
            test2Mat=[1 0; 0 0.1];
            test2Mat=testOrth2Mat*test2Mat*testOrth2Mat.';
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
            phi=pi/6;
            dirVec=[cos(phi) sin(phi) ].';
            resEllipsoid=minkdiffEa(testEllipsoid1, testEllipsoid2, dirVec);
            resOldEllipsoid=minkdiff_ea(ellipsoid(test1Mat), ellipsoid(test2Mat),...
                dirVec);
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,...
                Ellipsoid(oldCenVec,oldQMat)));
            %
            %Test#3. Difference between 3-dimension ellipsoids.
            test1Mat=10*diag(1:3);
            test1Mat=testOrth3Mat*test1Mat*testOrth3Mat.';
            test1Mat=0.5*(test1Mat+test1Mat.');
            test2Mat=diag(1:3);
            test2Mat=testOrth3Mat*test2Mat*testOrth3Mat.';
            test2Mat=0.5*(test2Mat+test2Mat.');
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
            phi=pi/6;
            dirVec=[cos(phi);sin(phi);zeros(1,1)];
            dirVec=testOrth3Mat*dirVec;
            resEllipsoid=minkdiffEa(testEllipsoid1, testEllipsoid2, dirVec);
            resOldEllipsoid=minkdiff_ea(ellipsoid(test1Mat), ellipsoid(test2Mat),...
                dirVec);
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,...
                Ellipsoid(oldCenVec,oldQMat)));
            %
            %Test#4. Difference between high dimension ellipsoids. 100D case.
            test1Mat=10*diag(1:100);
            test1Mat=testOrth100Mat*test1Mat*testOrth100Mat.';
            test1Mat=0.5*(test1Mat+test1Mat.');
            test2Mat=diag(1:100);
            test2Mat=testOrth100Mat*test2Mat*testOrth100Mat.';
            test2Mat=0.5*(test2Mat+test2Mat.');
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
            phi=pi/6;
            dirVec=[cos(phi);sin(phi);zeros(98,1)];
            dirVec=testOrth100Mat*dirVec;
            resEllipsoid=minkdiffEa(testEllipsoid1, testEllipsoid2, dirVec);
            resOldEllipsoid=minkdiff_ea(ellipsoid(test1Mat), ellipsoid(test2Mat),...
                dirVec);
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,...
                Ellipsoid(oldCenVec,oldQMat)));
            
            %Test#5. Difference between high dimension ellipsoids. 100D case.
            % Non-zero centers.
            nDims=100;
            testCen1Vec=(1:nDims)';
            testCen2Vec=(-49:50).';
            test1Mat=10*diag(1:nDims);
            test1Mat=testOrth100Mat*test1Mat*testOrth100Mat.';
            test1Mat=0.5*(test1Mat+test1Mat.');
            test2Mat=diag(1:nDims);
            test2Mat=testOrth100Mat*test2Mat*testOrth100Mat.';
            test2Mat=0.5*(test2Mat+test2Mat.');
            testEllipsoid1=Ellipsoid(testCen1Vec,test1Mat);
            testEllipsoid2=Ellipsoid(testCen2Vec,test2Mat);
            phi=pi/3;
            dirVec=[cos(phi);sin(phi);zeros(98,1)];
            dirVec=testOrth100Mat*dirVec;
            resEllipsoid=minkdiffEa(testEllipsoid1, testEllipsoid2, dirVec);
            resOldEllipsoid=minkdiff_ea(ellipsoid(testCen1Vec,test1Mat),...
                ellipsoid(testCen2Vec,test2Mat),dirVec);
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,...
                Ellipsoid(oldCenVec,oldQMat)));
            %
            %Test#6. Difference between 3-dimension ellipsoids.
            % Degenerate case
            test1Mat=diag([1;2;0]);
            test2Mat=diag([0.5;1;0]);
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
            phi=pi/2.1;
            dirVec=[cos(phi);sin(phi);zeros(1,1)];
            resEllipsoid=minkdiffEa(testEllipsoid1, testEllipsoid2, dirVec);
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
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,...
                ansEllipsoid));
            %
            %Test#7. Difference between 3-dimension ellipsoids.
            % Infinite case. Rotated.
            test1Mat=diag([Inf;5;5]);
            test2Mat=diag([Inf;1;1]);
            cenVec=zeros(3,1);
            testEllipsoid1=Ellipsoid(cenVec,test1Mat,testOrth3Mat);
            testEllipsoid2=Ellipsoid(cenVec,test2Mat,testOrth3Mat);
            dirVec=[0;10;-1];
            dirVec=dirVec/norm(dirVec);
            dirVec=testOrth3Mat*dirVec;
            resEllipsoid=minkdiffEa(testEllipsoid1, testEllipsoid2, dirVec);
            resOldEllipsoid=minkdiff_ea(ellipsoid(test1Mat(2:3,2:3)),...
                ellipsoid(test2Mat(2:3,2:3)),dirVec(2:3));
            [~, oldQMat]=double(resOldEllipsoid);
            [~, diaOMat]=eig(oldQMat);
            ansDMat=zeros(3);
            ansDMat(1,1)=Inf;
            ansDMat(2:3,2:3)=diaOMat;
            mlunit.assert_equals(1,isEllEll2Equal(Ellipsoid(resEllipsoid.diagMat),...
                Ellipsoid(ansDMat)));
            %
            %Test#8. Difference between 3-dimension ellipsoids.
            % Infinite and degenerate
            test1Mat=diag([Inf;Inf;1]);
            test2Mat=diag([1;1;0]);
            cenVec=zeros(3,1);
            testEllipsoid1=Ellipsoid(cenVec,test1Mat);
            testEllipsoid2=Ellipsoid(cenVec,test2Mat);
            dirVec=[1;1;1];
            dirVec=dirVec/norm(dirVec);
            resEllipsoid=minkdiffEa(testEllipsoid1, testEllipsoid2, dirVec);
            %
            ansDMat=diag([Inf;Inf;1]);
            mlunit.assert_equals(1,isEllEll2Equal(resEllipsoid,...
                Ellipsoid(cenVec,ansDMat)))
        end
        %
        %
        %%%%%%%%%%%%%%%
        function self = testDistance(self)
            import elltool.core.Ellipsoid;
            %
            load(strcat(self.testDataRootDir,filesep,'testNewEll.mat'),...
                'testEll2x2Mat','testEll2x3Mat','testEll10x2Mat',...
                'testEll10x3Mat','testEll10x20Mat',...
                'testEll10x50Mat','testEll10x100Mat');
            load(strcat(self.testDataRootDir,filesep,'testEllEllRMat.mat'),...
                'testOrth50Mat','testOrth100Mat','testOrth3Mat','testOrth2Mat');
            %
            CHECK_TOL=1e-9;
            % Test#1. Two ellipsoids. 2D case.
            testEllipsoid1 = Ellipsoid([25,0;0,9]);
            testEllipsoid2 = Ellipsoid([10;0],[4,0;0,9]);
            testRes=distanceNew(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1, (abs(testRes-3)<CHECK_TOL));
            % Test#2. Two ellipsoids. 3D case.
            testEllipsoid1 = Ellipsoid([0,-15,0].',[25,0,0;0,100,0;0,0,9]);
            testEllipsoid2 = Ellipsoid([0,7,0].',[9,0,0;0,25,0;0,0,100]);
            testRes=distanceNew(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1, (abs(testRes-7)<CHECK_TOL));
            % Test#3. Case of ellipses with intersection
            testEllipsoid1 = Ellipsoid([1 2 3].',[1,2,5;2,5,3;5,3,100]);
            testEllipsoid2 = Ellipsoid([1,2,3.2].',[1,2,7;2,10,5;7,5,100]);
            testRes=distanceNew(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1, (abs(testRes)<CHECK_TOL));
            %
            % Test#4. distance between two ellipsoids of high dimensions and random
            %matrices
            nDim=100;
            testEll1Mat=diag(1:2:2*nDim);
            testEll1Mat=testOrth100Mat*testEll1Mat*testOrth100Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll2Mat=diag([25;(1:(nDim-1)).']);
            testEll2Mat=testOrth100Mat*testEll2Mat*testOrth100Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth100Mat*[9;zeros(nDim-1,1)];
            testEllipsoid1=Ellipsoid(testEll1Mat);
            testEllipsoid2=Ellipsoid(testEll2CenterVec,testEll2Mat);
            testRes=distanceNew(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1,abs(testRes-3)<CHECK_TOL);
            %
            % Test#5. 3D. Nondeg-deg dist.
            testEllipsoid1 = Ellipsoid([1,1,1].');
            testEllipsoid2 = Ellipsoid([0,10,0].',[0,4,1].');
            testRes=distanceNew(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1, (abs(testRes-7)<CHECK_TOL));
            % Test#6. 3D. Nondeg-deg dist.
            testEllipsoid1 = Ellipsoid([1,1,1].');
            testEllipsoid2 = Ellipsoid([0,10,0].',[0,0,1].');
            testRes=distanceNew(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1, (abs(testRes-9)<CHECK_TOL));
        end
        function testRotation(~)
            d1Vec=[0 0 Inf 0 2 3];
            d2Vec=[1 Inf 0 0 2 Inf];
            nDims=numel(d1Vec);
            lVec=rand(nDims,1);
            [oMat,~]=qr(rand(nDims,nDims));
            %
            check(oMat,@minksumIa,lVec);
            check(oMat,@minksumEa,lVec);            
            %
            d1Vec=[1   Inf 0 2 2 0];
            d2Vec=[0.5 Inf 0 0 2 0];
            %
            check(oMat,@(x,y)minkdiffIa(x(1),x(2),y),lVec);
            check(oMat,@(x,y)minkdiffEa(x(1),x(2),y),lVec);
            %
            function check(oMat,fMethod,lVec)
                ell1Apx=build(oMat,fMethod,lVec);
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
                eigVMat=oMat.'*eigVMat;
                ellApx=Ellipsoid(ellApx.centerVec,ellApx.diagMat,eigVMat);
            end
            
        end
    end
end

function isEqual=isEllEqual(ellObj1, ellObj2)
%import elltool.conf.Properties;
%CHECK_TOL = Properties.getCHECK_TOL();
CHECK_TOL=1e-12;
isInfinite1Vec=diag(ellObj1.diagMat)==Inf;
isInfinite2Vec=diag(ellObj2.diagMat)==Inf;
ell1VMat=ellObj1.eigvMat(~isInfinite1Vec,~isInfinite1Vec);
ell1DMat=ellObj1.diagMat(~isInfinite1Vec,~isInfinite1Vec);
ell2DMat=ellObj2.diagMat(~isInfinite2Vec,~isInfinite2Vec);
ell2VMat=ellObj2.eigvMat(~isInfinite2Vec,~isInfinite2Vec);
isEqualInfinite=all(isInfinite1Vec==isInfinite2Vec);
isEqualFinite=all(all(abs(ell1VMat*ell1DMat*ell1VMat.'-...
    ell2VMat*ell2DMat*ell2VMat.')<CHECK_TOL));
isEqual=isEqualInfinite && isEqualFinite;
end

function isEqual=isEqM( objMat1, objMat2)
%     import elltool.conf.Properties;
%     CHECK_TOL = Properties.getCHECK_TOL();
CHECK_TOL=1e-9;
isEqual=all(all(abs(objMat1-objMat2)<CHECK_TOL));
end

function isEqual=isEqV( objVec1, objVec2)
%import elltool.conf.Properties;
%CHECK_TOL = Properties.getCHECK_TOL();
CHECK_TOL=1e-12;
isInf1Vec=objVec1==Inf;
isInf2Vec=objVec2==Inf;
isEqualInf=all(isInf1Vec==isInf2Vec);
isEqualFin=all(abs(objVec1(~isInf1Vec)-objVec2(~isInf2Vec))<CHECK_TOL);
isEqual=isEqualInf && isEqualFin;
end
function isEqual=isEqElM(resEllipsoid,ansVMat,ansDVec,ansCenVec)
eigvMat=resEllipsoid.eigvMat;
diagVec=diag(resEllipsoid.diagMat);
cenVec=resEllipsoid.centerVec;
%sort in increasing eigenvalue order
[diagVec indVec]=sort(diagVec);
eigvMat=eigvMat(:,indVec);
[ansDVec indVec]=sort(ansDVec);
ansVMat=ansVMat(:,indVec);
isEqual=isEqV(diagVec,ansDVec)&&isEqV(cenVec,ansCenVec)&&...
    isEqM(eigvMat,ansVMat);
end

function isEqual=isEllEll2Equal(ellObj1, ellObj2)
% eig vectors corresponding to the same eig values are collinear
eigv1Mat=ellObj1.eigvMat;
diag1Vec=diag(ellObj1.diagMat);
cen1Vec=ellObj1.centerVec;
eigv2Mat=ellObj2.eigvMat;
diag2Vec=diag(ellObj2.diagMat);
cen2Vec=ellObj2.centerVec;
isInf1Vec=diag1Vec==Inf;
isInf2Vec=diag2Vec==Inf;
eigvFin1Mat=eigv1Mat(:,~isInf1Vec);
eigvFin2Mat=eigv2Mat(:,~isInf2Vec);
ellQ1Mat=eigvFin1Mat*diag(diag1Vec(~isInf1Vec))*eigvFin1Mat.';
ellQ2Mat=eigvFin2Mat*diag(diag2Vec(~isInf2Vec))*eigvFin2Mat.';
isEqual=isEqM(ellQ1Mat,ellQ2Mat) && isEqV(cen1Vec,cen2Vec);
end