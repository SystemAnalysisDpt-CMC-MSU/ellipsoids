classdef LinSysDiscrete < elltool.linsys.ALinSys
    %
    % Discrete linear system class of the Ellipsoidal Toolbox.
    %
    %
    % $Authors: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
    %           Ivan Menshikov  <ivan.v.menshikov@gmail.com> $    $Date: 2012 $
    %           Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: March-2012 $
    %           Igor Kitsenko <kitsenko@gmail.com> $              $Date: March-2013 $
    %           Peter Gagarinov <pgagarinov@gmail.com> $          $Date: June-2013 $ 
    %
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2012 $
    %
    methods (Access=protected)
        function typeStr=getSystemTypeDescr(~)
            typeStr='discrete-time system';
        end
        function varargout=getSystemParamStrList(~)
            varargout=cell(1,nargout);
            [varargout{:}] = deal('[k]','x[k+1]  =  ','  y[k]  =  ',' x[k]');
        end
    end
    %
    methods
        function self = LinSysDiscrete(varargin)
            %
            % LINSYSDISCRETE - constructor of discrete linear system object.
            %
            % Discrete-time linear system:
            %           x[k+1]  =  A[k] x[k]  +  B[k] u[k]  +  C[k] v[k]
            %
            % Input:
            %   regular:
            %       atInpMat: double[nDim, nDim]/cell[nDim, nDim] - matrix A.
            %
            %       btInpMat: double[nDim, kDim]/cell[nDim, kDim] - matrix B.
            %   optional:
            %       uBoundsEll: ellipsoid[1, 1]/struct[1, 1] - control bounds
            %           ellipsoid.
            %
            %       ctInpMat: double[nDim, lDim]/cell[nDim, lDim] - matrix G.
            %
            %       distBoundsEll: ellipsoid[1, 1]/struct[1, 1] - disturbance bounds
            %           ellipsoid.
            %
            %       discrFlag: char[1, 1] - if discrFlag set:
            %            'd' - to discrete-time linSys
            %            not 'd' - to continuous-time linSys.
            %
            % Output:
            %   self: elltool.linsys.LinSysDiscrete[1, 1] - discrete linear system.
            %
            % Example:
            %   for k = 1:20
            %      atMat = {'0' '1 + cos(pi*k/2)'; '-2' '0'};
            %      btMat =  [0; 1];
            %      uBoundsEllObj = ellipsoid(4);
            %      ctMat = [1; 0];
            %      distBounds = 1/(k+1);
            %      lsys = elltool.linsys.LinSysDiscrete(atMat, btMat,...
            %          uBoundsEllObj, ctMat,distBounds);
            %   end
            %
            self = self@elltool.linsys.ALinSys(varargin{:});
        end

    end
end