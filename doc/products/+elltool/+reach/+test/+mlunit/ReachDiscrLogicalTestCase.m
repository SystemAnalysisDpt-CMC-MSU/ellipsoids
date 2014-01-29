classdef ReachDiscrLogicalTestCase < mlunitext.test_case

    properties (Constant, GetAccess = private)
        REL_TOL = 1e-6;
        ABS_TOL = 1e-7;
    end

    methods
        function self = ReachDiscrLogicalTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        
        function self =testDisplay(self)
            nDim = 3;
            x0Ell = ellipsoid(zeros(nDim, 1), eye(nDim));
            % used in @evalc
            rs = createReach(eye(nDim), eye(nDim,4), ell_unitball(4),...
                x0Ell, eye(nDim), [0, 5]);
            resStr = evalc('display(rs)');
            isOk = ~isempty(strfind(resStr,'Reach set'));
            isOk = isOk && ~isempty(strfind(resStr,'discrete'));
            isOk = isOk && ~isempty(strfind(resStr,'Center'));
            isOk = isOk && ~isempty(strfind(resStr,'Shape'));
            isOk = isOk && ~isempty(strfind(resStr,'external'));
            isOk = isOk && ~isempty(strfind(resStr,'internal'));
            mlunitext.assert(isOk);      
        end
        
        
        function self =testDimension(self)
            nSystemDimension = 4;
            x0Ell = ellipsoid(zeros(nSystemDimension, 1), eye(nSystemDimension));
            lMat = eye(nSystemDimension);
            rs = createReach( eye(nSystemDimension), ...
                eye(nSystemDimension,2), ell_unitball(2), ...
                x0Ell, lMat, [0, 5]);
            [nObtainedReachDimension, nObtainedSystemDimension] = rs.dimension();
            isOk = nObtainedSystemDimension == nSystemDimension;
            isOk = isOk && (nObtainedReachDimension == nSystemDimension);
            
            nProjectionDimension = 2;
            projectedRs = rs.projection([1 0 0 0; 0 1 0 0]');
            [nObtainedReachDimension, nObtainedSystemDimension] = ...
                projectedRs.dimension();
            isOk = isOk && (nObtainedSystemDimension == nSystemDimension);
            isOk = isOk && (nObtainedReachDimension == nProjectionDimension);
            mlunitext.assert(isOk);
        end
        
        
        function self =testGetSystem(self)
            lsVec(1) = elltool.linsys.LinSysFactory.create( eye(3), ...
                eye(3,4), ell_unitball(4), eye(3), ell_unitball(3), ...
                eye(3), ell_unitball(3), 'd');
            rsVec(1) = elltool.reach.ReachDiscrete(lsVec(1), ...
                ellipsoid(zeros(3, 1), eye(3)), ...
                eye(3), [0, 5]);
            lsVec(2) = elltool.linsys.LinSysFactory.create(eye(4), ...
                eye(4, 2), ell_unitball(2), ...
                [], [], [], [], 'd');
            rsVec(2) = elltool.reach.ReachDiscrete(lsVec(2), ...
                ellipsoid(ones(4, 1), eye(4)), ...
                eye(4), [0, 3]);
            isOk = true;
            for iIndex = 1 : 2
                isOk = isOk && lsVec(iIndex) == rsVec(iIndex).get_system();
            end
            mlunitext.assert(isOk);
        end
        
        
        function self =testIsCut(self)
            aMat = [1 2; 3 4];
            bMat = [3; 2];
            pEll = 2*ell_unitball(1);
            x0Ell = ellipsoid([0; 0], [3 1; 1 2]);
            rsVec(1) = createReach(aMat, bMat, pEll, x0Ell, eye(2), [0,5]);
            rsVec(2) = rsVec(1).cut([2, 3]);
            rsVec(3) = rsVec(1).cut(3);
            isExpectedVec = [false, true, true];
            isObtainedVec = arrayfun(@iscut, rsVec);
            isOk = all(isExpectedVec == isObtainedVec);
            mlunitext.assert(isOk);
        end
        
        
        function self =testIsProjection(self)
            nDim = 3;
            bMat = [1 0; 0 1; 1 1];
            pEll = ell_unitball(2);
            x0Ell = ellipsoid([0; 1; 0], eye(nDim));
            rsVec(1) = createReach(eye(nDim), bMat, pEll, x0Ell, eye(nDim),...
                [0, 5]);
            rsVec(2) = rsVec(1).projection([1 0 0; 0 1 0]');
            isExpectedVec = [false, true];
            isObtainedVec = arrayfun(@isprojection, rsVec);
            isOk = all(isExpectedVec == isObtainedVec);
            mlunitext.assert_equals( isOk, true );  
        end
        
        
        function self =testIsEmpty(self)
            nDim = 3;
            aMat = eye(nDim);
            bMat = diag([3, 2, 1]);
            pEll = ell_unitball(nDim);
            x0Ell = ell_unitball(nDim);
                    
            rsVec = [createReach([], [], [], x0Ell, eye(nDim), [0,5]),...
                     createReach(aMat, bMat, pEll, x0Ell, eye(nDim), [0, 5])];
            isObtainedVec = arrayfun(@isempty, rsVec);
            isExpectedVec = [true, false];
            isEqVec = isObtainedVec == isExpectedVec;
            mlunitext.assert_equals( all(isEqVec), true );
        end
        
        
        function self =testGetDirections(self)
            nDim = 3;
            aMat = [1 0 0; 1 1 0; 1 1 1];
            bMat = eye(nDim);
            pEll = ell_unitball(nDim);
            x0Ell = ell_unitball(nDim);
            lMat = eye(3);
            t = 15;
            tVec = [1, t];
            isOk = true;
            isFixedSystem = true;
            auxTestGetDirections();
                   
            
            aCMat = {'2 + cos(k)' '0' '0'; '1' '0' 'sin(k)'; '0' '1' '0'};
            bMat = eye(nDim);
            pEll = ell_unitball(3);
            x0Ell = ell_unitball(3);
            lMat = eye(3);
            t = 15;
            tVec = [1, t];
            isFixedSystem = false;
            auxTestGetDirections();
            
            mlunitext.assert_equals(isOk, true);
            
            function auxTestGetDirections()
                if (isFixedSystem)
                    rs = createReach(aMat, bMat, pEll, x0Ell, lMat, tVec);
                else
                    rs = createReach(aCMat, bMat, pEll, x0Ell, lMat, tVec);
                end
                expectedDirectionsCVec = cell(1, 3);
                expectedDirectionsCVec{1} = zeros(nDim, 15);
                expectedDirectionsCVec{2} = zeros(nDim, 15);
                expectedDirectionsCVec{3} = zeros(nDim, 15);
                dirMat = zeros(nDim, 15);
                for jDirection = 1 : 3
                    dirMat(:, 1) = lMat(:, jDirection);
                    if (isFixedSystem) 
                        for iTime = 2 : t
                            dirMat(:, iTime) = aMat' \ ...
                                dirMat(:, iTime - 1);
                        end
                    else
                        % used in @eval 
                        k = 1;
                        curAMat = cellfun(@eval, aCMat);
                        for k = 2 : t
                            dirMat(:, k) = curAMat' \ dirMat(:, k - 1);
                            curAMat = cellfun(@eval, aCMat);
                        end
                    end
                    expectedDirectionsCVec{jDirection} = dirMat;
                end
                observedDirectionsCVec = rs.get_directions();
                for jDirection = 1 : 3
                    isOkMat = abs(expectedDirectionsCVec{jDirection} - ...
                        observedDirectionsCVec{jDirection}) < self.ABS_TOL;
                    isOk = isOk && all(isOkMat(:));
                end
            end
        end
        
        
        function self =testGetCenter(self)
            nDim = 3;
            isOk = true;
            
            aMat = [1 0 1; -1 2 1; 0 1 -2];
            bMat = [2 0 1; 3 0 1; 2 2 2];
            pEll = ellipsoid([1 1 1]', [3 0 0; 0 4 0; 0 0 1]);
            x0Ell = ell_unitball(nDim);
            lMat = eye(3);
            tVec = [1, 20];
            isFixedSystem = true;
            auxTestGetCenter();
            
            aCMat = {'1', 'cos(k)', '0'; '1 - 1/k^2', '2', 'sin(k)'; ...
                    '0', '1', '1'};
            bMat = eye(nDim);
            pEll = ellipsoid([0 -3 1]', [2 1 0; 1 2 0; 0 0 1]);
            x0Ell = ell_unitball(nDim);
            lMat = eye(3);
            tVec = [1, 20];
            auxTestGetCenter();
            
            mlunitext.assert_equals(isOk, true);
            
            function auxTestGetCenter()
                if (isFixedSystem)
                    rs = createReach(aMat, bMat, pEll, x0Ell, lMat, tVec);
                else
                    rs = createReach(aCMat, bMat, pEll, x0Ell, lMat, tVec);
                end
                observedCenterMat = rs.get_center();

                expectedCenterMat = zeros(nDim, tVec(2));
                [expectedCenterMat(:, 1), ~] = x0Ell.double();
                [pCenterVec, ~] = pEll.double();
                for iTime = 2 : 20
                    if (isFixedSystem)
                        expectedCenterMat(:, iTime) = aMat * ...
                        expectedCenterMat(:, iTime - 1) + bMat * pCenterVec;
                    else
                        % used in @eval
                        k = iTime - 1;
                        aTempMat = cellfun(@eval, aCMat);
                        expectedCenterMat(:, iTime) = aTempMat * ...
                        expectedCenterMat(:, iTime - 1) + bMat * pCenterVec;
                    end
                end

                isOkMat = abs(expectedCenterMat - observedCenterMat) < ...
                    self.ABS_TOL;
                isOk = all(isOkMat(:));                
            end
        end
        
        
        function self = testCut(self)
            nDim = 3;
            isOk = true;
            aMat = [1 0 1; -1 2 1; 0 1 -2];
            bMat = [2 0 1; 3 0 1; 2 2 2];
            pEll = ellipsoid([1 1 1]', [3 0 0; 0 4 0; 0 0 1]);
            x0Ell = ell_unitball(nDim);
            lMat = eye(3);
            tVec = [1, 20];
            cutTVec = 5;
            isFixedSystem = true;
            auxTestCut();
            
            cutTVec = [5, 10];
            auxTestCut();
            
            aCMat = {'1', 'k', 'sin(k)'; '1/k', '0', '5'; '0', 'cos(k)', '1'};
            bMat = eye(3);
            pEll = ellipsoid([3 3 1]', [2 1 0; 1 2 0; 0 0 1]);
            x0Ell = ell_unitball(nDim);
            lMat = eye(3);
            tVec = [1, 20];
            cutTVec = [5, 10];
            isFixedSystem = false;
            auxTestCut();

            mlunitext.assert_equals(isOk, true);
            
            function auxTestCut()
                if (isFixedSystem)
                    rs = createReach(aMat, bMat, pEll, x0Ell, lMat, tVec);
                else
                    rs = createReach(aCMat, bMat, pEll, x0Ell, lMat, tVec);
                end
                rs2 = rs.cut(cutTVec);
                
                isOk = isOk && isEqualApproximations('get_ea');
                isOk = isOk && isEqualApproximations('get_ia');
                
                function isOk = isEqualApproximations(getApproxMethod)
                    sourceEllMat = rs.(getApproxMethod)();
                    isOk = true;
                    if (numel(cutTVec) == 1)
                        rs2 = rs.cut(cutTVec);
                        [cutEll obtainedT]= rs2.(getApproxMethod)();
                        isOk = isOk && all(sourceEllMat(:, cutTVec) ==...
                            cutEll(:));
                        isOk = isOk && (obtainedT(1) == cutTVec(1));
                    else
                        [cutEllMat obtainedTVec] = rs2.(getApproxMethod)();
                        isResultMat = sourceEllMat(:, cutTVec(1):cutTVec(2))...
                            == cutEllMat;
                        isOk = isOk && all(isResultMat(:));
                        isOk = isOk && all(obtainedTVec == ...
                            cutTVec(1):cutTVec(2));
                    end
                end
            end
        end
        
        
        function self =testGetGoodCurves(self)
            epsilon = self.REL_TOL * 1000;
            nDim = 3;
            isOk = true;
            
            aMat = [1 0 2; 2 1 2; -1 0 1];
            bMat = [0 1 0; 0 1 0; 3 2 1];
            pEll = 0.01 * ellipsoid([3 2 1]', [4 2 0; 2 4 0; 0 0 2]);
            x0Ell = ellipsoid([-1 -2 1]', diag([3, 2, 1]));
            lMat = eye(3);
            tVec = [1, 5];
            isFixedSystem = true;
            auxTestGoodCurves();
            
            
            aCMat = {'2 + cos(k)' '0' '0'; '1' '0' 'sin(k)'; '0' '1' '0'};
            bMat = diag([5, 2, 1]);
            pEll = 0.01 * ell_unitball(nDim);
            x0Ell = ell_unitball(nDim);
            lMat = eye(3);
            tVec = [1, 5];
            isFixedSystem = false;
            auxTestGoodCurves();
            
            mlunitext.assert_equals(isOk, true);
            
            function auxTestGoodCurves()
                if (isFixedSystem)
                    rs = createReach(aMat, bMat, pEll, x0Ell, lMat, tVec);
                else
                    rs = createReach(aCMat, bMat, pEll, x0Ell, lMat, tVec);
                end
                goodDirectionsCVec = rs.get_directions();
                eaEllMat = rs.get_ea();
                goodCurvesCVec = rs.get_goodcurves();
                expectedGoodCurvesMat = zeros(nDim, tVec(2));
                for iDirection = 1 : 3
                    goodDirectionsMat = goodDirectionsCVec{iDirection};
                    for jTime = 1 : tVec(2)
                        [~, expectedGoodCurvesMat(:, jTime)] = ...
                        rho(eaEllMat(iDirection, jTime), ...
                            goodDirectionsMat(:, jTime));
                    end
                    isOkMat = abs((expectedGoodCurvesMat - ...
                        goodCurvesCVec{iDirection})) < epsilon;
                    isOk = isOk && all(isOkMat(:));
                end
            end
        end
        
         
        function self =testGetIa(self)
            
            t0 = 1;
            t1 = 5;
            nDim = 3;
            epsilon = 0.001;
            isOk = true;
            
            aMat = [3 0 1; 2 1 0; 0 3 2];
            bMat = [0 1 2; 0 3 2; 1 1 1];
            x0Mat = eye(nDim);
            x0Vec = [0, 0, 0]';
            x0Ell = ellipsoid(x0Vec, x0Mat);
            pMat = eye(nDim);
            pVec = [1 0 1]';
            pEll = ellipsoid(pVec, pMat);
            lMat = eye(3);
            isFixedSystem = true;
            auxTestGetIa();
            
            t0 = 1;
            t1 = 5;
            epsilon = 1;
            aCMat = {'2 + cos(k)' '0' '0'; '1' '0' 'sin(k)'; '0' '1' '0'};
            bMat = diag([5, 2, 1]);
            x0Mat = diag([3, 2, 1]);
            x0Vec = [0, 0, 0]';
            x0Ell = ellipsoid(x0Vec, x0Mat);
            pMat = diag([3 4 1]);
            pVec = zeros(nDim, 1);
            pEll = ellipsoid(pVec, pMat);
            lMat = eye(3);
            isFixedSystem = false;
            auxTestGetIa();

            mlunitext.assert_equals(isOk, true);
            
            function auxTestGetIa()
                if (isFixedSystem)
                    rs = createReach(aMat, bMat, pEll, x0Ell, lMat, [t0, t1]);
                else
                    rs = createReach(aCMat, bMat, pEll, x0Ell, lMat, [t0, t1]);
                end
                if (isFixedSystem)
                    phiArray = repmat(eye(nDim), [1, 1, t1, t1]);
                    for iTime = 2 : t1
                        isIndArr = repmat(diag(true(t1 - iTime + 1, 1), ...
                            1 - iTime), [1, 1, nDim, nDim]);
                        isIndArr = permute(isIndArr, [3, 4, 1, 2]);           
                        phiArray(isIndArr) = repmat(aMat * ...
                            phiArray(:, :, iTime - 1, 1), ...
                            [1, 1, t1 - iTime + 1]);               
                    end
                else
                    phiArray = zeros(nDim, nDim, t1, t1);
                    for iTime = 1 : t1
                        phiArray(:, :, iTime, iTime) = eye(nDim);
                    end
                    aArray = zeros(nDim, nDim, t1);
                    for k = 1 : t1
                        aArray(:, :, k) = cellfun(@eval, aCMat);
                    end
                    for iTime = 1 : t1
                        for jTime = iTime + 1 : t1
                            phiArray(:, :, jTime, iTime) = ...
                                aArray(:, :, jTime - 1) * ...
                                phiArray(:, :, jTime - 1, iTime);
                        end
                    end
                end

                qArray = zeros(nDim, nDim, 3, t1);

                goodDirectionsCVec = rs.get_directions();

                for jDirection = 1 : 3
                    sArray = zeros(nDim, nDim, t1);

                    qArray(:, :, jDirection, 1) = x0Mat;
                    goodDirectionsMat = goodDirectionsCVec{jDirection};
                    for kTime = 2 : t1
                        auxArray = gras.gen.SquareMatVector.sqrtmpos(...
                            gras.gen.SquareMatVector.lrMultiply(...
                            repmat(pMat, [1, 1, kTime]),...
                            gras.gen.SquareMatVector.evalMFunc(@(x)x * bMat, ...
                            squeeze(phiArray(:, :, kTime, 1:kTime)), ...
                            'keepsize', true), 'L'));
                        lVec = goodDirectionsMat(:, kTime);
                        aVec = gras.la.sqrtmpos(phiArray(:, :, kTime, 1) * x0Mat * ...
                               phiArray(:, :, kTime, 1)') * lVec;
                        for iTime = 1 : kTime - 1
                            bVec = auxArray(:, :, iTime + 1) * lVec;
                            sArray(:, :, iTime) = ell_valign(aVec, bVec);
                        end

                        qStarMat = gras.la.sqrtmpos(phiArray(:, :, kTime, 1) * x0Mat * ...
                            phiArray(:, :, kTime, 1)');
                        for iTime = 1 : kTime - 1
                            qStarMat = qStarMat + sArray(:, :, iTime) * ...
                                auxArray(:, :, iTime + 1);
                        end
                        qArray(:, :, jDirection, kTime) = qStarMat' * qStarMat;
                    end
                end
                isOkMat = zeros(3, t1);
                obtainedValuesEllMat = rs.get_ia();
                for iDirection = 1 : 3
                    goodDirectionsMat = goodDirectionsCVec{iDirection};
                    for jTime = 1 : t1
                        lVec = goodDirectionsMat(:, jTime);
                        [qVec, ~] = ...
                            double(obtainedValuesEllMat(iDirection, jTime));
                        isOkMat(iDirection, jTime) = abs(...
                            obtainedValuesEllMat(iDirection, jTime).rho(lVec) -...
                            qVec' * lVec - ...
                            ellipsoid(zeros(nDim, 1), qArray(:, :, ...
                            iDirection, jTime)).rho(lVec)) < epsilon;
                    end
                end
                isOk = isOk && all(isOkMat(:));
            end
        end
        
        
        function self =testGetEa(self)
            t0 = 1;
            t1 = 5;
            nDim = 3;
            epsilon = 0.001;
            isOk = true;

            aMat = [3 0 1; 2 1 0; 0 3 2];
            bMat = [0 1 2; 0 3 2; 1 1 1];
            x0Mat = eye(nDim);
            x0Vec = [0, 0, 0]';
            x0Ell = ellipsoid(x0Vec, x0Mat);
            pMat = eye(nDim);
            pVec = [1 0 1]';
            pEll = ellipsoid(pVec, pMat);
            lMat = eye(3);
            isFixedSystem = true;
            auxTestGetEa();

            t0 = 1;
            t1 = 5;
            epsilon = 0.1;
            aCMat = {'1', 'cos(k)', '0'; '1 - 1/k^2', '2',...
                    'sin(k)'; '0', '1', '1'};
            bMat = [3 2 1; 0 0 1; 2 1 1];
            x0Mat = [5 1 0; 1 4 1; 0 1 3];
            x0Vec = [0, 0, 0]';
            x0Ell = ellipsoid(x0Vec, x0Mat);
            pMat = eye(nDim);
            pVec = [1 0 1]';
            pEll = ellipsoid(pVec, pMat);
            lMat = eye(3);
            isFixedSystem = false;
            auxTestGetEa();
            
            mlunitext.assert_equals(isOk, true);
            
            function auxTestGetEa()
                if (isFixedSystem)
                    rs = createReach(aMat, bMat, pEll, x0Ell, lMat, [t0, t1]);
                else
                    rs = createReach(aCMat, bMat, pEll, x0Ell, lMat, [t0, t1]);
                end
                if (isFixedSystem)
                    phiArray = zeros(nDim, nDim, t1, t1);
                    for iTime = 1 : t1
                        phiArray(:, :, iTime, iTime) = eye(nDim);
                    end

                    for iTime = 1 : t1
                        for jTime = iTime + 1 : t1
                            phiArray(:, :, jTime, iTime) = aMat * ...
                                phiArray(:, :, jTime - 1, iTime);
                        end
                    end
                else
                    phiArray = zeros(nDim, nDim, t1, t1);
                    for iTime = 1 : t1
                        phiArray(:, :, iTime, iTime) = eye(nDim);
                    end

                    aArray = zeros(nDim, nDim, t1);
                    for k = 1 : t1
                        aArray(:, :, k) = cellfun(@eval, aCMat);
                    end
                    for iTime = 1 : t1
                        for jTime = iTime + 1 : t1
                            phiArray(:, :, jTime, iTime) = ...
                                aArray(:, :, jTime - 1) *...
                                phiArray(:, :, jTime - 1, iTime);
                        end
                    end
                end

                qArray = zeros(nDim, nDim, 3, t1);

                goodDirectionsCVec = rs.get_directions();

                for jDirection = 1 : 3

                    qArray(:, :, jDirection, 1) = x0Mat;
                    goodDirectionsMat = goodDirectionsCVec{jDirection};
                    for kTime = 2 : t1
                        lVec = goodDirectionsMat(:, kTime);
                        pVec = zeros(t1, 1);
                        pVec(1) =realsqrt(lVec' * phiArray(:, :, kTime, 1) * ...
                            x0Mat * phiArray(:, :, kTime, 1)' * lVec);
                        for iTime = 1 : kTime - 1
                            pVec(iTime + 1) =realsqrt(lVec' * ...
                                phiArray(:, :, kTime, iTime+1) * bMat * ...
                                pMat * bMat' * phiArray(:, :, kTime, iTime+1)' * lVec);
                        end

                        qArray(:, :, jDirection, kTime) = phiArray(:, :, kTime, 1) * ...
                            x0Mat * phiArray(:, :, kTime, 1)' /pVec(1);
                        for iTime = 1 : kTime - 1
                            qArray(:, :, jDirection, kTime) = ...
                                qArray(:, :, jDirection, kTime) +...
                                phiArray(:, :, kTime, iTime + 1) * bMat * pMat *...
                                bMat' * phiArray(:, :, kTime, iTime + 1)'/...
                                pVec(iTime + 1);
                        end
                        qArray(:, :, jDirection, kTime) = ...
                            0.5 * (qArray(:, :, jDirection, kTime) * sum(pVec) + ...
                            (qArray(:, :, jDirection, kTime) * sum(pVec))');
                    end
                end

                isOkMat = zeros(3, t1);
                obtainedValuesEllMat = rs.get_ea();
                for iDirection = 1 : 3
                    directionsMat = goodDirectionsCVec{iDirection};
                    for kTime = 1 : t1
                        lVec = directionsMat(:, kTime);
                        [qVec, ~] = ...
                            double(obtainedValuesEllMat(iDirection, kTime));
                        isOkMat(iDirection, kTime) = abs(...
                            obtainedValuesEllMat(iDirection, kTime).rho(lVec) -...
                            qVec' * lVec - ...
                            ellipsoid(zeros(nDim, 1), qArray(:, :, ...
                            iDirection, kTime)).rho(lVec)) < epsilon;
                    end
                end
                isOk = isOk && all(isOkMat(:)); 
            end
        end
        
        
        function self = testProjection(self)
            t0 = 1;
            t1 = 4;
            epsilon = 1;
            nDim = 3;
            isOk = true;
            
            aMat = [3 0 1; 2 1 0; 0 3 2];
            bMat = [0 1 2; 0 3 2; 1 1 1];
            x0Mat = eye(nDim);
            x0Vec = [0, 0, 0]';
            x0Ell = ellipsoid(x0Vec, x0Mat);
            pMat = eye(nDim);
            pVec = [1 0 1]';
            pEll = ellipsoid(pVec, pMat);
            lMat = eye(3);
            projectionMatrix = [1/2^0.5 0 1/2^0.5; 0 1 0]';
            isFixedSystem = true;
            auxTestProjection();
            
            
            aCMat = {'1' 'k' '0'; '0' '1/k' '0'; '0' '1' '1'};
            bMat = [2 3 1; 2 2 2; 0 2 1];
            x0Mat = diag([1 2 3]);
            x0Vec = [0, 2, 0]';
            x0Ell = ellipsoid(x0Vec, x0Mat);
            pMat = eye(nDim);
            pVec = [3 0 1]';
            pEll = ellipsoid(pVec, pMat);
            lMat = eye(3);
            projectionMatrix = [1 0 0; 0 1 0]';
            isFixedSystem = false;
            auxTestProjection();
            mlunitext.assert_equals(isOk, true);
            
            
            function auxTestProjection()
                if (isFixedSystem)
                    rs = createReach(aMat, bMat, pEll, x0Ell, lMat, [t0, t1]);
                else
                    rs = createReach(aCMat, bMat, pEll, x0Ell, lMat, [t0, t1]);
                end
                projectedRs = rs.projection(projectionMatrix);

                isOk = isOk && isEqualApproximations('get_ia');
                isOk = isOk && isEqualApproximations('get_ea');
                
                function isOk = isEqualApproximations(getApproxMethod)
                    isOk = true;
                    initApproximationEllMat = rs.(getApproxMethod)();
                    finitApproximationEllMat = initApproximationEllMat;
                    for iDirection = 1 : 3
                        for tTime = 1 : t1
                           [qVec qMat] = ...
                               double(initApproximationEllMat(iDirection, tTime));
                           finitApproximationEllMat(iDirection, tTime) = ...
                               ellipsoid(projectionMatrix' * qVec, ...
                               projectionMatrix' * qMat * projectionMatrix);
                        end
                    end
                    obtainedApproximationEllMat = projectedRs.(getApproxMethod)();
                    for iDirection = 1 : 3
                        for tTime = 1 : t1
                            [q1Vec q1Mat] = ...
                                double(finitApproximationEllMat(iDirection, tTime));
                            [q2Vec q2Mat] = ...
                                double(obtainedApproximationEllMat(iDirection, tTime));
                            isOk = isOk && all(abs(q1Vec - q2Vec) < epsilon);
                            isOkMat = abs(q1Mat - q2Mat) < epsilon;
                            isOk = isOk && all(isOkMat(:));
                        end
                    end
                end
            end
        end
        
        
        function self =testIntersect(self)
            t0 = 1;
            t1 = 5;
            nDim = 3;

            aMat = [3 0 1; 2 1 0; 0 3 2];
            bMat = [0 1 2; 0 3 2; 1 1 1];
            x0Mat = eye(nDim);
            x0Vec = [0, 0, 0]';
            x0Ell = ellipsoid(x0Vec, x0Mat);
            pMat = eye(nDim);
            pVec = [1 0 1]';
            pEll = ellipsoid(pVec, pMat);
            rs = createReach(aMat, bMat, pEll, x0Ell, eye(3), [t0, t1]);          
            rs = rs.projection([1 0 0; 0 1 0]');
            
            ellCVec{1} = ellipsoid([-200, -120]', 200*eye(2));
            ellCVec{2} = ellipsoid([-100, 250]', 100*eye(2));
            ellCVec{3} = ellipsoid([0, 0]', 100*eye(2));
            
            isExpectedValuesMat = [1 0 1; 0 0 1];
            isObtainedValuesMat(1, :) = cellfun(@intersect, repmat({rs}, 1, 3), ...
                                          ellCVec, ...
                                          repmat({'e'}, 1, 3)); 
                                      
            isObtainedValuesMat(2, :) = cellfun(@intersect, repmat({rs}, 1, 3), ...
                                          ellCVec, ...
                                          repmat({'i'}, 1, 3)); 
                                      
            isOkMat = isObtainedValuesMat == isExpectedValuesMat;
            isOk = all(isOkMat(:));

            hpCVec{1} = hyperplane([6, 4]', 5000);
            hpCVec{2} = hyperplane([-1, 1]', 3000);
            hpCVec{3} = hyperplane([-1, -1]', 100);

            isObtainedValuesMat(1, :) = cellfun(@intersect, repmat({rs}, 1, 3),...
                                          hpCVec,...
                                          repmat({'e'}, 1, 3));
            isObtainedValuesMat(2, :) = cellfun(@intersect, repmat({rs}, 1, 3),...
                                          hpCVec,...
                                          repmat({'i'}, 1, 3));                          
            
            isOkMat = isObtainedValuesMat == isExpectedValuesMat;
            isOk = isOk && all(isOkMat(:));
            
            mlunitext.assert_equals(isOk, true);            
        end
        
        
        function self = testEvolve(self)
            t0 = 1;
            t1 = 3;
            t2 = 5;
            epsilon = 0.1;
            nDim = 3;
            isOk = true;
            
            a1Mat = [3 0 1; 2 1 0; 0 3 2];
            b1Mat = [0 1 2; 0 3 2; 1 1 1];
            x01Mat = eye(nDim);
            x01Vec = [0, 0, 0]';
            x01Ell = ellipsoid(x01Vec, x01Mat);
            p1Mat = eye(nDim);
            p1Vec = [1 0 1]';
            p1Ell = ellipsoid(p1Vec, p1Mat);
            
            a2Mat = [1 0 2; 2 1 2; -1 0 1];
            b2Mat = [0 1 0; 0 1 0; 3 2 1];
            p2Ell = 0.01 * ellipsoid([3 2 1]', [4 2 0; 2 4 0; 0 0 2]);
            ls2 = elltool.linsys.LinSysFactory.create(a2Mat, b2Mat, p2Ell, ...
                [], [], [], [], 'd');
            lMat = eye(3);
            
            isWithAnotherSystem = false;
            auxTestEvolve();
            
            isWithAnotherSystem = true;
            auxTestEvolve();
            
            mlunitext.assert_equals(isOk, true);
            
            function auxTestEvolve()
                if (~isWithAnotherSystem)
                    rs = createReach(a1Mat, b1Mat, p1Ell, x01Ell, lMat, [t0, t1]);
                    obtainedRs = rs.evolve(t2);

                    expectedRs = createReach(a1Mat, b1Mat, p1Ell, x01Ell,...
                                             lMat, [t0, t2]);
                else
                    rs = createReach(a1Mat, b1Mat, p1Ell, x01Ell, lMat, [t0, t1]);
                    obtainedRs = rs.evolve(t2, ls2);
                end
                
                isOk = isOk && isEqualApproximation('get_ia');
                isOk = isOk && isEqualApproximation('get_ea');
                
                function isOk = approxEllEq(x1Ell, x2Ell, epsilon)
                    [q1Vec q1Mat] = x1Ell.double();
                    [q2Vec q2Mat] = x2Ell.double();
                    isOk = max(abs(q1Vec - q2Vec)) < epsilon;
                    resMat = abs(q1Mat - q2Mat);
                    isOk = isOk && max(resMat(:))/max(abs(q1Mat(:))) < epsilon;
                end
                
                function isOk = isEqualApproximation(getApproxMethod)
                    isOk = true;
                    if (~isWithAnotherSystem)
                        expectedApproxEllMat = expectedRs.(getApproxMethod)();
                        obtainedApproxEllMat = obtainedRs.(getApproxMethod)();
                        isOkMat = expectedApproxEllMat(:, t1:t2) == obtainedApproxEllMat;
                        isOk = isOk && all(isOkMat(:));
                    else
                        obtainedApproxEllMat = obtainedRs.(getApproxMethod)();
                        initApproxEllMat = rs.(getApproxMethod)();
                        expectedApproxEllMat = obtainedApproxEllMat;
                        for iDirection = 1 : 3
                            evolvingRs = elltool.reach.ReachDiscrete(ls2, ...
                                initApproxEllMat(iDirection, t1), ...
                                lMat(:, iDirection), [t1 t2]);
                            expectedApproxEllMat(iDirection, :) =...
                                       evolvingRs.(getApproxMethod)();
                        end
                        
                        isOkMat = arrayfun(@approxEllEq, expectedApproxEllMat, ...
                                           obtainedApproxEllMat, ...
                                           repmat(epsilon, t2 - t1 + 1, t2 - t1 + 1));
                        isOk = isOk && all(isOkMat(:));
                    end
                end
            end
        end
        
        
        function self =testOverflow(self)
            aMat = [4 5 1; 3 2 1; 0 1 3];
            bMat = [2 0 1; 3 0 1; 2 2 2];
            nDim = 3;
            
            pEll = ellipsoid([1 1 1]', [3 0 0; 0 4 0; 0 0 1]);
            lMat = eye(nDim);
            x0Ell = ell_unitball(nDim);
            argumentList = {aMat, bMat, pEll, x0Ell, lMat, [1, 20]};
            
            self.runAndCheckError(@check,{'complexResult','wrongInput'});
            function check()
                % is ok. Object is created but is not used.
                rs = createReach(argumentList{:});
            end         
        end
    end
end

function rs = createReach(aMat, bMat, pEll, x0Ell, lMat, tVec)
    ls = elltool.linsys.LinSysFactory.create( aMat, bMat, ...
                pEll, [], [], [], [], 'd');
    rs = elltool.reach.ReachDiscrete(ls, x0Ell, lMat, tVec);
end