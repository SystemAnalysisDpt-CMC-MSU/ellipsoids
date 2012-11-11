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

            ellObj5=Ellipsoid([0 0 0 0].', [1 Inf 2 Inf]', rand(4,4));
            ellObj2=Ellipsoid([1 2 3].');
            nDims=10;
            M1=orth(randn(nDims,nDims));
            M=M1*diag(1:nDims)*M1.';
            M=M+M.';
            ellObj1=Ellipsoid([1:nDims].',M);
        end
        
        function self = testInv(self)
            import elltool.core.Ellipsoid;
            ell1Obj=Ellipsoid([1 5 10].');
            ellInv1Obj=ell1Obj.inv();
            ell2Obj=Ellipsoid([0 5 Inf].');
            ellInv2Obj=ell2Obj.inv();
        end
        function self = testMinksum_ea(self)
            global ellOptions
            %
            import elltool.core.Ellipsoid;
            %
            load(strcat(self.testDataRootDir,filesep,'testNewEll.mat'),...
                 'testEll2x2Mat','testEll2x3Mat','testEll10x2Mat',...
                 'testEll10x3Mat','testEll10x20Mat',...
                  'testEll10x50Mat','testEll10x100Mat');
            % Test#1. Two non-degenerate ellipsoids. Zero centers. 
            %Simple diagonal matrices. Simple direction. 2D case.
            q1Mat=[1 0;0 1];
            q2Mat=[9 0;0 9];
            dirVec=[1, 0].';
            ellNew1Obj=Ellipsoid(q1Mat);
            ellNew2Obj=Ellipsoid(q2Mat);
            resNewEll=minksumNew_ea([ellNew1Obj,ellNew2Obj],dirVec);
            resOldEll=minksum_ea([ellipsoid(q1Mat),ellipsoid(q2Mat)],dirVec);
            newQMat=resNewEll.eigvMat*resNewEll.diagMat*resNewEll.eigvMat.';
            [oldQCenVec oldQMat]=double(resOldEll);
            mlunit.assert_equals(1, all(all(abs(newQMat-oldQMat)<...
                ellOptions.abs_tol)));
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
            resNewEll=minksumNew_ea([ellNew1Obj,ellNew2Obj],dirVec);
            resOldEll=minksum_ea([ellipsoid(cen1Vec,q1Mat),ellipsoid(cen2Vec,q2Mat)],dirVec);
            newQMat=resNewEll.eigvMat*resNewEll.diagMat*resNewEll.eigvMat.';
            newQCenVec=resNewEll.centerVec;
            [oldQCenVec oldQMat]=double(resOldEll);
            mlunit.assert_equals(1, all(all(abs(newQMat-oldQMat)<...
                ellOptions.abs_tol))&& all(oldQCenVec-newQCenVec)<ellOptions.abs_tol);
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
            resNewEll=minksumNew_ea([ellNew1Obj,ellNew2Obj],dirVec);
            resOldEll=minksum_ea([ellipsoid(cen1Vec,q1Mat),ellipsoid(cen2Vec,q2Mat)],dirVec);
            newQMat=resNewEll.eigvMat*resNewEll.diagMat*resNewEll.eigvMat.';
            newQCenVec=resNewEll.centerVec;
            [oldQCenVec oldQMat]=double(resOldEll);
            mlunit.assert_equals(1, all(all(abs(newQMat-oldQMat)<...
                ellOptions.abs_tol))&& all((oldQCenVec-newQCenVec)<ellOptions.abs_tol));
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
            resNewEllVec=minksumNew_ea([ellNew1Obj,ellNew2Obj],dirMat);
            resOldEllVec=minksum_ea([ellipsoid(cen1Vec,q1Mat),ellipsoid(cen2Vec,q2Mat)],dirMat);
            while (iDir<nDirs) && isStillCorrect
                newQMat=resNewEllVec(iDir).eigvMat*resNewEllVec(iDir).diagMat*...
                    resNewEllVec(iDir).eigvMat.';
                newQCenVec=resNewEllVec(iDir).centerVec;
                [oldQCenVec oldQMat]=double(resOldEllVec(iDir));
                iDir=iDir+1;
                isStillCorrect=all(all(abs(newQMat-oldQMat)<...
                ellOptions.abs_tol))&& all((oldQCenVec-newQCenVec)<ellOptions.abs_tol);
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
            resNewEllVec=minksumNew_ea([ellNew1Obj,ellNew2Obj],dirMat);
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
                ellOptions.abs_tol))&& all((oldQCenVec-newQCenVec)<ellOptions.abs_tol);
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
            resNewEllVec=minksumNew_ea(testEllNewVec,dirMat);
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
                ellOptions.abs_tol))&& all((oldQCenVec-newQCenVec)<ellOptions.abs_tol);
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
            resNewEllVec=minksumNew_ea(testEllNewVec,dirMat);
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
                ellOptions.abs_tol))&& all((oldQCenVec-newQCenVec)<ellOptions.abs_tol);
            end
            mlunit.assert_equals(1, isStillCorrect);
            %
            % Test#8. Two ellipsoids. Degenerate case. 
            % Bounded result.
            testEllipsoid1=Ellipsoid([1 0; 0 1]);
            testEllipsoid2=Ellipsoid([1 0; 0 0]);
            testDirVec=[1 0].';
            resEllObj=minksumNew_ea([testEllipsoid1,testEllipsoid2],testDirVec);
            resEllMat=resEllObj.eigvMat*resEllObj.diagMat*resEllObj.eigvMat.';
            testAnswerMat=[4 0; 0 2];
            mlunit.assert_equals(1,all(all(abs(resEllMat-testAnswerMat)<...
                ellOptions.abs_tol)))
            % Test#8. Two ellipsoids. Degenerate case. 
            % Unbounded result.
            testEllipsoid1=Ellipsoid([1 0; 0 1]);
            testEllipsoid2=Ellipsoid([1 0; 0 0]);
            testDirVec=[0 1].';
            resEllObj=minksumNew_ea([testEllipsoid1,testEllipsoid2],testDirVec);
            resEllMat=resEllObj.diagMat;
            testAnswerMat=[Inf 0; 0 1];
            mlunit.assert_equals(1,all(all(resEllMat==testAnswerMat)));
            % Test#9. Two ellipsoids. Degenerate case. 
            % Zero Matrix.
            testEllipsoid1=Ellipsoid([1 2; 2 5]);
            testEllipsoid2=Ellipsoid([0 0; 0 0]);
            testDirVec=[cos(0.7) sin(0.7)].';
            resEllObj=minksumNew_ea([testEllipsoid1,testEllipsoid2],testDirVec);
            resEllMat=resEllObj.eigvMat*resEllObj.diagMat*resEllObj.eigvMat.';
            testAnswerMat=[1 2; 2 5];
            mlunit.assert_equals(1,all(all((resEllMat-testAnswerMat)<...
                ellOptions.abs_tol)));
            %
            % Test#10. Two ellipsoids. Degenerate case. 
            % Two directions. 2D case.
            testEllipsoid1=Ellipsoid([10 0; 0 0]);
            testEllipsoid2=Ellipsoid([0 0; 0 20]);
            testDirMat=[0,1;1,0];
            resEllObjVec=minksumNew_ea([testEllipsoid1,testEllipsoid2],testDirMat);
            mlunit.assert_equals(1,isEllEqual(resEllObjVec(1),Ellipsoid([Inf 0; 0 20]))&&...
                isEllEqual(resEllObjVec(2),Ellipsoid([10 0; 0 Inf])));
            %
            % Test#11. Three ellipsoids. Degenerate case. 
            % One directions. 3D case.
            testEllipsoid1=Ellipsoid([10;25;30]);
            testEllipsoid2=Ellipsoid([2 0 0;0 0 0;0 0 0]);
            testEllipsoid3=Ellipsoid([0 0 0;0 9 0;0 0 0]);
            testDirVec=[0,1,0].';
            testEllVec=[testEllipsoid1,testEllipsoid2,testEllipsoid3];
            resEllObj=minksumNew_ea(testEllVec,testDirVec);
            mlunit.assert_equals(1,isEllEqual(resEllObj,...
                Ellipsoid([Inf 0 0; 0 64 0;0 0 48])));
            
        end
         function self = testMinkdiff_ia(self)
            global ellOptions
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
            resEllipsoid=minkdiffNew_ia(testEllipsoid1, testEllipsoid2, dirVec);
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
             resEllipsoid=minkdiffNew_ia(testEllipsoid1, testEllipsoid2, dirVec);
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
             resEllipsoid=minkdiffNew_ia(testEllipsoid1, testEllipsoid2, dirVec);
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
             resEllipsoid=minkdiffNew_ia(testEllipsoid1, testEllipsoid2, dirVec);
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
             resEllipsoid=minkdiffNew_ia(testEllipsoid1, testEllipsoid2, dirVec);
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
             resEllipsoid=minkdiffNew_ia(testEllipsoid1, testEllipsoid2, dirVec);
             resOldEllipsoid=minkdiff_ia(ellipsoid(testCen1Vec,test1Mat),...
                 ellipsoid(testCen2Vec,test2Mat),dirVec);
             [oldCenVec oldQMat]=double(resOldEllipsoid);
             mlunit.assert_equals(1,isEllEqual(resEllipsoid,...
                 Ellipsoid(oldCenVec,oldQMat)));      
         end
         function self = testMinksum_ia(self)
            global ellOptions
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
            % Test#1. Simple.
            test1Mat=2*eye(2);
            test2Mat=[1 0; 0 2];
            testEllipsoid1=Ellipsoid(test1Mat);
            testEllipsoid2=Ellipsoid(test2Mat);
            dirVec=[1,0].';
            resEllipsoid=minksumNew_ia([testEllipsoid1, testEllipsoid2], dirVec);
            resOldEllipsoid=minksum_ia([ellipsoid(test1Mat), ellipsoid(test2Mat)],...
                dirVec);
