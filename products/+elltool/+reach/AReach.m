classdef AReach < elltool.reach.IReach
    % $Authors: Kirill Mayantsev <kirill.mayantsev@gmail.com> $
    %               $Date: March-2013 $
    %           Igor Kitsenko <kitsenko@gmail.com> $
    %               $Date: May-2013 $
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2013$
    %
    properties (Constant, GetAccess = protected)
        MIN_EIG_Q_REG_UNCERT = 0.1
        EXTERNAL_SCALE_FACTOR = 1.02
        INTERNAL_SCALE_FACTOR = 0.98
        DEFAULT_INTAPX_S_SELECTION_MODE = 'volume'
        COMP_PRECISION = 5e-3
        FIELDS_NOT_TO_COMPARE = {'LT_GOOD_DIR_MAT'; ...
            'LT_GOOD_DIR_NORM_VEC'; 'LS_GOOD_DIR_NORM'; ...
            'LS_GOOD_DIR_VEC';'IND_S_TIME';...
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
    methods (Access = private)
        function isArr = fApplyArrMethod(self,propertyName,addFunc)
            if nargin < 3
                isArr = arrayfun(@(x) x.(propertyName), self);
            else
                fApplyToProperty = str2func(addFunc);
                isArr = arrayfun(@(x) fApplyToProperty(x.(propertyName)), self);
            end
            %in case of empty input array make output logical
            isArr = logical(isArr);
        end
    end
    %
    methods (Static, Abstract, Access = protected)
        linSys = getProbDynamics(atStrCMat, btStrCMat, ...
            ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec, ...
            x0Mat, x0Vec, timeVec, calcPrecision, isDisturb)
        %
        newEllTubeRel = transformEllTube(ellTubeRel)
    end
    %
    methods (Abstract, Access = protected)
        ellTubeRel = makeEllTubeRel(self, probDynObj, l0Mat, ...
            timeVec, isDisturb, calcPrecision, approxTypeVec)
    end
    %
    methods (Static, Access = protected)
        function [propArr, propVal] = getProperty(rsArr,propName,fPropFun)
            % GETPROPERTY - gives array the same size as rsArray with values of
            %               propName properties for each reach set in rsArr.
            %               Private method, used in every public property getter.
            %
            %
            % Input:
            %   regular:
            %       rsArray: elltool.reach.ReachDiscrete [nDims1, nDims2,...] -
            %           multidimension array of reach sets
            %       propName: char[1,N] - name property
            %
            %   optional:
            %       fPropFun: function_handle[1,1] - function that apply to the propArr.
            %           The default is @min.
            %
            % Output:
            %   regular:
            %       propArr: double[nDim1, nDim2,...] -  multidimension array of properties
            %          for reach object in rsArr
            %   optional:
            %       propVal: double[1, 1] - return result of work fPropFun with the propArr
            %
            % $Author: Zakharov Eugene <justenterrr@gmail.com>$
            %   $Date: 17-november-2012$
            % $Author: Grachev Artem  <grachev.art@gmail.com> $
            %   $Date: March-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2013 $
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
            %       rsArr: elltool.reach.ReachDiscrete[nDim1, nDim2, ...] - multidimension
            %              array of reach sets
            %   optional:
            %       fAbsTolFun: function_handle[1,1] - function that apply to the absTolArr.
            %               The default is @min.
            %
            % Output:
            %   regular:
            %       absTolArr: double [absTol1, absTol2, ...] - return absTol for each
            %                 element in rsArr
            %   optional:
            %       absTol: double[1,1] - return result of work fAbsTolFun with the absTolArr
            %
            % Usage:
            %   use [~,absTol] = rsArr.getAbsTol() if you want get only absTol,
            %   use [absTolArr,absTol] = rsArr.getAbsTol() if you want get absTolArr and absTol,
            %   use absTolArr = rsArr.getAbsTol() if you want get only absTolArr
            %
            %$Author: Zakharov Eugene  <justenterrr@gmail.com> $
            % $Author: Grachev Artem  <grachev.art@gmail.com> $
            %   $Date: March-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2013 $
            %
            [absTolArr,absTolVal]=rsArr.getProperty('absTol',varargin{:});
            
        end
        %
        function nPlot2dPointsArr = getNPlot2dPoints(rsArr)
            % GETNPLOT2DPOINTS - gives array  the same size as rsArr of value of
            %                    nPlot2dPoints property for each element in rsArr -
            %                    array of reach sets
            %
            %
            % Input:
            %   regular:
            %     rsArr:elltool.reach.ReachDiscrete [nDims1,nDims2,...] - reach set array
            %
            %
            % Output:
            %   nPlot2dPointsArr:double[nDims1,nDims2,...] - array of values of
            %       nTimeGridPoints property for each reach set in rsArr
            %
            % $Author: Zakharov Eugene
            % <justenterrr@gmail.com> $
            % $Date: 17-november-2012 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2012 $
            %
            nPlot2dPointsArr =...
                elltool.reach.ReachDiscrete.getProperty(rsArr,'nPlot2dPoints');
        end
        %
        function nPlot3dPointsArr = getNPlot3dPoints(rsArr)
            % GETNPLOT3DPOINTS - gives array  the same size as rsArr of value of
            %                    nPlot3dPoints property for each element in rsArr
            %                    - array of reach sets
            %
            % Input:
            %   regular:
            %       rsArr:reach[nDims1,nDims2,...] - reach set array
            %
            % Output:
            %   nPlot3dPointsArr:double[nDims1,nDims2,...]- array of values of
            %             nPlot3dPoints property for each reach set in rsArr
            %
            %
            % $Author: Zakharov Eugene
            % <justenterrr@gmail.com> $
            % $Date: 17-november-2012 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2012 $
            %
            nPlot3dPointsArr =...
                elltool.reach.ReachDiscrete.getProperty(rsArr,'nPlot3dPoints');
        end
        %
        function nTimeGridPointsArr = getNTimeGridPoints(rsArr)
            % GETNTIMEGRIDPOINTS - gives array  the same size as rsArr of value of
            %                      nTimeGridPoints property for each element in rsArr
            %                     - array of reach sets
            %
            % Input:
            %   regular:
            %       rsArr: elltool.reach.ReachDiscrete [nDims1,nDims2,...] - reach set
            %         array
            %
            % Output:
            %   nTimeGridPointsArr: double[nDims1,nDims2,...]- array of values of
            %       nTimeGridPoints property for each reach set in rsArr
            %
            %
            % $Author: Zakharov Eugene
            % <justenterrr@gmail.com> $
            % $Date: 17-november-2012 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2012 $
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
            %       rsArr: elltool.reach.ReachDiscrete[nDim1,nDim2, ...] - multidimension
            %           array of reach sets.
            %   optional
            %       fRelTolFun: function_handle[1,1] - function that apply to the
            %           relTolArr. The default is @min.
            %
            % Output:
            %   regular:
            %       relTolArr: double [relTol1, relTol2, ...] - return relTol for each
            %           element in rsArr
            %   optional:
            %       relTol: double[1,1] - return result of work fRelTolFun with the
            %           relTolArr
            %
            %
            % Usage:
            %   use [~,relTol] = rsArr.getRelTol() if you want get only relTol,
            %   use [relTolArr,relTol] = rsArr.getRelTol() if you want get relTolArr
            %        and relTol,
            %   use relTolArr = rsArr.getRelTol() if you want get only relTolArr
            %
            %$Author: Zakharov Eugene  <justenterrr@gmail.com> $
            % $Author: Grachev Artem  <grachev.art@gmail.com> $
            %   $Date: March-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2013 $
            %
            [relTolArr,relTolVal]=rsArr.Property('relTol',varargin{:});
        end
        %
        function outStrCMat = getStrCMat(inpMat)
            outStrCMat =...
                arrayfun(@num2str, inpMat, 'UniformOutput', false);
        end
        %
        function [centerVec, shapeMat] = getEllParams(inpEll, relMat)
            if ~isempty(inpEll)
                if isa(inpEll, 'ellipsoid')
                    [centerVec shapeMat] = double(inpEll);
                else
                    if isfield(inpEll, 'center')
                        centerVec = inpEll.center;
                    else
                        centerVec = zeros(size(relMat, 2), 1);
                    end
                    if isfield(inpEll, 'shape')
                        shapeMat = inpEll.shape;
                    else
                        shapeMat = zeros(size(relMat, 2));
                    end
                end
            else
                shapeMat = zeros(size(relMat, 2));
                centerVec = zeros(size(relMat, 2), 1);
            end
        end
        %
        function [atStrCMat btStrCMat gtStrCMat ptStrCMat ptStrCVec ...
                qtStrCMat qtStrCVec] = prepareSysParam(linSys)
            atMat = linSys.getAtMat();
            btMat = linSys.getBtMat();
            gtMat = linSys.getGtMat();
            if ~iscell(atMat) && ~isempty(atMat)
                atStrCMat = elltool.reach.AReach.getStrCMat(atMat);
            else
                atStrCMat = atMat;
            end
            if ~iscell(btMat) && ~isempty(btMat)
                btStrCMat = elltool.reach.AReach.getStrCMat(btMat);
            else
                btStrCMat = btMat;
            end
            if isempty(gtMat)
                gtMat = zeros(size(btMat));
            end
            if ~iscell(gtMat)
                gtStrCMat = elltool.reach.AReach.getStrCMat(gtMat);
            else
                gtStrCMat = gtMat;
            end
            uEll = linSys.getUBoundsEll();
            [ptVec ptMat] =...
                elltool.reach.AReach.getEllParams(uEll, btMat);
            if ~iscell(ptMat)
                ptStrCMat = elltool.reach.AReach.getStrCMat(ptMat);
            else
                ptStrCMat = ptMat;
            end
            if ~iscell(ptVec)
                ptStrCVec = elltool.reach.AReach.getStrCMat(ptVec);
            else
                ptStrCVec = ptVec;
            end
            vEll = linSys.getDistBoundsEll();
            [qtVec qtMat] =...
                elltool.reach.AReach.getEllParams(vEll, gtMat);
            if ~iscell(qtMat)
                qtStrCMat = elltool.reach.AReach.getStrCMat(qtMat);
            else
                qtStrCMat = qtMat;
            end
            if ~iscell(qtVec)
                qtStrCVec = elltool.reach.AReach.getStrCMat(qtVec);
            else
                qtStrCVec = qtVec;
            end
        end
        %
        function isDisturb = isDisturbance(gtStrCMat, qtStrCMat)
            import gras.mat.symb.iscellofstringconst;
            import gras.gen.MatVector;
            isDisturb = true;
            if iscellofstringconst(gtStrCMat)
                gtMat = MatVector.fromFormulaMat(gtStrCMat, 0);
                if all(gtMat(:) == 0)
                    isDisturb = false;
                end
            end
            if isDisturb && iscellofstringconst(qtStrCMat)
                qtMat = MatVector.fromFormulaMat(qtStrCMat, 0);
                if all(qtMat(:) == 0)
                    isDisturb = false;
                end
            end
        end
        %
        function isDisturb = isNoise(gtStrCMat, qtStrCMat)
            import gras.mat.symb.iscellofstringconst;
            import gras.gen.MatVector;
            isDisturb = true;
            if iscellofstringconst(gtStrCMat)
                gtMat = MatVector.fromFormulaMat(gtStrCMat, 0);
                if all(gtMat(:) == 0)
                    isDisturb = false;
                end
            end
            if isDisturb && iscellofstringconst(qtStrCMat)
                qtMat = MatVector.fromFormulaMat(qtStrCMat, 0);
                if all(qtMat(:) == 0)
                    isDisturb = false;
                end
            end
        end
        %
        function outMat = getNormMat(inpMat, dim)
            matSqNormVec = sum(inpMat .* inpMat);
            isNormGrZeroVec = matSqNormVec > 0;
            matSqNormVec(isNormGrZeroVec) =...
                sqrt(matSqNormVec(isNormGrZeroVec));
            outMat(:, isNormGrZeroVec) =...
                inpMat(:, isNormGrZeroVec) ./...
                matSqNormVec(ones(1, dim), isNormGrZeroVec);
        end
    end
    %
    methods (Access = private)
        function [dataCVec, indVec] = evolveApprox(self, ...
                newTimeVec, newLinSys, approxType)
            import gras.ellapx.smartdb.F;
            APPROX_TYPE = F.APPROX_TYPE;
            [filteredTubes, isThereVec] =...
                self.ellTubeRel.getTuplesFilteredBy(...
                APPROX_TYPE, approxType);
            oldData = filteredTubes.getData();
            indVec = find(isThereVec);
            %
            sysDimRows = size(oldData.QArray{1}, 1);
            sysDimCols = size(oldData.QArray{1}, 2);
            %
            dataDimVec = oldData.dim;
            l0VecNum = size(dataDimVec, 1);
            l0Mat = zeros(dataDimVec(1), l0VecNum);
            x0VecMat = zeros(sysDimRows, l0VecNum);
            x0MatArray = zeros(sysDimRows, sysDimCols, l0VecNum);
            if self.isBackward
                for il0Num = 1 : l0VecNum
                    l0Mat(:, il0Num) = oldData.ltGoodDirMat{il0Num}(:, 1);
                    x0VecMat(:, il0Num) = oldData.aMat{il0Num}(:, 1);
                    x0MatArray(:, :, il0Num) =...
                        oldData.QArray{il0Num}(:, :, 1);
                end
            else
                for il0Num = 1 : l0VecNum
                    l0Mat(:, il0Num) = oldData.ltGoodDirMat{il0Num}(:, end);
                    x0VecMat(:, il0Num) = oldData.aMat{il0Num}(:, end);
                    x0MatArray(:, :, il0Num) =...
                        oldData.QArray{il0Num}(:, :, end);
                end
            end
            [atStrCMat btStrCMat gtStrCMat ptStrCMat ptStrCVec ...
                qtStrCMat qtStrCVec] = ...
                self.prepareSysParam(newLinSys, newTimeVec);
            %
            % Normalize good ext/int-directions
            %
            sysDim = size(atStrCMat, 1);
            l0Mat = self.getNormMat(l0Mat, sysDim);
            %
            % ext/int-approx on the next time interval
            %
            dataCVec = cell(1, l0VecNum);
            isDisturbance = self.isDisturbance(gtStrCMat, qtStrCMat);
            for il0Num = l0VecNum: -1 : 1
                probDynObj = self.getProbDynamics(atStrCMat, ...
                    btStrCMat, ptStrCMat, ptStrCVec, gtStrCMat, ...
                    qtStrCMat, qtStrCVec, x0MatArray(:, :, il0Num), ...
                    x0VecMat(:, il0Num), newTimeVec, self.relTol, ...
                    isDisturbance);
                ellTubeRelVec{il0Num} = self.makeEllTubeRel(...
                    probDynObj, l0Mat(:, il0Num), ...
                    newTimeVec, isDisturbance, self.relTol, approxType);
                dataCVec{il0Num} = ...
                    ellTubeRelVec{il0Num}.getTuplesFilteredBy(...
                    APPROX_TYPE, approxType).getData();
            end
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
    end
    methods
        function parse(self, linSys, x0Ell, l0Mat, timeVec, varargin)
            import modgen.common.type.simple.checkgenext;
            import modgen.common.throwerror;
            import elltool.logging.Log4jConfigurator;
            import elltool.conf.Properties;
            %
            logger = Log4jConfigurator.getLogger(...
                'elltool.ReachCont.constrCallCount');
            logger.debug(sprintf('constructor is called %s',...
                modgen.exception.me.printstack(...
                dbstack, 'useHyperlink', false)));
            %
            neededPropNameList =...
                {'absTol', 'relTol', 'nPlot2dPoints',...
                'nPlot3dPoints','nTimeGridPoints'};
            [absTolVal, relTolVal, nPlot2dPointsVal,...
                nPlot3dPointsVal, nTimeGridPointsVal] =...
                Properties.parseProp(varargin, neededPropNameList);
            %
            self.absTol = absTolVal;
            self.relTol = relTolVal;
            self.nPlot2dPoints = nPlot2dPointsVal;
            self.nPlot3dPoints = nPlot3dPointsVal;
            self.nTimeGridPoints = nTimeGridPointsVal;
            %
            self.switchSysTimeVec = [min(timeVec), max(timeVec)];
            self.x0Ellipsoid = x0Ell;
            self.linSysCVec = {linSys};
            self.isCut = false;
            self.isProj = false;
            self.isBackward = timeVec(1) > timeVec(2);
            self.projectionBasisMat = [];
            %
            % check and analize input
            %
            if nargin < 4
                throwerror('wrongInput', ['insufficient ',...
                    'number of input arguments.']);
            end
            if ~(isa(linSys, self.LINSYS_CLASS_STRING))
                throwerror('wrongInput', ['first input argument ',...
                    'must be linear system object.']);
            end
            if ~(isa(x0Ell, 'ellipsoid'))
                throwerror('wrongInput', ['set of initial ',...
                    'conditions must be ellipsoid.']);
            end
            checkgenext('x1==x2&&x2==x3', 3,...
                dimension(linSys), dimension(x0Ell), size(l0Mat, 1));
            %
            [timeRows, timeCols] = size(timeVec);
            if ~(isa(timeVec, 'double')) ||...
                    (timeRows ~= 1) || (timeCols ~= 2)
                throwerror('wrongInput', ['time interval must be ',...
                    'specified as ''[t0 t1]'', or, in ',...
                    'discrete-time - as ''[k0 k1]''.']);
            end
        end
        %
        function resArr=repMat(self,varargin)
            sizeVec=horzcat(varargin{:});
            resArr=repmat(self,sizeVec);
            resArr=resArr.getCopy();
        end
        %
        function isProjArr = isprojection(self)
            isProjArr = fApplyArrMethod(self,'isProj');
        end
        %
        function isCutArr = iscut(self)
            isCutArr = fApplyArrMethod(self,'isCut');
        end
        %
        function isEmptyArr = isempty(self)
            isEmptyArr = fApplyArrMethod(self,'x0Ellipsoid','isempty');
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
        function [isEq,reportStr] = isEqual(self, reachObj, varargin)
            %
            % ISEQUAL - checks for equality given reach set objects
            %
            % Input:
            %   regular:
            %       self.
            %       reachObj:
            %           elltool.reach.ReachContinuous[1, 1] - each set object, which
            %            compare with self.
            %   optional:
            %       tuple: int[1, 1] - number of tuple for which will be compared.
            %       approxType: gras.ellapx.enums.EApproxType[1, 1] -  type of
            %           approximation, which will be compared.
            %
            % Output:
            %   regular:
            %       ISEQUAL: logical[1, 1] - true - if reach set objects are equal.
            %           false - otherwise.
            %
            % Example:
            %   aMat = [0 1; 0 0]; bMat = eye(2);
            %   SUBounds = struct();
            %   SUBounds.center = {'sin(t)'; 'cos(t)'};
            %   SUBounds.shape = [9 0; 0 2];
            %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
            %   x0EllObj = ell_unitball(2);
            %   timeVec = [0 10];
            %   dirsMat = [1 0; 0 1]';
            %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
            %   copyRsObj = rsObj.getCopy();
            %   isEqual = isEqual(rsObj, copyRsObj)
            %
            %   isEqual =
            %
            %           1
            %
            % $Author: Kirill Mayantsev <kirill.mayantsev@gmail.com> $
            % $Date: March-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational
            %             Mathematics and Computer Science,
            %             System Analysis Department 2013 $
            %
            import gras.ellapx.smartdb.F;
            import gras.ellapx.enums.EApproxType;
            APPROX_TYPE = F.APPROX_TYPE;
            %
            ellTube = self.ellTubeRel;
            ellTube.sortBy(APPROX_TYPE);
            compEllTube = reachObj.ellTubeRel;
            compEllTube.sortBy(APPROX_TYPE);
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
            if self.isBackward
                compTimeGridIndVec = 2 .* (1 : pointsNum);
            else
                compTimeGridIndVec = 2 .* (1 : pointsNum) - 1;
            end
            firstTimeVec = ellTube.timeVec{1};
            secondTimeVec = compEllTube.timeVec{1};
            if pointsNum ~= newPointsNum
                secondTimeVec = secondTimeVec(compTimeGridIndVec);
            end
            if max(abs(firstTimeVec - secondTimeVec) > self.COMP_PRECISION)
                compTimeGridIndVec = compTimeGridIndVec +...
                    double(compTimeGridIndVec > pointsNum);
            end
            %
            if nargin == 3
                fieldsNotToCompVec =...
                    F.getNameList(varargin{1});
                fieldsToCompVec =...
                    setdiff(ellTube.getFieldNameList, fieldsNotToCompVec);
            else
                fieldsNotToCompVec =...
                    F.getNameList(self.FIELDS_NOT_TO_COMPARE);
                fieldsToCompVec =...
                    setdiff(ellTube.getFieldNameList, fieldsNotToCompVec);
            end
            %
            if pointsNum ~= newPointsNum
                compEllTube =...
                    compEllTube.thinOutTuples(compTimeGridIndVec);
            end
            [isEq,reportStr] = compEllTube.getFieldProjection(...
                fieldsToCompVec).isEqual(...
                ellTube.getFieldProjection(fieldsToCompVec),...
                'maxTolerance', 2*self.COMP_PRECISION, ...
                'checkTupleOrder', 'true');
        end
        %
        function display(self)
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
            if self.isBackward
                isBack = true;
                fprintf(['Backward reach set of the %s linear system ',...
                    'in R^%d in the time interval [%d, %d].\n'],...
                    sysTypeStr, dim, timeVec(end), timeVec(1));
            else
                isBack = false;
                fprintf(['Reach set of the %s linear system ',...
                    'in R^%d in the time interval [%d, %d].\n'],...
                    sysTypeStr, dim, timeVec(1), timeVec(end));
            end
            if self.isProj
                fprintf('Projected onto the basis:\n');
                disp(self.projectionBasisMat);
            end
            fprintf('\n');
            if isBack
                fprintf('Target set at time %s%d:\n',...
                    sysTimeEndStr, timeVec(end));
            else
                fprintf('Initial set at time %s%d:\n',...
                    sysTimeStartStr, timeVec(1));
            end
            disp(self.x0Ellipsoid);
            fprintf('Number of external approximations: %d\n',...
                sum(self.ellTubeRel.approxType == EApproxType.External));
            fprintf('Number of internal approximations: %d\n',...
                sum(self.ellTubeRel.approxType == EApproxType.Internal));
            fprintf('\n');
        end
        %
        function linSys = get_system(self)
            linSys = self.linSysCVec{end}.getCopy();
        end
        %
        function [rSdimArr sSdimArr] = dimension(self)
            rSdimArr = arrayfun(@(x) x.linSysCVec{end}.dimension(), self);
            sSdimArr = arrayfun(@(x,y) getSSdim(x,y), self, rSdimArr);
            function sSdim = getSSdim(reachObj, rSdim)
                if ~reachObj.isProj
                    sSdim = rSdim;
                else
                    sSdim = size(reachObj.projectionBasisMat, 2);
                end
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
            [eaEllMat timeVec] = ...
                self.ellTubeRel.getEllArray(EApproxType.External);
        end
        %
        function [iaEllMat timeVec] = get_ia(self)
            import gras.ellapx.enums.EApproxType;
            [iaEllMat timeVec] = ...
                self.ellTubeRel.getEllArray(EApproxType.Internal);
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
            %
            % GET_EASCALEFACTOR - return the scale factor for external approximation
            %                     of reach tube
            %
            % Input:
            %   regular:
            %       self.
            %
            % Output:
            %   regular:
            %       eaScaleFactor: double[1, 1] - scale factor.
            %
            % Example:
            %   aMat = [0 1; 0 0]; bMat = eye(2);
            %   SUBounds = struct();
            %   SUBounds.center = {'sin(t)'; 'cos(t)'};
            %   SUBounds.shape = [9 0; 0 2];
            %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
            %   x0EllObj = ell_unitball(2);
            %   timeVec = [10 0];
            %   dirsMat = [1 0; 0 1]';
            %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
            %   rsObj.getEaScaleFactor()
            %
            %   ans =
            %
            %       1.0200
            %
            % $Author: Kirill Mayantsev <kirill.mayantsev@gmail.com> $
            % $Date: March-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational
            %             Mathematics and Computer Science,
            %             System Analysis Department 2013 $
            %
            eaScaleFactor = self.EXTERNAL_SCALE_FACTOR;
        end
        %
        function iaScaleFactor = getIaScaleFactor(self)
            %
            % GET_IASCALEFACTOR - return the scale factor for internal approximation
            %                     of reach tube
            %
            % Input:
            %   regular:
            %       self.
            %
            % Output:
            %   regular:
            %       iaScaleFactor: double[1, 1] - scale factor.
            %
            % Example:
            %   aMat = [0 1; 0 0]; bMat = eye(2);
            %   SUBounds = struct();
            %   SUBounds.center = {'sin(t)'; 'cos(t)'};
            %   SUBounds.shape = [9 0; 0 2];
            %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
            %   x0EllObj = ell_unitball(2);
            %   timeVec = [10 0];
            %   dirsMat = [1 0; 0 1]';
            %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
            %   rsObj.getIaScaleFactor()
            %
            %   ans =
            %
            %       1.0200
            %
            % $Author: Kirill Mayantsev <kirill.mayantsev@gmail.com> $
            % $Date: March-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational
            %             Mathematics and Computer Science,
            %             System Analysis Department 2013 $
            %
            iaScaleFactor = self.INTERNAL_SCALE_FACTOR;
        end
        %
        function x0Ell = getInitialSet(self)
            %
            % GETINITIALSET - return the initial set for linear system, which is solved
            %                 for building reach tube.
            %
            % Input:
            %   regular:
            %       self.
            %
            % Output:
            %   regular:
            %       x0Ell: ellipsoid[1, 1] - ellipsoid x0, which was initial set for
            %           linear system.
            %
            % Example:
            %   aMat = [0 1; 0 0]; bMat = eye(2);
            %   SUBounds = struct();
            %   SUBounds.center = {'sin(t)'; 'cos(t)'};
            %   SUBounds.shape = [9 0; 0 2];
            %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
            %   x0EllObj = ell_unitball(2);
            %   timeVec = [10 0];
            %   dirsMat = [1 0; 0 1]';
            %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
            %   x0Ell = rsObj.getInitialSet()
            %
            %   x0Ell =
            %
            %   Center:
            %        0
            %        0
            %
            %   Shape Matrix:
            %        1     0
            %        0     1
            %
            %   Nondegenerate ellipsoid in R^2.
            %
            % $Author: Kirill Mayantsev <kirill.mayantsev@gmail.com> $
            % $Date: March-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational
            %             Mathematics and Computer Science,
            %             System Analysis Department 2013 $
            %
            x0Ell = self.x0Ellipsoid.getCopy();
        end
        %
        function isBackward = isbackward(self)
            %
            % ISBACKWARD - checks if given reach set object was obtained by solving
            %              the system in reverse time.
            %
            % Input:
            %   regular:
            %       self.
            %
            % Output:
            %   regular:
            %       isBackward: logical[1, 1] - true - if self was obtained by solving
            %           in reverse time, false - otherwise.
            %
            % Example:
            %   aMat = [0 1; 0 0]; bMat = eye(2);
            %   SUBounds = struct();
            %   SUBounds.center = {'sin(t)'; 'cos(t)'};
            %   SUBounds.shape = [9 0; 0 2];
            %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
            %   x0EllObj = ell_unitball(2);
            %   timeVec = [10 0];
            %   dirsMat = [1 0; 0 1]';
            %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
            %   rsObj.isbackward()
            %
            %   ans =
            %
            %        1
            %
            %
            % $Author: Kirill Mayantsev <kirill.mayantsev@gmail.com> $
            % $Date: March-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational
            %             Mathematics and Computer Science,
            %             System Analysis Department 2013 $
            %
            isBackward = self.isBackward;
        end
        %
        function projObj = projection(self, projMat)
            import gras.ellapx.enums.EProjType;
            import modgen.common.throwerror;
            projSet = self.getProjSet(projMat);
            projObj = self.getCopy();
            projObj.ellTubeRel = projSet.getCopy();
            projObj.isProj = true;
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
        function self = refine(self, l0Mat)
            import modgen.common.throwerror;
            import gras.ellapx.enums.EApproxType;
            if isempty(self.ellTubeRel)
                throwerror('wrongInput', 'empty reach set');
            end
            if ~isa(l0Mat, 'double')
                throwerror('wrongInput', strcat('second argument must ',...
                    'be matrix of directions'));
            end
            %
            % Calculate additional tubes
            %
            linSys = self.linSysCVec{1};
            if self.isBackward
                timeLimsVec = ...
                    [self.switchSysTimeVec(end), self.switchSysTimeVec(1)];
            else
                timeLimsVec = ...
                    [self.switchSysTimeVec(1), self.switchSysTimeVec(end)];
            end
            x0Ell = self.x0Ellipsoid;
            %
            % Normalize good directions
            %
            nDim = dimension(x0Ell);
            l0Mat = self.getNormMat(l0Mat, nDim);
            if self.isProj
                projMat = self.projectionBasisMat;
                reachSetObj = feval(class(self), linSys, x0Ell, ...
                    l0Mat, timeLimsVec);
                projSet = reachSetObj.getProjSet(projMat);
                self.ellTubeRel.unionWith(projSet);
            else
                [x0Vec x0Mat] = double(x0Ell);
                [atStrCMat btStrCMat gtStrCMat ptStrCMat ptStrCVec ...
                    qtStrCMat qtStrCVec] = ...
                    self.prepareSysParam(linSys, timeLimsVec);
                isDisturbance = self.isDisturbance(gtStrCMat, qtStrCMat);
                %
                probDynObj = self.getProbDynamics(atStrCMat, btStrCMat, ...
                    ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec, ...
                    x0Mat, x0Vec, timeLimsVec, ...
                    self.relTol, isDisturbance);
                approxTypeVec = [EApproxType.External EApproxType.Internal];
                ellTubeRelNew = self.makeEllTubeRel(probDynObj, l0Mat, ...
                    timeLimsVec, isDisturbance, self.relTol, approxTypeVec);
                if self.isBackward
                    ellTubeRelNew = self.transformEllTube(ellTubeRelNew);
                end
                %
                % Update self.ellTubRel
                %
                self.ellTubeRel.unionWith(ellTubeRelNew);
            end
        end
        %
        function cutObj = cut(self, cutTimeVec)
            import modgen.common.throwerror;
            if self.isProj
                throwerror('wrongInput',...
                    'Method cut does not work with projections');
            else
                cutObj = self.getCopy();
                if self.isBackward
                    cutTimeVec = fliplr(cutTimeVec);
                end
                switchTimeVec = self.switchSysTimeVec;
                cutObj.ellTubeRel = cutObj.ellTubeRel.cut(cutTimeVec);
                switchTimeIndVec = ...
                    switchTimeVec > cutTimeVec(1) & ...
                    switchTimeVec < cutTimeVec(end);
                cutObj.switchSysTimeVec = [cutTimeVec(1) ...
                    switchTimeVec(switchTimeIndVec) cutTimeVec(end)];
                firstIntInd = find(switchTimeIndVec == 1, 1);
                if ~isempty(firstIntInd)
                    switchTimeIndVec(firstIntInd - 1) = 1;
                else
                    switchTimeIndVec(find(switchTimeVec >= ...
                        cutTimeVec(end), 1) - 1) = 1;
                end
                cutObj.linSysCVec = cutObj.linSysCVec(switchTimeIndVec);
                cutObj.isCut = true;
            end
        end
        %
        function copyReachObjArr = getCopy(self)
            % Example:
            %   aMat = [0 1; 0 0]; bMat = eye(2);
            %   SUBounds = struct();
            %   SUBounds.center = {'sin(t)'; 'cos(t)'};
            %   SUBounds.shape = [9 0; 0 2];
            %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
            %   x0EllObj = ell_unitball(2);
            %   timeVec = [0 10];
            %   dirsMat = [1 0; 0 1]';
            %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
            %   copyRsObj = rsObj.getCopy()
            %   copyRsObj =
            %   Reach set of the continuous-time linear system in R^2 in the time ...
            %             interval [0, 10].
            %
            %   Initial set at time t0 = 0:
            %   Ellipsoid with parameters
            %   Center:
            %        0
            %        0
            %
            %   Shape Matrix:
            %        1     0
            %        0     1
            %
            %   Number of external approximations: 2
            %   Number of internal approximations: 2
            if ~isempty(self)
                sizeCVec = num2cell(size(self));
                copyReachObjArr(sizeCVec{:}) = feval(class(self(1, 1)));
                arrayfun(@fSingleCopy,copyReachObjArr,self);
            else
                copyReachObjArr = elltool.reach.ReachContinuous.empty(size(self));
            end
            function fSingleCopy(copyReachObj, reachObj)
                copyReachObj.absTol = reachObj.absTol;
                copyReachObj.relTol = reachObj.relTol;
                copyReachObj.nPlot2dPoints = reachObj.nPlot2dPoints;
                copyReachObj.nPlot3dPoints = reachObj.nPlot3dPoints;
                copyReachObj.nTimeGridPoints = reachObj.nTimeGridPoints;
                copyReachObj.switchSysTimeVec = reachObj.switchSysTimeVec;
                copyReachObj.x0Ellipsoid = reachObj.x0Ellipsoid.getCopy();
                copyReachObj.linSysCVec = cellfun(@(x) x.getCopy(),...
                    reachObj.linSysCVec, 'UniformOutput', false);
                copyReachObj.isCut = reachObj.isCut;
                copyReachObj.isProj = reachObj.isProj;
                copyReachObj.isBackward = reachObj.isBackward;
                copyReachObj.projectionBasisMat = reachObj.projectionBasisMat;
                copyReachObj.ellTubeRel = reachObj.ellTubeRel.getCopy();
            end
        end
        %
        function ellTubeRel = getEllTubeRel(self)
            % Example:
            %   aMat = [0 1; 0 0]; bMat = eye(2);
            %   SUBounds = struct();
            %   SUBounds.center = {'sin(t)'; 'cos(t)'};
            %   SUBounds.shape = [9 0; 0 2];
            %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
            %   x0EllObj = ell_unitball(2);
            %   timeVec = [0 10];
            %   dirsMat = [1 0; 0 1]';
            %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
            %   rsObj.getEllTubeRel();
            %
            ellTubeRel = self.ellTubeRel;
        end
        %
        function ellTubeUnionRel = getEllTubeUnionRel(self)
            % Example:
            %   aMat = [0 1; 0 0]; bMat = eye(2);
            %   SUBounds = struct();
            %   SUBounds.center = {'sin(t)'; 'cos(t)'};
            %   SUBounds.shape = [9 0; 0 2];
            %   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
            %   x0EllObj = ell_unitball(2);
            %   timeVec = [0 10];
            %   dirsMat = [1 0; 0 1]';
            %   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
            %   getEllTubeUnionRel(rsObj);
            %
            import gras.ellapx.smartdb.rels.EllUnionTube;
            ellTubeUnionRel = EllUnionTube.fromEllTubes(self.ellTubeRel);
        end
        %
        function newReachObj = evolve(self, newEndTime, linSys)
            import elltool.conf.Properties;
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
            import gras.ellapx.uncertcalc.EllApxBuilder;
            import modgen.common.throwerror;
            %
            % check and analize input
            %
            if nargin < 2
                throwerror('wrongInput', ['insufficient number ',...
                    'of input arguments.']);
            end
            if nargin > 3
                throwerror('wrongInput', 'too much arguments.');
            end
            if self.isProj
                throwerror('wrongInput', ['cannot compute ',...
                    'the reach set for projection.']);
            end
            if nargin < 3
                newLinSys = self.get_system();
                oldLinSys = newLinSys;
            else
                if ~(isa(linSys, class(self.get_system())))
                    throwerror('wrongInput', ['first input argument ',...
                        'must be linear system object.']);
                end
                newLinSys = linSys;
                oldLinSys = self.get_system();
            end
            if isempty(newLinSys)
                return;
            end
            if ~isa(newEndTime, 'double')
                throwerror('wrongInput',...
                    'second argument must be double.');
            end
            if (newEndTime < self.switchSysTimeVec(end) && ...
                    ~self.isBackward) || ...
                    (newEndTime > self.switchSysTimeVec(end) && ...
                    self.isBackward)
                throwerror('wrongInput', ['new end time must be more ',...
                    '(if forward) or less (if backward) than the old one.']);
            end
            if newLinSys.dimension() ~= oldLinSys.dimension()
                throwerror('wrongInput', ['dimensions of the ',...
                    'old and new linear systems do not match.']);
            end
            %
            newReachObj = self.getCopy();
            if self.isBackward
                newReachObj.switchSysTimeVec =...
                    [newEndTime, self.switchSysTimeVec];
                newTimeVec = [self.switchSysTimeVec(1), newEndTime];
            else
                newReachObj.switchSysTimeVec =...
                    [self.switchSysTimeVec, newEndTime];
                newTimeVec = [self.switchSysTimeVec(end), newEndTime];
            end
            newReachObj.linSysCVec = [newReachObj.linSysCVec {newLinSys}];
            newReachObj.isCut = false;
            %
            [dataIntCVec, indIntVec] = self.evolveApprox(newTimeVec, ...
                newLinSys, EApproxType.Internal);
            [dataExtCVec, indExtVec] = self.evolveApprox(newTimeVec, ...
                newLinSys, EApproxType.External);
            dataCVec = [dataIntCVec, dataExtCVec];
            %
            % cat old and new ellTubeRel
            %
            newEllTubeRel =...
                gras.ellapx.smartdb.rels.EllTube.fromStructList(...
                'gras.ellapx.smartdb.rels.EllTube', dataCVec);
            if self.isBackward
                newEllTubeRel = self.transformEllTube(newEllTubeRel);
            end
            %
            indVec = [indIntVec; indExtVec];
            [~, indRelVec] = sort(indVec);
            newEllTubeRel = newEllTubeRel.getTuples(indRelVec);
            %
            if self.isBackward
                timeVec = self.ellTubeRel.timeVec{1};
                isIndVec = true(size(timeVec));
                isIndVec(1) = false;
                newReachObj.ellTubeRel =...
                    newEllTubeRel.cat(self.ellTubeRel, isIndVec);
            else
                timeVec = newEllTubeRel.timeVec{1};
                isIndVec = true(size(timeVec));
                isIndVec(1) = false;
                newReachObj.ellTubeRel =...
                    self.ellTubeRel.cat(newEllTubeRel, isIndVec);
            end
        end
    end
end