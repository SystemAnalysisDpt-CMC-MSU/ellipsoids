classdef ReachContinuousFactory
    %
    % Factory class of continuous reach set objects of
    % the Ellipsoidal Toolbox.
    %
    %
    %  create - Returns ReachContinuous object.
    %
    % $Authors: Igor Kitsenko <kitsenko@gmail.com> $              $Date: March-2013 $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2012 $
    %
    methods(Static)
        function reachObj = create(varargin)
            %
            % CREATE returns ReachContinuous object.
            %
            % Input:
            %   regular:
            %       linSys: elltool.linsys.LinSysContinuous object - 
            %           given continuous linear system
            %       x0Ell: ellipsoid[1, 1] - 
            %           ellipsoidal set of initial conditions
            %       l0Mat: matrix of double - l0Mat
            %       timeVec: double[1, 2] - time interval
            %           timeVec(1) must be less then timeVec(2)
            %       OptStruct: structure
            %           In this class OptStruct doesn't matter anything
            %
            % Output:
            %   reachObj: elltool.reach.ReachContinuous[1, 1] -
            %       continuous reach set object.
            %
            reachObj = elltool.reach.ReachContinuous(varargin{:});
        end
    end
end