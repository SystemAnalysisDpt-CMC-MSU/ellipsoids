classdef AReach < elltool.reach.IReach
    % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: March-2013 $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2013 $
    %
    properties (Constant, GetAccess = protected)
        MIN_EIG_Q_REG_UNCERT = 0.1
        EXTERNAL_SCALE_FACTOR = 1.02
        INTERNAL_SCALE_FACTOR = 0.98
        DEFAULT_INTAPX_S_SELECTION_MODE = 'volume'
        COMP_PRECISION = 5e-3
        FIELDS_NOT_TO_COMPARE = {'LT_GOOD_DIR_MAT'; ...
            'LT_GOOD_DIR_NORM_VEC'; 'LS_GOOD_DIR_NORM'; ...
            'LS_GOOD_DIR_VEC';' IND_S_TIME';...
            'S_TIME'; 'TIME_VEC'};
    end
    %
    properties (Access = protected)
        absTol
        relTol
        nPlot2dPoints
        nPlot3dPoints
        nTimeGridPoints
        switchSysTimeVec
        x0Ellipsoid
        linSysCVec
        isCut
        isProj
        isBackward
        projectionBasisMat
        ellTubeRel
    end
    %
    properties (Constant, Access = private)
        EXTERNAL = 'e'
        INTERNAL = 'i'
        UNION = 'u'
    end
    %
    methods (Static, Access = protected)
        function [propArr, propVal] = getProperty(rsArr,propName,fPropFun)
            % GETPROPERTY gives array the same size as rsArray with values
            % of propName properties for each reach set in rsArr.
            % Private method, used in every public property getter.
            %
            % Input:
            %   regular:
            %       rsArray:reach[nDims1, nDims2,...] - multidimension array
            %           of reach sets propName: char[1,N] - name property
            %   optional:
            %       fPropFun: function_handle[1,1] - function that apply
            %           to the propArr. The default is @min.
            %
            % Output:
            %   regular:
            %       propArr: double[nDim1, nDim2,...] - multidimension array of
            %           propName properties for ellipsoids in rsArr
            %   optional:
            %       propVal: double[1, 1] - return result of work fPropFun with
            %           the propArr
            %
            % $Author: Zakharov Eugene  <justenterrr@gmail.com> $
            %   $Date: 17-november-2012$
            % $Author: Grachev Artem  <grachev.art@gmail.com> $
            %   $Date: March-2013$
            % $Copyright: Moscow State University,
            %            Faculty of Computational Arrhematics
            %               and Computer Science,
            %            System Analysis Department 2012 $
            %
            import modgen.common.throwerror;
            propNameList = {'absTol','relTol','nPlot2dPoints',...
                'nPlot3dPoints','nTimeGridPoints'};
            if ~any(strcmp(propName,propNameList))
                throwerror('wrongInput',[propName,':no such property']);
            end
            %
            if nargin == 2
                fPropFun = @min;
            end
            
            propArr= arrayfun(@(x)x.(propName),rsArr);
            
            if nargout == 2
                propVal = fPropFun(propArr(:));
            end
            
        end
        %
        function [absTolArr, absTolVal] = getAbsTol(rsArr, varargin)
            % GETABSTOL - gives the array of absTol for all elements in rsArr
            %
            % Input:
            %   regular:
            %       rsArr: elltool.reach.ReachDiscrete[nDim1, nDim2, ...] -
            %           multidimension array of reach sets
            %   optional
            %       fAbsTolFun: function_handle[1,1] - function that apply
            %           to the absTolArr. The default is @min.
            %
            % Output:
            %   regular:
            %       absTolArr: double [absTol1, absTol2, ...] - return absTol
            %           for each element in rsArr
            %   optional:
            %       absTol: double[1,1] - return result of work fAbsTolFun
            %           with the absTolArr
            %
            % Usage:
            %   use [~,absTol] = rsArr.getAbsTol() if you want get only
            %       absTol,
            %   use [absTolArr,absTol] = rsArr.getAbsTol() if you want get
            %       absTolArr and absTol,
            %   use absTolArr = rsArr.getAbsTol() if you want get only
            %       absTolArr
            %
            %$Author: Zakharov Eugene  <justenterrr@gmail.com> $
            % $Author: Grachev Artem  <grachev.art@gmail.com> $
            %   $Date: March-2013$
            % $Copyright: Moscow State University,
            %            Faculty of Computational Arrhematics
            %            and Computer Science,
            %            System Analysis Department 2013 $
            %
            
            [absTolArr,absTolVal]=rsArr.getProperty('absTol',varargin{:});
            
        end
        %
        function nPlot2dPointsArr = getNPlot2dPoints(rsArr)
            % GETNPLOT2DPOINTS gives array  the same size as rsArr of value of
            % nPlot2dPoints property for each element in rsArr - array of reach sets
            %
            % Input:
            %   regular:
            %       rsArr:reach[nDims1,nDims2,...] - reach set array
            %
            % Output:
            %   nPlot2dPointsArr:double[nDims1,nDims2,...]- array of values of nTimeGridPoints
            %                                         property for each reach set in
            %                                         rsArr
            %
            % $Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Arrhematics and Computer Science,
            %            System Analysis Department 2012 $
            %
            nPlot2dPointsArr =...
                elltool.reach.ReachDiscrete.getProperty(rsArr,'nPlot2dPoints');
        end
        %
        function nPlot3dPointsArr = getNPlot3dPoints(rsArr)
            % GETNPLOT3DPOINTS gives array  the same size as rsArr of value of
            % nPlot3dPoints property for each element in rsArr - array of reach sets
            %
            % Input:
            %   regular:
            %       rsArr:reach[nDims1,nDims2,...] - reach set array
            %
            % Output:
            %   nPlot3dPointsArr:double[nDims1,nDims2,...]- array of values of nPlot3dPoints
            %                                         property for each reach set in
            %                                         rsArr
            %
            % $Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Arrhematics and Computer Science,
            %            System Analysis Department 2012 $
            %
            nPlot3dPointsArr =...
                elltool.reach.ReachDiscrete.getProperty(rsArr,'nPlot3dPoints');
        end
        %
        function nTimeGridPointsArr = getNTimeGridPoints(rsArr)
            % GETNTIMEGRIDPOINTS gives array  the same size as rsArr of value of
            % nTimeGridPoints property for each element in rsArr - array of reach sets
            %
            % Input:
            %   regular:
            %       rsArr:reach[nDims1,nDims2,...] - reach set array
            %
            % Output:
            %   nTimeGridPointsArr:double[nDims1,nDims2,...]- array of values of nTimeGridPoints
            %                                         property for each reach set in
            %                                         rsArr
            %
            % $Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Arrhematics and Computer Science,
            %            System Analysis Department 2012 $
            %
            nTimeGridPointsArr =...
                elltool.reach.ReachDiscrete.getProperty(rsArr,'nTimeGridPoints');
        end
        %
        function [relTolArr, relTolVal] = getRelTol(rsArr, varargin)
            % GETRELTOL - gives the array of relTol for all elements in ellArr
            %
            % Input:
            %   regular:
            %       rsArr: elltool.reach.ReachDiscrete[nDim1, nDim2, ...] -
            %           multidimension array of reach sets.
            %   optional
            %       fRelTolFun: function_handle[1,1] - function that apply
            %           to the relTolArr. The default is @min.
            %
            % Output:
            %   regular:
            %       relTolArr: double [relTol1, relTol2, ...] - return relTol
            %           for each element in rsArr
            %   optional:
            %       relTol: double[1,1] - return result of work fRelTolFun
            %           with the relTolArr
            %
            % Usage:
            %   use [~,relTol] = rsArr.getRelTol() if you want get only
            %       relTol,
            %   use [relTolArr,relTol] = rsArr.getRelTol() if you want get
            %       relTolArr and relTol,
            %   use relTolArr = rsArr.getRelTol() if you want get only
            %        relTolArr
            %
            %$Author: Zakharov Eugene  <justenterrr@gmail.com> $
            % $Author: Grachev Artem  <grachev.art@gmail.com> $
            %   $Date: March-2013$
            % $Copyright: Moscow State University,
            %            Faculty of Computational Arrhematics
            %            and Computer Science,
            %            System Analysis Department 2013 $
            %
            
            [relTolArr,relTolVal]=rsArr.Property('relTol',varargin{:});
        end
    end
    %
    methods (Access = protected)
        function projSet = getProjSet(self, projMat,...
                approxType, scaleFactor)
            import gras.ellapx.enums.EProjType;
            import gras.ellapx.smartdb.F;
            APPROX_TYPE = F.APPROX_TYPE;
            fProj =...
                @(~, timeVec, varargin)...
                deal(repmat(projMat.', [1 1 numel(timeVec)]),...
                repmat(projMat, [1 1 numel(timeVec)]));
            ProjCMatList = {projMat'};
            projType = EProjType.Static;
            if nargin > 2
                localEllTubeRel =...
                    self.ellTubeRel.getTuplesFilteredBy(...
                    APPROX_TYPE, approxType);
            else
                localEllTubeRel = self.ellTubeRel;
            end
            if nargin == 4
                localEllTubeRel.scale(@(x) scaleFactor, {APPROX_TYPE});
            end
            projSet = localEllTubeRel.project(projType,...
                ProjCMatList, fProj);
        end
        %
        function plotter = plotApprox(self, approxType, varargin)
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            import gras.ellapx.smartdb.F;
            APPROX_TYPE = F.APPROX_TYPE;
            DEFAULT_EA_COLOR_VEC = [0 0 1];
            DEFAULT_IA_COLOR_VEC = [0 1 0];
            DEFAULT_LINE_WIDTH = 2;
            DEFAULT_EA_SHADE = 0.3;
            DEFAULT_IA_SHADE = 0.1;
            DEFAULT_FILL = 0;
            %
            if approxType == EApproxType.External
                colorVec = DEFAULT_EA_COLOR_VEC;
                shade = DEFAULT_EA_SHADE;
                scaleFactor = self.EXTERNAL_SCALE_FACTOR;
            else
                colorVec = DEFAULT_IA_COLOR_VEC;
                shade = DEFAULT_IA_SHADE;
                scaleFactor = self.INTERNAL_SCALE_FACTOR;
            end
            lineWidth = DEFAULT_LINE_WIDTH;
            fill = DEFAULT_FILL;
            if nargin > 4
                throwerror('wrongInput', 'Too many arguments.');
            elseif nargin == 3
                if ischar(varargin{1})
                    colorVec = self.getColorVec(varargin{1});
                elseif isstruct(varargin{1})
                    ColorOpt = varargin{1};
                    setPlotParams(ColorOpt);
                else
                    throwerror('wrongInput', 'Wrong argument format.');
                end
            elseif nargin == 4
                if isstruct(varargin{2})
                    ColorOpt = varargin{2};
                    setPlotParams(ColorOpt);
                else
                    throwerror('wrongInput', 'Wrong argument format.');
                end
                if ischar(varargin{1})
                    colorVec = self.getColorVec(varargin{1});
                else
                    throwerror('wrongInput', 'Wrong argument format.');
                end
            end
            %
            if ~ismatrix(colorVec)
                throwerror('wrongInput', 'Wrong field format ("color")');
            else
                [nRows nCols] = size(colorVec);
                if nRows ~= 1 || nCols ~= 3
                    throwerror('wrongInput',...
                        'Wrong field format ("color")');
                end
            end
            if ~isa(lineWidth, 'double')
                throwerror('wrongInput', 'Wrong field format ("width")');
            end
            if ~isa(shade, 'double')
                throwerror('wrongInput', 'Wrong field format ("shade")');
            else
                if shade < 0 || shade > 1
                    throwerror('wrongInput',...
                        'Wrong field format ("shade")');
                end
            end
            if ~isa(fill, 'double')
                throwerror('Wrong field format ("fill")');
            end
            %
            if self.isProj
                if self.ellTubeRel.dim() > 3
                    throwerror('wrongData',...
                        'Dimension of the projection must be leq 3');
                else
                    plObj = smartdb.disp.RelationDataPlotter();
                    plotter = self.ellTubeRel.getTuplesFilteredBy(...
                        APPROX_TYPE, approxType).plot(plObj,...
                        'fGetTubeColor', @(x) deal(colorVec, shade));
                end
            else
                if self.dimension() > 2
                    projBasisMat = eye(self.dimension(), 2);
                else
                    projBasisMat = eye(self.dimension());
                end
                plObj = smartdb.disp.RelationDataPlotter();
                projSetObj = self.getProjSet(projBasisMat,...
                    approxType, scaleFactor);
                plotter = projSetObj.plot(plObj, 'fGetTubeColor',...
                    @(x) deal(colorVec, shade));
            end
            %
            function setPlotParams(ColorOpt)
                if isfield(ColorOpt, 'color')
                    colorVec = ColorOpt.color;
                end
                if isfield(ColorOpt, 'width')
                    lineWidth = ColorOpt.width;
                end
                if isfield(ColorOpt, 'shade')
                    shade = ColorOpt.shade;
                end
                if isfield(ColorOpt, 'fill')
                    fill = ColorOpt.fill;
                end
            end
        end
        %
        function [apprEllMat timeVec] = getApprox(self, approxType)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.smartdb.F;
            APPROX_TYPE = F.APPROX_TYPE;
            SData = self.ellTubeRel.getTuplesFilteredBy(APPROX_TYPE,...
                approxType);
            nTuples = SData.getNTuples();
            if nTuples > 0
                nTimes = numel(SData.timeVec{1});
                for iTuple = nTuples : -1 : 1
                    tupleCentMat = SData.aMat{iTuple};
                    tupleMatArray = SData.QArray{iTuple};
                    for jTime = nTimes : -1 : 1
                        apprEllMat(iTuple, jTime) =...
                            ellipsoid(tupleCentMat(:, jTime),...
                            tupleMatArray(:, :, jTime));
                    end
                end
            else
                apprEllMat = [];
            end
            if nargout > 1
                timeVec = SData.timeVec{1};
            end
        end
        %
        function displayInternal(self)
            import gras.ellapx.enums.EApproxType;
            fprintf('\n');
            disp([inputname(1) ' =']);
            if self.isempty()
                fprintf('Empty reach set object.\n\n');
                return;
            end
            [sysTypeStr sysTimeStartStr sysTimeEndStr] = ...
                self.DISPLAY_PARAMETER_STRINGS{:};
            dim = self.dimension();
            timeVec =...
                [self.switchSysTimeVec(1) self.switchSysTimeVec(end)];
            if timeVec(1) > timeVec(end)
                isBack = true;
                fprintf(['Backward reach set of the %s linear system ',...
                    'in R^%d in the time interval [%d, %d].\n'],...
                    sysTypeStr, dim, timeVec(1), timeVec(end));
            else
                isBack = false;
                fprintf(['Reach set of the %s linear system ',...
                    'in R^%d in the time interval [%d, %d].\n'],...
                    sysTypeStr, dim, timeVec(1), timeVec(end));
            end
            if self.isprojection()
                fprintf('Projected onto the basis:\n');
                disp(self.projectionBasisMat);
            end
            fprintf('\n');
            if isBack
                fprintf('Target set at time %s%d:\n',...
                    sysTimeEndStr, timeVec(1));
            else
                fprintf('Initial set at time %s%d:\n',...
                    sysTimeStartStr, timeVec(1));
            end
            disp(self.getInitialSet());
            fprintf('Number of external approximations: %d\n',...
                sum(self.ellTubeRel.approxType == EApproxType.External));
            fprintf('Number of internal approximations: %d\n',...
                sum(self.ellTubeRel.approxType == EApproxType.Internal));
            fprintf('\n');
        end
    end
    methods
        function isProj = isprojection(self)
            isProj = self.isProj;
        end
        %
        function isCut = iscut(self)
            isCut = self.isCut;
        end
        %
        function isEmpty = isempty(self)
            isEmpty = isempty(self.x0Ellipsoid);
        end
        %
        function isEmptyIntersect =...
                intersect(self, intersectObj, approxTypeChar)
            if ~(isa(intersectObj, 'ellipsoid')) &&...
                    ~(isa(intersectObj, 'hyperplane')) &&...
                    ~(isa(intersectObj, 'polytope'))
                throwerror(['INTERSECT: first input argument must be ',...
                    'ellipsoid, hyperplane or polytope.']);
            end
            if (nargin < 3) || ~(ischar(approxTypeChar))
                approxTypeChar = self.EXTERNAL;
            elseif approxTypeChar ~= self.INTERNAL
                approxTypeChar = self.EXTERNAL;
            end
            if approxTypeChar == self.INTERNAL
                approxCVec = self.get_ia();
                isEmptyIntersect =...
                    intersect(approxCVec, intersectObj, self.UNION);
            else
                approxCVec = self.get_ea();
                approxNum = size(approxCVec, 2);
                isEmptyIntersect =...
                    intersect(approxCVec(:, 1),...
                    intersectObj, self.INTERNAL);
                for iApprox = 2 : approxNum
                    isEmptyIntersect =...
                        isEmptyIntersect |...
                        intersect(approxCVec(:, iApprox),...
                        intersectObj, self.INTERNAL);
                end
            end
        end
        %
        function isEqual = isEqual(self, reachObj, varargin)
            import gras.ellapx.smartdb.F;
            import gras.ellapx.enums.EApproxType;
            APPROX_TYPE = F.APPROX_TYPE;
            %
            ellTube = self.ellTubeRel;
            compEllTube = reachObj.ellTubeRel;
            %
            if nargin == 4
                ellTube = ellTube.getTuplesFilteredBy(APPROX_TYPE,...
                    varargin{2});
                ellTube = ellTube.getTuples(varargin{1});
                compEllTube = compEllTube.getTuplesFilteredBy(APPROX_TYPE,...
                    varargin{2});
            end
            %
            if ellTube.getNElems < compEllTube.getNElems
                compEllTube = compEllTube.getTuplesFilteredBy(...
                    'lsGoodDirNorm', 1);
            end
            %
            pointsNum = numel(ellTube.timeVec{1});
            newPointsNum = numel(compEllTube.timeVec{1});
            compTimeGridIndVec = 2 .* (1 : pointsNum) - 1;
            firstTimeVec = ellTube.timeVec{1};
            secondTimeVec = compEllTube.timeVec{1};
            if pointsNum ~= newPointsNum
                secondTimeVec = secondTimeVec(compTimeGridIndVec);
            end
            if max(abs(firstTimeVec - secondTimeVec) > self.COMP_PRECISION)
                compTimeGridIndVec = compTimeGridIndVec +...
                    double(compTimeGridIndVec > pointsNum);
            end
            fieldsNotToCompVec =...
                F.getNameList(self.FIELDS_NOT_TO_COMPARE);
            fieldsToCompVec =...
                setdiff(ellTube.getFieldNameList, fieldsNotToCompVec);
            
            if pointsNum ~= newPointsNum
                compEllTube =...
                    compEllTube.thinOutTuples(compTimeGridIndVec);
            end
            isEqual = compEllTube.getFieldProjection(...
                fieldsToCompVec).isEqual(...
                ellTube.getFieldProjection(fieldsToCompVec),...
                'maxTolerance', self.COMP_PRECISION);
        end
        %
        function linSys = get_system(self)
            linSys = self.linSysCVec{end}.getCopy();
        end
        %
        function [rSdim sSdim] = dimension(self)
            rSdim = self.linSysCVec{end}.dimension();
            if ~self.isProj
                sSdim = rSdim;
            else
                sSdim = size(self.projectionBasisMat, 2);
            end
            if nargout < 2
                clear('sSdim');
            end
        end
        %
        function [directionsCVec timeVec] = get_directions(self)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.smartdb.F;
            APPROX_TYPE = F.APPROX_TYPE;
            SData = self.ellTubeRel.getTuplesFilteredBy(APPROX_TYPE,...
                EApproxType.External);
            directionsCVec = SData.ltGoodDirMat.';
            if nargout > 1
                timeVec = SData.timeVec{1};
            end
        end
        %
        function [trCenterMat timeVec] = get_center(self)
            trCenterMat = self.ellTubeRel.aMat{1};
            if nargout > 1
                timeVec = self.ellTubeRel.timeVec{1};
            end
        end
        %
        function [eaEllMat timeVec] = get_ea(self)
            import gras.ellapx.enums.EApproxType;
            [eaEllMat timeVec] = self.getApprox(EApproxType.External);
        end
        %
        function [iaEllMat timeVec] = get_ia(self)
            import gras.ellapx.enums.EApproxType;
            [iaEllMat timeVec] = self.getApprox(EApproxType.Internal);
        end
        %
        function [goodCurvesCVec timeVec] = get_goodcurves(self)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.smartdb.F;
            APPROX_TYPE = F.APPROX_TYPE;
            SData = self.ellTubeRel.getTuplesFilteredBy(APPROX_TYPE,...
                EApproxType.External);
            goodCurvesCVec = SData.xTouchCurveMat.';
            if nargout > 1
                timeVec = SData.timeVec{1};
            end
        end
        %
        function eaScaleFactor = getEaScaleFactor(self)
            eaScaleFactor = self.EXTERNAL_SCALE_FACTOR;
        end
        %
        function iaScaleFactor = getIaScaleFactor(self)
            iaScaleFactor = self.INTERNAL_SCALE_FACTOR;
        end
        %
        function x0Ell = getInitialSet(self)
            x0Ell = self.x0Ellipsoid.getCopy();
        end
        %
        function isBackward = isbackward(self)
            isBackward = self.isBackward;
        end
        %
        function projObj = projection(self, projMat)
            import gras.ellapx.enums.EProjType;
            import modgen.common.throwerror;
            isOnesMat = flipud(sortrows(projMat)) == eye(size(projMat));
            isOk = all(isOnesMat(:));
            if ~isOk
                throwerror('wrongInput', ['Each column of projection ',...
                    'matrix should be a unit vector.']);
            end
            projSet = self.getProjSet(projMat);
            projObj = feval(class(self));
            projObj.switchSysTimeVec = self.switchSysTimeVec;
            projObj.x0Ellipsoid = self.x0Ellipsoid;
            projObj.ellTubeRel = projSet;
            projObj.linSysCVec = self.linSysCVec;
            projObj.isCut = self.isCut;
            projObj.isProj = true;
            projObj.isBackward = self.isbackward();
            projObj.projectionBasisMat = projMat;
        end
        %
        function eaPlotter = plot_ea(self, varargin)
            import gras.ellapx.enums.EApproxType;
            if nargin == 1
                eaPlotter =...
                    self.plotApprox(EApproxType.External);
            elseif nargin == 2
                eaPlotter =...
                    self.plotApprox(EApproxType.External, varargin{1});
            elseif nargin == 3
                eaPlotter = self.plotApprox(EApproxType.External,...
                    varargin{1}, varargin{2});
            end
        end
        %
        function iaPlotter = plot_ia(self, varargin)
            import gras.ellapx.enums.EApproxType;
            if nargin == 1
                iaPlotter =...
                    self.plotApprox(EApproxType.Internal);
            elseif nargin == 2
                iaPlotter =...
                    self.plotApprox(EApproxType.Internal, varargin{1});
            elseif nargin == 3
                iaPlotter = self.plotApprox(EApproxType.Internal,...
                    varargin{1}, varargin{2});
            end
        end
        %
        function copyReachObj = getCopy(self)
            copyReachObj = feval(class(self));
            copyReachObj.absTol = self.absTol;
            copyReachObj.relTol = self.relTol;
            copyReachObj.nPlot2dPoints = self.nPlot2dPoints;
            copyReachObj.nPlot3dPoints = self.nPlot3dPoints;
            copyReachObj.nTimeGridPoints = self.nTimeGridPoints;
            copyReachObj.switchSysTimeVec = self.switchSysTimeVec;
            copyReachObj.x0Ellipsoid = self.x0Ellipsoid.getCopy();
            copyReachObj.isCut = self.isCut;
            copyReachObj.isProj = self.isProj;
            copyReachObj.isBackward = self.isBackward;
            copyReachObj.projectionBasisMat = self.projectionBasisMat;
            copyReachObj.ellTubeRel = self.ellTubeRel.getCopy();
            %
            copyReachObj.linSysCVec{numel(self.linSysCVec)} = ...
                feval(class(self.linSysCVec{1}));
            arrayfun(@(index) fLinSysCopy(index), ...
                1:numel(self.linSysCVec));
            %
            function fLinSysCopy(index)
                copyReachObj.linSysCVec{index} = ...
                    self.linSysCVec{index}.getCopy();
            end
        end
    end
end