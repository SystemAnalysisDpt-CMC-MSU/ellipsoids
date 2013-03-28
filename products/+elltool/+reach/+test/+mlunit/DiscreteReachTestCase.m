classdef DiscreteReachTestCase < mlunitext.test_case

    %
    properties (Access = private)
       testDataRootDir
    end
    %
    methods
        function self = DiscreteReachTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir =...
                [fileparts(which(className)), filesep,...
                'TestData', filesep, shortClassName];
        end
        %
      
        function self = testFirstBasicTest(self)
            loadFileStr = strcat(self.testDataRootDir,...
                '/demo3DiscreteTest.mat');
            load(loadFileStr, 'aMat', 'bMat', 'ControlBounds',...
                'x0Ell', 'l0Mat', 'timeVec');
            linSysObj = elltool.linsys.LinSys(aMat, bMat,...
                ControlBounds, [], [], [], [], 'd');
            reachSetObj = elltool.reach.ReachDiscrete(linSysObj,...
                x0Ell, l0Mat, timeVec);
            reachSetObj.display();
            firstCutReachObj =...
                reachSetObj.cut([timeVec(1)+1 timeVec(end)-1]);
            secondCutReachObj = reachSetObj.cut(timeVec(1)+2);
            [rSdim sSdim] = reachSetObj.dimension();
            [trCenterMat tVec] = reachSetObj.get_center();
            [directionsCVec tVec] = reachSetObj.get_directions();
            [eaEllMat tVec] = reachSetObj.get_ea();
            [iaEllMat tVec] = reachSetObj.get_ia();
            [goodCurvesCVec tVec] = reachSetObj.get_goodcurves();
            [muMat tVec] = reachSetObj.get_mu();
            linSys = reachSetObj.get_system();
            projBasMat = [0 0 0 0 1 0; 0 0 0 0 0 1]';
            projReachSetObj = reachSetObj.projection(projBasMat);
            fig = figure();
            hold on;
            projReachSetObj.plot_ea();
            projReachSetObj.plot_ia();
            hold off;
            close(fig);
            newReachObj = reachSetObj.evolve(2 * timeVec(2));
            projReachSetObj.isprojection();
            firstCutReachObj.iscut();
            newReachObj.isempty();
            mlunit.assert_equals(true, true);
        end
        %
        function self = testSecondBasicTest(self)
            loadFileStr = strcat(self.testDataRootDir,...
                '/distorbDiscreteTest.mat');
            load(loadFileStr, 'aMat', 'bMat', 'ControlBounds',...
                'gMat', 'DistorbBounds', 'x0Ell', 'l0Mat', 'timeVec');
            linSysObj = elltool.linsys.LinSys(aMat, bMat,...
                ControlBounds, gMat, DistorbBounds, [], [], 'd');
            reachSetObj = elltool.reach.ReachDiscrete(linSysObj,...
                x0Ell, l0Mat, timeVec);
            reachSetObj.display();
            firstCutReachObj =...
                reachSetObj.cut([timeVec(1)+1 timeVec(end)-1]);
            secondCutReachObj = reachSetObj.cut(timeVec(1)+2);
            [rSdim sSdim] = reachSetObj.dimension();
            [trCenterMat tVec] = reachSetObj.get_center();
            [directionsCVec tVec] = reachSetObj.get_directions();
            [eaEllMat tVec] = reachSetObj.get_ea();
            [iaEllMat tVec] = reachSetObj.get_ia();
            [goodCurvesCVec tVec] = reachSetObj.get_goodcurves();
            [muMat tVec] = reachSetObj.get_mu();
            linSys = reachSetObj.get_system();
            projBasMat = [1 0 0; 0 0 1]';
            projReachSetObj = reachSetObj.projection(projBasMat);
            fig = figure();
            hold on;
            projReachSetObj.plot_ea();
            projReachSetObj.plot_ia();
            hold off;
            close(fig);
            newReachObj = reachSetObj.evolve(2 * timeVec(2));
            projReachSetObj.isprojection();
            firstCutReachObj.iscut();
            newReachObj.isempty();
            mlunit.assert_equals(true, true);
        end
        %
          function self=testConstructor(self)
            timeVec=[0 5.1];
            fMethod=@(lSys) elltool.reach.ReachDiscrete(lSys,ellipsoid(eye(2)),...
                [1 0]', timeVec);
            %
            checkUVW2(self,'U',fMethod);
            checkUVW2(self,'V',fMethod);
            checkUVW2(self,'W',fMethod);
        end
        %
        function self = testEvolve(self)
          
            lSys=elltool.linsys.LinSys(eye(2),eye(2),ellipsoid(eye(2)));
            rSet=elltool.reach.ReachDiscrete(lSys,ellipsoid(eye(2)),[1 0]', [0 1]);
            timeVec=[2 5]';
            fMethod=@(lSys) evolve(rSet,timeVec,lSys);
            %
            checkUVW2(self,'V',fMethod);
            checkUVW2(self,'U',fMethod);
            checkUVW2(self,'W',fMethod);
        end
        %
        function checkUVW2(self,typeUVW,fMethod)
            
            % U - control, V - disturbance, W - noise
            % Center of ellipsoid is of type double
            lSysRight=formVLinSys(typeUVW,1,false,false);
            lSysWrong=formVLinSys(typeUVW,2,false,false);
            fMethod(lSysRight);
            self.runAndCheckError(@check,...
                'wrongMat');
            %
            % Center of ellipsoid is of type cell
            lSysRight=formVLinSys(typeUVW,1,false,true);
            lSysWrong=formVLinSys(typeUVW,2,false,true);
            fMethod(lSysRight);
            self.runAndCheckError(@check,...
                'wrongMat');
            %
            if typeUVW~='W'
                % Matrix is of type cell
                lSysRight=formVLinSys(typeUVW,1,true,true);
                lSysWrong=formVLinSys(typeUVW,2,true,true);
                fMethod(lSysRight);
                self.runAndCheckError(@check,...
                    'wrongMat');
            end
            function check()
                fMethod(lSysWrong);
            end
            function lSys=formVLinSys(typeUVW,typeMatShape,isGCell,isCenterCell)
                
                
                if isCenterCell
                    testStruct.center={'0';'0'};
                else
                    testStruct.center=[0,0]';
                end
                if typeMatShape==1
                    shapeCMat={'1' ,'0'; '0', '1'};
                else
                    shapeCMat={'0.1-k', 'k'; 'k', 'k'};
                end
                if ~isGCell
                    testMat=eye(2);
                else
                    testMat={'1', '0'; '0', '1'};
                end
                testStruct.shape=shapeCMat;
                if typeUVW=='V'
                    lSys=elltool.linsys.LinSys(eye(2),eye(2),ellipsoid(eye(2)),testMat,...
                        testStruct);
                elseif typeUVW=='U'
                    lSys=elltool.linsys.LinSys(eye(2),testMat,testStruct);
                elseif typeUVW=='W'
                    lSys=elltool.linsys.LinSys(eye(2),eye(2),ellipsoid(eye(2)),...
                        eye(2),ellipsoid(eye(2)),eye(2),testStruct);
                end
            end
        end
    end
    
end