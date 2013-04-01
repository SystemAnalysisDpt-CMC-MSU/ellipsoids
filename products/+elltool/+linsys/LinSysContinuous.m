classdef LinSysContinuous < elltool.linsys.ALinSys
    %
    % Continuous linear system class of the Ellipsoidal Toolbox.
    %
    %
    % Constructor and data accessing functions:
    % -----------------------------------------
    %  LinSysContinuous  - Constructor of continuous linear system object.
    %  getAtMat          - Returns A matrix.
    %  getBtMat          - Returns B matrix.
    %  getUBoundsEll     - Returns control bounds ellipsoid.
    %  getGtMat          - Returns G matrix.
    %  getDistBoundsEll  - Returns disturbance bounds ellipsoid.
    %  getCtMat          - Returns C matrix.
    %  getNoiseBoundsEll - Returns noise bounds ellipsoid.
    %  dimension         - Returns state space dimension, number of inputs, number of
    %                      outputs and number of disturbance inputs.
    %  isempty           - Checks if the linear system object is empty.
    %  isdiscrete        - Returns 1 if linear system is discrete-time,
    %                      0 - if continuous-time.
    %  islti             - Returns 1 if the system is time-invariant, 0 - otherwise.
    %  hasdisturbance    - Returns 1 if unknown bounded disturbance is present,
    %                      0 - if there is no disturbance, or disturbance vector is fixed.
    %  hasnoise          - Returns 1 if unknown bounded noise at the output is present,
    %                      0 - if there is no noise, or noise vector is fixed.
    %  getAbsTol         - Returns array the same size as linsysArr with
    %                      values of absTol properties for each hyperplane in hplaneArr.
    %
    % Overloaded functions:
    % ---------------------
    %  display - Displays the details of linear system object.
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
    methods
        function self = LinSysContinuous(varargin)
            %
            % LINSYSCONTINUOUS - Constructor of continuous linear 
            %   system object.
            %
            % Continuous-time linear system:
            %           dx/dt  =  A(t) x(t)  +  B(t) u(t)  +  G(t) v(t)
            %            y(t)  =  C(t) x(t)  +  w(t)
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
            %   self: elltool.linsys.LinSysContinuous[1, 1] -
            %       continuous linear system.
            %
            self = self@elltool.linsys.ALinSys(varargin{:});
            self.isDiscr  = false;
        end
        
        function display(self)
            %
            % See description of DISPLAY in ILinSys class.
            %
            self.displayInternal(self)
        end
    end
end