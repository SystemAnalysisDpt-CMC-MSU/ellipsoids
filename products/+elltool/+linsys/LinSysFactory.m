classdef LinSysFactory
%
% Factory class of linear system objects of the Ellipsoidal Toolbox.
% 
% $Authors: Igor Kitsenko <kitsenko@gmail.com> $              
% $Date: March-2013 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2013 $
%
    methods(Static)
        function linSys = create(varargin)
%
            % CREATE - returns linear system object.
            %
            % Continuous-time linear system:
            %           dx/dt  =  A(t) x(t)  +  B(t) u(t)  +  C(t) v(t)
            %
            % Discrete-time linear system:
            %           x[k+1]  =  A[k] x[k]  +  B[k] u[k]  +  C[k] v[k]
            %
            % Input:
            %   regular:
            %       atInpMat: double[nDim, nDim]/cell[nDim, nDim] - matrix A.
            %
            %       btInpMat: double[nDim, kDim]/cell[nDim, kDim] - matrix B.
            %
            %       uBoundsEll: ellipsoid[1, 1]/struct[1, 1] - control bounds 
            %           ellipsoid.
            %
            %       ctInpMat: double[nDim, lDim]/cell[nDim, lDim] - matrix G.
            %
            %       distBoundsEll: ellipsoid[1, 1]/struct[1, 1] - disturbance bounds 
            %           ellipsoid.
            %
            %       discrFlag: char[1, 1] - if discrFlag set:
            %           'd' - to discrete-time linSys
            %           not 'd' - to continuous-time linSys.
            %
            % Output:
            %   linSys: elltool.linsys.LinSysContinuous[1, 1]/ 
            %       elltool.linsys.LinSysDiscrete[1, 1] - linear system.
            %
            % Examples:
            %   aMat = [0 1; 0 0]; bMat = eye(2);  
            %   SUBounds = struct();
            %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
            %   SUBounds.shape = [9 0; 0 2]; 
            %   sys = elltool.linsys.LinSysFactory.create(aMat, bMat,SUBounds);
            %
            if (nargin > 5)  && ischar(varargin{6}) && (varargin{6} == 'd')
                linSys = elltool.linsys.LinSysDiscrete(varargin{:});
            else
                linSys = elltool.linsys.LinSysContinuous(varargin{:});
            end
        end
    end
end