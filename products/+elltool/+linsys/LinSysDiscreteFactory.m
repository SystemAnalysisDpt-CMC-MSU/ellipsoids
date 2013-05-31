classdef LinSysDiscreteFactory
    %
    % Factory class of discrete linear system objects of 
    % the Ellipsoidal Toolbox.
    %
    %
    %  create - Returns LinSysDiscrete object.
    %
    % $Authors: Igor Kitsenko <kitsenko@gmail.com> $              $Date: March-2013 $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2012 $
    %
    methods(Static)
        function linSys = create(varargin)
            %
            % CREATE returns discrete-time linear system object.
            %
            % Discrete-time linear system:
            %           x[k+1]  =  A[k] x[k]  +  B[k] u[k]  +  G[k] v[k]
            %             y[k]  =  C[k] x[k]  +  w[k]
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
            %       gtInpMat: double[nDim, lDim]/cell[nDim, lDim] -
            %           matrix G.
            %
            %       distBoundsEll: ellipsoid[1, 1]/struct[1, 1] -
            %           disturbance bounds ellipsoid.
            %
            %       ctInpMat: double[mDim, nDim]/cell[mDim, nDim]-
            %           matrix C.
            %
            %       noiseBoundsEll: ellipsoid[1, 1]/struct[1, 1] -
            %           noise bounds ellipsoid.
            %
            %       discrFlag: char[1, 1] - if discrFlag set:
            %           'd' - to discrete-time linSys
            %           not 'd' - to continuous-time linSys.
            %
            % Output:
            %   linSys: elltool.linsys.LinSysDiscrete[1, 1] - 
            %       discrete-time linear system.
            %
            linSys = elltool.linsys.LinSysDiscrete(varargin{:});
        end
    end
end