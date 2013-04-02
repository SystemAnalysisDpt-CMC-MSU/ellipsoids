classdef LinSysDiscrete < elltool.linsys.ALinSys
    %
    % Discrete linear system class of the Ellipsoidal Toolbox.
    %
    %
    % Constructor and data accessing functions:
    % -----------------------------------------
    %  LinSysContinuous  - Constructor of discrete linear system object.
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
    properties (Constant, Access = private)
        DISPLAY_PARAMETER_STRINGS = {'[k]', 'x[k+1]  =  ', ...
            '  y[k]  =  ', ' x[k]'}
    end
    
    methods (Static)
        function isDiscr = isdiscrete()
            %
            % See description of ISDISCRETE in ILinSys class.
            %
            isDiscr = true;
        end
    end
    
    methods
        function self = LinSysDiscrete(varargin)
            %
            % LINSYSDISCRETE - constructor of discrete linear
            %   system object.
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
            %   self: elltool.linsys.LinSysDiscrete[1, 1] -
            %       discrete linear system.
            %
            self = self@elltool.linsys.ALinSys(varargin{:});
        end
        
        function display(self)
            %
            % See description of DISPLAY in ILinSys class.
            %
            self.displayInternal(self.DISPLAY_PARAMETER_STRINGS)
        end
    end
end