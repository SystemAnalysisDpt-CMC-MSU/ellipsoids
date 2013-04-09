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
        function [ell] = ellipsoid(varargin)
            %
            % ELLIPSOID - constructor of the ellipsoid object.
            %
            %   Ellipsoid E = { x in R^n : <(x - q), Q^(-1)(x - q)> <= 1 },
            %       with current "Properties"..
            %       Here q is a vector in R^n, and Q in R^(nxn) is positive
            %           semi-definite matrix
            %
            %   ell = ELLIPSOID - Creates an empty ellipsoid
            %
            %   ell = ELLIPSOID(shMat) - creates an ellipsoid with shape
            %       matrix shMat, centered at 0
            %
            %	ell = ELLIPSOID(centVec, shMat) - creates an ellipsoid with
            %       shape matrix shMat and center centVec
            %
            %   ell = ELLIPSOID(centVec, shMat, 'propName1', propVal1,...,
            %       'propNameN',propValN) - creates an ellipsoid with shape
            %       matrix shMat, center centVec and propName1 = propVal1,...,
            %       propNameN = propValN. In other cases "Properties"
            %       are taken from current values stored in
            %       elltool.conf.Properties.
            %
            %   These parameters can be accessed by DOUBLE(E) function call.
            %   Also, DIMENSION(E) function call returns the dimension of
            %   the space in which ellipsoid E is defined and the actual
            %   dimension of the ellipsoid; function ISEMPTY(E) checks if
            %   ellipsoid E is empty; function ISDEGENERATE(E) checks if
            %   ellipsoid E is degenerate.
            %
            % Input:
            %   Case1:
            %     regular:
            %       shMat: double [nDim, nDim] - shape matrix of an ellipsoid
            %
            %   Case2:
            %     regular:
            %       centVec: double [nDim,1] - center of an ellipsoid
            %       shMat: double [nDim, nDim] - shape matrix of an ellipsoid
            %
            %   properties:
            %       absTol: double [1,1] - absolute tolerance with default
            %           value 10^(-7)
            %       relTol: double [1,1] - relative tolerance with default
            %           value 10^(-5)
            %       nPlot2dPoints: double [1,1] - number of points for 2D plot
            %           with default value 200
            %       nPlot3dPoints: double [1,1] - number of points for 3D plot
            %           with default value 200.
            %
            % Output:
            %   ell: ellipsoid [1,1] - ellipsoid with specified properties.
            %
            % $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
            % $Copyright: The Regents of the University
            %   of California 2004-2008 $
            %
            % $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics and Cybernetics,
            %             Science, System Analysis Department 2012 $
            %
            
            import modgen.common.throwerror;
            import modgen.common.checkvar;
            import modgen.common.checkmultvar;
            import gras.la.ismatsymm;
            
            neededPropNameList = {'absTol','relTol','nPlot2dPoints','nPlot3dPoints'};
            [absTolVal, relTolVal,nPlot2dPointsVal,nPlot3dPointsVal] =...
                elltool.conf.Properties.parseProp(varargin,neededPropNameList);
            
            if nargin == 0
                ell.center = [];
                ell.shape  = [];
                ell.absTol = absTolVal;
                ell.relTol = relTolVal;
                ell.nPlot2dPoints = nPlot2dPointsVal;
                ell.nPlot3dPoints = nPlot3dPointsVal;
                return;
            end
            
            if nargin == 1
                checkvar(varargin{1},@(x) isa(x,'double')&&isreal(x),...
                    'errorTag','wrongInput:imagArgs',...
                    'errorMessage','shape matrix must be real.');
                shMat = varargin{1};
                [nShRows, nShCols] = size(shMat);
                centVec = zeros(nShCols, 1);
                nCentRows = nShCols;
                nCentCols = 1;
            else
                checkmultvar(@(x,y) isa(x,'double') && isa(y,'double') &&...
                    isreal(x) && isreal(y),2,varargin{1},varargin{2},...
                    'errorTag','wrongInput:imagArgs',...
                    'errorMessage','center and shape matrix must be real.');
                centVec = varargin{1};
                shMat = varargin{2};
                [nCentRows, nCentCols] = size(centVec);
                [nShRows, nShCols] = size(shMat);
            end
            
            checkmultvar('(x1==x2)&&(x3==x1)&&(x4==1)&& gras.la.ismatsymm(x5)',...
                5,nShRows,nShCols,nCentRows,nCentCols,shMat,...
                'errorTag','wrongInput', 'errorMessage',...
                'center must be vector and shape matrix must be symmetric.');
            % We cannot just check the condition 'min(eig(Q)) < 0'
            % because the zero eigenvalue may be internally represented
            % as something like -10^(-15).
            checkmultvar('gras.la.ismatposdef(x1,x2,1)',2,shMat, absTolVal,...
                'errorTag','wrongInput','errorMessage',...
                'shape matrix must be positive semi-definite.');
            ell.center = centVec;
            ell.shape  = shMat;
            ell.absTol = absTolVal;
            ell.relTol = relTolVal;
            ell.nPlot2dPoints = nPlot2dPointsVal;
            ell.nPlot3dPoints = nPlot3dPointsVal;
        end
    end
    
    
    methods(Static,Access = private)
        res = my_color_table(ch)
        regQMat = regularize(qMat,absTol)
        clrDirsMat = rm_bad_directions(q1Mat, q2Mat, dirsMat,absTol)
        [isBadDirVec,pUniversal] = isbaddirectionmat(q1Mat, q2Mat, dirsMat,absTol)
    end
    methods (Static,Access = public)
        [supArr, bpMat] = rhomat(ellShapeMat,ellCenterVec,absTol, dirsMat)
        [lGetGrid, fGetGrid] = calcGrid(nDim,nPlotPoints,sphereTriang)
        [diffBoundMat, isPlotCenter3d] = calcdiffonedir(fstEll,secEll,lMat,pUniversalVec,isGoodDirVec)
    end
    methods(Access = private)
        [propMat, propVal] = getProperty(hplaneMat,propName, fPropFun)
        x = ellbndr_2d(E)
        x = ellbndr_3d(E)
    end
    methods (Static)
        checkIsMe(someObj,varargin)
    end
end
