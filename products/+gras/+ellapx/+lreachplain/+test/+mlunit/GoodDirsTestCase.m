classdef GoodDirsTestCase < mlunitext.test_case
    %
    methods
        function self = GoodDirsTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function tear_down(~)
            close all;
        end
        %
        function testGoodDirsClassesCreation(~)
            gras.ellapx.lreachplain.test.examples.examlpe_getGoodDirsContinuousGenLeft();
            gras.ellapx.lreachplain.test.examples.examlpe_getGoodDirsContinuousGenRight();
            gras.ellapx.lreachplain.test.examples.examlpe_getGoodDirsContinuousGenMid();
            gras.ellapx.lreachplain.test.examples.examlpe_getGoodDirsContinuousLTI();
            gras.ellapx.lreachplain.test.examples.examlpe_getGoodDirsDiscrete();
        end
        %
        function testGoodDirsContiniousLTI(~)
            import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
            import gras.ellapx.gen.RegProblemDynamicsFactory;
            import gras.ellapx.lreachplain.GoodDirsContinuousLTI;
            At = [{'1'}, {'0'}, {'0'};
                  {'0'}, {'1'}, {'0'};
                  {'0'}, {'0'}, {'1'}];
            Bt = [{'1'};
                  {'1'};
                  {'1'}];
            Pt = {'1'};
            pt = {'0'};
            Ct = [{'0'};
                  {'0'};
                  {'0'};];
            Qt = {'0'};
            qt = {'0'};
            X0 = eye(3);
            x0 = zeros(3, 1);
            t0 = 0;
            t1 = 10;
            sTime = 5;
            absTol = 1e-5;
            relTol = 1e-5;
            normTol = 1e-3;
            pDynObj = LReachProblemDynamicsFactory.createByParams(...
                At, Bt, Pt, pt, Ct, Qt, qt, X0, x0, [t0, t1], relTol, absTol);
            isRegEnabled = 1;
            isJustCheck = 0;
            regTol= 1e-5;
            pDynObj = RegProblemDynamicsFactory.create(pDynObj,...
                isRegEnabled, isJustCheck, regTol);
            lsGoodDirMat = [1, 0, 0;
                            1, 1, 0;
                            0, 1, 1];            
            normVec=sum(lsGoodDirMat.*lsGoodDirMat);
            indVec=find(normVec);
            normVec(indVec)=realsqrt(normVec(indVec));
            lsGoodDirMat(:,indVec)=lsGoodDirMat(:,indVec)./normVec(ones(1,size(At, 1)),...
                indVec);
            GoodDirsContiniousLTIObj=GoodDirsContinuousLTI(pDynObj, sTime, lsGoodDirMat, ...
                relTol, absTol);
            %
            evalTime=4;
            XstTransDynamicsEthalon=expm(eye(3).*(sTime-evalTime)).';
            XstNormDynamicsEthalon=norm(XstTransDynamicsEthalon);
            RstTransDynamicsEthalon=XstTransDynamicsEthalon./XstNormDynamicsEthalon;
            %
            XstTransDynamics=GoodDirsContiniousLTIObj.XstTransDynamics.evaluate(evalTime);
            XstNormDynamics=GoodDirsContiniousLTIObj.XstNormDynamics.evaluate(evalTime);
            RstTransDynamics=GoodDirsContiniousLTIObj.RstTransDynamics.evaluate(evalTime);
            %
            isOk=norm(XstTransDynamicsEthalon-XstTransDynamics)<normTol&&...
                norm(XstNormDynamicsEthalon-XstNormDynamics)<normTol&&...
                norm(RstTransDynamicsEthalon-RstTransDynamics)<normTol;
            mlunitext.assert_equals(true,isOk);
        end
        %
        function testGoodDirsContinious(~)
            import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
            import gras.ellapx.gen.RegProblemDynamicsFactory;
            import gras.ellapx.lreachplain.GoodDirsContinuousGen;
            At = [{'1'}, {'t'};
                  {'t'}, {'1'}];
            Bt = [{'1'};
                  {'1'}];
            Pt = {'1'};
            pt = {'0'};
            Ct = [{'0'};
                  {'0'};];
            Qt = {'0'};
            qt = {'0'};
            X0 = eye(2);
            x0 = zeros(2, 1);
            t0 = 0;
            sTime = 1;
            t1 = 1;
            absTol = 1e-5;
            relTol = 1e-5;
            normTol = 1e-3;
            pDynObj = LReachProblemDynamicsFactory.createByParams(...
                At, Bt, Pt, pt, Ct, Qt, qt, X0, x0, [t0, t1], relTol, absTol);
            isRegEnabled = 1;
            isJustCheck = 0;
            regTol= 1e-5;
            pDynObj = RegProblemDynamicsFactory.create(pDynObj,...
                isRegEnabled, isJustCheck, regTol);           
            lsGoodDirMat = [1, 0;
                            0, 1];            
            normVec=sum(lsGoodDirMat.*lsGoodDirMat);
            indVec=find(normVec);
            normVec(indVec)=realsqrt(normVec(indVec));
            lsGoodDirMat(:,indVec)=lsGoodDirMat(:,indVec)./normVec(ones(1,size(At, 1)),...
                indVec);
            GoodDirsContiniousObj=GoodDirsContinuousGen(pDynObj, sTime, lsGoodDirMat, ...
                relTol, absTol);
            %
            evalTime=0;
            XstTransDynamicsEthalon=[exp(1)*cosh(1^2/2), -exp(1)*sinh(1^2/2);
                                     -exp(1)*sinh(1^2/2), exp(1)*cosh(1^2/2)];
            %
            XstTransDynamics=GoodDirsContiniousObj.XstTransDynamics.evaluate(evalTime);
            %
            isOk=norm(XstTransDynamicsEthalon-XstTransDynamics)<normTol;
            mlunitext.assert_equals(true,isOk);
        end
    end
end