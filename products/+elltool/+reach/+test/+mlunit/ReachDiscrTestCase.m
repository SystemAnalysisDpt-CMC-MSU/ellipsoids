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
        
        function self = testDisplay(self)
            system = linsys( eye(3), eye(3,4), ell_unitball(4), ...
                [], [], [], [], 'd');
            X0 = ellipsoid(zeros(3, 1), eye(3));
            L = eye(3);
            T = [0, 5];
            rs = reach(system, X0, L, T);
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
            N = 4;
            system = linsys( eye(N), eye(N,2), ell_unitball(2), ...
                [], [], [], [], 'd');
            X0 = ellipsoid(zeros(N, 1), eye(N));
            L = eye(N);
            T = [0, 5];
            rs = reach(system, X0, L, T);
            [d, n] = dimension(rs);
            isOk = n == N;
            isOk = isOk && (d == N);
            ProjectionDimension = 2;
            rsp = projection(rs, [1 0 0 0; 0 1 0 0]');
            [d, n] = dimension(rsp);
            isOk = isOk && (n == N);
            isOk = isOk && (d == ProjectionDimension);
            mlunitext.assert(isOk);
        end
        
        function self = testGetSystem(self)
            system1 = linsys( eye(3), eye(3,4), ell_unitball(4), ...
                [], [], [], [], 'd');
            rs1 = reach(system1, ...
                       ellipsoid(zeros(3, 1), eye(3)), ...
                       eye(3),...
                       [0, 5]);
            system2 = linsys(eye(4), eye(4, 2), ell_unitball(2), ...
                [], [], [], [], 'd');
            rs2 = reach(system2, ...
                        ellipsoid(ones(4, 1), eye(4)), ...
                        eye(4), ...
                        [0, 3]);
            isOk = system1 == get_system(rs1);
            isOk = isOk && (system2 == get_system(rs2));
            isOk = isOk && (get_system(rs1) ~= get_system(rs2));
            mlunitext.assert(isOk);
        end
        
        function self = testIsCut(self)
                       
        end
    end
end