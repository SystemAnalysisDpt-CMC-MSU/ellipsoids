classdef ellipsoid < handle
%ELLIPSOID class of ellipsoids
    properties (Access=private)
        center
        shape 
        absTol
        relTol 
        nPlot2dPoints
        nPlot3dPoints
    end
    
    methods
        function [E] = ellipsoid(varargin)
        % ELLIPSOID - constructor of the ellipsoid object.
        %
        %
        % Description:
        % ------------
        %
        %    
        %    E = ELLIPSOID              Creates an empty ellipsoid.
        %    E = ELLIPSOID(Q)           Creates an ellipsoid with shape matrix Q,
        %                               centered at 0.
        %    E = ELLIPSOID(q, Q)        Creates an ellipsoid with shape
        %                               matrix Q and center q.
        %    E = ELLIPSOID(q, Q, prop)  Creates an ellipsoid with shape matrix Q, center q and 
        %                               "Properties" prop. In other cases "Properties" are taken from
        %                               current values stored in elltool.conf.Properties
        %    As "Properties" we understand here such list of ellipsoid
        %    properties:
        %           absTol
        %           relTol 
        %           nPlot2dPoints
        %           nPlot3dPoints
        %
        %    Here q is a vector in R^n, and Q in R^(nxn) is positive semi-definite matrix.
        %    These parameters can be accessed by PARAMETERS(E) function call.
        %    Also, DIMENSION(E) function call returns the dimension of the space
        %    in which ellipsoid E is defined and the actual dimension of the ellipsoid;
        %    function ISDEGENERATE(E) checks if ellipsoid E is degenerate.
        %
        %
        % Output:
        % -------
        %
        %    E = { x : <(x - q), Q^(-1)(x - q)> <= 1 } - ellipsoid.
        %
        %
        % See also:
        % ---------
        %
        %    ELLIPSOID/CONTENTS.
        %

        %
        % Author:
        % -------
        %
        %    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
        %

          neededPropNameList = {'absTol','relTol','nPlot2dPoints','nPlot3dPoints'};
          [absTolVal, relTolVal,nPlot2dPointsVal,nPlot3dPointsVal] =  elltool.conf.Properties.parseProp(varargin,neededPropNameList);

          if nargin == 0
            E.center = [];
            E.shape  = [];
            E.absTol = absTolVal;
            E.relTol = relTolVal;
            E.nPlot2dPoints = nPlot2dPointsVal;
            E.nPlot3dPoints = nPlot3dPointsVal;
            return;
          end


          if nargin == 1
            Q      = real(varargin{1});
            [m, n] = size(Q);
            q      = zeros(n, 1);
            k      = n;
            l      = 1;
          else
            q      = real(varargin{1});
            Q      = real(varargin{2});
            [k, l] = size(q);
            [m, n] = size(Q);
          end

          if l > 1
            error('ELLIPSOID: center of an ellipsoid must be a vector.');
          end

          if (m ~= n) | (min(min((Q == Q'))) == 0)
            error('ELLIPSOID: shape matrix must be symmetric.');
          end

          % We cannot just check the condition 'min(eig(Q)) < 0'
          % because the zero eigenvalue may be internally represented
          % as something like -10^(-15).
          mev = min(eig(Q));
          if (mev < 0)
            %tol = n * norm(Q) * eps;
            tol = absTolVal;
            if abs(mev) > tol
              error('ELLIPSOID: shape matrix must be positive semi-definite.');
            end
          end
          if k ~= n
            error('ELLIPSOID: dimensions of the center and the shape matrix do not match.');
          end

          E.center = q;
          E.shape  = Q; 
          E.absTol = absTolVal;
          E.relTol = relTolVal;
          E.nPlot2dPoints = nPlot2dPointsVal;
          E.nPlot3dPoints = nPlot3dPointsVal;
        end
    end
    
    
    methods(Static,Access = private)
        res = my_color_table(ch)
        R = regularize(Q,absTol)
        LC = rm_bad_directions(Q1, Q2, L)
    end
    methods(Access = private)
        propValMat = getProperty(hplaneMat,propName)
        x = ellbndr_2d(E)
        x = ellbndr_3d(E)
    end
    
end