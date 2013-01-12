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
            system = linsys(AMat, BMat, PEll, [], [], [], [], [], 'd');
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
            system = linsys(AMat, BMat, PEll, [], [], [], [], [], 'd');
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
        
        function self = testIsEmpty(self)
            AMat = eye(3);
            BMat = ones(3);
            PEll = ell_unitball(3);
            systemVec = [linsys(), ...
                         linsys([], [], []),...
                         linsys(AMat, BMat, PEll)];
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
        
    end
end