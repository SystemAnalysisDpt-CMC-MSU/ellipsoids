classdef ReachDiscrLogicalTestCase < mlunitext.test_case
    %
    properties (Constant, GetAccess = private)
        REL_TOL = 1e-6;
        ABS_TOL = 1e-7;
    end
    %
    methods
        function self = ReachDiscrLogicalTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
        end
        
        
        function self = testDisplay(self)
            nDim = 3;
            x0Ell = ellipsoid(zeros(nDim, 1), eye(nDim));
            rs = createReach(eye(3), eye(3,4), ell_unitball(4),...
                x0Ell, eye(3), [0, 5]);
            resStr = evalc('display(rs)');
            isOk = ~isempty(strfind(resStr,'Reach set'));
            isOk = isOk && ~isempty(strfind(resStr,'discrete'));
            isOk = isOk && ~isempty(strfind(resStr,'Center'));
            isOk = isOk && ~isempty(strfind(resStr,'Shape'));
            isOk = isOk && ~isempty(strfind(resStr,'external'));
            isOk = isOk && ~isempty(strfind(resStr,'internal'));
            mlunitext.assert(isOk);      
        end
        
        
        function self = testDimension(self)
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
            projectedRS = rs.projection([1 0 0 0; 0 1 0 0]');
            [nObtainedReachDimension, nObtainedSystemDimension] = ...
                projectedRS.dimension();
            isOk = isOk && (nObtainedSystemDimension == nSystemDimension);
            isOk = isOk && (nObtainedReachDimension == nProjectionDimension);
            mlunitext.assert(isOk);
        end
        
        
        function self = testGetSystem(self)
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
        
        
        function self = testIsCut(self)
            aMat = [1 2; 3 4];
            bMat = [3; 2];
            pEll = 2*ell_unitball(1);
            x0Ell = ellipsoid([0; 0], [3 1; 1 2]);
            rsVec(1) = createReach(aMat, bMat, pEll, x0Ell, eye(2), [0,5]);
            rsVec(2) = rsVec(1).cut([2, 3]);
            rsVec(3) = rsVec(1).cut(3);
            isExpectedValues = [false, true, true];
            isObtainedValues = arrayfun(@iscut, rsVec);
            isOk = all(isExpectedValues == isObtainedValues);
            mlunitext.assert(isOk);
        end
        
        
        function self = testIsProjection(self)
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
            mlunit.assert_equals( isOk, true );  
        end
        
        
        function self = testIsEmpty(self)
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
            mlunit.assert_equals( all(isEqVec), true );
        end
        
        
        function self = testGetDirections(self)
            nDim = 3;
            aMat = [1 0 0; 1 1 0; 1 1 1];
            bMat = eye(nDim);
            pEll = ell_unitball(nDim);
            x0Ell = ell_unitball(nDim);
            lMat = eye(3);
            T = 15;
            tVec = [1, T];
            isOk = true;
            auxTestGetDirections();
                   
            
            aMat = {'2 + cos(k)' '0' '0'; '1' '0' 'sin(k)'; '0' '1' '0'};
            bMat = eye(nDim);
            pEll = ell_unitball(3);
            x0Ell = ell_unitball(3);
            lMat = eye(3);
            T = 15;
            tVec = [1, T];
            auxTestGetDirections();
            
            mlunit.assert_equals(isOk, true);
            
            function auxTestGetDirections()
                rs = createReach(aMat, bMat, pEll, x0Ell, lMat, tVec);
                expectedDirectionsCVec = cell(1, 3);
                expectedDirectionsCVec{1} = zeros(nDim, 15);
                expectedDirectionsCVec{2} = zeros(nDim, 15);
                expectedDirectionsCVec{3} = zeros(nDim, 15);
                dirMat = zeros(nDim, 15);
                for jDirection = 1 : 3
                    dirMat(:, 1) = lMat(:, jDirection);
                    if (~iscell(aMat)) 
                        for iTime = 2 : T
                            dirMat(:, iTime) = (aMat')^(-1) *...
                                dirMat(:, iTime - 1);
                        end
                    else
                        k = 1;
                        curAMat = cellfun(@eval, aMat);
                        for k = 2 : T
                            dirMat(:, k) = inv(curAMat') * dirMat(:, k - 1);
                            curAMat = cellfun(@eval, aMat);
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
        
        
        function self = testGetCenter(self)
            nDim = 3;
            isOk = true;
            
            aMat = [1 0 1; -1 2 1; 0 1 -2];
            bMat = [2 0 1; 3 0 1; 2 2 2];
            pEll = ellipsoid([1 1 1]', [3 0 0; 0 4 0; 0 0 1]);
            x0Ell = ell_unitball(nDim);
            lMat = eye(3);
            tVec = [1, 20];
            auxTestGetCenter();
            
            aMat = {'1', 'cos(k)', '0'; '1 - 1/k^2', '2', 'sin(k)'; ...
                    '0', '1', '1'};
            bMat = eye(nDim);
            pEll = ellipsoid([0 -3 1]', [2 1 0; 1 2 0; 0 0 1]);
            x0Ell = ell_unitball(nDim);
            lMat = eye(3);
            tVec = [1, 20];
            auxTestGetCenter();
            
            mlunit.assert_equals(isOk, true);
            
            function auxTestGetCenter()
                rs = createReach(aMat, bMat, pEll, x0Ell, lMat, tVec);
                observedCenterMat = rs.get_center();

                expectedCenterMat = zeros(nDim, tVec(2));
                [expectedCenterMat(:, 1), Q] = x0Ell.double();
                [pCenterVec, Q] = pEll.double();
                for iTime = 2 : 20
                    if (~iscell(aMat))
                        expectedCenterMat(:, iTime) = aMat * ...
                        expectedCenterMat(:, iTime - 1) + bMat * pCenterVec;
                    else
                        k = iTime -1;
                        aTempMat = cellfun(@eval, aMat);
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
            auxTestCut();
            
            cutTVec = [5, 10];
            auxTestCut();
            
            aMat = {'1', 'k', 'sin(k)'; '1/k', '0', '5'; '0', 'cos(k)', '1'};
            bMat = eye(3);
            pEll = ellipsoid([3 3 1]', [2 1 0; 1 2 0; 0 0 1]);
            x0Ell = ell_unitball(nDim);
            lMat = eye(3);
            tVec = [1, 20];
            cutTVec = [5, 10];
            auxTestCut();

            mlunit.assert_equals(isOk, true);
            
            function auxTestCut()
                rs = createReach(aMat, bMat, pEll, x0Ell, lMat, tVec);
                sourceEAEllMat = rs.get_ea();
                sourceIAEllMat = rs.get_ia();
                if (numel(cutTVec) == 1)
                    rs2 = rs.cut(cutTVec);
                    cutEAEll = rs2.get_ea();
                    cutIAEll = rs2.get_ia();
                    isOk = isOk && all(sourceEAEllMat(:, cutTVec) ==...
                        cutEAEll(:));
                    isOk = isOk && all(sourceIAEllMat(:, cutTVec) ==...
                        cutIAEll(:));
                else
                    rs2 = cut(rs, cutTVec);
                    [cutEAEllMat tVec] = rs2.get_ea();
                    isResultMat = sourceEAEllMat(:, cutTVec(1):cutTVec(2))...
                        == cutEAEllMat;
                    isOk = isOk && all(isResultMat(:));
                    isOk = isOk && all(tVec == cutTVec(1):cutTVec(2));
                    [cutIAEllMat tVec] = rs2.get_ia();
                    isResultMat = sourceIAEllMat(:, cutTVec(1):cutTVec(2)) ...
                        == cutIAEllMat;
                    isOk = isOk && all(isResultMat(:));           
                    isOk = isOk && all(tVec == cutTVec(1):cutTVec(2));
                    
                end
            end
        end
        
        
        function self = testGetGoodCurves(self)
            epsilon = self.REL_TOL * 1000;
            nDim = 3;
            isOk = true;
            
            aMat = [1 0 2; 2 1 2; -1 0 1];
            bMat = [0 1 0; 0 1 0; 3 2 1];
            pEll = 0.01 * ellipsoid([3 2 1]', [4 2 0; 2 4 0; 0 0 2]);
            x0Ell = ellipsoid([-1 -2 1]', diag([3, 2, 1]));
            lMat = eye(3);
            tVec = [1, 5];
            auxTestGoodCurves();
            
            
            aMat = {'2 + cos(k)' '0' '0'; '1' '0' 'sin(k)'; '0' '1' '0'};
            bMat = diag([5, 2, 1]);
            pEll = 0.01 * ell_unitball(nDim);
            x0Ell = ell_unitball(nDim);
            lMat = eye(3);
            tVec = [1, 5];
            auxTestGoodCurves();
            
            mlunit.assert_equals(isOk, true);
            
            function auxTestGoodCurves()
                rs = createReach(aMat, bMat, pEll, x0Ell, lMat, tVec);
            
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
        
         
        function self = testGetIA(self)
            
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
            auxTestGetIA();
            
            t0 = 1;
            t1 = 5;
            epsilon = 1;
            aMat = {'2 + cos(k)' '0' '0'; '1' '0' 'sin(k)'; '0' '1' '0'};
            bMat = diag([5, 2, 1]);
            x0Mat = diag([3, 2, 1]);
            x0Vec = [0, 0, 0]';
            x0Ell = ellipsoid(x0Vec, x0Mat);
            pMat = diag([3 4 1]);
            pVec = zeros(nDim, 1);
            pEll = ellipsoid(pVec, pMat);
            lMat = eye(3);
            auxTestGetIA();

            mlunit.assert_equals(isOk, true);
            
            function auxTestGetIA()
                rs = createReach(aMat, bMat, pEll, x0Ell, lMat, [t0, t1]);
                
                if (~iscell(aMat))
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
                        aArray(:, :, k) = cellfun(@eval, aMat);
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
                    for k = 2 : t1
                        auxArray = gras.gen.SquareMatVector.sqrtmpos(...
                            gras.gen.SquareMatVector.lrMultiply(...
                            repmat(pMat, [1, 1, k]),...
                            gras.gen.SquareMatVector.evalMFunc(@(x)x * bMat, ...
                            squeeze(phiArray(:, :, k, 1:k)), ...
                            'keepsize', true), 'L'));
                        lVec = goodDirectionsMat(:, k);
                        aVec = gras.la.sqrtmpos(phiArray(:, :, k, 1) * x0Mat * ...
                               phiArray(:, :, k, 1)') * lVec;
                        for iTime = 1 : k - 1
                            bVec = auxArray(:, :, iTime + 1) * lVec;
                            sArray(:, :, iTime) = ell_valign(aVec, bVec);
                        end

                        qStarMat = gras.la.sqrtmpos(phiArray(:, :, k, 1) * x0Mat * ...
                            phiArray(:, :, k, 1)');
                        for iTime = 1 : k - 1
                            qStarMat = qStarMat + sArray(:, :, iTime) * ...
                                auxArray(:, :, iTime + 1);
                        end
                        qArray(:, :, jDirection, k) = qStarMat' * qStarMat;
                    end
                end
                isOkMat = zeros(3, t1);
                obtainedValuesEllMat = rs.get_ia();
                for iDirection = 1 : 3
                    goodDirectionsMat = goodDirectionsCVec{iDirection};
                    for jTime = 1 : t1
                        lVec = goodDirectionsMat(:, jTime);
                        approximationEll = obtainedValuesEllMat(iDirection, jTime);
                        [qq QQ] = double(approximationEll);
                        isOkMat(iDirection, jTime) = (abs((lVec' * QQ * lVec) - ...
                            (lVec' * qArray(:, :, iDirection, jTime) * ...
                            lVec)) < epsilon);
                    end
                end
                isOk = isOk && all(isOkMat(:));
            end
        end
        
        
        function self = testGetEA(self)
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
            auxTestGetEA();

            t0 = 1;
            t1 = 5;
            epsilon = 0.1;
            aMat = {'1', 'cos(k)', '0'; '1 - 1/k^2', '2',...
                    'sin(k)'; '0', '1', '1'};
            bMat = [3 2 1; 0 0 1; 2 1 1];
            x0Mat = [5 1 0; 1 4 1; 0 1 3];
            x0Vec = [0, 0, 0]';
            x0Ell = ellipsoid(x0Vec, x0Mat);
            pMat = eye(nDim);
            pVec = [1 0 1]';
            pEll = ellipsoid(pVec, pMat);
            lMat = eye(3);
            auxTestGetEA();
            
            mlunit.assert_equals(isOk, true);
            
            function auxTestGetEA()
                rs = createReach(aMat, bMat, pEll, x0Ell, lMat, [t0, t1]);
                
                if (~iscell(aMat))
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
                        aArray(:, :, k) = cellfun(@eval, aMat);
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
                    for k = 2 : t1
                        lVec = goodDirectionsMat(:, k);
                        pVec = zeros(t1, 1);
                        pVec(1) =realsqrt(lVec' * phiArray(:, :, k, 1) * ...
                            x0Mat * phiArray(:, :, k, 1)' * lVec);
                        for iTime = 1 : k - 1
                            pVec(iTime + 1) =realsqrt(lVec' * ...
                                phiArray(:, :, k, iTime+1) * bMat * ...
                                pMat * bMat' * phiArray(:, :, k, iTime+1)' * lVec);
                        end

                        qArray(:, :, jDirection, k) = phiArray(:, :, k, 1) * ...
                            x0Mat * phiArray(:, :, k, 1)' /pVec(1);
                        for iTime = 1 : k - 1
                            qArray(:, :, jDirection, k) = ...
                                qArray(:, :, jDirection, k) +...
                                phiArray(:, :, k, iTime + 1) * bMat * pMat *...
                                bMat' * phiArray(:, :, k, iTime + 1)'/...
                                pVec(iTime + 1);
                        end
                        qArray(:, :, jDirection, k) = ...
                            qArray(:, :, jDirection, k) * sum(pVec);
                    end
                end

                isOkMat = zeros(3, t1);
                obtainedValuesEllMat = rs.get_ea();
                for iDirection = 1 : 3
                    directions = goodDirectionsCVec{iDirection};
                    for k = 1 : t1
                        lVec = directions(:, k);
                        approximationEll = obtainedValuesEllMat(iDirection, k);
                        [qq QQ] = double(approximationEll);
                        isOkMat(iDirection, k) = (abs((lVec' * QQ * lVec) - ...
                            (lVec' * qArray(:, :, iDirection, k) * lVec))...
                            < epsilon);
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
            auxTestProjection();
            
            
            aMat = {'1' 'k' '0'; '0' '1/k' '0'; '0' '1' '1'};
            bMat = [2 3 1; 2 2 2; 0 2 1];
            x0Mat = diag([1 2 3]);
            x0Vec = [0, 2, 0]';
            x0Ell = ellipsoid(x0Vec, x0Mat);
            pMat = eye(nDim);
            pVec = [3 0 1]';
            pEll = ellipsoid(pVec, pMat);
            lMat = eye(3);
            projectionMatrix = [1 0 0; 0 1 0]';
            auxTestProjection();
            mlunit.assert_equals(isOk, true);
            
            
            function auxTestProjection()
                rs = createReach(aMat, bMat, pEll, x0Ell, lMat, [t0, t1]);
            
                projectedRS = rs.projection(projectionMatrix);
                initApproximationEllMat = rs.get_ia();
                finitApproximationEllMat = initApproximationEllMat;
                for iDirection = 1 : 3
                    for t = 1 : t1
                       [q Q] = double(initApproximationEllMat(iDirection, t));
                       finitApproximationEllMat(iDirection, t) = ...
                           ellipsoid(projectionMatrix' * q, projectionMatrix' *...
                           Q * projectionMatrix);
                    end
                end
                obtainedApproximationEllMat = projectedRS.get_ia();
                for iDirection = 1 : 3
                    for t = 1 : t1
                        [q1 Q1] = double(finitApproximationEllMat(iDirection, t));
                        [q2 Q2] = double(obtainedApproximationEllMat(iDirection, t));
                        isOk = isOk && all(abs(q1 - q2) < epsilon);
                        isOkMat = abs(Q1 - Q2) < epsilon;
                        isOk = isOk && all(isOkMat(:));
                    end
                end

                initApproximationEllMat = rs.get_ea();
                finitApproximationEllMat = initApproximationEllMat;
                for iDirection = 1 : 3
                    for t = 1 : t1
                       [q Q] = double(initApproximationEllMat(iDirection, t));
                       finitApproximationEllMat(iDirection, t) = ...
                           ellipsoid(projectionMatrix' * q, ...
                           projectionMatrix' * Q * projectionMatrix);
                    end
                end
                obtainedApproximationEllMat = projectedRS.get_ea();
                for iDirection = 1 : 3
                    for t = 1 : t1
                        [q1 Q1] = finitApproximationEllMat(iDirection, t).double();
                        [q2 Q2] = obtainedApproximationEllMat(iDirection, t).double();
                        isOk = isOk && all(abs(q1 - q2) < epsilon);
                        isOkMat = abs(Q1 - Q2) < epsilon;
                        isOk = isOk && all(isOkMat(:));
                    end
                end
            end
        end
        
        
        function self = testIntersect(self)
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
            
            mlunit.assert_equals(isOk, true);            
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
            x0Vec1 = [0, 0, 0]';
            x01Ell = ellipsoid(x0Vec1, x01Mat);
            p1Mat = eye(nDim);
            p1Vec = [1 0 1]';
            p1Ell = ellipsoid(p1Vec, p1Mat);
            ls1 = elltool.linsys.LinSysFactory.create(a1Mat, b1Mat, p1Ell, ...
                [], [], [], [], 'd');
            
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
            
            mlunit.assert_equals(isOk, true);
            
            function auxTestEvolve()
                if (~isWithAnotherSystem)
                    rs = elltool.reach.ReachDiscrete(ls1, x01Ell, lMat, ...
                        [t0, t1]);
                    obtainedRS = rs.evolve(t2);

                    expectedRS = elltool.reach.ReachDiscrete(ls1, ...
                        x01Ell, lMat, [t0, t2]);
                    
                    expectedApproxEllMat = expectedRS.get_ia();
                    obtainedApproxEllMat = obtainedRS.get_ia();
                    for iDirection = 1 : 3
                        for t = t1 : t2
                            [q1 Q1] = expectedApproxEllMat(iDirection, t).double();
                            [q2 Q2] = obtainedApproxEllMat(iDirection, ...
                                t - t1 + 1).double();
                            isOk = isOk && max(abs(q1 - q2)) < epsilon;
                            resMat = abs(Q1 - Q2);
                            isOk = isOk && max(resMat(:)) < epsilon;
                        end
                    end

                    expectedApproxEllMat = expectedRS.get_ea();
                    obtainedApproxEllMat = obtainedRS.get_ea();
                    for iDirection = 1 : 3
                        for t = t1 : t2
                            [q1 Q1] = double(expectedApproxEllMat(iDirection, t));
                            [q2 Q2] = double(obtainedApproxEllMat(...
                                iDirection, t - t1 + 1));
                            isOk = isOk && max(abs(q1 - q2)) < epsilon;
                            resMat = abs(Q1 - Q2);
                            isOk = isOk && max(resMat(:)) < epsilon;
                        end
                    end
                else
                    rs = elltool.reach.ReachDiscrete(ls1, x01Ell, lMat, [t0, t1]);
                    obtainedRS = rs.evolve(t2, ls2);
                    obtainedApproxEllMat = obtainedRS.get_ia();
                    initApproxEllMat = rs.get_ia();

                    for iDirection = 1 : 3
                        evolvingRS = elltool.reach.ReachDiscrete(ls2, ...
                            initApproxEllMat(iDirection, t1), lMat(:, iDirection),...
                            [t1 t2]);
                        expectedApproxEllMat = evolvingRS.get_ia();
                        for t = 1 : t2 - t1 + 1
                            [q1 Q1] = double(expectedApproxEllMat(1, t));
                            [q2 Q2] = double(obtainedApproxEllMat(iDirection, t));
                            isOk = isOk && max(abs(q1 - q2)) < epsilon;
                            resMat = abs(Q1 - Q2);
                            isOk = isOk && max(resMat(:))/max(abs(Q1(:))) < epsilon; 
                        end
                    end

                    obtainedApproxEllMat = obtainedRS.get_ea();
                    initApproxEllMat = rs.get_ea();

                    for iDirection = 1 : 3
                        evolvingRS = elltool.reach.ReachDiscrete(ls2, ...
                            initApproxEllMat(iDirection, t1), lMat(:, iDirection),...
                            [t1 t2]);
                        expectedApproxEllMat = evolvingRS.get_ea();
                        for t = 1 : t2 - t1 + 1
                            [q1 Q1] = double(expectedApproxEllMat(1, t));
                            [q2 Q2] = double(obtainedApproxEllMat(iDirection, t));
                            isOk = isOk && max(abs(q1 - q2)) < epsilon;
                            resMat = abs(Q1 - Q2);
                            isOk = isOk && max(resMat(:))/max(abs(Q1(:))) < epsilon; 
                        end
                    end   
                end
            end
        end
        
        
        function self = testOverflow(self)
            aMat = [4 5 1; 3 2 1; 0 1 3];
            bMat = [2 0 1; 3 0 1; 2 2 2];
            nDim = 3;
            
            pEll = ellipsoid([1 1 1]', [3 0 0; 0 4 0; 0 0 1]);
            ls = elltool.linsys.LinSysFactory.create(aMat, bMat, pEll,...
                [], [], [], [], 'd');
            x0Ell = ell_unitball(nDim);
            lMat = eye(3);
            argumentList = {ls, x0Ell, lMat, [1, 20]};
            
            self.runAndCheckError(@check,'complexResult');
            function check()
                rs = elltool.reach.ReachDiscrete(argumentList{:});
            end         
        end
    end
end

function rs = createReach(aMat, bMat, pEll, x0Ell, lMat, tVec)
    ls = elltool.linsys.LinSysFactory.create( aMat, bMat, ...
                pEll, [], [], [], [], 'd');
    rs = elltool.reach.ReachDiscrete(ls, x0Ell, lMat, tVec);
end