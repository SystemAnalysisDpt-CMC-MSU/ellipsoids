classdef LinSysContinuous < elltool.linsys.ALinSys
    %
    % Continuous linear system class of the Ellipsoidal Toolbox.
    %
    %
    % $Authors: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
    %           Ivan Menshikov  <ivan.v.menshikov@gmail.com> $    $Date: 2012 $
    %           Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: March-2012 $
    %           Igor Kitsenko <kitsenko@gmail.com> $              $Date: March-2013 $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2012 $
    %
    properties (Constant, GetAccess = ?elltool.linsys.ALinSys)
        DISPLAY_PARAMETER_STRINGS = {'(t)', 'dx/dt  =  ',...
            ' y(t)  =  ', ' x(t)'}
    end
    %
    methods
        function self = LinSysContinuous(varargin)
            %
            % LINSYSCONTINUOUS - Constructor of continuous linear system object.
            %
            % Continuous-time linear system:
            %           dx/dt  =  A(t) x(t)  +  B(t) u(t)  +  G(t) v(t)
            %            y(t)  =  C(t) x(t)  +  w(t)
            %
            % Input:
            %   regular:
            %       atInpMat: double[nDim, nDim]/cell[nDim, nDim] - matrix A.
            %
            %       btInpMat: double[nDim, kDim]/cell[nDim, kDim] - matrix B.
            %
            %       uBoundsEll: ellipsoid[1, 1]/struct[1, 1] - control bounds 
            %             ellipsoid.
            %
            %       gtInpMat: double[nDim, lDim]/cell[nDim, lDim] - matrix G.
            %
            %       distBoundsEll: ellipsoid[1, 1]/struct[1, 1] - disturbance 
            %             bounds ellipsoid.
            %
            %       ctInpMat: double[mDim, nDim]/cell[mDim, nDim]- matrix C.
            %
            %       noiseBoundsEll: ellipsoid[1, 1]/struct[1, 1] - noise bounds
            %             ellipsoid.
            %
            %       discrFlag: char[1, 1] - if discrFlag set: 
            %              'd' - to discrete-time linSys, 
            %              not 'd' - to continuous-time linSys.
            %
            %
            % Output:
            %   self: elltool.linsys.LinSysContinuous[1, 1] - continuous linear 
            %             system.
            %
            % Example:
            %   aMat = [0 1; 0 0]; bMat = eye(2);
            %   SUBounds = struct();
            %   SUBounds.center = {'sin(t)'; 'cos(t)'};  
            %   SUBounds.shape = [9 0; 0 2];
            %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
            %
            self = self@elltool.linsys.ALinSys(varargin{:});
        end
        %
        function display(self)
           self.displayInternal()
        end
    end
end