classdef LinSysContinuousFactory
    %
    % Factory class of continuous linear system objects of
    % the Ellipsoidal Toolbox.
    %
    %
    %  create - Returns LinSysContinuous object.
    %
    % $Authors: Igor Kitsenko <kitsenko@gmail.com> $    $Date: March-2013 $
    % $Authors: Igor Kitsenko <pgagarinov@gmail.com> $  $Date: June-2013 $    
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2012 $
    %
    methods(Static)
        function linSys = create(varargin)
            %
            % CREATE returns continuous-time linear system object.
            %
            % Continuous-time linear system:
            %           dx/dt  =  A(t) x(t)  +  B(t) u(t)  +  C(t) v(t)
            %
            % Input:
            %   regular:
            %       atInpMat: double[nDim, nDim]/cell[nDim, nDim] -
            %           matrix A.
            %
            %       btInpMat: double[nDim, kDim]/cell[nDim, kDim] -
            %           matrix B.
            %
            %       uBoundsEll: ellipsoid[1, 1]/struct[1, 1] -
            %           control bounds ellipsoid.
            %
            %       ctInpMat: double[nDim, lDim]/cell[nDim, lDim] -
            %           matrix C.
            %
            %       distBoundsEll: ellipsoid[1, 1]/struct[1, 1] -
            %           disturbance bounds ellipsoid.
            %
            %       discrFlag: char[1, 1] - if discrFlag set:
            %           'd' - to discrete-time linSys
            %           not 'd' - to continuous-time linSys.
            %
            % Output:
            %   linSys: elltool.linsys.LinSysContinuous[1, 1] - 
            %       continuous-time linear system.
            %
            linSys = elltool.linsys.LinSysContinuous(varargin{:});
        end
    end
end