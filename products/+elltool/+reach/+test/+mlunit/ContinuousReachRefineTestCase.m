classdef ContinuousReachRefineTestCase < mlunitext.test_case
    properties (Access=private)
        linSys
        reachObj
        tVec
        x0Ell
        l0P1Mat
        l0P2Mat
    end
     methods
        function self = ContinuousReachRefineTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self, reachFactObj)
            self.reachObj = reachFactObj.createInstance();
            self.linSys = reachFactObj.getLinSys();
            self.tVec = reachFactObj.getTVec();
            l0Mat = reachFactObj.getL0Mat();
            [~, mSize]=size(l0Mat);
            nPart1=floor(mSize/2);
            self.x0Ell = reachFactObj.getX0Ell();
            self.l0P1Mat=l0Mat(:,1:nPart1);
            self.l0P2Mat=l0Mat(:,nPart1+1:end);
        end
        %
        function self = testRefine(self)
            import gras.ellapx.smartdb.F;
            %
            reachWholeObj=elltool.reach.ReachContinuous(self.linSys,...
                self.x0Ell,self.l0P1Mat,self.tVec);
            %
            reachWholeObj.refine(self.l0P2Mat);
            isEqual = self.reachObj.isEqual(reachWholeObj);
            mlunit.assert_equals(true,isEqual);
        end
        function self = testRefMisc(self)
            lSys=buildLS();
            lDirMat=[1,-1,0,1;
                0,2,1,-1];
            nN=2;
            l1DirMat=lDirMat(:,1:nN);
            l2DirMat=lDirMat(:,nN+1:end);
            %
            %Check Refine direct time
            timeVec=[0 0.5];
            reachSetObj=buildRS(l1DirMat);
            checkRefine();
            %
            %Check refine reverse time
            timeVec=[0.5 0];
            reachSetObj=buildRS(l1DirMat);
            checkRefine();
            %
            % Check after evolve
            newEndTime=1;
            timeVec=[0 0.5];
            reachSetObj=buildRS(l1DirMat);
            reachSetObj.evolve(newEndTime);
            checkRefine();
            %
            % Check after evolve, reverse time
            newEndTime=0;
            timeVec=[1 0.5];
            reachSetObj=buildRS(l1DirMat);
            reachSetObj.evolve(newEndTime);
            checkRefine();
            %
            % Check projection
            timeVec=[0 0.5];
            reachSetObj=buildRS(l1DirMat);
            %
            projMat=[1,0;0,1];
            projSet=reachSetObj.projection(projMat);
            %
            projSetNew=projSet;
            projSetNew.refine(l2DirMat);
            %
            reachSetObj=buildRS(lDirMat);
            projReachSetObj=reachSetObj.projection(projMat);
            isEqual = projSetNew.isEqual(projReachSetObj);
            mlunit.assert_equals(true,isEqual);
            %
            function checkRefine()
                reachObjNew=reachSetObj;
                reachObjNew.refine(l2DirMat);
                reachSetObj=buildRS(lDirMat);
                isEqual = reachSetObj.isEqual(reachObjNew);
                mlunit.assert_equals(true,isEqual);
            end
            function reachSet = buildRS(lDirMat)
                x0EllObj=ellipsoid(eye(2));
                reachSet=elltool.reach.ReachContinuous(...
                    lSys,x0EllObj,lDirMat,timeVec);
            end
            function linSys = buildLS()
                aMat=[1 2; 2 1];
                bMat=[1 2;0 1];
                uEll=ellipsoid(eye(2));
                linSys=elltool.linsys.LinSysContinuous(aMat,bMat,uEll);
            end
        end
    end
end