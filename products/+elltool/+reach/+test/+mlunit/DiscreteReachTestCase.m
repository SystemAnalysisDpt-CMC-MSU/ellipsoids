classdef DiscreteReachTestCase < mlunitext.test_case
    properties (Access = private, Constant)
        COMP_PRECISION = 5e-5;
    end
    properties (Access=private)
        testDataRootDir
        linSys
        reachObj
        tIntervalVec
        x0Ell
        l0Mat
        expDim
        fundCMat
    end
    methods (Static)
        function fundCMat = calculateFundamentalMatrix(self)
            k0 = self.tIntervalVec(1);
            k1 = self.tIntervalVec(2);
            
            xDim = size(self.linSys.getAtMat(), 1);
            
            syms t;
            fAMatCalc = @(x)subs(self.linSys.getAtMat(), t, x);
            
            nTimeStep = abs(k1 - k0) + 1;
            
            isBack = k0 > k1;
            
            if isBack
                tVec = k0:-1:k1;
            else
                tVec = k0:k1;
            end
            
            fundCMat = cell(nTimeStep, nTimeStep);
            for iTime = 1:nTimeStep
                fundCMat{iTime, iTime} = eye(xDim);
            end
            
            for jTime = 1:nTimeStep
                for iTime = jTime + 1:nTimeStep
                    if isBack
                        fundCMat{iTime, jTime} = ...
                            pinv(fAMatCalc(tVec(iTime))) * fundCMat{iTime - 1, jTime};
                    else
                        fundCMat{iTime, jTime} = ...
                            fAMatCalc(tVec(iTime - 1)) * fundCMat{iTime - 1, jTime};
                    end
                end
            end
            
            for jTime = 1:nTimeStep
                for iTime = 1:jTime - 1
                    fundCMat{iTime, jTime} = ...
                        pinv(fundCMat{jTime, iTime});
                end
            end
        end
        
        function trCenterMat = calculateTrajectoryCenterMat(self)
            k0 = self.tIntervalVec(1);
            k1 = self.tIntervalVec(2);
            
            xDim = size(self.linSys.getAtMat(), 1);
            
            syms t;
            fAMatCalc = @(x)subs(self.linSys.getAtMat(), t, x);
            fBMatCalc = @(x)subs(self.linSys.getBtMat(), t, x);
            
            pCVec = self.linSys.getUBoundsEll().center;
            
            fControlBoundsCenterVecCalc = @(x)subs(pCVec, t, x);
            
            nTimeStep = abs(k1 - k0) + 1;
            
            isBack = k0 > k1;
            
            if isBack
                tVec = k0:-1:k1;
            else
                tVec = k0:k1;
            end
            
            trCenterMat = zeros(xDim, nTimeStep);
            
            [x0Vec ~] = double(self.x0Ell);
            
            trCenterMat(:, 1) = x0Vec;
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
        end
        
        function directionsCVec = calculateDirectionsCVec(self)
            k0 = self.tIntervalVec(1);
            k1 = self.tIntervalVec(2);
            
            xDim = size(self.linSys.getAtMat(), 1);
            nDirections = size(self.l0Mat, 2);
            
            nTimeStep = abs(k1 - k0) + 1;
            
            directionsCVec = cell(1, nDirections);
            
            for iDirection = 1:nDirections
                directionsCVec{iDirection} = zeros(xDim, nTimeStep);
                l0Vec = self.l0Mat(:, iDirection);
                directionsCVec{iDirection}(:, 1) = l0Vec;
                for kTime = 1:nTimeStep - 1
                    lVec = self.fundCMat{1, kTime + 1}' * l0Vec;
                    directionsCVec{iDirection}(:, kTime + 1) = lVec;
                end
            end
            
            if self.reachObj.isbackward()
                directionsCVec = cellfun(@(x) fliplr(x), directionsCVec, ...
                    'UniformOutput', false);
            end
        end
        
        function goodCurvesCVec = calculateGoodCurvesCVec(self)
            k0 = self.tIntervalVec(1);
            k1 = self.tIntervalVec(2);
            
            xDim = size(self.linSys.getAtMat(), 1);
            nDirections = size(self.l0Mat, 2);
            
            nTimeStep = abs(k1 - k0) + 1;
            
            [directionsCVec ~] = self.reachObj.get_directions();
            [eaEllMat ~] = self.reachObj.get_ea();
            
            goodCurvesCVec = cell(1, nDirections);
            for iDirection = 1:nDirections
                goodCurvesCVec{iDirection} = zeros(xDim, nTimeStep);
                
                for kTime = 1:nTimeStep
                    lVec = directionsCVec{iDirection}(:, kTime);
                    [curEaCenterVec curEaShapeMat] = ...
                        double(eaEllMat(iDirection, kTime));
                    
                    goodCurvesCVec{iDirection}(:, kTime) = ...
                        curEaCenterVec + curEaShapeMat * lVec / ...
                        (lVec' * curEaShapeMat * lVec)^(1/2);
                end
            end
        end
        
        function supFunMat = calculateSupFunMat(self)
            k0 = self.tIntervalVec(1);
            k1 = self.tIntervalVec(2);
            
            nDirections = size(self.l0Mat, 2);
            pCMat = self.linSys.getUBoundsEll().shape;
            
            syms t;
            fBMatCalc = @(x)subs(self.linSys.getBtMat(), t, x);
            fControlBoundsMatCalc = @(x)subs(pCMat, t, x);
            rMatCalc = @(x) fBMatCalc(x) * fControlBoundsMatCalc(x) * fBMatCalc(x)';
            
            nTimeStep = abs(k1 - k0) + 1;
            
            isBack = k0 > k1;
            
            if isBack
                tVec = k0:-1:k1;
            else
                tVec = k0:k1;
            end
            
            [directionsCVec ~] = self.reachObj.get_directions();
            [trCenterMat ~] = self.reachObj.get_center();
            
            x0Mat = double(self.x0Ell);
            
            supFunMat = zeros(nTimeStep, nDirections);
            
            for iDirection = 1:nDirections
                lVec = self.l0Mat(:, iDirection);
                supFunMat(1, iDirection) = sqrt(lVec' * x0Mat * lVec);
                for kTime = 1:nTimeStep - 1
                    if isBack
                        supFunMat(kTime + 1, iDirection) = ...
                            supFunMat(kTime, iDirection) + ...
                            sqrt(lVec' * self.fundCMat{1, kTime} * ...
                            rMatCalc(tVec(kTime + 1)) * self.fundCMat{1, kTime}' * lVec);
                    else
                        supFunMat(kTime + 1, iDirection) = ...
                            supFunMat(kTime, iDirection) + ...
                            sqrt(lVec' * self.fundCMat{1, kTime + 1} * ...
                            rMatCalc(tVec(kTime)) * self.fundCMat{1, kTime + 1}' * lVec);
                    end
                end
                
                for kTime = 1:nTimeStep
                    curDirectionVec = directionsCVec{iDirection}(:, kTime);
                    supFunMat(kTime, iDirection) = supFunMat(kTime, iDirection) + ...
                        curDirectionVec' * trCenterMat(:, kTime);
                end
            end
            
            if self.reachObj.isbackward()
                supFunMat = flipdim(supFunMat, 1);
            end
        end
    end
    methods
        function self = DiscreteReachTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir = [fileparts(which(className)),...
                filesep, 'TestData', filesep, shortClassName];
        end
        %
        function self = set_up_param(self, reachFactObj)
            self.reachObj = reachFactObj.createInstance();
            self.linSys = reachFactObj.getLinSys();
            self.expDim = reachFactObj.getDim();
            self.tIntervalVec = reachFactObj.getTVec();
            self.x0Ell = reachFactObj.getX0Ell();
            self.l0Mat = reachFactObj.getL0Mat();
            self.fundCMat = self.calculateFundamentalMatrix(self);
        end
        
        function self = testGetSystem(self)
            isEqual = self.linSys.isEqual(self.reachObj.get_system());
            mlunitext.assert_equals(true, isEqual);
            projReachObj = self.reachObj.projection(...
                eye(self.reachObj.dimension, 2));
            isEqual = self.linSys.isEqual(projReachObj.get_system);
            mlunitext.assert_equals(true, isEqual);
        end
        
        function self = testGetCenter(self)
            [trCenterMat ~] = self.reachObj.get_center();
            expectedTrCenterMat = self.calculateTrajectoryCenterMat(self);
            
            isEqual =...
                all(max(abs(expectedTrCenterMat - trCenterMat), [], 1)...
                < self.COMP_PRECISION);
            mlunitext.assert_equals(true, isEqual);
        end
        
        function self = testGetDirections(self)
            expectedDirectionsCVec = self.calculateDirectionsCVec(self);
            [directionsCVec ~] = self.reachObj.get_directions();
            
            nDirections = size(self.l0Mat, 2);
            isEqual = true;
            for iDirection = 1:nDirections
                isEqual = isEqual && ...
                    all(max(abs(expectedDirectionsCVec{iDirection} - directionsCVec{iDirection}), [], 1) < self.COMP_PRECISION);
            end
            mlunitext.assert_equals(true, isEqual);
        end
        
        function self = testGetGoodCurves(self)
            expectedGoodCurvesCVec = self.calculateGoodCurvesCVec(self);
            [goodCurvesCVec ~] = self.reachObj.get_goodcurves();
            
            k0 = self.tIntervalVec(1);
            k1 = self.tIntervalVec(2);
            
            nTimeStep = abs(k1 - k0) + 1;
            nDirections = size(self.l0Mat, 2);
            
            isEqual = true;
            for iDirection = 1:nDirections
                corRelTolMat = [max(abs(goodCurvesCVec{iDirection}), [], 1); ...
                    ones(1, nTimeStep)];
                correctedRelTolVec = self.COMP_PRECISION * ...
                    max(corRelTolMat, [], 1) * 10;
                
                isEqual = isEqual && ...
                    all(max(abs(expectedGoodCurvesCVec{iDirection} - goodCurvesCVec{iDirection}), [], 1) < correctedRelTolVec);
            end
            mlunitext.assert_equals(true, isEqual);
        end
        
        function self = testGetEa(self)
            expectedSupFunMat = self.calculateSupFunMat(self);
            
            k0 = self.tIntervalVec(1);
            k1 = self.tIntervalVec(2);
            
            nTimeStep = abs(k1 - k0) + 1;
            nDirections = size(self.l0Mat, 2);
            
            [directionsCVec ~] = self.reachObj.get_directions();
            [eaEllMat ~] = self.reachObj.get_ea();
            
            eaSupFunValueMat = zeros(nTimeStep, nDirections);
            
            for iDirection = 1:nDirections
                directionsSeqMat = directionsCVec{iDirection};
                
                for kTime = 1:nTimeStep
                    lVec = directionsSeqMat(:, kTime);
                    eaSupFunValueMat(kTime, iDirection) = ...
                        rho(eaEllMat(iDirection, kTime), lVec);
                end
            end
            
            isEqual = all(max(abs(expectedSupFunMat - eaSupFunValueMat), [], 2) < ...
                self.COMP_PRECISION);
            
            mlunitext.assert_equals(true, isEqual);
        end
        
        function self = testGetIa(self)
            expectedSupFunMat = self.calculateSupFunMat(self);
            
            k0 = self.tIntervalVec(1);
            k1 = self.tIntervalVec(2);
            
            nTimeStep = abs(k1 - k0) + 1;
            nDirections = size(self.l0Mat, 2);
            
            [directionsCVec ~] = self.reachObj.get_directions();
            [iaEllMat ~] = self.reachObj.get_ia();
            
            eaSupFunValueMat = zeros(nTimeStep, nDirections);
            
            for iDirection = 1:nDirections
                directionsSeqMat = directionsCVec{iDirection};
                
                for kTime = 1:nTimeStep
                    lVec = directionsSeqMat(:, kTime);
                    eaSupFunValueMat(kTime, iDirection) = ...
                        rho(iaEllMat(iDirection, kTime), lVec);
                end
            end
            
            isEqual = all(max(abs(expectedSupFunMat - eaSupFunValueMat), [], 2) < ...
                self.COMP_PRECISION);
            
            mlunitext.assert_equals(true, isEqual);
        end
        
        function self = testFirstBasicTest(self)
            loadFileStr = strcat(self.testDataRootDir,...
                '/demo3DiscreteTest.mat');
            load(loadFileStr, 'aMat', 'bMat', 'ControlBounds',...
                'x0Ell', 'l0Mat', 'timeVec');
            linSysObj = elltool.linsys.LinSysFactory.create(aMat, bMat,...
                ControlBounds, [], [], [], [], 'd');
            %timeVec = [0, 3];
            reachSetObj = elltool.reach.ReachDiscrete(linSysObj,...
                x0Ell, l0Mat, timeVec);
            evalc('reachSetObj.display();');
            firstCutReachObj =...
                reachSetObj.cut([timeVec(1)+1 timeVec(end)-1]);
            [~] = reachSetObj.cut(timeVec(1)+2);
            [~, ~] = reachSetObj.dimension();
            [~, ~] = reachSetObj.get_center();
            [~, ~] = reachSetObj.get_directions();
            [~, ~] = reachSetObj.get_ea();
            [~, ~] = reachSetObj.get_ia();
            [~, ~] = reachSetObj.get_goodcurves();
            [~] = reachSetObj.get_system();
            projBasMat = [0 0 0 0 1 0; 0 0 0 0 0 1].';
            projReachSetObj = reachSetObj.projection(projBasMat);
            fig = figure();
            hold on;
            projReachSetObj.plot_ea();
            projReachSetObj.plot_ia();
            hold off;
            close(fig);
            newReachObj = reachSetObj.evolve(timeVec(2) + 1);
            projReachSetObj.isprojection();
            firstCutReachObj.iscut();
            newReachObj.isempty();
            mlunitext.assert_equals(true, true);
        end
        %
        function self = testSecondBasicTest(self)
            loadFileStr = strcat(self.testDataRootDir,...
                '/distorbDiscreteTest.mat');
            load(loadFileStr, 'aMat', 'bMat', 'ControlBounds',...
                'gMat', 'DistorbBounds', 'x0Ell', 'l0Mat', 'timeVec');
            linSysObj = elltool.linsys.LinSysFactory.create(aMat, bMat,...
                ControlBounds, gMat, DistorbBounds, [], [], 'd');
            reachSetObj = elltool.reach.ReachDiscrete(linSysObj,...
                x0Ell, l0Mat, timeVec);
            evalc('reachSetObj.display();');
            firstCutReachObj =...
                reachSetObj.cut([timeVec(1)+1 timeVec(end)-1]);
            [~] = reachSetObj.cut(timeVec(1)+2);
            [~,~] = reachSetObj.dimension();
            [~,~] = reachSetObj.get_center();
            [~,~] = reachSetObj.get_directions();
            [~,~] = reachSetObj.get_ea();
            [~,~] = reachSetObj.get_ia();
            [~,~] = reachSetObj.get_goodcurves();
            [~] = reachSetObj.get_system();
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
            mlunitext.assert_equals(true, true);
        end
    end
end