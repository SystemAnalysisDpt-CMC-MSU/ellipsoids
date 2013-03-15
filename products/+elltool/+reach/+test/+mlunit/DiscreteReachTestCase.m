classdef DiscreteReachTestCase < mlunit.test_case
    properties (Constant, GetAccess = private)
        REL_TOL = 1e-5;
        ABS_TOL = 1e-6;
    end
    %
    properties (Access = private)
       testDataRootDir
    end
    %
    methods (Static)
        function [supFunMat directionsCVec trCenterMat] = calcExpectedParameters(linsysACMat, ...
                linsysBCMat, ...
                controlBoundsCenterCVec, controlBoundsCMat, ...
                initialSetCenterVec, initialSetMat, ...
                initialDirectionsMat, timeIntervalVec)
            
            
            k0 = timeIntervalVec(1);
            k1 = timeIntervalVec(2);
            
            xDim = size(linsysACMat, 1);
            nDirections = size(initialDirectionsMat, 2);
            
            syms k;
            fAMatCalc = @(t)subs(linsysACMat,k,t);
            fBMatCalc = @(t)subs(linsysBCMat,k,t);
            fControlBoundsCenterVecCalc = @(t)subs(controlBoundsCenterCVec,k,t);
            fControlBoundsMatCalc = @(t)subs(controlBoundsCMat,k,t);
            
            nTimeStep = abs(k1 - k0) + 1;
            
            isBack = k0 > k1;
            
            if isBack
                tVec = k0:-1:k1;
            else
                tVec = k0:k1;
            end
            
            directionsCVec = cell(1, nDirections);
            trCenterMat = zeros(xDim, nTimeStep);
            
            trCenterMat(:, 1) = initialSetCenterVec;
            for kTime = 2:nTimeStep
                if isBack
                    pinvAMat = pinv(fAMatCalc(tVec(kTime)));
                    trCenterMat(:, kTime) =  pinvAMat * trCenterMat(:, kTime - 1) - ...
                        pinvAMat * fBMatCalc(tVec(kTime)) * fControlBoundsCenterVecCalc(tVec(kTime));
                else
                    trCenterMat(:, kTime) =  fAMatCalc(tVec(kTime - 1)) * trCenterMat(:, kTime - 1) + ...
                        fBMatCalc(tVec(kTime - 1)) * fControlBoundsCenterVecCalc(tVec(kTime - 1));
                end
            end
            
            
            FundCMat = cell(nTimeStep, nTimeStep);
            for iTime = 1:nTimeStep
                FundCMat{iTime, iTime} = eye(xDim);
            end
            
            for jTime = 1:nTimeStep
                for iTime = jTime + 1:nTimeStep
                    if isBack
                        FundCMat{iTime, jTime} = ...
                            pinv(fAMatCalc(tVec(iTime))) * FundCMat{iTime - 1, jTime};
                    else
                        FundCMat{iTime, jTime} = ...
                            fAMatCalc(tVec(iTime - 1)) * FundCMat{iTime - 1, jTime};
                    end
                end
            end
            
            for jTime = 1:nTimeStep
                for iTime = 1:jTime - 1
                    FundCMat{iTime, jTime} = ...
                        pinv(FundCMat{jTime, iTime});
                end
            end
            
            supFunMat = zeros(nTimeStep, nDirections);
            
            rMatCalc = @(t) fBMatCalc(t) * fControlBoundsMatCalc(t) * fBMatCalc(t)';
            
            for iDirection = 1:nDirections
                directionsCVec{iDirection} = zeros(xDim, nTimeStep);
                lVec = initialDirectionsMat(:, iDirection);
                supFunMat(1, iDirection) = sqrt(lVec' * initialSetMat * lVec);
                directionsCVec{iDirection}(:, 1) = lVec;
                for kTime = 1:nTimeStep - 1
                    directionsCVec{iDirection}(:, kTime + 1) = FundCMat{1, kTime + 1}' * lVec;
                    if isBack
                        supFunMat(kTime + 1, iDirection) = ...
                            supFunMat(kTime, iDirection) + ...
                            sqrt(lVec' * FundCMat{1, kTime} * ...
                            rMatCalc(tVec(kTime + 1)) * FundCMat{1, kTime}' * lVec);
                    else
                        supFunMat(kTime + 1, iDirection) = ...
                            supFunMat(kTime, iDirection) + ...
                            sqrt(lVec' * FundCMat{1, kTime + 1} * ...
                            rMatCalc(tVec(kTime + 1)) * FundCMat{1, kTime + 1}' * lVec);
                    end
                end
                
                for kTime = 1:nTimeStep
                    curDirectionVec = directionsCVec{iDirection}(:, kTime);
                    supFunMat(kTime, iDirection) = supFunMat(kTime, iDirection) + ...
                        curDirectionVec' * trCenterMat(:, kTime);
                end
                
            end            
        end
    end
    %
    methods
        function self = DiscreteReachTestCase(varargin)
            self = self@mlunit.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir =...
                [fileparts(which(className)), filesep,...
                'TestData', filesep, shortClassName];
        end
        %
        function self = DISABLED_testFirstBasicTest(self)
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
        function self = DISABLED_testSecondBasicTest(self)
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
        function self = testFirst(self)
            nTest = 6;
            
            for iTest = 1:nTest
                loadFileStr = strcat(self.testDataRootDir,...
                    '/test', num2str(iTest), '.mat');
                load(loadFileStr,...
                    'linsysACMat', 'linsysBCMat', 'controlBoundsCentreCVec', ...
                    'controlBoundsCMat', 'initialSetCenterVec', 'initialSetMat', ...
                    'timeIntervalVec', 'initialDirectionsMat');
                
                controlBoundsUEll.center = controlBoundsCentreCVec;
                controlBoundsUEll.shape = controlBoundsCMat;
                
                initialSetEll = ellipsoid(initialSetCenterVec, initialSetMat);
                
                linSysObj = ...
                    elltool.linsys.LinSys(linsysACMat, ...
                    linsysBCMat, controlBoundsUEll, ...
                    [], [], [], [], 'd');                

                reachSetObj = elltool.reach.ReachDiscrete(linSysObj, ...
                    initialSetEll, ...
                    initialDirectionsMat, ...
                    timeIntervalVec);
                
                [eaEllMat ~] = reachSetObj.get_ea();
                [iaEllMat ~] = reachSetObj.get_ia();
                [directionsCVec ~] = reachSetObj.get_directions();
                [goodCurvesCVec ~] = reachSetObj.get_goodcurves();
                [trCenterMat ~] = reachSetObj.get_center();
                returnedLinSys = reachSetObj.get_system();
                
                isGetSystemOk = returnedLinSys == linSysObj;
                
                
                
                [expectedSupFunMat expectedDirectionsCVec ...
                    expectedTrCenterMat] = ...
                    self.calcExpectedParameters(linsysACMat, ...
                    linsysBCMat, ...
                    controlBoundsCentreCVec, controlBoundsCMat, ...
                    initialSetCenterVec, initialSetMat, ...
                    initialDirectionsMat, timeIntervalVec);
                
                k0 = timeIntervalVec(1);
                k1 = timeIntervalVec(2);
                
                nTimeStep = abs(k1 - k0) + 1;
                nDirections = size(initialDirectionsMat, 2);
                iaSupFunValueMat = zeros(nTimeStep, nDirections);
                eaSupFunValueMat = zeros(nTimeStep, nDirections);
                
                xDim = size(linsysACMat, 1);
                
                isCenterOk = all(max(abs(expectedTrCenterMat - trCenterMat), [], 1) < self.REL_TOL);
                
                isDirectionOk = true;
                for iDirection = 1:nDirections
                    isDirectionOk = isDirectionOk && ...
                        all(max(abs(expectedDirectionsCVec{iDirection} - directionsCVec{iDirection}), [], 1) < self.REL_TOL);
                end
                                
                isGoodCurvesOk = true;
                expectedGoodCurvesCVec = cell(1, nDirections);
                for iDirection = 1:nDirections
                    expectedGoodCurvesCVec{iDirection} = zeros(xDim, nTimeStep);
                    
                    
                    for kTime = 1:nTimeStep
                        lVec = directionsCVec{iDirection}(:, kTime); 
                        [curEaCenterVec curEaShapeMat] = ...
                            double(eaEllMat(iDirection, kTime));
                        
                        expectedGoodCurvesCVec{iDirection}(:, kTime) = ...
                            curEaCenterVec + curEaShapeMat * lVec / ...
                            (lVec' * curEaShapeMat * lVec)^(1/2);
                    end                    

                    corRelTolMat = [max(abs(goodCurvesCVec{iDirection}), [], 1); ...
                        ones(1, nTimeStep)];                    
                    correctedRelTolVec = self.REL_TOL * ...
                        max(corRelTolMat, [], 1) * 10;
                    
                    isGoodCurvesOk = isGoodCurvesOk && ...
                        all(max(abs(expectedGoodCurvesCVec{iDirection} - goodCurvesCVec{iDirection}), [], 1) < correctedRelTolVec);
                end
                
                for iDirection = 1:nDirections
                    directionsSeqMat = directionsCVec{iDirection};
                    
                    for kTime = 1:nTimeStep
                       lVec = directionsSeqMat(:, kTime);
                        iaSupFunValueMat(kTime, iDirection) = ...
                            rho(iaEllMat(iDirection, kTime), lVec);
                        eaSupFunValueMat(kTime, iDirection) = ...
                            rho(eaEllMat(iDirection, kTime), lVec); 
                    end
                end
                
                corRelTolMat = [max(abs(eaSupFunValueMat), [], 2) ...
                    ones(nTimeStep, 1)];
                correctedRelTolVec = self.REL_TOL * ...
                    max(corRelTolMat, [], 2) * 10;
                
                isEaOk = all(max(abs(expectedSupFunMat - eaSupFunValueMat), [], 2) < ...
                    correctedRelTolVec);
                
                isIaOk = all(max(abs(expectedSupFunMat - iaSupFunValueMat), [], 2) < ...
                    correctedRelTolVec);
                
                isOk = isCenterOk && isDirectionOk && isGoodCurvesOk && ...
                    isEaOk && isIaOk && isGetSystemOk;
                
                
                
                mlunit.assert_equals(isOk, true);
            end
        end
        
    end
    
end