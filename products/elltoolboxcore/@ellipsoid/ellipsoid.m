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
        function [ellMat] = ellipsoid(varargin)
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
            %   ellMat = Ellipsoid(centVecArray, shMatArray, 
            %       ['propName1', propVal1,...,'propNameN',propValN]) - 
            %       creates an array (possibly multidimensional) of 
            %       ellipsoids with centers centVecArray(:,dim1,...,dimn)
            %       and matrices shMatArray(:,:,dim1,...dimn) with
            %       properties if given.
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
            %       shMatArray: double [nDim, nDim] / 
            %           double [nDim, nDim, nDim1,...,nDimn] - 
            %           shape matrices array
            %
            %   Case2:
            %     regular:
            %       centVecArray: double [nDim,1] / 
            %           double [nDim, 1, nDim1,...,nDimn] - 
            %           centers array
            %       shMatArray: double [nDim, nDim] / 
            %           double [nDim, nDim, nDim1,...,nDimn] - 
            %           shape matrices array
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
            %   ellMat: ellipsoid [1,1] / ellipsoid [nDim1,...nDimn] - 
            %       ellipsoid with specified properties 
            %       or multidimensional array of ellipsoids.
            %
            % $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
            % $Copyright: The Regents of the University
            %   of California 2004-2008 $
            %
            % $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
            % $Author: Daniil Stepenskiy <reinkarn@gmail.com> $   $Date: Apr-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics and Cybernetics,
            %             Science, System Analysis Department 2012-2013 $
            %
            
            import modgen.common.throwerror;
            import modgen.common.checkvar;
            import modgen.common.checkmultvar;
            import gras.la.ismatsymm;
            
            neededPropNameList = {'absTol','relTol','nPlot2dPoints','nPlot3dPoints'};
            [absTolVal, relTolVal,nPlot2dPointsVal,nPlot3dPointsVal] =...
                elltool.conf.Properties.parseProp(varargin,neededPropNameList);
            
            if nargin == 0
                ellMat.center = [];
                ellMat.shape  = [];
                ellMat.absTol = absTolVal;
                ellMat.relTol = relTolVal;
                ellMat.nPlot2dPoints = nPlot2dPointsVal;
                ellMat.nPlot3dPoints = nPlot3dPointsVal;
                return;
            end
            
            if nargin == 1
                checkvar(varargin{1},@(x) isa(x,'double')&&isreal(x),...
                    'errorTag','wrongInput:imagArgs',...
                    'errorMessage','shape matrix must be real.');                
                shMatArray = varargin{1};                
                nShDims = ndims(shMatArray);
                shDimsVec(1:nShDims) = size(shMatArray);
                nShRows = shDimsVec(1);
                nShCols = shDimsVec(2);
                nCentRows = nShCols;
                nCentCols = 1;
                if (nShDims > 2)
                    centVecArray = zeros([nCentRows, shDimsVec(3:end)]);
                else
                    centVecArray = zeros(nCentRows, 1);
                end
                
            else
                checkmultvar(@(x,y) isa(x,'double') && isa(y,'double') &&...
                    isreal(x) && isreal(y),2,varargin{1},varargin{2},...
                    'errorTag','wrongInput:imagArgs',...
                    'errorMessage','center and shape matrix must be real.');
                centVecArray = varargin{1};
                shMatArray = varargin{2};
                nShDims = ndims(shMatArray);
                nCentDims = ndims(centVecArray);
                checkmultvar(...
                    @(x,y)(x==2&&y==2)||x==y+1, 2, nShDims, nCentDims,...
                    'errorTag','wrongInput',...
                    'errorMessage', ['center and shape matrix must ',...
                    'differ in dimensionality by 1.']);
                centDimsVec(1:nCentDims) = size(centVecArray);
                shDimsVec(1:nShDims) = size(shMatArray);
                checkmultvar(@(x,y)all(x==y), 2, centDimsVec(2:end),...
                    shDimsVec(3:end), 'errorTag','wrongInput',...
                    'errorMessage',...
                    'additional dimensions must agree');
                nCentRows = centDimsVec(1);            
                nCentCols = centDimsVec(2);                
                nShRows = shDimsVec(1);
                nShCols = shDimsVec(2);   
            end
            %
            checkmultvar('(x1==x2)&&(x3==x1)&&(x4==1||x5>2)',...
                5,nShRows,nShCols,nCentRows,nCentCols,nShDims,...
                'errorTag','wrongInput', 'errorMessage',...
                'center must be vector and dimesions must agree.');
            %
            
            if nShDims > 2
                ellMat(prod(shDimsVec(3:end))) = ellipsoid();
                arrayfun(@(iEll)fMakeEllipsoid(iEll), 1:numel(ellMat));                  
                ellMat = reshape(ellMat, [shDimsVec(3:end)]);
            else
                fMakeEllipsoid(1);
            end
            function fMakeEllipsoid(iEll)
                %shape matrix must be symmetric.');
                % We cannot just check the condition 'min(eig(Q)) < 0'
                % because the zero eigenvalue may be internally represented
                % as something like -10^(-15).
                import modgen.common.checkmultvar;
                checkmultvar(@(aMat, aAbsTolVal)gras.la.ismatsymm(aMat)...
                    &&gras.la.ismatposdef(aMat,aAbsTolVal,1), 2,...
                    shMatArray(:,:,iEll), absTolVal,...
                    'errorTag','wrongInput',...
                    'errorMessage', ['shape matrices must be symmetric',...
                    'and positive semi-definite']);
                ellMat(iEll).center = centVecArray(:,iEll);
                ellMat(iEll).shape = shMatArray(:,:,iEll);
                ellMat(iEll).absTol = absTolVal;
                ellMat(iEll).relTol = relTolVal;
                ellMat(iEll).nPlot2dPoints = nPlot2dPointsVal;
                ellMat(iEll).nPlot3dPoints = nPlot3dPointsVal;
            end
        end
    end
    
    
    methods(Static,Access = private)
        res = my_color_table(ch)
        regQMat = regularize(qMat,absTol)
        clrDirsMat = rm_bad_directions(q1Mat, q2Mat, dirsMat,absTol)
        isBadDirVec = isbaddirectionmat(q1Mat, q2Mat, dirsMat,absTol)
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
