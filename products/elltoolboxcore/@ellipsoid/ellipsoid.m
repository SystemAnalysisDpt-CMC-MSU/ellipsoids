classdef ellipsoid < elltool.core.AGenEllipsoid
    %ELLIPSOID class of ellipsoids
    properties (Access=private,Hidden)
        centerVec
        shapeMat
        absTol
        relTol
        nPlot2dPoints
        nPlot3dPoints
    end
    
    methods
        function set.shapeMat(self,shMat)
            import modgen.common.throwerror;
            if any(isnan(shMat(:)))
                throwerror('wrongInput',...
                    'configuration matrix cannot contain NaN values');
            end
            self.shapeMat=shMat;
        end
    end
    %
    methods (Access=private)
        function checkIfScalar(self,errMsg)
            if nargin<2
                errMsg='input argument must be single ellipsoid.';
            end
            modgen.common.checkvar(self,'isscalar(x)',...
                'errorMessage',errMsg);
        end
    end
    methods
        function resArr=repMat(self,varargin)
            % REPMAT - is analogous to built-in repmat function with one exception - it
            %          copies the objects, not just the handles
            %
            % Example:
            %   firstEllObj = ellipsoid([1; 2], eye(2));
            %   secEllObj = ellipsoid([1; 1], 2*eye(2));
            %   ellVec = [firstEllObj secEllObj];
            %   repMat(ellVec)
            %
            %   ans =
            %   1x2 array of ellipsoids.
            %
            %
            % $Author: Peter Gagarinov <pgagarinov@gmail.com> $   $Date: 24-04-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics and Cybernetics,
            %             Science, System Analysis Department 2012-2013 $
            %
            %
            sizeVec=horzcat(varargin{:});
            resArr=repmat(self,sizeVec);
            resArr=resArr.getCopy();
        end
        %
        function shMat=getShapeMat(self)
            % GETSHAPEMAT - returns shapeMat matrix of given ellipsoid
            %
            % Input:
            %   regular:
            %      self: ellipsoid[1,1]
            %
            % Output:
            %   shMat: double[nDims,nDims] - shapeMat matrix of ellipsoid
            %
            % Example:
            %   ellObj = ellipsoid([1; 2], eye(2));
            %   getShapeMat(ellObj)
            %
            %   ans =
            %
            %        1     0
            %        0     1
            %
            % $Author: Peter Gagarinov <pgagarinov@gmail.com> $   $Date: 24-04-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics and Cybernetics,
            %             Science, System Analysis Department 2012-2013 $
            self.checkIfScalar();
            shMat=self.shapeMat;
        end
        %
        function centerVecVec=getCenterVec(self)
            % GETCENTERVEC - returns centerVec vector of given ellipsoid
            %
            % Input:
            %   regular:
            %      self: ellipsoid[1,1]
            %
            % Output:
            %   centerVecVec: double[nDims,1] - centerVec of ellipsoid
            %
            % Example:
            %   ellObj = ellipsoid([1; 2], eye(2));
            %   getCenterVec(ellObj)
            %
            %   ans =
            %
            %        1
            %        2
            %
            % $Author: Peter Gagarinov <pgagarinov@gmail.com> $   $Date: 24-04-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics and Cybernetics,
            %             Science, System Analysis Department 2012-2013 $
            self.checkIfScalar();
            centerVecVec=self.centerVec;
        end
    end
    methods
        function [ellMat] = ellipsoid(varargin)
            %
            % ELLIPSOID - constructor of the ellipsoid object.
            %
            %   Ellipsoid E = { x in R^n : <(x - q), Q^(-1)(x - q)> <= 1 }, with current
            %       "Properties". Here q is a vector in R^n, and Q in R^(nxn) is positive
            %       semi-definite matrix
            %
            %   ell = ELLIPSOID - Creates an empty ellipsoid
            %
            %   ell = ELLIPSOID(shMat) - creates an ellipsoid with shape matrix shMat,
            %       centered at 0
            %
            %	ell = ELLIPSOID(centVec, shMat) - creates an ellipsoid with shape matrix
            %       shMat and center centVec
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
            %
            %   properties:
            %       absTol: double [1,1] - absolute tolerance with default value 10^(-7)
            %       relTol: double [1,1] - relative tolerance with default value 10^(-5)
            %       nPlot2dPoints: double [1,1] - number of points for 2D plot with
            %           default value 200
            %       nPlot3dPoints: double [1,1] - number of points for 3D plot with
            %            default value 200.
            %
            % Output:
            %   ellMat: ellipsoid [1,1] / ellipsoid [nDim1,...nDimn] -
            %       ellipsoid with specified properties
            %       or multidimensional array of ellipsoids.
            %
            % Example:
            %   ellObj = ellipsoid([1 0 -1 6]', 9*eye(4));
            %
            % $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
            % $Copyright: The Regents of the University
            %   of California 2004-2008 $
            %
            % $Author: Guliev Rustam <glvrst@gmail.com> $
            % $Date: Dec-2012$
            % $Author: Daniil Stepenskiy <reinkarn@gmail.com> $   $Date: Apr-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics and and Computer Science,
            %             System Analysis Department 2012-2013 $
            %
            import modgen.common.throwerror;
            import modgen.common.checkvar;
            import modgen.common.checkmultvar;
            import gras.la.ismatsymm;
            %
            NEEDED_PROP_NAME_LIST = {'absTol','relTol',...
                'nPlot2dPoints','nPlot3dPoints'};
            [regParamList,propNameValList]=modgen.common.parseparams(...
                varargin,NEEDED_PROP_NAME_LIST);
            [absTolVal, relTolVal,nPlot2dPointsVal,nPlot3dPointsVal] =...
                elltool.conf.Properties.parseProp(propNameValList,...
                NEEDED_PROP_NAME_LIST);
            %
            nReg=numel(regParamList);
            if nReg == 0
                ellMat.centerVec = [];
                ellMat.shapeMat  = [];
                ellMat.absTol = absTolVal;
                ellMat.relTol = relTolVal;
                ellMat.nPlot2dPoints = nPlot2dPointsVal;
                ellMat.nPlot3dPoints = nPlot3dPointsVal;
            else
                if nReg == 1
                    checkvar(regParamList{1},@(x) isa(x,'double')&&isreal(x),...
                        'errorTag','wrongInput:imagArgs',...
                        'errorMessage','shapeMat matrix must be real.');
                    shMatArray = regParamList{1};
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
                    %
                else
                    checkmultvar(@(x,y) isa(x,'double') && isa(y,'double') &&...
                        isreal(x) && isreal(y),2,regParamList{1},regParamList{2},...
                        'errorTag','wrongInput:imagArgs',...
                        'errorMessage','centerVec and shapeMat matrix must be real.');
                    centVecArray = regParamList{1};
                    shMatArray = regParamList{2};
                    nShDims = ndims(shMatArray);
                    nCentDims = ndims(centVecArray);
                    checkmultvar(...
                        @(x,y)(x==2&&y==2)||x==y+1, 2, nShDims, nCentDims,...
                        'errorTag','wrongInput',...
                        'errorMessage', ['centerVec and shapeMat matrix must ',...
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
                    'centerVec must be vector and dimesions must agree.');
                %
                if nShDims > 2
                    ellMat(prod(shDimsVec(3:end))) = ellipsoid();
                    arrayfun(@(iEll)fMakeEllipsoid(iEll), 1:numel(ellMat));
                    if (nShDims > 3)
                        ellMat = reshape(ellMat, shDimsVec(3:end));
                    end
                else
                    fMakeEllipsoid(1);
                end
            end
            function fMakeEllipsoid(iEll)
                %shapeMat matrix must be symmetric.');
                % We cannot just check the condition 'min(eig(Q)) < 0'
                % because the zero eigenvalue may be internally represented
                % as something like -10^(-15).
                import modgen.common.checkmultvar;
                checkmultvar(@(aMat, aAbsTolVal)gras.la.ismatsymm(aMat)...
                    &&gras.la.ismatposdef(aMat,aAbsTolVal,1), 2,...
                    shMatArray(:,:,iEll), absTolVal,...
                    'errorTag','wrongInput:shapeMat',...
                    'errorMessage', ['shapeMat matrices must be symmetric',...
                    ' and positive semi-definite']);
                ellMat(iEll).centerVec = centVecArray(:,iEll);
                ellMat(iEll).shapeMat = shMatArray(:,:,iEll);
                ellMat(iEll).absTol = absTolVal;
                ellMat(iEll).relTol = relTolVal;
                ellMat(iEll).nPlot2dPoints = nPlot2dPointsVal;
                ellMat(iEll).nPlot3dPoints = nPlot3dPointsVal;
            end
        end
    end
    
    methods(Static)
        ellArr = fromRepMat(varargin)
        ellArr = fromStruct(SEllArr)
    end
    methods(Static,Access = private)
        res = my_color_table(ch)
        regQMat = regularize(qMat,absTol)
        clrDirsMat = rm_bad_directions(q1Mat, q2Mat, dirsMat,absTol)
        [isBadDirVec,pUniversalVec] = isbaddirectionmat(q1Mat, q2Mat,...
            dirsMat,absTol)
        [supArr, bpMat] = rhomat(ellShapeMat,ellCenterVec,absTol, dirsMat)
        [diffBoundMat, isPlotCenter3d] = calcdiffonedir(fstEll,secEll,...
            lMat,pUniversalVec,isGoodDirVec)
        [ bpMat, fMat] = ellbndr_3dmat(nPoints, cenVec, qMat,absTol)
        [ bpMat, fMat] = ellbndr_2dmat(nPoints, cenVec, qMat,absTol)
    end
    methods(Access = private)
        [propMat, propVal] = getProperty(hplaneMat,propName, fPropFun)
        [bpMat, fVec] = getGridByFactor(ellObj,factorVec)
        checkDoesContainArgs(ell,poly)
        doesContain = doesContainPoly(ellArr,polytope,varagin)
    end
    methods (Static)
        checkIsMe(someObj,varargin)
    end
    
    methods (Access=private)
        function isArrEq = isMatEqualInternal(self,aArr,bArr)
            % ISMATEQUALINTERNAL - returns isArrEq - logical 1(true) if
            %           multidimensional arrays aArr and bArr are equal,
            %           and logical 0(false) otherwise, comparing them
            %           using absTol and relTol fields of the object self
            %
            % Input:
            %   regular:
            %      self: ellipsoid[1,1]
            %      aArr: double[nDim1,nDim2,...,nDimk]
            %      bArr: double[nDim1,nDim2,...,nDimk]
            %
            % Output:
            %   isArrEq: logical[1,1]
            %
            %
            %
            % $Author: Victor Gribov <illuminati1606@gmail.com> $   $Date: 28-05-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics and Cybernetics,
            %             Science, System Analysis Department 2012-2013 $
            self.checkIfScalar();
            absTol = self.absTol;
            if any(abs(aArr(:))>absTol) || any(abs(bArr(:))>absTol)
                isArrEq = abs(2*(aArr-bArr)./(aArr+bArr));
                isArrEq = all(isArrEq(:)<=self.relTol);
            else
                isArrEq = true;
            end
        end
    end
    
    methods (Access = protected, Static)
        function SComp = formCompStruct(SEll, SFieldNiceNames, absTol, isPropIncluded)
            if (~isempty(SEll.shapeMat))
                SComp.(SFieldNiceNames.shapeMat) = gras.la.sqrtmpos(SEll.shapeMat, absTol);
            else
                SComp.(SFieldNiceNames.shapeMat) = [];
            end
            SComp.(SFieldNiceNames.centerVec) = SEll.centerVec;
            if (isPropIncluded)
                SComp.(SFieldNiceNames.absTol) = SEll.absTol;
                SComp.(SFieldNiceNames.relTol) = SEll.relTol;
                SComp.(SFieldNiceNames.nPlot2dPoints) = SEll.nPlot2dPoints;
                SComp.(SFieldNiceNames.nPlot3dPoints) = SEll.nPlot3dPoints;
            end
        end
    end
    
    
end
