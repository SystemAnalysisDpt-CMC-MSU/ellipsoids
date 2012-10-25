classdef ReachTestCase < mlunit.test_case
    
    methods
        function self = ReachTestCase(varargin)
            self = self@mlunit.test_case(varargin{:});
        end
        
        % testing function reach(...)
        
        % \dot{x}(\tau) = A x(\tau), B = 0
        % T = [0 t]
        function self = testStationarySystemWithoutControl(self)
            
            global ellOptions;
            linsysAMat = eye(2);
            linsysBMat = zeros(2);
            configurationQMat = eye(2);
            controlBoundsUEll = ellipsoid(configurationQMat);
            stationaryLinsys =...
                linsys(linsysAMat, linsysBMat, controlBoundsUEll);
            initialSetEll = ellipsoid(configurationQMat);
            initialDirectionsMat = [1 0; 0 1];
            timeIntervalVec = [0 1];
            
            reachSet = reach(stationaryLinsys,...
                             initialSetEll,...
                             initialDirectionsMat,...
                             timeIntervalVec);
            externalApproximationMat = get_ea(reachSet);
            internalApproximationMat = get_ia(reachSet);
            
            %externalApproximationVec = cell(1, ellOptions.time_grid);
            %internalApproximationVec = cell(1, ellOptions.time_grid);
            externalApproximationVec = [];
            internalApproximationVec = [];
            timeGridVec = linspace(timeIntervalVec(1),...
                                   timeIntervalVec(2),...
                                   ellOptions.time_grid);
            for iTime = 1 : ellOptions.time_grid
                %externalApproximationVec(iTime) =...
                %    {ellipsoid(exp(2 * timeGridVec(iTime)) * eye(2))};
                %internalApproximationVec(iTime) =...
                %    {ellipsoid(exp(2 * timeGridVec(iTime)) * eye(2))};
                
                
                % changing size on each step is bad, but method with
                % cell array (commented) isn't work, because get_ea
                % returns not a cell array
                externalApproximationVec =...
                    [externalApproximationVec...
                    ellipsoid(exp(2 * timeGridVec(iTime)) * eye(2))];
                internalApproximationVec =...
                    [internalApproximationVec...
                    ellipsoid(exp(2 * timeGridVec(iTime)) * eye(2))];
            end
            
            % if you uncomment these two strings you will see
            % that approximations are not equal even under 1e-4:
            
            %externalApproximationVec(ellOptions.time_grid)
            %externalApproximation(1, ellOptions.time_grid)
            
            % rows of ea (or ia) are equal in this test,
            % because nothing depends on L0:
            ellOptions.abs_tol = 1e-4;
            
            externalApproximationEqualityVec =...
                externalApproximationVec == externalApproximationMat(1, :);
            internalApproximationEqualityVec =...
                internalApproximationVec == internalApproximationMat(1, :);
            testResult = all(externalApproximationEqualityVec) *...
                         all(internalApproximationEqualityVec);
            
            mlunit.assert_equals(1, testResult);
            
            ellOptions.abs_tol = 1e-7;
            %plot_ea(reachSet);
            %hold on;
            %plot_ia(reachSet);
            %mlunit.assert_equals();
            %display(externalApproximation);
        end
        
    end
    
end