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
        
        
        
        function self = testGetGoodCurves(self)
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
        
        function self = testGetIA(self)
             
        end
    end
end