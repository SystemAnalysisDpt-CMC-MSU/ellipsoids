classdef ReachDiscrTestCase < mlunit.test_case
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
        function self = ReachDiscrTestCase(varargin)
            self = self@mlunit.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir =...
                [fileparts(which(className)), filesep,...
                'TestData', filesep, shortClassName];
        end
        
        function self = DISABLED_testDisplay(self)
            system = linsys( eye(3), eye(3,4), ell_unitball(4), ...
                [], [], [], [], 'd');
            X0Ell = ellipsoid(zeros(3, 1), eye(3));
            LMat = eye(3);
            TVec = [0, 5];
            rs = reach(system, X0Ell, LMat, TVec);
            resStr = evalc('display(rs)');
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
            system = linsys( eye(nSystemDimension), eye(nSystemDimension,2), ell_unitball(2), ...
                [], [], [], [], 'd');
            X0Ell = ellipsoid(zeros(nSystemDimension, 1), eye(nSystemDimension));
            LMat = eye(nSystemDimension);
            TVec = [0, 5];
            rs = reach(system, X0Ell, LMat, TVec);
            [nObtainedReachDimension, nObtainedSystemDimension] = dimension(rs);
            isOk = nObtainedSystemDimension == nSystemDimension;
            isOk = isOk && (nObtainedReachDimension == nSystemDimension);
            
            ProjectionDimension = 2;
            rsp = projection(rs, [1 0 0 0; 0 1 0 0]');
            [nObtainedReachDimension, nObtainedSystemDimension] = dimension(rsp);
            isOk = isOk && (nObtainedSystemDimension == nSystemDimension);
            isOk = isOk && (nObtainedReachDimension == ProjectionDimension);
            mlunitext.assert(isOk);
        end
        
        function self = DISABLED_testGetSystem(self)
            firstSystem = linsys( eye(3), eye(3,4), ell_unitball(4), ...
                eye(3), ell_unitball(3), eye(3), ell_unitball(3), 'd');
            firstReach = reach(firstSystem, ...
                       ellipsoid(zeros(3, 1), eye(3)), ...
                       eye(3),...
                       [0, 5]);
            secondSysmtem = linsys(eye(4), eye(4, 2), ell_unitball(2), ...
                [], [], [], [], 'd');
            secondReach = reach(secondSysmtem, ...
                        ellipsoid(ones(4, 1), eye(4)), ...
                        eye(4), ...
                        [0, 3]);
            isOk = firstSystem == get_system(firstReach);
            isOk = isOk && (secondSysmtem == get_system(secondReach));
            isOk = isOk && (get_system(firstReach) ~= get_system(secondReach));
            mlunitext.assert(isOk);
        end
        
        function self = DISABLED_testIsCut(self)
            AMat = [1 2; 3 4];
            BMat = [3; 2];
            PEll = 2*ell_unitball(1);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ellipsoid([0; 0], [3 1; 1 2]);
            LMat = eye(2);
            TVec = [0, 5];
            firstReach = reach(system, X0Ell, LMat, TVec);
            secondReach = cut(firstReach, [2, 3]);
            thirdReach = cut(firstReach, 3);
            isOk = ~iscut(firstReach);
            isOk = isOk && iscut(secondReach);
            isOk = isOk && iscut(thirdReach);
            mlunitext.assert(isOk);
        end
        
        function self = DISABLED_testIsProjection(self)
            AMat = eye(3);
            BMat = [1 0; 0 1; 1 1];
            PEll = ell_unitball(2);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ellipsoid([0; 1; 0], eye(3));
            LMat = eye(3);
            TVec = [0, 5];
            firstReach = reach(system, X0Ell, LMat, TVec);
            secondReach = projection(firstReach, [1 0 0; 0 1 0]');
            expectedVec = [false, true];
            obtainedVec = isprojection([firstReach, secondReach]);
            eqVec = expectedVec == obtainedVec;
            mlunit.assert_equals( all(eqVec), true );  
        end
        
        function self = DISABLED_testIsEmpty(self)
            AMat = eye(3);
            BMat = ones(3);
            PEll = ell_unitball(3);
            systemVec = [linsys(), ...
                         linsys([], [], [], [], [], [], [], 'd'),...
                         linsys(AMat, BMat, PEll, [], [], [], [], 'd')];
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            TVec = [0, 5];
            reachVec = [reach(systemVec(1), X0Ell, LMat, TVec),...
                        reach(systemVec(2), X0Ell, LMat, TVec),...
                        reach(systemVec(3), X0Ell, LMat, TVec)];
            obtainedVec = isempty(reachVec);
            expectedVec = [true, true, false];
            eqVec = obtainedVec == expectedVec;
            mlunit.assert_equals( all(eqVec), true );
        end
        
        
        
        function self = DISABLED_testGetDirections(self)
            AMat = [1 0 0; 1 1 0; 1 1 1];
            BMat = eye(3);
            PEll = ell_unitball(3);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            T = 15;
            TVec = [1, T];
            rs = reach(system, X0Ell, LMat, TVec);
            ExpectedDirections = cell(1, 3);
            ExpectedDirections{1} = zeros(3, 15);
            ExpectedDirections{2} = zeros(3, 15);
            ExpectedDirections{3} = zeros(3, 15);
            Dir = zeros(3, 15);
            for j = 1 : 3
                Dir(:, 1) = LMat(:, j);
                for i = 2 : T
                    Dir(:, i) = (AMat')^(-1) * Dir(:, i - 1);
                end
                ExpectedDirections{j} = Dir;
            end
            ObservedDirections = get_directions(rs);
            isOk = true;
            for j = 1 : 3
                CompareMat = abs(ExpectedDirections{j} - ObservedDirections{j}) < self.ABS_TOL;
                isOk = isOk && all(CompareMat(:));
            end
            
            
            AMat = {'2 + cos(t)' '0' '0'; '1' '0' 'sin(t)'; '0' '1' '0'};
            BMat = eye(3);
            PEll = ell_unitball(3);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            T = 15;
            TVec = [1, T];
            rs = reach(system, X0Ell, LMat, TVec);
            ExpectedDirections = cell(1, 3);
            ExpectedDirections{1} = zeros(3, 15);
            ExpectedDirections{2} = zeros(3, 15);
            ExpectedDirections{3} = zeros(3, 15);
            Dir = zeros(3, 15);
            for j = 1 : 3
                Dir(:, 1) = LMat(:, j);
                t = 1;
                CurAMat = zeros(3);
                for k = 1 : 3
                    for l = 1 : 3
                        CurAMat(k, l)  = eval(AMat{k, l});
                    end
                end
                for i = 2 : T
                    Dir(:, i) = (CurAMat')^(-1) * Dir(:, i - 1);
                    t = i;
                    CurAMat = zeros(3);
                    for k = 1 : 3
                        for l = 1 : 3
                            CurAMat(k, l)  = eval(AMat{k, l});
                        end
                    end
                end
                ExpectedDirections{j} = Dir;
            end
            
            ObservedDirections = get_directions(rs);
            for j = 1 : 3
                CompareMat = abs(ExpectedDirections{j} - ObservedDirections{j}) < self.ABS_TOL;
                isOk = isOk && all(CompareMat(:));
            end
            
            mlunit.assert_equals(isOk, true);
        end
        
        
        
        function self = DISABLED_testGetCenter(self)
            AMat = [1 0 1; -1 2 1; 0 1 -2];
            BMat = [2 0 1; 3 0 1; 2 2 2];
            PEll = ellipsoid([1 1 1]', [3 0 0; 0 4 0; 0 0 1]);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            rs = reach(system, X0Ell, LMat, [1, 20]);
            ObservedCenterMat = get_center(rs);
            
            ExpectedCenterMat = zeros(3, 20);
            [ExpectedCenterMat(:, 1), Q] = double(X0Ell);
            [UCenter, Q] = double(PEll);
            for i = 2 : 20
                ExpectedCenterMat(:, i) = AMat * ExpectedCenterMat(:, i - 1) + BMat * UCenter;
            end
            
            result = abs(ExpectedCenterMat - ObservedCenterMat) < self.ABS_TOL;
            isOk = all(result(:));
            
            AMat = {'1', 'cos(t)', '0'; '1 - 1/t^2', '2', 'sin(t)'; '0', '1', '1'};
            BMat = eye(3);
            PEll = ellipsoid([0 -3 1]', [2 1 0; 1 2 0; 0 0 1]);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            rs = reach(system, X0Ell, LMat, [1, 20]);
            ObservedCenterMat = get_center(rs);
            
            ExpectedCenterMat = zeros(3, 20);
            [ExpectedCenterMat(:, 1), Q] = double(X0Ell);
            [UCenter, Q] = double(PEll);
            for i = 2 : 20
                t = i -1;
                ATempMat = zeros(3);
                for k = 1 : 3
                    for l = 1 : 3
                        ATempMat(k, l) = eval(AMat{k, l});
                    end
                end
                ExpectedCenterMat(:, i) = ATempMat * ExpectedCenterMat(:, i - 1) + BMat * UCenter;
            end
            
            result = abs(ExpectedCenterMat - ObservedCenterMat) < self.ABS_TOL;
            isOk = isOk && all(result(:));
            
            mlunit.assert_equals(isOk, true);
        end
        
        
        
        function self = DISABLED_testCut(self)
            AMat = [3 0 2; 2 2 2; -1 0 3];
            BMat = [0 1 0; 0 1 0; 3 2 1];
            PEll = ellipsoid([3 2 1]', [4 2 0; 2 4 0; 0 0 2]);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ellipsoid([-1 -2 1]', diag([3, 2, 1]));
            LMat = eye(3);
            rs = reach(system, X0Ell, LMat, [1, 20]);
            SourceEA = get_ea(rs);
            SourceIA = get_ia(rs);
            rs2 = cut(rs, 5);
            CutEA = get_ea(rs2);
            CutIA = get_ia(rs2);
            isOk = all(SourceEA(:, 5) == CutEA(:));
            isOk = isOk && all(SourceIA(:, 5) == CutIA(:));
            
%             AMat = [1 0 1; -1 2 1; 0 1 -2];
%             BMat = eye(3);
%             PEll = ellipsoid([-1 0 -1]', [3 2 1; 2 4 1; 1 1 2]);
%             system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');
%             X0Ell = ellipsoid([5 5 5]', [2 1 0; 1 2 0; 0 0 1]);
%             LMat = eye(3);
%             rs = reach(system, X0Ell, LMat, [1, 20]);
%             SourceEA = get_ea(rs);
%             rs2 = cut(rs, [5, 10]);
%             [CutEA T] = get_ea(rs2);
%             ResultMat = SourceEA(:, 5:10) == CutEA;
%             isOk = isOk && all(ResultMat(:));
%             SourceIA = get_ia(rs);
%             CutIA = get_ia(rs2);
%             ResultMat = SourceIA(:, 5:10) == CutIA;
%             isOk = isOk && all(ResultMat(:));

%             AMat = {'1', 't', 'sin(t)'; '1/t', '0', '5'; '0', 'cos(t)', '1'};
%             BMat = eye(3);
%             PEll = ellipsoid([3 3 1]', [2 1 0; 1 2 0; 0 0 1]);
%             system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');
%             X0Ell = ell_unitball(3);
%             LMat = eye(3);
%             rs = reach(system, X0Ell, LMat, [1, 20]);
%             rs2 = cut(rs, [10, 15]);
%             SourceEA = get_ea(rs);
%             SourceIA = get_ia(rs);
%             [CutEA T] = get_ea(rs2);
%             isOk = isOk && all(T == 10:15);
%             [CutIA T] = get_ia(rs2);
%             isOk = isOk && all(T == 10:15);
%             ResultMat = SourceEA(:, 10:15) == CutEA;
%             isOk = isOk && all(ResultMat(:));
%             ResultMat = SourceIA(:, 10:15) == CutIA;
%             isOk = isOk && all(ResultMat(:));

            mlunit.assert_equals(isOk, true);
        end
        
        
        
        function self = DISABLED_testGetGoodCurves(self)
            eps = self.REL_TOL * 1000;
            
            AMat = [1 0 2; 2 1 2; -1 0 1];
            BMat = [0 1 0; 0 1 0; 3 2 1];
            PEll = 0.01 * ellipsoid([3 2 1]', [4 2 0; 2 4 0; 0 0 2]);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ellipsoid([-1 -2 1]', diag([3, 2, 1]));
            LMat = eye(3);
            rs = reach(system, X0Ell, LMat, [1, 20]);
            
            LL = get_directions(rs);
            EA = get_ea(rs);
            GoodCurves = get_goodcurves(rs);
            ExpectedGoodCurves = zeros(3, 20);
            isOk = true;
            for i = 1 : 3
                L = LL{i};
                for j = 1 : 20
                    ApproximationEll = EA(i, j);
                    [q Q] = double(ApproximationEll);
                    l = L(:, j);
                    ExpectedGoodCurves(:, j) =  q + Q*l/(l'*Q*l)^0.5;
                end
                Result = abs((ExpectedGoodCurves - GoodCurves{i})./ExpectedGoodCurves) < eps;
                isOk = isOk && all(Result(:));
            end
            
            AMat = {'2 + cos(t)' '0' '0'; '1' '0' 'sin(t)'; '0' '1' '0'};
            BMat = diag([5, 2, 1]);
            PEll = 0.01 * ell_unitball(3);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');
            X0Ell = ell_unitball(3);
            LMat = eye(3);
            rs = reach(system, X0Ell, LMat, [1, 10]);
            
            LL = get_directions(rs);
            EA = get_ea(rs);
            GoodCurves = get_goodcurves(rs);
            ExpectedGoodCurves = zeros(3, 10);
            for i = 1 : 3
                L = LL{i};
                for j = 1 : 10
                    ApproximationEll = EA(i, j);
                    [q Q] = double(ApproximationEll);
                    l = L(:, j);
                    ExpectedGoodCurves(:, j) =  q + Q*l/(l'*Q*l)^0.5;
                end
                Result = abs((ExpectedGoodCurves - GoodCurves{i})) < eps * (abs(ExpectedGoodCurves) + 1);
                isOk = isOk && all(Result(:));
            end
            
            mlunit.assert_equals(isOk, true);
        end
        
        function self = DISABLED_testGetIA(self)
            
            k0 = 1;
            T = 5;

            AMat = [3 0 1; 2 1 0; 0 3 2];
            BMat = [0 1 2; 0 3 2; 1 1 1];
            X0Mat = eye(3);
            x0Vec = [0, 0, 0]';
            X0 = ellipsoid(x0Vec, X0Mat);
            PMat = eye(3);
            PVec = [1 0 1]';
            PEll = ellipsoid(PVec, PMat);
            LMat = eye(3);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');

            rs = reach(system, X0, LMat, [k0, T]);

            PhiMat = zeros(3, 3, T, T);
            for i = 1 : T
                PhiMat(:, :, i, i) = eye(3);
            end

            for i = 1 : T
                for j = i + 1 : T
                    PhiMat(:, :, j, i) = AMat * PhiMat(:, :, j - 1, i);
                end
            end

            q = zeros(3, 3, T);
            Q = zeros(3, 3, 3, T);

            GoodDirections = get_directions(rs);

            % цикл по направлениям
            for j = 1 : 3
                S = zeros(3, 3, T);
                % цикл по времени

                Q(:, :, j, 1) = X0Mat;
                L = GoodDirections{j};
                for t = 2 : T
                    l = L(:, t);
                    aVec = sqrtm(PhiMat(:, :, t, 1) * X0Mat * PhiMat(:, :, t, 1)') * l;
                    for i = 1 : t - 1
                        bVec = sqrtm(PhiMat(:, :, t, i + 1) * BMat * PMat * BMat' * PhiMat(:, :, t, i + 1)') * l;
                        S(:, :, i) = ell_valign(aVec, bVec);
                    end

                    QStar = sqrtm(PhiMat(:, :, t, 1) * X0Mat * PhiMat(:, :, t, 1)');
                    for i = 1 : t - 1
                        QStar = QStar + S(:, :, i) * sqrtm(PhiMat(:, :, t, i + 1) * BMat * PMat * BMat' * PhiMat(:, :, t, i + 1)');
                    end
                    Q(:, :, j, t) = QStar' * QStar;
                end
            end
            result = zeros(3, T);
            ObtainedValues = get_ia(rs);
            for i = 1 : 3
                directions = GoodDirections{i};
                for j = 1 : T
                    l = directions(:, j);
                    Approximation = ObtainedValues(i, j);
                    [qq QQ] = double(Approximation);
                    result(i, j) = (abs((l' * QQ * l) -(l' * Q(:, :, i, j) * l)) < 0.001);
                end
            end
            isOk = all(result(:));
            
            
            
            
            k0 = 1;
            T = 5;

            AMat = {'2 + cos(t)' '0' '0'; '1' '0' 'sin(t)'; '0' '1' '0'};
            BMat = diag([5, 2, 1]);
            X0Mat = diag([3, 2, 1]);
            x0Vec = [0, 0, 0]';
            X0 = ellipsoid(x0Vec, X0Mat);
            PMat = diag([3 4 1]);
            PVec = zeros(3, 1);
            PEll = ellipsoid(PVec, PMat);
            LMat = eye(3);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');

            rs = reach(system, X0, LMat, [k0, T]);

            PhiMat = zeros(3, 3, T, T);
            for i = 1 : T
                PhiMat(:, :, i, i) = eye(3);
            end
            AMatArray = zeros(3, 3, T);
            for t = 1 : T
                for i = 1 : 3
                    for j = 1 : 3
                        AMatArray(i, j, t) = eval(AMat{i, j});
                    end
                end
            end
            for i = 1 : T
                for j = i + 1 : T
                    PhiMat(:, :, j, i) = AMatArray(:, :, j - 1) * PhiMat(:, :, j - 1, i);
                end
            end

            q = zeros(3, 3, T);
            Q = zeros(3, 3, 3, T);

            GoodDirections = get_directions(rs);

            % цикл по направлениям
            for j = 1 : 3
                S = zeros(3, 3, T);
                % цикл по времени

                Q(:, :, j, 1) = X0Mat;
                L = GoodDirections{j};
                for t = 2 : T
                    l = L(:, t);
                    aVec = sqrtm(PhiMat(:, :, t, 1) * X0Mat * PhiMat(:, :, t, 1)') * l;
                    for i = 1 : t - 1
                        bVec = sqrtm(PhiMat(:, :, t, i + 1) * BMat * PMat * BMat' * PhiMat(:, :, t, i + 1)') * l;
                        S(:, :, i) = ell_valign(aVec, bVec);
                    end

                    QStar = sqrtm(PhiMat(:, :, t, 1) * X0Mat * PhiMat(:, :, t, 1)');
                    for i = 1 : t - 1
                        QStar = QStar + S(:, :, i) * sqrtm(PhiMat(:, :, t, i + 1) * BMat * PMat * BMat' * PhiMat(:, :, t, i + 1)');
                    end
                    Q(:, :, j, t) = QStar' * QStar;
                end
            end
            result = zeros(3, T);
            ObtainedValues = get_ia(rs);
            for i = 1 : 3
                directions = GoodDirections{i};
                for j = 1 : T
                    l = directions(:, j);
                    Approximation = ObtainedValues(i, j);
                    [qq QQ] = double(Approximation);
                    result(i, j) = (abs((l' * QQ * l) -(l' * Q(:, :, i, j) * l)) < 1);
                end
            end
            isOk = isOk && all(result(:));
            
           
            mlunit.assert_equals(all(isOk(:)), true);
        end
        
        
        function self = testGetEA(self)
            k0 = 1;
            T = 5;

            AMat = [3 0 1; 2 1 0; 0 3 2];
            BMat = [0 1 2; 0 3 2; 1 1 1];
            X0Mat = eye(3);
            x0Vec = [0, 0, 0]';
            X0 = ellipsoid(x0Vec, X0Mat);
            PMat = eye(3);
            PVec = [1 0 1]';
            PEll = ellipsoid(PVec, PMat);
            LMat = eye(3);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');

            rs = reach(system, X0, LMat, [k0, T]);

            PhiMat = zeros(3, 3, T, T);
            for i = 1 : T
                PhiMat(:, :, i, i) = eye(3);
            end

            for i = 1 : T
                for j = i + 1 : T
                    PhiMat(:, :, j, i) = AMat * PhiMat(:, :, j - 1, i);
                end
            end

            q = zeros(3, 3, T);
            Q = zeros(3, 3, 3, T);

            GoodDirections = get_directions(rs);

            % цикл по направлениям
            for j = 1 : 3
                % цикл по времени

                Q(:, :, j, 1) = X0Mat;
                L = GoodDirections{j};
                for t = 2 : T
                    l = L(:, t);
                    p = zeros(T, 1);
                    p(1) = sqrt(l' * PhiMat(:, :, t, 1) * X0Mat * PhiMat(:, :, t, 1)' * l);
                    for i = 1 : t - 1
                        p(i + 1) = sqrt(l'* PhiMat(:, :, t, i+1) * BMat * PMat * BMat' * PhiMat(:, :, t, i+1)' *l);
                    end

                    Q(:, :, j, t) = PhiMat(:, :, t, 1) * X0Mat * PhiMat(:, :, t, 1)' /p(1);
                    for i = 1 : t - 1
                        Q(:, :, j, t) = Q(:, :, j, t) + PhiMat(:, :, t, i + 1) * BMat * PMat * BMat' * PhiMat(:, :, t, i + 1)'/p(i + 1);
                    end
                    Q(:, :, j, t) = Q(:, :, j, t) * sum(p);
                end
            end
            
            result = zeros(3, T);
            ObtainedValues = get_ea(rs);
            for i = 1 : 3
                directions = GoodDirections{i};
                for j = 1 : T
                    l = directions(:, j);
                    Approximation = ObtainedValues(i, j);
                    [qq QQ] = double(Approximation);
                    result(i, j) = (abs((l' * QQ * l) -(l' * Q(:, :, i, j) * l)) < 0.001);
                end
            end
            isOk = all(result(:));
            
            k0 = 1;
            T = 5;

            AMat = {'1', 'cos(t)', '0'; '1 - 1/t^2', '2', 'sin(t)'; '0', '1', '1'};
            BMat = [3 2 1; 0 0 1; 2 1 1];
            X0Mat = [5 1 0; 1 4 1; 0 1 3];
            x0Vec = [0, 0, 0]';
            X0 = ellipsoid(x0Vec, X0Mat);
            PMat = eye(3);
            PVec = [1 0 1]';
            PEll = ellipsoid(PVec, PMat);
            LMat = eye(3);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');

            rs = reach(system, X0, LMat, [k0, T]);

            PhiMat = zeros(3, 3, T, T);
            for i = 1 : T
                PhiMat(:, :, i, i) = eye(3);
            end

            AMatArray = zeros(3, 3, T);
            for t = 1 : T
                for i = 1 : 3
                    for j = 1 : 3
                        AMatArray(i, j, t) = eval(AMat{i, j});
                    end
                end
            end
            for i = 1 : T
                for j = i + 1 : T
                    PhiMat(:, :, j, i) = AMatArray(:, :, j - 1) * PhiMat(:, :, j - 1, i);
                end
            end

            q = zeros(3, 3, T);
            Q = zeros(3, 3, 3, T);

            GoodDirections = get_directions(rs);

            % цикл по направлениям
            for j = 1 : 3
                % цикл по времени

                Q(:, :, j, 1) = X0Mat;
                L = GoodDirections{j};
                for t = 2 : T
                    l = L(:, t);
                    p = zeros(T, 1);
                    p(1) = sqrt(l' * PhiMat(:, :, t, 1) * X0Mat * PhiMat(:, :, t, 1)' * l);
                    for i = 1 : t - 1
                        p(i + 1) = sqrt(l'* PhiMat(:, :, t, i+1) * BMat * PMat * BMat' * PhiMat(:, :, t, i+1)' *l);
                    end

                    Q(:, :, j, t) = PhiMat(:, :, t, 1) * X0Mat * PhiMat(:, :, t, 1)' /p(1);
                    for i = 1 : t - 1
                        Q(:, :, j, t) = Q(:, :, j, t) + PhiMat(:, :, t, i + 1) * BMat * PMat * BMat' * PhiMat(:, :, t, i + 1)'/p(i + 1);
                    end
                    Q(:, :, j, t) = Q(:, :, j, t) * sum(p);
                end
            end
            
            result = zeros(3, T);
            ObtainedValues = get_ea(rs);
            for i = 1 : 3
                directions = GoodDirections{i};
                for j = 1 : T
                    l = directions(:, j);
                    Approximation = ObtainedValues(i, j);
                    [qq QQ] = double(Approximation);
                    result(i, j) = (abs((l' * QQ * l) -(l' * Q(:, :, i, j) * l)) < 0.1);
                end
            end
            isOk = isOk && all(result(:));
            
            mlunit.assert_equals(all(isOk(:)), true);
        end
        
        function self = testProjection(self)
            k0 = 1;
            T = 4;
            epsilon = 1;

            AMat = [3 0 1; 2 1 0; 0 3 2];
            BMat = [0 1 2; 0 3 2; 1 1 1];
            X0Mat = eye(3);
            x0Vec = [0, 0, 0]';
            X0 = ellipsoid(x0Vec, X0Mat);
            PMat = eye(3);
            PVec = [1 0 1]';
            PEll = ellipsoid(PVec, PMat);
            LMat = eye(3);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');

            rs = reach(system, X0, LMat, [k0, T]);
            
            ProjectionMatrix = [1/2^0.5 0 1/2^0.5; 0 1 0]';
            rs2 = projection(rs, ProjectionMatrix);
            initApproximation = get_ia(rs);
            finitApproximation = initApproximation;
            for i = 1 : 3
                for j = 1 : T
                   [q Q] = double(initApproximation(i, j));
                   finitApproximation(i, j) = ellipsoid(ProjectionMatrix' * q, ProjectionMatrix' * Q * ProjectionMatrix);
                end
            end
            obtainedApproximation = get_ia(rs2);
            isOk = 1;
            for i = 1 : 3
                for j = 1 : T
                    [q1 Q1] = double(finitApproximation(i, j));
                    [q2 Q2] = double(obtainedApproximation(i, j));
                    isOk = isOk && sum(abs(q1 - q2)) < epsilon;
                    result = abs(Q1 - Q2);
                    isOk = isOk && sum(result(:)) < epsilon;
                end
            end
            
            initApproximation = get_ea(rs);
            finitApproximation = initApproximation;
            for i = 1 : 3
                for j = 1 : T
                   [q Q] = double(initApproximation(i, j));
                   finitApproximation(i, j) = ellipsoid(ProjectionMatrix' * q, ProjectionMatrix' * Q * ProjectionMatrix);
                end
            end
            obtainedApproximation = get_ea(rs2);
            for i = 1 : 3
                for j = 1 : T
                    [q1 Q1] = double(finitApproximation(i, j));
                    [q2 Q2] = double(obtainedApproximation(i, j));
                    isOk = isOk && sum(abs(q1 - q2)) < epsilon;
                    result = abs(Q1 - Q2);
                    isOk = isOk && sum(result(:)) < epsilon;
                end
            end
            
            mlunit.assert_equals(isOk, true);
            
        end
        
        function self = testIntersect(self)
           k0 = 1;
            T = 5;

            AMat = [3 0 1; 2 1 0; 0 3 2];
            BMat = [0 1 2; 0 3 2; 1 1 1];
            X0Mat = eye(3);
            x0Vec = [0, 0, 0]';
            X0 = ellipsoid(x0Vec, X0Mat);
            PMat = eye(3);
            PVec = [1 0 1]';
            PEll = ellipsoid(PVec, PMat);
            LMat = eye(3);
            system = linsys(AMat, BMat, PEll, [], [], [], [], 'd');
            rs = reach(system, X0, LMat, [k0, T]);
            rs = projection(rs, [1 0 0; 0 1 0]');
            ell1 = ellipsoid([-200, -120]', 200*eye(2));
            ell2 = ellipsoid([-100, 250]', 100*eye(2));
            ell3 = ellipsoid([0, 0]', 100*eye(2));
            
            obtainedValues = zeros(2, 3);
            expectedValues = [1 0 1; 0 0 1];
            
            obtainedValues(1, 1) = intersect(rs, ell1, 'e');
            obtainedValues(1, 2) = intersect(rs, ell2, 'e');
            obtainedValues(1, 3) = intersect(rs, ell3, 'e');
            obtainedValues(2, 1) = intersect(rs, ell1, 'i');
            obtainedValues(2, 2) = intersect(rs, ell2, 'i');
            obtainedValues(2, 3) = intersect(rs, ell3, 'i');
           
            res = obtainedValues == expectedValues;
            isOk = all(res(:));

            hp1 = hyperplane([6, 4]', 5000);
            hp2 = hyperplane([-1, 1]', 3000);
            hp3 = hyperplane([-1, -1]', 100);

            obtainedValues = zeros(2, 3);
            obtainedValues(1, 1) = intersect(rs, hp1, 'e');
            obtainedValues(1, 2) = intersect(rs, hp2, 'e');
            obtainedValues(1, 3) = intersect(rs, hp3, 'e');
            obtainedValues(2, 1) = intersect(rs, hp1, 'i');
            obtainedValues(2, 2) = intersect(rs, hp2, 'i');
            obtainedValues(2, 3) = intersect(rs, hp3, 'i');
            
            res = obtainedValues == expectedValues;
            isOk = isOk && all(res(:));
            
            mlunit.assert_equals(isOk, true);            
        end
        
        function self = testEvolve(self)
            k0 = 1;
            T1 = 3;
            T2 = 5;
            epsilon = 0.1;
            
            AMat1 = [3 0 1; 2 1 0; 0 3 2];
            BMat1 = [0 1 2; 0 3 2; 1 1 1];
            X0Mat1 = eye(3);
            x0Vec1 = [0, 0, 0]';
            X01 = ellipsoid(x0Vec1, X0Mat1);
            PMat1 = eye(3);
            PVec1 = [1 0 1]';
            PEll1 = ellipsoid(PVec1, PMat1);
            
            AMat2 = [1 0 2; 2 1 2; -1 0 1];
            BMat2 = [0 1 0; 0 1 0; 3 2 1];
            PEll2 = 0.01 * ellipsoid([3 2 1]', [4 2 0; 2 4 0; 0 0 2]);
            system2 = linsys(AMat2, BMat2, PEll2, [], [], [], [], 'd');
            
            LMat = eye(3);
            system1 = linsys(AMat1, BMat1, PEll1, [], [], [], [], 'd');
            rs = reach(system1, X01, LMat, [k0, T1]);
            obtainedRS = evolve(rs, T2);
            expectedRS = reach(system1, X01, LMat, [k0, T2]);
            
            isOk = 1;
            expectedApprox = get_ia(expectedRS);
            obtainedApprox = get_ia(obtainedRS);
            for i = 1 : 3
                for j = T1 : T2
                    [q1 Q1] = double(expectedApprox(i, j));
                    [q2 Q2] = double(obtainedApprox(i, j - T1 + 1));
                    isOk = isOk && max(abs(q1 - q2)) < epsilon;
                    res = abs(Q1 - Q2);
                    isOk = isOk && max(res(:)) < epsilon;
                end
            end
            
            expectedApprox = get_ea(expectedRS);
            obtainedApprox = get_ea(obtainedRS);
            for i = 1 : 3
                for j = T1 : T2
                    [q1 Q1] = double(expectedApprox(i, j));
                    [q2 Q2] = double(obtainedApprox(i, j - T1 + 1));
                    isOk = isOk && max(abs(q1 - q2)) < epsilon;
                    res = abs(Q1 - Q2);
                    isOk = isOk && max(res(:)) < epsilon;
                end
            end
            
            
            obtainedRS = evolve(rs, T2, system2);
            obtainedApprox = get_ia(obtainedRS);
            initApprox = get_ia(rs);
            
            for i = 1 : 3
                EvolvingRS = reach(system2, initApprox(i, T1), LMat(:, i), [T1 T2]);
                expectedApprox = get_ia(EvolvingRS);
                for j = 1 : T2 - T1 + 1
                    [q1 Q1] = double(expectedApprox(1, j));
                    [q2 Q2] = double(obtainedApprox(i, j));
                    isOk = isOk && max(abs(q1 - q2)) < epsilon;
                    res = abs(Q1 - Q2);
                    isOk = isOk && max(res(:))/max(abs(Q1(:))) < epsilon; 
                end
            end
            
            obtainedApprox = get_ea(obtainedRS);
            initApprox = get_ea(rs);
            
            for i = 1 : 3
                EvolvingRS = reach(system2, initApprox(i, T1), LMat(:, i), [T1 T2]);
                expectedApprox = get_ea(EvolvingRS);
                for j = 1 : T2 - T1 + 1
                    [q1 Q1] = double(expectedApprox(1, j));
                    [q2 Q2] = double(obtainedApprox(i, j));
                    isOk = isOk && max(abs(q1 - q2)) < epsilon;
                    res = abs(Q1 - Q2);
                    isOk = isOk && max(res(:))/max(abs(Q1(:))) < epsilon; 
                end
            end   
            mlunit.assert_equals(isOk, true);
        end
    end
end