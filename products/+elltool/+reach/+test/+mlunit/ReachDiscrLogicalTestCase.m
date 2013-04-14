classdef ReachDiscrLogicalTestCase < mlunit.test_case
    %
    properties (Constant, GetAccess = private)
%         N_TIME_GRID_POINTS = 200;
        REL_TOL = 1e-6;
        ABS_TOL = 1e-7;
    end
    %
    properties (Access = private)
       testDataRootDir
    end
    %
    methods
        function self = ReachDiscrLogicalTestCase(varargin)
            self = self@mlunit.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir =...
                [fileparts(which(className)), filesep,...
                'TestData', filesep, shortClassName];
        end
        
        
        function self = DISABLED_testDisplay(self)
            LS = elltool.linsys.LinSysFactory.create( eye(3), eye(3,4), ell_unitball(4), ...
                [], [], [], [], 'd');
            X0Ell = ellipsoid(zeros(3, 1), eye(3));
            LMat = eye(3);
            TVec = [0, 5];
            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, TVec);
            resStr = evalc('display(RS)');
            isOk = ~isempty(strfind(resStr,'Reach set'));
            isOk = isOk && ~isempty(strfind(resStr,'discrete'));
            isOk = isOk && ~isempty(strfind(resStr,'Center'));
            isOk = isOk && ~isempty(strfind(resStr,'Shape'));
            isOk = isOk && ~isempty(strfind(resStr,'external'));
            isOk = isOk && ~isempty(strfind(resStr,'internal'));
            mlunitext.assert(isOk);      
        end
        
        
        function self = DISABLED_testDimension(self)
            nSystemDimension = 4;
            LS = elltool.linsys.LinSysFactory.create( eye(nSystemDimension), eye(nSystemDimension,2), ell_unitball(2), ...
                [], [], [], [], 'd');
            X0Ell = ellipsoid(zeros(nSystemDimension, 1), eye(nSystemDimension));
            LMat = eye(nSystemDimension);
            TVec = [0, 5];
            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, TVec);
            [nObtainedReachDimension, nObtainedSystemDimension] = dimension(RS);
            isOk = nObtainedSystemDimension == nSystemDimension;
            isOk = isOk && (nObtainedReachDimension == nSystemDimension);
            
            nProjectionDimension = 2;
            ProjectedRS = projection(RS, [1 0 0 0; 0 1 0 0]');
            [nObtainedReachDimension, nObtainedSystemDimension] = dimension(ProjectedRS);
            isOk = isOk && (nObtainedSystemDimension == nSystemDimension);
            isOk = isOk && (nObtainedReachDimension == nProjectionDimension);
            mlunitext.assert(isOk);
        end
        
        
        function self = DISABLED_testGetSystem(self)
            FirstLS = elltool.linsys.LinSysFactory.create( eye(3), eye(3,4), ell_unitball(4), ...
                eye(3), ell_unitball(3), eye(3), ell_unitball(3), 'd');
            FirstRS = elltool.reach.ReachDiscrete(FirstLS, ...
                       ellipsoid(zeros(3, 1), eye(3)), ...
                       eye(3),...
                       [0, 5]);
            SecondLS = elltool.linsys.LinSysFactory.create(eye(4), eye(4, 2), ell_unitball(2), ...
                [], [], [], [], 'd');
            SecondRS = elltool.reach.ReachDiscrete(SecondLS, ...
                        ellipsoid(ones(4, 1), eye(4)), ...
                        eye(4), ...
                        [0, 3]);
            isOk = FirstLS == get_system(FirstRS);
            isOk = isOk && (SecondLS == get_system(SecondRS));
            isOk = isOk && (get_system(FirstRS) ~= get_system(SecondRS));
            mlunitext.assert(isOk);
        end
        
        
        function self = DISABLED_testIsCut(self)
            AMat = [1 2; 3 4];
            BMat = [3; 2];
            PEll = 2*ell_unitball(1);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ellipsoid([0; 0], [3 1; 1 2]);
            LMat = eye(2);
            TVec = [0, 5];
            FirstRS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, TVec);
            SecondRS = cut(FirstRS, [2, 3]);
            ThirdRS = cut(FirstRS, 3);
            isOk = ~iscut(FirstRS);
            isOk = isOk && iscut(SecondRS);
            isOk = isOk && iscut(ThirdRS);
            mlunitext.assert(isOk);
        end
        
        
        function self = DISABLED_testIsProjection(self)
            AMat = eye(3);
            BMat = [1 0; 0 1; 1 1];
            PEll = ell_unitball(2);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ellipsoid([0; 1; 0], eye(3));
            LMat = eye(3);
            TVec = [0, 5];
            FirstRS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, TVec);
            SecondRS = projection(FirstRS, [1 0 0; 0 1 0]');
            expectedVec = [false, true];
            obtainedVec = zeros(1, 2);
            obtainedVec(1) = isprojection(FirstRS);
            obtainedVec(2) = isprojection(SecondRS);
            isEqVec = expectedVec == obtainedVec;
            mlunit.assert_equals( all(isEqVec), true );  
        end
        
        
        function self = DISABLED_testIsEmpty(self)
            AMat = eye(3);
            BMat = diag([3, 2, 1]);
            PEll = ell_unitball(3);
            LSVec = [    elltool.linsys.LinSysFactory.create([], [], [], [], [], [], [], 'd'),...
                         elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd')];
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            TVec = [0, 5];
            RSVec = [elltool.reach.ReachDiscrete(LSVec(1), X0Ell, LMat, TVec),...
                        elltool.reach.ReachDiscrete(LSVec(2), X0Ell, LMat, TVec)];
            obtainedVec = zeros(1, 2);
            obtainedVec(1) = isempty(RSVec(1));
            obtainedVec(2) = isempty(RSVec(2));
            expectedVec = [true, false];
            isEqVec = obtainedVec == expectedVec;
            mlunit.assert_equals( all(isEqVec), true );
        end
        
        
        function self = DISABLED_testGetDirections(self)
            AMat = [1 0 0; 1 1 0; 1 1 1];
            BMat = eye(3);
            PEll = ell_unitball(3);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            T = 15;
            TVec = [1, T];
            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, TVec);
            ExpectedDirectionsCVec = cell(1, 3);
            ExpectedDirectionsCVec{1} = zeros(3, 15);
            ExpectedDirectionsCVec{2} = zeros(3, 15);
            ExpectedDirectionsCVec{3} = zeros(3, 15);
            DirMat = zeros(3, 15);
            for j = 1 : 3
                DirMat(:, 1) = LMat(:, j);
                for i = 2 : T
                    DirMat(:, i) = (AMat')^(-1) * DirMat(:, i - 1);
                end
                ExpectedDirectionsCVec{j} = DirMat;
            end
            ObservedDirectionsCVec = get_directions(RS);
            isOk = true;
            for j = 1 : 3
                isOkMat = abs(ExpectedDirectionsCVec{j} - ObservedDirectionsCVec{j}) < self.ABS_TOL;
                isOk = isOk && all(isOkMat(:));
            end
                     
            AMat = {'2 + cos(k)' '0' '0'; '1' '0' 'sin(k)'; '0' '1' '0'};
            BMat = eye(3);
            PEll = ell_unitball(3);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            T = 15;
            TVec = [1, T];
            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, TVec);
            ExpectedDirectionsCVec = cell(1, 3);
            ExpectedDirectionsCVec{1} = zeros(3, 15);
            ExpectedDirectionsCVec{2} = zeros(3, 15);
            ExpectedDirectionsCVec{3} = zeros(3, 15);
            DirMat = zeros(3, 15);
            for j = 1 : 3
                DirMat(:, 1) = LMat(:, j);
                k = 1;
                CurAMat = zeros(3);
                for s = 1 : 3
                    for l = 1 : 3
                        CurAMat(s, l)  = eval(AMat{s, l});
                    end
                end
                for k = 2 : T
                    DirMat(:, k) = (CurAMat')^(-1) * DirMat(:, k - 1);
                    CurAMat = zeros(3);
                    for s = 1 : 3
                        for l = 1 : 3
                            CurAMat(s, l)  = eval(AMat{s, l});
                        end
                    end
                end
                ExpectedDirectionsCVec{j} = DirMat;
            end
            
            ObservedDirections = get_directions(RS);
            for j = 1 : 3
                isOkMat = abs(ExpectedDirectionsCVec{j} - ObservedDirections{j}) < self.ABS_TOL;
                isOk = isOk && all(isOkMat(:));
            end
            
            mlunit.assert_equals(isOk, true);
        end
        
        
        function self = DISABLED_testGetCenter(self)
            AMat = [1 0 1; -1 2 1; 0 1 -2];
            BMat = [2 0 1; 3 0 1; 2 2 2];
            PEll = ellipsoid([1 1 1]', [3 0 0; 0 4 0; 0 0 1]);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, [1, 20]);
            ObservedCenterMat = get_center(RS);
            
            ExpectedCenterMat = zeros(3, 20);
            [ExpectedCenterMat(:, 1), Q] = double(X0Ell);
            [PCenterVec, Q] = double(PEll);
            for i = 2 : 20
                ExpectedCenterMat(:, i) = AMat * ExpectedCenterMat(:, i - 1) + BMat * PCenterVec;
            end
            
            isOkMat = abs(ExpectedCenterMat - ObservedCenterMat) < self.ABS_TOL;
            isOk = all(isOkMat(:));
            
            AMat = {'1', 'cos(k)', '0'; '1 - 1/k^2', '2', 'sin(k)'; '0', '1', '1'};
            BMat = eye(3);
            PEll = ellipsoid([0 -3 1]', [2 1 0; 1 2 0; 0 0 1]);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, [1, 20]);
            ObservedCenterMat = get_center(RS);
            
            ExpectedCenterMat = zeros(3, 20);
            [ExpectedCenterMat(:, 1), Q] = double(X0Ell);
            [PCenterVec, Q] = double(PEll);
            for i = 2 : 20
                k = i -1;
                ATempMat = zeros(3);
                for s = 1 : 3
                    for l = 1 : 3
                        ATempMat(s, l) = eval(AMat{s, l});
                    end
                end
                ExpectedCenterMat(:, i) = ATempMat * ExpectedCenterMat(:, i - 1) + BMat * PCenterVec;
            end
            
            isOkMat = abs(ExpectedCenterMat - ObservedCenterMat) < self.ABS_TOL;
            isOk = isOk && all(isOkMat(:));
            
            mlunit.assert_equals(isOk, true);
        end
        
        
        function self = DISABLED_testCut(self)
            AMat = [1 0 1; -1 2 1; 0 1 -2];
            BMat = [2 0 1; 3 0 1; 2 2 2];
            PEll = ellipsoid([1 1 1]', [3 0 0; 0 4 0; 0 0 1]);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, [1, 20]);
            SourceEAEllMat = get_ea(RS);
            SourceIAEllMat = get_ia(RS);
            RS2 = cut(RS, 5);
            CutEAEll = get_ea(RS2);
            CutIAEll = get_ia(RS2);
            isOk = all(SourceEAEllMat(:, 5) == CutEAEll(:));
            isOk = isOk && all(SourceIAEllMat(:, 5) == CutIAEll(:));
            

            RS2 = cut(RS, [5, 10]);
            [CutEAEllMat TVec] = get_ea(RS2);
            ResultMat = SourceEAEllMat(:, 5:10) == CutEAEllMat;
            isOk = isOk && all(ResultMat(:));
            isOk = isOk && all(TVec == 5:10);
            [CutIAEllMat TVec] = get_ia(RS2);
            ResultMat = SourceIAEllMat(:, 5:10) == CutIAEllMat;
            isOk = isOk && all(ResultMat(:));           
            isOk = isOk && all(TVec == 5:10);
            
            AMat = {'1', 'k', 'sin(k)'; '1/k', '0', '5'; '0', 'cos(k)', '1'};
            BMat = eye(3);
            PEll = ellipsoid([3 3 1]', [2 1 0; 1 2 0; 0 0 1]);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, [1, 20]);
            RS2 = cut(RS, [10, 15]);
            SourceEAEllMat = get_ea(RS);
            SourceIAEllMat = get_ia(RS);
            [CutEAEllMat TVec] = get_ea(RS2);
            isOk = isOk && all(TVec == 10:15);
            [CutIAEllMat TVec] = get_ia(RS2);
            isOk = isOk && all(TVec == 10:15);
            ResultMat = SourceEAEllMat(:, 10:15) == CutEAEllMat;
            isOk = isOk && all(ResultMat(:));
            ResultMat = SourceIAEllMat(:, 10:15) == CutIAEllMat;
            isOk = isOk && all(ResultMat(:));

            mlunit.assert_equals(isOk, true);
        end
        
        
        function self = DISABLED_testGetGoodCurves(self)
            eps = self.REL_TOL * 1000;
            T = 7;
            
            AMat = [1 0 2; 2 1 2; -1 0 1];
            BMat = [0 1 0; 0 1 0; 3 2 1];
            PEll = 0.01 * ellipsoid([3 2 1]', [4 2 0; 2 4 0; 0 0 2]);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ellipsoid([-1 -2 1]', diag([3, 2, 1]));
            LMat = eye(3);
            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, [1, T]);
            
            GoodDirectionsCVec = get_directions(RS);
            EAEllMat = get_ea(RS);
            GoodCurvesCVec = get_goodcurves(RS);
            ExpectedGoodCurvesMat = zeros(3, T);
            isOk = true;
            for iDirection = 1 : 3
                GoodDirectionsMat = GoodDirectionsCVec{iDirection};
                for jTime = 1 : T
                    ApproximationEll = EAEllMat(iDirection, jTime);
                    [qVec QMat] = double(ApproximationEll);
                    lVec = GoodDirectionsMat(:, jTime);
                    ExpectedGoodCurvesMat(:, jTime) =  qVec + QMat*lVec/(lVec'*QMat*lVec)^0.5;
                end
                isOkMat = abs(ExpectedGoodCurvesMat - GoodCurvesCVec{iDirection}) < eps;
                isOk = isOk && all(isOkMat(:));
            end
            
            AMat = {'2 + cos(k)' '0' '0'; '1' '0' 'sin(k)'; '0' '1' '0'};
            BMat = diag([5, 2, 1]);
            PEll = 0.01 * ell_unitball(3);
            system = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            RS = elltool.reach.ReachDiscrete(system, X0Ell, LMat, [1, 10]);
            
            GoodDirectionsCVec = get_directions(RS);
            EAEllMat = get_ea(RS);
            GoodCurvesCVec = get_goodcurves(RS);
            ExpectedGoodCurvesMat = zeros(3, 10);
            for iDirection = 1 : 3
                GoodDirectionsMat = GoodDirectionsCVec{iDirection};
                for jTime = 1 : 10
                    ApproximationEll = EAEllMat(iDirection, jTime);
                    [qVec QMat] = double(ApproximationEll);
                    lVec = GoodDirectionsMat(:, jTime);
                    ExpectedGoodCurvesMat(:, jTime) =  qVec + QMat*lVec/(lVec'*QMat*lVec)^0.5;
                end
                isOkMat = abs((ExpectedGoodCurvesMat - GoodCurvesCVec{iDirection})) < eps * (abs(ExpectedGoodCurvesMat) + 1);
                isOk = isOk && all(isOkMat(:));
            end
            
            mlunit.assert_equals(isOk, true);
        end
        
         
        function self = DISABLED_testGetIA(self)
            
            T0 = 1;
            T1 = 5;

            AMat = [3 0 1; 2 1 0; 0 3 2];
            BMat = [0 1 2; 0 3 2; 1 1 1];
            X0Mat = eye(3);
            x0Vec = [0, 0, 0]';
            X0Ell = ellipsoid(x0Vec, X0Mat);
            PMat = eye(3);
            PVec = [1 0 1]';
            PEll = ellipsoid(PVec, PMat);
            LMat = eye(3);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');

            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, [T0, T1]);

            PhiArray = zeros(3, 3, T1, T1);
            for i = 1 : T1
                PhiArray(:, :, i, i) = eye(3);
            end
            
            for i = 1 : T1
                for j = i + 1 : T1
                    PhiArray(:, :, j, i) = AMat * PhiArray(:, :, j - 1, i);
                end
            end

            QArray = zeros(3, 3, 3, T1);

            GoodDirectionsCVec = get_directions(RS);

            for jDirection = 1 : 3
                SArray = zeros(3, 3, T1);

                QArray(:, :, jDirection, 1) = X0Mat;
                GoodDirectionsMat = GoodDirectionsCVec{jDirection};
                for k = 2 : T1
                    lVec = GoodDirectionsMat(:, k);
                    aVec = sqrtm(PhiArray(:, :, k, 1) * X0Mat * PhiArray(:, :, k, 1)') * lVec;
                    for i = 1 : k - 1
                        bVec = sqrtm(PhiArray(:, :, k, i + 1) * BMat * PMat * BMat' * PhiArray(:, :, k, i + 1)') * lVec;
                        SArray(:, :, i) = ell_valign(aVec, bVec);
                    end

                    QStarMat = sqrtm(PhiArray(:, :, k, 1) * X0Mat * PhiArray(:, :, k, 1)');
                    for i = 1 : k - 1
                        QStarMat = QStarMat + SArray(:, :, i) * sqrtm(PhiArray(:, :, k, i + 1) * BMat * PMat * BMat' * PhiArray(:, :, k, i + 1)');
                    end
                    QArray(:, :, jDirection, k) = QStarMat' * QStarMat;
                end
            end
            isOkMat = zeros(3, T1);
            ObtainedValuesEllMat = get_ia(RS);
            for iDirection = 1 : 3
                GoodDirectionsMat = GoodDirectionsCVec{iDirection};
                for j = 1 : T1
                    lVec = GoodDirectionsMat(:, j);
                    ApproximationEll = ObtainedValuesEllMat(iDirection, j);
                    [qq QQ] = double(ApproximationEll);
                    isOkMat(iDirection, j) = (abs((lVec' * QQ * lVec) -(lVec' * QArray(:, :, iDirection, j) * lVec)) < 0.001);
                end
            end
            isOk = all(isOkMat(:));
            
            
            T0 = 1;
            T1 = 5;

            AMat = {'2 + cos(k)' '0' '0'; '1' '0' 'sin(k)'; '0' '1' '0'};
            BMat = diag([5, 2, 1]);
            X0Mat = diag([3, 2, 1]);
            x0Vec = [0, 0, 0]';
            X0Ell = ellipsoid(x0Vec, X0Mat);
            PMat = diag([3 4 1]);
            PVec = zeros(3, 1);
            PEll = ellipsoid(PVec, PMat);
            LMat = eye(3);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');

            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, [T0, T1]);

            PhiArray = zeros(3, 3, T1, T1);
            for i = 1 : T1
                PhiArray(:, :, i, i) = eye(3);
            end
            AArray = zeros(3, 3, T1);
            for k = 1 : T1
                for i = 1 : 3
                    for j = 1 : 3
                        AArray(i, j, k) = eval(AMat{i, j});
                    end
                end
            end
            for i = 1 : T1
                for j = i + 1 : T1
                    PhiArray(:, :, j, i) = AArray(:, :, j - 1) * PhiArray(:, :, j - 1, i);
                end
            end

            QArray = zeros(3, 3, 3, T1);

            GoodDirectionsCVec = get_directions(RS);

            for jDirection = 1 : 3
                SArray = zeros(3, 3, T1);

                QArray(:, :, jDirection, 1) = X0Mat;
                GoodDirectionsMat = GoodDirectionsCVec{jDirection};
                for k = 2 : T1
                    lVec = GoodDirectionsMat(:, k);
                    aVec = sqrtm(PhiArray(:, :, k, 1) * X0Mat * PhiArray(:, :, k, 1)') * lVec;
                    for i = 1 : k - 1
                        bVec = sqrtm(PhiArray(:, :, k, i + 1) * BMat * PMat * BMat' * PhiArray(:, :, k, i + 1)') * lVec;
                        SArray(:, :, i) = ell_valign(aVec, bVec);
                    end

                    QStarMat = sqrtm(PhiArray(:, :, k, 1) * X0Mat * PhiArray(:, :, k, 1)');
                    for i = 1 : k - 1
                        QStarMat = QStarMat + SArray(:, :, i) * sqrtm(PhiArray(:, :, k, i + 1) * BMat * PMat * BMat' * PhiArray(:, :, k, i + 1)');
                    end
                    QArray(:, :, jDirection, k) = QStarMat' * QStarMat;
                end
            end
            isOkMat = zeros(3, T1);
            ObtainedValuesEllMat = get_ia(RS);
            for iDirection = 1 : 3
                GoodDirectionMat = GoodDirectionsCVec{iDirection};
                for k = 1 : T1
                    lVec = GoodDirectionMat(:, k);
                    ApproximationEll = ObtainedValuesEllMat(iDirection, k);
                    [qq QQ] = double(ApproximationEll);
                    isOkMat(iDirection, k) = (abs((lVec' * QQ * lVec) -(lVec' * QArray(:, :, iDirection, k) * lVec)) < 1);
                end
            end
            isOk = isOk && all(isOkMat(:));
            
           
            mlunit.assert_equals(all(isOk(:)), true);
        end
        
        
        function self = DISABLED_testGetEA(self)
            T0 = 1;
            T1 = 5;

            AMat = [3 0 1; 2 1 0; 0 3 2];
            BMat = [0 1 2; 0 3 2; 1 1 1];
            X0Mat = eye(3);
            x0Vec = [0, 0, 0]';
            X0Ell = ellipsoid(x0Vec, X0Mat);
            PMat = eye(3);
            PVec = [1 0 1]';
            PEll = ellipsoid(PVec, PMat);
            LMat = eye(3);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');

            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, [T0, T1]);

            PhiArray = zeros(3, 3, T1, T1);
            for i = 1 : T1
                PhiArray(:, :, i, i) = eye(3);
            end

            for i = 1 : T1
                for j = i + 1 : T1
                    PhiArray(:, :, j, i) = AMat * PhiArray(:, :, j - 1, i);
                end
            end

            qArray = zeros(3, 3, T1);
            QArray = zeros(3, 3, 3, T1);

            GoodDirectionsCVec = get_directions(RS);

            for jDirection = 1 : 3
                
                QArray(:, :, jDirection, 1) = X0Mat;
                GoodDirectionsMat = GoodDirectionsCVec{jDirection};
                for k = 2 : T1
                    lVec = GoodDirectionsMat(:, k);
                    pVec = zeros(T1, 1);
                    pVec(1) = sqrt(lVec' * PhiArray(:, :, k, 1) * X0Mat * PhiArray(:, :, k, 1)' * lVec);
                    for i = 1 : k - 1
                        pVec(i + 1) = sqrt(lVec' * PhiArray(:, :, k, i+1) * BMat * PMat * BMat' * PhiArray(:, :, k, i+1)' * lVec);
                    end

                    QArray(:, :, jDirection, k) = PhiArray(:, :, k, 1) * X0Mat * PhiArray(:, :, k, 1)' /pVec(1);
                    for i = 1 : k - 1
                        QArray(:, :, jDirection, k) = QArray(:, :, jDirection, k) + PhiArray(:, :, k, i + 1) * BMat * PMat * BMat' * PhiArray(:, :, k, i + 1)'/pVec(i + 1);
                    end
                    QArray(:, :, jDirection, k) = QArray(:, :, jDirection, k) * sum(pVec);
                end
            end
            
            isOkMat = zeros(3, T1);
            ObtainedValuesEllMat = get_ea(RS);
            for iDirection = 1 : 3
                directions = GoodDirectionsCVec{iDirection};
                for k = 1 : T1
                    lVec = directions(:, k);
                    ApproximationEll = ObtainedValuesEllMat(iDirection, k);
                    [qq QQ] = double(ApproximationEll);
                    isOkMat(iDirection, k) = (abs((lVec' * QQ * lVec) -(lVec' * QArray(:, :, iDirection, k) * lVec)) < 0.001);
                end
            end
            isOk = all(isOkMat(:));
            
            T0 = 1;
            T1 = 5;

            AMat = {'1', 'cos(k)', '0'; '1 - 1/k^2', '2', 'sin(k)'; '0', '1', '1'};
            BMat = [3 2 1; 0 0 1; 2 1 1];
            X0Mat = [5 1 0; 1 4 1; 0 1 3];
            x0Vec = [0, 0, 0]';
            X0Ell = ellipsoid(x0Vec, X0Mat);
            PMat = eye(3);
            PVec = [1 0 1]';
            PEll = ellipsoid(PVec, PMat);
            LMat = eye(3);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');

            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, [T0, T1]);

            PhiArray = zeros(3, 3, T1, T1);
            for i = 1 : T1
                PhiArray(:, :, i, i) = eye(3);
            end

            AArray = zeros(3, 3, T1);
            for k = 1 : T1
                for i = 1 : 3
                    for j = 1 : 3
                        AArray(i, j, k) = eval(AMat{i, j});
                    end
                end
            end
            for i = 1 : T1
                for j = i + 1 : T1
                    PhiArray(:, :, j, i) = AArray(:, :, j - 1) * PhiArray(:, :, j - 1, i);
                end
            end

            QArray = zeros(3, 3, 3, T1);

            GoodDirectionsCVec = get_directions(RS);

            for jDirection = 1 : 3

                QArray(:, :, jDirection, 1) = X0Mat;
                GoodDirectionsMat = GoodDirectionsCVec{jDirection};
                for k = 2 : T1
                    lVec = GoodDirectionsMat(:, k);
                    pVec = zeros(T1, 1);
                    pVec(1) = sqrt(lVec' * PhiArray(:, :, k, 1) * X0Mat * PhiArray(:, :, k, 1)' * lVec);
                    for i = 1 : k - 1
                        pVec(i + 1) = sqrt(lVec'* PhiArray(:, :, k, i+1) * BMat * PMat * BMat' * PhiArray(:, :, k, i+1)' *lVec);
                    end

                    QArray(:, :, jDirection, k) = PhiArray(:, :, k, 1) * X0Mat * PhiArray(:, :, k, 1)' /pVec(1);
                    for i = 1 : k - 1
                        QArray(:, :, jDirection, k) = QArray(:, :, jDirection, k) + PhiArray(:, :, k, i + 1) * BMat * PMat * BMat' * PhiArray(:, :, k, i + 1)'/pVec(i + 1);
                    end
                    QArray(:, :, jDirection, k) = QArray(:, :, jDirection, k) * sum(pVec);
                end
            end
            
            isOkMat = zeros(3, T1);
            ObtainedValuesEllMat = get_ea(RS);
            for iDirection = 1 : 3
                GoodDirectionsMat = GoodDirectionsCVec{iDirection};
                for j = 1 : T1
                    lVec = GoodDirectionsMat(:, j);
                    ApproximationEll = ObtainedValuesEllMat(iDirection, j);
                    [qq QQ] = double(ApproximationEll);
                    isOkMat(iDirection, j) = (abs((lVec' * QQ * lVec) -(lVec' * QArray(:, :, iDirection, j) * lVec)) < 0.1);
                end
            end
            isOk = isOk && all(isOkMat(:));
            
            mlunit.assert_equals(isOk, true);
        end
        
        
        function self = DISABLED_testProjection(self)
            T0 = 1;
            T1 = 4;
            epsilon = 1;

            AMat = [3 0 1; 2 1 0; 0 3 2];
            BMat = [0 1 2; 0 3 2; 1 1 1];
            X0Mat = eye(3);
            x0Vec = [0, 0, 0]';
            X0Ell = ellipsoid(x0Vec, X0Mat);
            PMat = eye(3);
            PVec = [1 0 1]';
            PEll = ellipsoid(PVec, PMat);
            LMat = eye(3);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');

            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, [T0, T1]);
            
            ProjectionMatrix = [1/2^0.5 0 1/2^0.5; 0 1 0]';
            ProjectedRS = projection(RS, ProjectionMatrix);
            initApproximationEllMat = get_ia(RS);
            finitApproximationEllMat = initApproximationEllMat;
            for iDirection = 1 : 3
                for t = 1 : T1
                   [q Q] = double(initApproximationEllMat(iDirection, t));
                   finitApproximationEllMat(iDirection, t) = ellipsoid(ProjectionMatrix' * q, ProjectionMatrix' * Q * ProjectionMatrix);
                end
            end
            obtainedApproximationEllMat = get_ia(ProjectedRS);
            isOk = 1;
            for iDirection = 1 : 3
                for t = 1 : T1
                    [q1 Q1] = double(finitApproximationEllMat(iDirection, t));
                    [q2 Q2] = double(obtainedApproximationEllMat(iDirection, t));
                    isOk = isOk && all(abs(q1 - q2) < epsilon);
                    isOkMat = abs(Q1 - Q2) < epsilon;
                    isOk = isOk && all(isOkMat(:));
                end
            end
            
            initApproximationEllMat = get_ea(RS);
            finitApproximationEllMat = initApproximationEllMat;
            for iDirection = 1 : 3
                for t = 1 : T1
                   [q Q] = double(initApproximationEllMat(iDirection, t));
                   finitApproximationEllMat(iDirection, t) = ellipsoid(ProjectionMatrix' * q, ProjectionMatrix' * Q * ProjectionMatrix);
                end
            end
            obtainedApproximationEllMat = get_ea(ProjectedRS);
            for iDirection = 1 : 3
                for t = 1 : T1
                    [q1 Q1] = double(finitApproximationEllMat(iDirection, t));
                    [q2 Q2] = double(obtainedApproximationEllMat(iDirection, t));
                    isOk = isOk && all(abs(q1 - q2) < epsilon);
                    isOkMat = abs(Q1 - Q2) < epsilon;
                    isOk = isOk && all(isOkMat(:));
                end
            end
            
            mlunit.assert_equals(isOk, true);
            
        end
        
        
        function self = DISABLED_testIntersect(self)
            T0 = 1;
            T1 = 5;

            AMat = [3 0 1; 2 1 0; 0 3 2];
            BMat = [0 1 2; 0 3 2; 1 1 1];
            X0Mat = eye(3);
            x0Vec = [0, 0, 0]';
            X0Ell = ellipsoid(x0Vec, X0Mat);
            PMat = eye(3);
            PVec = [1 0 1]';
            PEll = ellipsoid(PVec, PMat);
            LMat = eye(3);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');
            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, [T0, T1]);
            RS = projection(RS, [1 0 0; 0 1 0]');
            ell1 = ellipsoid([-200, -120]', 200*eye(2));
            ell2 = ellipsoid([-100, 250]', 100*eye(2));
            ell3 = ellipsoid([0, 0]', 100*eye(2));
            
            obtainedValuesMat = zeros(2, 3);
            expectedValuesMat = [1 0 1; 0 0 1];
            
            obtainedValuesMat(1, 1) = intersect(RS, ell1, 'e');
            obtainedValuesMat(1, 2) = intersect(RS, ell2, 'e');
            obtainedValuesMat(1, 3) = intersect(RS, ell3, 'e');
            obtainedValuesMat(2, 1) = intersect(RS, ell1, 'i');
            obtainedValuesMat(2, 2) = intersect(RS, ell2, 'i');
            obtainedValuesMat(2, 3) = intersect(RS, ell3, 'i');
           
            isOkMat = obtainedValuesMat == expectedValuesMat;
            isOk = all(isOkMat(:));

            hp1 = hyperplane([6, 4]', 5000);
            hp2 = hyperplane([-1, 1]', 3000);
            hp3 = hyperplane([-1, -1]', 100);

            obtainedValuesMat = zeros(2, 3);
            obtainedValuesMat(1, 1) = intersect(RS, hp1, 'e');
            obtainedValuesMat(1, 2) = intersect(RS, hp2, 'e');
            obtainedValuesMat(1, 3) = intersect(RS, hp3, 'e');
            obtainedValuesMat(2, 1) = intersect(RS, hp1, 'i');
            obtainedValuesMat(2, 2) = intersect(RS, hp2, 'i');
            obtainedValuesMat(2, 3) = intersect(RS, hp3, 'i');
            
            isOkMat = obtainedValuesMat == expectedValuesMat;
            isOk = isOk && all(isOkMat(:));
            
            mlunit.assert_equals(isOk, true);            
        end
        
        
        function self = DISABLED_testEvolve(self)
            T0 = 1;
            T1 = 3;
            T2 = 5;
            epsilon = 0.1;
            
            A1Mat = [3 0 1; 2 1 0; 0 3 2];
            B1Mat = [0 1 2; 0 3 2; 1 1 1];
            X01Mat = eye(3);
            x0Vec1 = [0, 0, 0]';
            X01Ell = ellipsoid(x0Vec1, X01Mat);
            P1Mat = eye(3);
            P1Vec = [1 0 1]';
            P1Ell = ellipsoid(P1Vec, P1Mat);
            
            A2Mat = [1 0 2; 2 1 2; -1 0 1];
            B2Mat = [0 1 0; 0 1 0; 3 2 1];
            P2Ell = 0.01 * ellipsoid([3 2 1]', [4 2 0; 2 4 0; 0 0 2]);
            LS2 = elltool.linsys.LinSysFactory.create(A2Mat, B2Mat, P2Ell, [], [], [], [], 'd');
            
            LMat = eye(3);
            LS1 = elltool.linsys.LinSysFactory.create(A1Mat, B1Mat, P1Ell, [], [], [], [], 'd');
            RS = elltool.reach.ReachDiscrete(LS1, X01Ell, LMat, [T0, T1]);
            obtainedRS = evolve(RS, T2);
            expectedRS = elltool.reach.ReachDiscrete(LS1, X01Ell, LMat, [T0, T2]);
            
            isOk = 1;
            expectedApproxEllMat = get_ia(expectedRS);
            obtainedApproxEllMat = get_ia(obtainedRS);
            for iDirection = 1 : 3
                for t = T1 : T2
                    [q1 Q1] = double(expectedApproxEllMat(iDirection, t));
                    [q2 Q2] = double(obtainedApproxEllMat(iDirection, t - T1 + 1));
                    isOk = isOk && max(abs(q1 - q2)) < epsilon;
                    resMat = abs(Q1 - Q2);
                    isOk = isOk && max(resMat(:)) < epsilon;
                end
            end
            
            expectedApproxEllMat = get_ea(expectedRS);
            obtainedApproxEllMat = get_ea(obtainedRS);
            for iDirection = 1 : 3
                for t = T1 : T2
                    [q1 Q1] = double(expectedApproxEllMat(iDirection, t));
                    [q2 Q2] = double(obtainedApproxEllMat(iDirection, t - T1 + 1));
                    isOk = isOk && max(abs(q1 - q2)) < epsilon;
                    resMat = abs(Q1 - Q2);
                    isOk = isOk && max(resMat(:)) < epsilon;
                end
            end
            
            
            obtainedRS = evolve(RS, T2, LS2);
            obtainedApproxEllMat = get_ia(obtainedRS);
            initApproxEllMat = get_ia(RS);
            
            for iDirection = 1 : 3
                EvolvingRS = elltool.reach.ReachDiscrete(LS2, initApproxEllMat(iDirection, T1), LMat(:, iDirection), [T1 T2]);
                expectedApproxEllMat = get_ia(EvolvingRS);
                for t = 1 : T2 - T1 + 1
                    [q1 Q1] = double(expectedApproxEllMat(1, t));
                    [q2 Q2] = double(obtainedApproxEllMat(iDirection, t));
                    isOk = isOk && max(abs(q1 - q2)) < epsilon;
                    res = abs(Q1 - Q2);
                    isOk = isOk && max(res(:))/max(abs(Q1(:))) < epsilon; 
                end
            end
            
            obtainedApproxEllMat = get_ea(obtainedRS);
            initApproxEllMat = get_ea(RS);
            
            for iDirection = 1 : 3
                EvolvingRS = elltool.reach.ReachDiscrete(LS2, initApproxEllMat(iDirection, T1), LMat(:, iDirection), [T1 T2]);
                expectedApproxEllMat = get_ea(EvolvingRS);
                for t = 1 : T2 - T1 + 1
                    [q1 Q1] = double(expectedApproxEllMat(1, t));
                    [q2 Q2] = double(obtainedApproxEllMat(iDirection, t));
                    isOk = isOk && max(abs(q1 - q2)) < epsilon;
                    res = abs(Q1 - Q2);
                    isOk = isOk && max(res(:))/max(abs(Q1(:))) < epsilon; 
                end
            end   
            mlunit.assert_equals(isOk, true);
        end
        
        function self = testOverflow(self)
            AMat = [4 5 1; 3 2 1; 0 1 3];
            BMat = [2 0 1; 3 0 1; 2 2 2];
            PEll = ellipsoid([1 1 1]', [3 0 0; 0 4 0; 0 0 1]);
            LS = elltool.linsys.LinSysFactory.create(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            RS = elltool.reach.ReachDiscrete(LS, X0Ell, LMat, [1, 20]);
        end
    end
end