%             vMat=resEllipsoid.eigvMat;
%             dMat=resEllipsoid.diagMat;
%             qMat=vMat*dMat*vMat.';
            [oldCenVec oldQMat]=double(resOldEllipsoid);
            mlunit.assert_equals(1,isEllEqual(resEllipsoid,...
                 Ellipsoid(oldCenVec,oldQMat)));       
            % 
            % Test#2. Ten ellipsoids. Non-degenerate. Non-zero centers. 
            % Non-diagonal matrices. Random matrices.
            % A lot of multiple various directions. 
            % 50D case.
            nElems=10;
            testEllNewVec(nElems)=Ellipsoid();
            testEllOldVec(nElems)=ellipsoid();
            for iElem=1:nElems
                centerVec=iElem*(1:50).';
                qMat=testEll10x50Mat{iElem};
                testEllNewVec(iElem)=Ellipsoid(centerVec,qMat);
                testEllOldVec(iElem)=ellipsoid(centerVec,qMat);
            end
            nDirs=48;
            angleStep=2*pi/nDirs;
            phiAngle=0:angleStep:2*pi-angleStep;
            dirMat=[cos(phiAngle); sin(phiAngle); zeros(48,nDirs)];
            resNewEllVec=minksumNew_ia(testEllNewVec,dirMat);
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
                isStillCorrect=isEllEqual(Ellipsoid(newQCenVec,newQMat),...
                    Ellipsoid(oldQCenVec,oldQMat));
            end
            mlunit.assert_equals(1, isStillCorrect);
            %             
         end
     end
end

function isEqual=isEllEqual(ellObj1, ellObj2)
    global ellOptions
    isInfinite1Vec=diag(ellObj1.diagMat)==Inf;
    isInfinite2Vec=diag(ellObj2.diagMat)==Inf;
    ell1VMat=ellObj1.eigvMat(~isInfinite1Vec,~isInfinite1Vec);
    ell1DMat=ellObj1.diagMat(~isInfinite1Vec,~isInfinite1Vec);
    ell2DMat=ellObj2.diagMat(~isInfinite2Vec,~isInfinite2Vec);
    ell2VMat=ellObj2.eigvMat(~isInfinite2Vec,~isInfinite2Vec);
    isEqualInfinite=all(isInfinite1Vec==isInfinite2Vec);
    isEqualFinite=all(all(abs(ell1VMat*ell1DMat*ell1VMat.'-...
        ell2VMat*ell2DMat*ell2VMat.')<ellOptions.abs_tol));
    isEqual=isEqualInfinite && isEqualFinite;
end
