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
    properties (Constant, Abstract,GetAccess=protected)
        DISPLAY_PARAMETER_STRINGS
        LINSYS_CLASS_STRING
    end
    properties (Constant, GetAccess = protected)
        MIN_EIG_Q_REG_UNCERT = 0.1
        EXTERNAL_SCALE_FACTOR = 1.02
        INTERNAL_SCALE_FACTOR = 0.98
        DEFAULT_INTAPX_S_SELECTION_MODE = 'volume'
        FIELDS_NOT_TO_COMPARE = {'LT_GOOD_DIR_MAT'; ...
            'LT_GOOD_DIR_NORM_VEC'; 'LS_GOOD_DIR_NORM'; ...
            'LS_GOOD_DIR_VEC';'IND_S_TIME';...
            'S_TIME'; 'TIME_VEC'};
        %
        ETAG_WR_INP = 'wrongInput';
        ETAG_R_PROB = ':regProblem';
        ETAG_R_DISABLED = ':RegIsDisabled';
        ETAG_ONLY_CHECK = ':onlyCheckIsEnabled';
        ETAG_LOW_REG_TOL = ':regTolIsTooLow';
        ETAG_BAD_CALC_PREC = ':BadCalcPrec';
        %
        EMSG_R_PROB = 'There is a problem with regularization. ';
        EMSG_INIT_SET_PROB = ['There is a problem with initial',...
            ' set (x0Ell, second parameter). '];
        EMSG_CALC_PREC_PROB = ['There is a problem with ',...
            'calculation precision. Try to do some of this: '];
        EMSG_USE_REG = ['Try to enable regularization: set property ',...
            '''isRegEnabled'' to ''true'', ''isJustCheck'' to ',...
            '''false'' and ''regTol'' to some positive.'];
        EMSG_LOW_REG_TOL = ['Try to increase regularization ',...
            'tolerance: increase value of ''regTol'' property.'];
        EMSG_SMALL_INIT_SET = ['Try to increase it: change its',...
            ' shape matrix'];
        EMSG_BAD_TIME_VEC = ['Try to decrease the length of ',...
            'your time interval (timeVec, fourth parameter).'];
        FIRST_COMMON_PART_BAD_ELL_STR = 'Try to decrease ';
        SECOND_COMMON_PART_BAD_ELL_STR =...
            [' ellipsoid (linear system''s parameter): change ',...
            'its shape matrix.'];
        EMSG_BAD_CONTROL = ...
            [elltool.reach.AReach.FIRST_COMMON_PART_BAD_ELL_STR,...
            'control', elltool.reach.AReach.SECOND_COMMON_PART_BAD_ELL_STR];
        EMSG_BAD_DIST = ...
            [elltool.reach.AReach.FIRST_COMMON_PART_BAD_ELL_STR,...
            'disturbance', ...
            elltool.reach.AReach.SECOND_COMMON_PART_BAD_ELL_STR];
        EMSG_BAD_INIT_SET = ...
            [elltool.reach.AReach.FIRST_COMMON_PART_BAD_ELL_STR,...
            'initial set', ...
            elltool.reach.AReach.SECOND_COMMON_PART_BAD_ELL_STR];
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
        isRegEnabled
        isJustCheck
        regTol
    end
    methods
        function set.ellTubeRel(self,rel)
            self.checkIndSTime(rel);
            self.ellTubeRel=rel;
        end
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
                isArr=arrayfun(@(x)fApplyToProperty(x.(propertyName)),self);
            end
            %in case of empty input array make output logical
            isArr = logical(isArr);
        end
    end
    %
    methods (Static, Abstract, Access = protected)
        linSys = getProbDynamics(atStrCMat, btStrCMat, ...
            ptStrCMat, ptStrCVec, ctStrCMat, qtStrCMat, qtStrCVec, ...
            x0Mat, x0Vec, timeVec, calcPrecision, isDisturb)
    end
    %
    methods (Abstract, Access = protected)
        %
        ellTubeRel = internalMakeEllTubeRel(self, probDynObj, l0Mat, ...
            timeVec, isDisturb, calcPrecision, approxTypeVec)
    end
    %
    methods (Access=protected)
        function checkIndSTime(self,ellTubeRel)
            import modgen.common.throwerror;
            indSTimeVec=ellTubeRel.indSTime;
            if self.isbackward()
                isOk=all(indSTimeVec==...
                    cellfun(@numel,ellTubeRel.timeVec));
            else
                isOk=all(indSTimeVec==1);
            end
            if ~isOk
                throwerror('wrongState:internalError',...
                    'Oops,we should be here, indSTime is incorrect');
            end
        end
        function [propArr, propVal] = getProperty(rsArr,propName,fPropFun)
            % GETPROPERTY - gives array the same size as rsArray with
            %   values of propName property for each element in rsArr array
            %
            % Input:
            %   regular:
            %       rsArray: elltool.reach.AReach [nDims1, nDims2,...] -
            %           multidimension array of reach sets
            %       propName: char[1,N] - name property
            %
            %   optional:
            %       fPropFun: function_handle[1,1] - function that apply
            %           to the propArr. The default is @min.
            %
            % Output:
            %   regular:
            %       propArr: double[nDim1, nDim2,...] -  multidimension
            %           array of properties for reach object in rsArr
            %   optional:
            %       propVal: double[1, 1] - return result of work
            %           fPropFun with the propArr
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
            PROP_NAME_LIST = {'absTol','relTol','nPlot2dPoints',...
                'nPlot3dPoints','nTimeGridPoints'};
            if ~any(strcmp(propName,PROP_NAME_LIST))
                throwerror('wrongInput',[propName,':no such property']);
            end
            %
            if nargin == 2
                fPropFun = @min;
            end
            %
            propArr= arrayfun(@(x)x.(propName),rsArr);
            if nargout == 2
                propVal = fPropFun(propArr(:));
            end
        end
    end
    methods
        %
        function [absTolArr, absTolVal] = getAbsTol(rsArr, varargin)
            % GETABSTOL - gives the array of absTol for all elements
            %   in rsArr
            %
            % Input:
            %   regular:
            %       rsArr: elltool.reach.AReach[nDim1, nDim2, ...] -
            %           multidimension array of reach sets
            %   optional:
            %       fAbsTolFun: function_handle[1,1] - function that is
            %           applied to the absTolArr. The default is @min.
            %
            % Output:
            %   regular:
            %       absTolArr: double [absTol1, absTol2, ...] - return
            %           absTol for each element in rsArr
            %   optional:
            %       absTol: double[1,1] - return result of work fAbsTolFun
            %           with the absTolArr
            %
            % Usage:
            %   use [~,absTol] = rsArr.getAbsTol() if you want get only
            %       absTol,
            %   use [absTolArr,absTol] = rsArr.getAbsTol() if you want
            %       get absTolArr and absTol,
            %   use absTolArr = rsArr.getAbsTol() if you want get only
            %       absTolArr
            %
            % $Author: Zakharov Eugene  <justenterrr@gmail.com> $
            % $Author: Grachev Artem  <grachev.art@gmail.com> $
            %   $Date: March-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2013 $
            %
            [absTolArr, absTolVal]=rsArr.getProperty('absTol',varargin{:});
        end
        %
        function nPlot2dPointsArr = getNPlot2dPoints(rsArr)
            % GETNPLOT2DPOINTS - gives array  the same size as rsArr of
            %   value of nPlot2dPoints property for each element in rsArr -
            %   array of reach sets
            %
            % Input:
            %   regular:
            %     rsArr:elltool.reach.AReach[nDims1,nDims2,...] - reach
            %       set array
            %
            % Output:
            %   nPlot2dPointsArr:double[nDims1,nDims2,...] - array of
            %       values of nTimeGridPoints property for each reach set
            %       in rsArr
            %
            % $Author: Zakharov Eugene
            % <justenterrr@gmail.com> $
            % $Date: 17-november-2012 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2012 $
            %
            nPlot2dPointsArr=rsArr.getProperty('nPlot2dPoints');
        end
        %
        function nPlot3dPointsArr = getNPlot3dPoints(rsArr)
            % GETNPLOT3DPOINTS - gives array  the same size as rsArr of
            %   value of nPlot3dPoints property for each element in rsArr
            %   array of reach sets
            %
            % Input:
            %   regular:
            %       rsArr:reach[nDims1,nDims2,...] - reach set array
            %
            % Output:
            %   nPlot3dPointsArr:double[nDims1,nDims2,...]- array of values
            %       of nPlot3dPoints property for each reach set in rsArr
            %
            % $Author: Zakharov Eugene  % <justenterrr@gmail.com> $
            % $Author: Gagarinov Peter  % <pgagarinov@gmail.com> $
            % $Date: 05-June-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2012 $
            %
            nPlot3dPointsArr=rsArr.getProperty('nPlot3dPoints');
        end
        %
        function nTimeGridPointsArr = getNTimeGridPoints(rsArr)
            % GETNTIMEGRIDPOINTS - gives array  the same size as rsArr of
            %   value of nTimeGridPoints property for each element in rsArr
            %   array of reach sets
            %
            % Input:
            %   regular:
            %       rsArr: elltool.reach.AReach [nDims1,nDims2,...] - reach
            %           set array
            %
            % Output:
            %   nTimeGridPointsArr: double[nDims1,nDims2,...]- array of
            %       values of nTimeGridPoints property for each reach set
            %       in rsArr
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
                elltool.reach.AReach.getProperty(rsArr, 'nTimeGridPoints');
        end
        %
        function [relTolArr, relTolVal] = getRelTol(rsArr, varargin)
            % GETRELTOL - gives the array of relTol for all elements in
            % ellArr
            %
            % Input:
            %   regular:
            %       rsArr: elltool.reach.AReach[nDim1,nDim2, ...] -
            %           multidimension array of reach sets.
            %   optional
            %       fRelTolFun: function_handle[1,1] - function that is
            %           applied to the relTolArr. The default is @min.
            %
            % Output:
            %   regular:
            %       relTolArr: double [relTol1, relTol2, ...] - return
            %           relTol for each element in rsArr.
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
            %       relTolArr
            %
            %$Author: Zakharov Eugene  <justenterrr@gmail.com> $
            % $Author: Grachev Artem  <grachev.art@gmail.com> $
            %   $Date: March-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2013 $
            %
            [relTolArr, relTolVal] = elltool.reach.AReach.getProperty(...
                rsArr, 'relTol', varargin{:});
        end
        %
    end
    methods (Static, Access = protected)
        function [atStrCMat btStrCMat ctStrCMat ptStrCMat ptStrCVec ...
                qtStrCMat qtStrCVec] = prepareSysParam(linSys)
            atMat = linSys.getAtMat();
            btMat = linSys.getBtMat();
            ctMat = linSys.getCtMat();
            if ~iscell(atMat) && ~isempty(atMat)
                atStrCMat = getStrCMat(atMat);
            else
                atStrCMat = atMat;
            end
            if ~iscell(btMat) && ~isempty(btMat)
                btStrCMat = getStrCMat(btMat);
            else
                btStrCMat = btMat;
            end
            if isempty(ctMat)
                ctMat = zeros(size(btMat));
            end
            if ~iscell(ctMat)
                ctStrCMat = getStrCMat(ctMat);
            else
                ctStrCMat = ctMat;
            end
            uEll = linSys.getUBoundsEll();
            [ptVec ptMat] =getEllParams(uEll, btMat);
            if ~iscell(ptMat)
                ptStrCMat = getStrCMat(ptMat);
            else
                ptStrCMat = ptMat;
            end
            if ~iscell(ptVec)
                ptStrCVec = getStrCMat(ptVec);
            else
                ptStrCVec = ptVec;
            end
            vEll = linSys.getDistBoundsEll();
            [qtVec qtMat] =getEllParams(vEll, ctMat);
            if ~iscell(qtMat)
                qtStrCMat = getStrCMat(qtMat);
            else
                qtStrCMat = qtMat;
            end
            if ~iscell(qtVec)
                qtStrCVec = getStrCMat(qtVec);
            else
                qtStrCVec = qtVec;
            end
            function outStrCMat = getStrCMat(inpMat)
                outStrCMat =...
                    arrayfun(@num2str, inpMat, 'UniformOutput', false);
            end
            function [centerVec, shapeMat] = getEllParams(inpEll, relMat)
                if isa(inpEll, 'ellipsoid')
                    if inpEll.isEmpty()
                        shapeMat = zeros(size(relMat, 2));
                        centerVec = zeros(size(relMat, 2), 1);
                    else
                        [centerVec shapeMat] = double(inpEll);
                    end
                elseif isstruct(inpEll)
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
                else
                    modgen.common.throwerror('wrongInput',...
                        'input must be either ellipsid or structure');
                end
            end
        end
        %
        function isDisturb = isDisturbance(ctStrCMat, qtStrCMat)
            import gras.mat.symb.iscellofstringconst;
            import gras.gen.MatVector;
            isDisturb = true;
            if iscellofstringconst(ctStrCMat)
                gtMat = MatVector.fromFormulaMat(ctStrCMat, 0);
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
    methods (Access = protected)
        function plotter = plotByApprox(self, approxType,...
                varargin)
            import gras.ellapx.smartdb.F;
            import gras.ellapx.enums.EProjType;
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            [reg,~,isShowDiscrete,nPlotPoints]=...
                modgen.common.parseparext(varargin,...
                {'showDiscrete','nSpacePartPoins' ;...
                false, self.nPlot3dPoints;
                @(x)isa(x,'logical'),@(x)isa(x,'double')});
            [colorVec, shade, lineWidth, isFill,reg] =...
                parceInputForPlot(approxType,reg{:});
            
            
            switch approxType
                case EApproxType.Internal
                    if ~self.isprojection()
                        nDims = self.dimension;
                        if nDims > 3 ||  nDims < 2
                            throwerror('WrongDim',...
                                'object dimension can be  2 or 3');
                        end
                        projReachObj = self.projection(eye(nDims));
                        
                    else
                        projReachObj= self;
                    end
                    plotter = projReachObj.ellTubeRel...
                        .getTuplesFilteredBy(...
                        F.APPROX_TYPE, approxType)...
                        .plotInt(reg{:},'fGetColor',...
                        @(x)(colorVec), 'fGetAlpha', @(x)(shade),...
                        'fGetLineWidth', @(x)(lineWidth),...
                        'fGetFill', @(x)(isFill),...
                        'nSpacePartPoins',nPlotPoints,...
                        'showDiscrete',isShowDiscrete);
                case EApproxType.External
                    if ~self.isprojection()
                        nDims = self.dimension;
                        if nDims > 3 ||  nDims < 2
                            throwerror('WrongDim',...
                                'object dimension can be  2 or 3');
                        end
                        projReachObj = self.projection(eye(nDims));
                        
                    else
                        projReachObj= self;
                    end
                    plotter = projReachObj.ellTubeRel...
                        .getTuplesFilteredBy(...
                        F.APPROX_TYPE, approxType)...
                        .plotExt(reg{:},'fGetColor',...
                        @(x)(colorVec), 'fGetAlpha', @(x)(shade),...
                        'fGetLineWidth', @(x)(lineWidth),...
                        'fGetFill', @(x)(isFill),...
                        'nSpacePartPoins',nPlotPoints,...
                        'showDiscrete',isShowDiscrete);
                otherwise
                    throwerror('WrongApproxType',...
                        'approxType %s is not supported',char(approxType));
            end
            
            
            
        end
    end
    methods (Access = private)
        function [dataCVec, indVec] = evolveApprox(self, ...
                newTimeVec, newLinSys, approxType)
            import gras.ellapx.smartdb.F;
            APPROX_TYPE = F.APPROX_TYPE;
            [filteredTubes, isThereVec] =...
                self.ellTubeRel.getTuplesFilteredBy(...
                APPROX_TYPE, approxType);
            oldData = filteredTubes.getData('denormGoodDirs',true);
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
                    l0Mat(:, il0Num) =...
                        oldData.ltGoodDirMat{il0Num}(:, 1);
                    %
                    x0VecMat(:, il0Num) = oldData.aMat{il0Num}(:, 1);
                    x0MatArray(:, :, il0Num) =...
                        oldData.QArray{il0Num}(:, :, 1);
                end
            else
                for il0Num = 1 : l0VecNum
                    l0Mat(:, il0Num) =...
                        oldData.ltGoodDirMat{il0Num}(:, end);
                    %
                    x0VecMat(:, il0Num) = oldData.aMat{il0Num}(:, end);
                    x0MatArray(:, :, il0Num) =...
                        oldData.QArray{il0Num}(:, :, end);
                end
            end
            [atStrCMat btStrCMat ctStrCMat ptStrCMat ptStrCVec ...
                qtStrCMat qtStrCVec] = ...
                self.prepareSysParam(newLinSys, newTimeVec);
            %
            % ext/int-approx on the next time interval
            %
            dataCVec = cell(1, l0VecNum);
            isDisturbance = self.isDisturbance(ctStrCMat, qtStrCMat);
            for il0Num = l0VecNum: -1 : 1
                probDynObj = self.getProbDynamics(atStrCMat, ...
                    btStrCMat, ptStrCMat, ptStrCVec, ctStrCMat, ...
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
        function ellTubeProjRel = getProjSet(self, projMat,...
                approxType, scaleFactor)
            import gras.ellapx.enums.EProjType;
            import gras.ellapx.smartdb.F;
            APPROX_TYPE = F.APPROX_TYPE;
            ProjCMatList = {projMat'};
            projType = EProjType.Static;
            if nargin > 2
                localEllTubeRel =...
                    self.ellTubeRel.getTuplesFilteredBy(...
                    APPROX_TYPE, approxType);
            else
                localEllTubeRel = self.ellTubeRel.getCopy();
            end
            if nargin == 4
                localEllTubeRel.scale(@(x) scaleFactor, {APPROX_TYPE});
            end
            ellTubeProjRel = localEllTubeRel.project(projType,...
                ProjCMatList, @fProj);
            function [projOrthMatArray,projOrthMatTransArray] ...
                    = fProj(projMat,timeVec,varargin)
                kSize = size(projMat,1);
                projMat = gras.la.matorth(projMat');
                projMat = projMat(:,1:kSize)';
                nTimes=length(timeVec);
                projOrthMatArray=repmat(projMat,[1 1 nTimes]);
                projOrthMatTransArray=repmat(projMat.',[1 1 nTimes]);
            end
        end
        function plotter = plotApprox(self, approxType, varargin)
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            import gras.ellapx.smartdb.F;
            APPROX_TYPE = F.APPROX_TYPE;
            
            [colorVec, shade, lineWidth, isFill,reg] =...
                parceInputForPlot(approxType,varargin{:});
            %
            [~, dim] = self.dimension();
            
            
            if self.isProj
                
                if dim < 2 || dim > 3
                    throwerror('wrongInput',...
                        'Dimension of projection must be 2 or 3.');
                else
                    plotter = self.ellTubeRel.getTuplesFilteredBy(...
                        APPROX_TYPE, approxType).plot(reg{:}, 'fGetColor',...
                        @(x)(colorVec), 'fGetAlpha', @(x)(shade),...
                        'fGetLineWidth', @(x)(lineWidth),...
                        'fGetFill', @(x)(isFill));
                end
            else
                if dim < 2 || dim > 3
                    plObj = smartdb.disp.RelationDataPlotter();
                    plotter = self.ellTubeRel.getTuplesFilteredBy(...
                        APPROX_TYPE, approxType).plot(plObj);
                else
                    projReachObj = self.projection(eye(dim));
                    plObj = smartdb.disp.RelationDataPlotter();
                    plotter = projReachObj.ellTubeRel.getTuplesFilteredBy(...
                        APPROX_TYPE, approxType).plot(plObj);
                end
                
            end
            
            
            
        end
        %
        function ellTubeRel = makeEllTubeRel(self, probDynObj, l0Mat,...
                timeVec, isDisturb, calcPrecision, approxTypeVec)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.gen.RegProblemDynamicsFactory;
            import modgen.common.throwerror;
            %
            probDynObj = RegProblemDynamicsFactory.create(probDynObj,...
                self.isRegEnabled, self.isJustCheck, self.regTol);
            try
                ellTubeRel = self.internalMakeEllTubeRel(...
                    probDynObj,  l0Mat, timeVec, isDisturb, ...
                    calcPrecision, approxTypeVec);
            catch meObj
                errorStr = '';
                errorTag = '';
                %
                if isMatch(['GRAS:ELLAPX:SMARTDB:RELS:',...
                        'ELLTUBETOUCHCURVEBASIC:',...
                        'CHECKTOUCHCURVEINDEPENDENCE:',...
                        'wrongInput:touchCurveDependency'])
                    errorStr = [self.EMSG_CALC_PREC_PROB, ...
                        self.EMSG_BAD_TIME_VEC, self.EMSG_BAD_CONTROL, ...
                        self.EMSG_BAD_DIST, self.EMSG_BAD_INIT_SET];
                    errorTag = [self.ETAG_WR_INP, self.ETAG_BAD_CALC_PREC];
                elseif isMatch(['SMARTDB:RELS:ELLTUBEBASIC:',...
                        'CHECKDATACONSISTENCY:wrongInput:QArrayNotPos'])
                    errorStr = [self.EMSG_R_PROB, self.EMSG_USE_REG];
                    errorTag = [self.ETAG_WR_INP, self.ETAG_R_PROB, ...
                        self.ETAG_LOW_REG_TOL];
                elseif isMatch('MODGEN:COMMON:CHECKVAR:wrongInput')
                    errorStr = [self.EMSG_R_PROB, self.EMSG_USE_REG];
                    errorTag = [self.ETAG_WR_INP, ...
                        self.ETAG_R_PROB, self.ETAG_ONLY_CHECK];
                end
                if isempty(errorStr)
                    rethrow(meObj);
                else
                    friendlyMeObj = throwerror(errorTag, errorStr);
                    friendlyMeObj = addCause(friendlyMeObj, meObj);
                    throw(friendlyMeObj);
                end
            end
            function isPos=isMatch(patternStr)
                isPos=~isempty(strfind(meObj.identifier,patternStr));
            end
        end
    end
    methods
        function self=AReach(linSys, x0Ell, l0Mat, timeVec, varargin)
            import modgen.common.checkmultvar;
            import modgen.common.checkvar;
            import modgen.common.throwerror;
            import elltool.conf.Properties;
            import gras.ellapx.enums.EApproxType;
            %
            if nargin>0
                NEEDED_PROP_LIST =...
                    {'absTol', 'relTol', 'nPlot2dPoints',...
                    'nPlot3dPoints','nTimeGridPoints','regTol'};
                [self.absTol, self.relTol, self.nPlot2dPoints,...
                    self.nPlot3dPoints, self.nTimeGridPoints,...
                    self.regTol,restList]=...
                    Properties.parseProp(varargin, NEEDED_PROP_LIST);
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
                if ~isa(linSys, self.LINSYS_CLASS_STRING)
                    throwerror('wrongInput', ['first input argument ',...
                        'must be linear system object.']);
                end
                if ~isa(x0Ell, 'ellipsoid')
                    throwerror('wrongInput', ['set of initial ',...
                        'conditions must be ellipsoid.']);
                end
                checkmultvar(...
                    'dimension(x1)==dimension(x2)&&dimension(x2)==size(x3,1)',...
                    3,linSys,x0Ell,l0Mat);
                %
                checkvar(timeVec,'isnumeric(x)&isrow(x)&&numel(x)==2',...
                    'errorTag','wrongInput', 'errorMessage',...
                    'time interval must be specified by a vector');
                %
                [~, ~, self.isRegEnabled, self.isJustCheck] =...
                    modgen.common.parseparext(restList,...
                    {'isRegEnabled', 'isJustCheck';...
                    false, false;...
                    'islogical(x)&&isscalar(x)',...
                    'islogical(x)&&isscalar(x)'},0);
                %
                % create gras LinSys object
                %
                [x0Vec, x0Mat] = double(x0Ell);
                [atStrCMat, btStrCMat, ctStrCMat, ptStrCMat, ptStrCVec,...
                    qtStrCMat, qtStrCVec] =...
                    self.prepareSysParam(linSys, timeVec);
                isDisturbance = self.isDisturbance(ctStrCMat, qtStrCMat);
                %
                % Normalize good directions
                %
                sysDim = size(atStrCMat, 1);
                l0Mat = self.getNormMat(l0Mat, sysDim);
                %
                probDynObj = self.getProbDynamics(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, ctStrCMat, qtStrCMat, qtStrCVec,...
                    x0Mat, x0Vec, timeVec, self.relTol, isDisturbance);
                approxTypeVec = [EApproxType.External, EApproxType.Internal];
                %
                %temporary plug used until we replace calcPrecision with
                %separate relTol and absTol fields in EllTube classes
                calcPrecision=max(self.relTol,self.absTol);
                self.ellTubeRel = self.makeEllTubeRel(probDynObj, l0Mat,...
                    timeVec, isDisturbance, calcPrecision, approxTypeVec);
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
        function isEmptyArr = isEmpty(self)
            isEmptyArr = fApplyArrMethod(self,'x0Ellipsoid','isempty');
        end
        %
        function isEmptyIntersect =...
                intersect(self, intersectObj, approxTypeChar)
            import modgen.common.throwerror;
            if ~ (isa(intersectObj, 'ellipsoid') ||...
                    ~isa(intersectObj, 'hyperplane') ||...
                    ~isa(intersectObj, 'polytope'))
                throwerror('wrongInput',...
                    ['first input argument must be ',...
                    'ellipsoid, hyperplane or polytope.']);
            end
            if (nargin < 3) || ~ischar(approxTypeChar)
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
        function [isEqual,reportStr] = isEqual(self, reachObj, varargin)
            %
            % ISEQUAL - checks for equality given reach set objects
            %
            % Input:
            %   regular:
            %       self.
            %       reachObj:
            %           elltool.reach.AReach[1, 1] - each set object, which
            %            compare with self.
            %   optional:
            %       indTupleVec: double[1,] - tube numbers that are
            %           compared
            %       approxType: gras.ellapx.enums.EApproxType[1, 1] -  type of
            %           approximation, which will be compared.
            %   properties:
            %       notComparedFieldList: cell[1,k] - fields not to compare
            %           in tubes. Default: LT_GOOD_DIR_*, LS_GOOD_DIR_*,
            %           IND_S_TIME, S_TIME, TIME_VEC
            %       areTimeBoundsCompared: logical[1,1] - treat tubes with
            %           different timebounds as inequal if 'true'.
            %           Default: false
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
            [isEqual, reportStr] = self.ellTubeRel.isEqual(...
                reachObj.ellTubeRel,varargin{:});
        end
        %
        function display(self)
            import gras.ellapx.enums.EApproxType;
            fprintf('\n');
            if self.isEmpty()
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
        function [directionsCVec timeVec,l0Mat] = get_directions(self)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.smartdb.F;
            APPROX_TYPE = F.APPROX_TYPE;
            SData = self.ellTubeRel.getTuplesFilteredBy(APPROX_TYPE,...
                EApproxType.External);
            if self.isprojection()
                ltGoodDirFieldName='ltGoodDirOrigProjMat';
            else
                ltGoodDirFieldName='ltGoodDirMat';
            end
            directionsCVec = SData.(ltGoodDirFieldName).';
            lsGoodDirVecList=cellfun(@(x,y)x(:,y),...
                SData.(ltGoodDirFieldName),...
                num2cell(SData.indSTime),'UniformOutput',false);
            %
            if nargout > 1
                timeVec = SData.timeVec{1};
                if nargout>2
                    l0Mat=horzcat(lsGoodDirVecList{:});
                end
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
            ellTubeProjRel = self.getProjSet(projMat);
            projObj = self.getCopy();
            projObj.ellTubeRel = ellTubeProjRel.getCopy();
            projObj.isProj = true;
            projObj.projectionBasisMat = projMat;
        end
        %
        
        function eaPlotter = plotEa(self, varargin)
            import gras.ellapx.enums.EApproxType;
            eaPlotter = self.plotApprox(EApproxType.External, varargin{:});
        end
        %
        
        function iaPlotter = plotIa(self, varargin)
            import gras.ellapx.enums.EApproxType;
            iaPlotter = self.plotApprox(EApproxType.Internal,...
                varargin{:});
        end
        %
        function eaPlotter = plotByEa(self, varargin)
            %
            % plotByEa - plots external approximation of reach tube.
            %
            %
            % Usage:
            %       plotByEa(self,'Property',PropValue,...)
            %       - plots external approximation of reach tube
            %            with  setting properties
            %
            % Input:
            %   regular:
            %       self: - reach tube
            %
            %   optional:
            %       relDataPlotter:smartdb.disp.RelationDataPlotter[1,1] - relation data plotter object.
            %       charColor: char[1,1]  - color specification code, can be 'r','g',
            %                      etc (any code supported by built-in Matlab function).
            %   properties:
            %
            %       'fill': logical[1,1]  -
            %               if 1, tube in 2D will be filled with color.
            %               Default value is true.
            %       'lineWidth': double[1,1]  -
            %                    line width for 2D plots. Default value is 2.
            %       'color': double[1,3] -
            %                sets default colors in the form [x y z].
            %                   Default value is [0 0 1].
            %       'shade': double[1,1]  -
            %      level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
            %                Default value is 0.3.
            %
            % Output:
            %   regular:
            %       plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
            %       data plotter object.
            %
            %
            % $Author: <Ilya Lyubich>  <lubi4ig@gmail.com> $    $Date: <15 July 2013> $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Cybernetics,
            %            System Analysis Department 2013 $
            import gras.ellapx.enums.EApproxType;
            eaPlotter = self.plotByApprox(EApproxType.External,...
                varargin{:});
            
        end
        function iaPlotter = plotByIa(self, varargin)
            % plotByIa - plots internal approximation of reach tube.
            %
            %
            % Usage:
            %       plotByIa(self,'Property',PropValue,...)
            %       - plots internal approximation of reach tube
            %            with  setting properties
            %
            % Input:
            %   regular:
            %       self: - reach tube
            %
            %   optional:
            %       relDataPlotter:smartdb.disp.RelationDataPlotter[1,1] - relation data plotter object.
            %       charColor: char[1,1]  - color specification code, can be 'r','g',
            %                      etc (any code supported by built-in Matlab function).
            %   properties:
            %
            %       'fill': logical[1,1]  -
            %               if 1, tube in 2D will be filled with color.
            %               Default value is true.
            %       'lineWidth': double[1,1]  -
            %                    line width for 2D plots. Default value is 2.
            %       'color': double[1,3] -
            %                sets default colors in the form [x y z].
            %                   Default value is [0 1 0].
            %       'shade': double[1,1]  -
            %      level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
            %                Default value is 0.1.
            %
            % Output:
            %   regular:
            %       plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
            %       data plotter object.
            %
            %
            % $Author: <Ilya Lyubich>  <lubi4ig@gmail.com> $    $Date: <15 July 2013> $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Cybernetics,
            %            System Analysis Department 2013 $
            import gras.ellapx.enums.EApproxType;
            iaPlotter = self.plotByApprox(EApproxType.Internal,...
                varargin{:});
            
        end
        
        function outReachObj = refine(self, l0Mat)
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
            outReachObj=self.getCopy();
            %
            sysTimeVecLenght = numel(outReachObj.linSysCVec);
            linSys = outReachObj.linSysCVec{1};
            %
            if outReachObj.isBackward
                timeLimsVec = ...
                    [outReachObj.switchSysTimeVec(end),...
                    outReachObj.switchSysTimeVec(end - 1)];
            else
                timeLimsVec = ...
                    [outReachObj.switchSysTimeVec(1),...
                    outReachObj.switchSysTimeVec(2)];
            end
            
            x0Ell = outReachObj.x0Ellipsoid;
            %
            % Normalize good directions
            %
            nDim = dimension(x0Ell);
            l0Mat = outReachObj.getNormMat(l0Mat, nDim);
            reachSetObj = feval(class(outReachObj), linSys, x0Ell,...
                l0Mat, timeLimsVec);
            %
            for iLinSys = 2 : sysTimeVecLenght
                reachSetObj = ...
                    reachSetObj.evolve(...
                    getNewTime(outReachObj.switchSysTimeVec,...
                    outReachObj.isBackward,iLinSys),...
                    outReachObj.linSysCVec{iLinSys});
            end
            %
            if outReachObj.isProj
                projMat = outReachObj.projectionBasisMat;
                ellTubeProjRel = reachSetObj.getProjSet(projMat);
                outReachObj.ellTubeRel.unionWith(ellTubeProjRel);
            else
                outReachObj.ellTubeRel.unionWith(reachSetObj.getEllTubeRel());
            end
            
            function newTime = getNewTime(sysTimeVec,isBackward,ind)
                if isBackward
                    newTime = sysTimeVec(end - ind);
                else
                    newTime = sysTimeVec(ind + 1);
                end
            end
        end
        %
        function cutObj = cut(self, cutTimeVec)
            import modgen.common.throwerror;
            if numel(cutTimeVec) > 2
                throwerror('wrongInput',...
                    'Time vector must consist of one or two elements.');
            end
            cutObj = self.getCopy();
            if cutTimeVec(1) > cutTimeVec(end)
                cutTimeVec = fliplr(cutTimeVec);
            end
            switchTimeVec = self.switchSysTimeVec;
            cutObj.ellTubeRel = self.ellTubeRel.cut(cutTimeVec);
            switchTimeIndVec =...
                switchTimeVec > cutTimeVec(1) &...
                switchTimeVec < cutTimeVec(end);
            switchSystemsTimeVec = [cutTimeVec(1)...
                switchTimeVec(switchTimeIndVec) cutTimeVec(end)];
            if cutTimeVec(1) == cutTimeVec(end)
                switchSystemsTimeVec = switchSystemsTimeVec(1:end - 1);
            end
            cutObj.switchSysTimeVec = switchSystemsTimeVec;
            firstIntInd = find(switchTimeIndVec == true, 1);
            if ~isempty(firstIntInd)
                switchTimeIndVec(firstIntInd - 1) = true;
            else
                firstGreaterInd =...
                    find(switchTimeVec >= cutTimeVec(end), 1);
                switchTimeIndVec(max(1, firstGreaterInd - 1)) = true;
            end
            maxIncludedInd = find(switchTimeIndVec == 1, 1, 'last');
            switchTimeIndVec(1 : maxIncludedInd) = true;
            cutObj.linSysCVec =...
                self.linSysCVec(switchTimeIndVec(1 : end - 1));
            cutObj.isCut = true;
        end
        %
        function copyReachObjArr = getCopy(self,varargin)
            % Input:
            %   regular:
            %       self:
            %   properties:
            %       l0Mat: double[nDims,nDirs] - matrix of good
            %           directions at time s
            %       isIntExtApxVec: logical[1,2] - two element vector with the
            %          first element corresponding to internal approximations
            %         and second - to external ones. An element equal to
            %          false means that the corresponding approximation type
            %          is filtered out. Default value is [true,true]
            % Example:
            %     aMat = [0 1; 0 0]; bMat = eye(2);
            %     SUBounds = struct();
            %     SUBounds.center = {'sin(t)'; 'cos(t)'};
            %     SUBounds.shape = [9 0; 0 2];
            %     sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
            %     x0EllObj = ell_unitball(2);
            %     timeVec = [0 10];
            %     dirsMat = [1 0; 0 1; 1 1;1 2]';
            %     rsObj = elltool.reach.ReachContinuous(sys, x0EllObj,...
            %       dirsMat, timeVec);
            %
            %     copyRsObj = rsObj.getCopy()
            %
            %     Reach set of the continuous-time linear system in R^2 in
            %       the time interval [0, 10].
            %
            %     Initial set at time k0 = 0:
            %     Ellipsoid with parameters
            %     Center:
            %          0
            %          0
            %
            %     Shape Matrix:
            %          1     0
            %          0     1
            %
            %     Number of external approximations: 4
            %     Number of internal approximations: 4
            %
            %     copyRsObj = rsObj.getCopy('l0Mat',[0;1],'approxType',...
            %       [true,false])
            %
            %     Reach set of the continuous-time linear system in R^2 in
            %       the time interval [0, 10].
            %
            %     Initial set at time k0 = 0:
            %     Ellipsoid with parameters
            %     Center:
            %          0
            %          0
            %
            %     Shape Matrix:
            %          1     0
            %          0     1
            %
            %     Number of external approximations: 1
            %     Number of internal approximations: 1
            import modgen.common.parseparext;
            import gras.ellapx.enums.EApproxType;
            INT_EXT_APX_TYPE_VEC=[EApproxType.Internal,EApproxType.External];
            %
            [~,~,isIntExtApxVec,lsGoodDirMat,isIntExtApxVecSpec,...
                isLsGoodDirMat]=parseparext(varargin,...
                {'isIntExtApxVec','l0Mat';...
                [true true],[];...
                'isrow(x)&&numel(x)==2&&islogical(x)&&sum(x)>0',...
                @(x)isa(x,'double')&&ismatrix(x)},0);
            if ~isempty(self)
                sizeCVec = num2cell(size(self));
                copyReachObjArr(sizeCVec{:}) = feval(class(self(1, 1)));
                arrayfun(@fSingleCopy,copyReachObjArr,self);
            else
                copyReachObjArr = self.empty(size(self));
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
                %
                curEllTubeRel=reachObj.ellTubeRel;
                nTuples=curEllTubeRel.getNTuples();
                if isIntExtApxVecSpec&&~all(isIntExtApxVec)
                    approxType=INT_EXT_APX_TYPE_VEC(isIntExtApxVec);
                    isThereVec=ismember(curEllTubeRel.approxType,...
                        approxType);
                else
                    isThereVec=true(nTuples,1);
                end
                relTolVal=reachObj.relTol;
                if isLsGoodDirMat
                    nDims=size(lsGoodDirMat,1);
                    lsGoodDirNormVec=realsqrt(dot(lsGoodDirMat,...
                        lsGoodDirMat,1));
                    lsGoodDirMat=lsGoodDirMat./repmat(lsGoodDirNormVec,nDims,1);
                    isThereVec=isThereVec&(...
                        curEllTubeRel.applyTupleGetFunc(...
                        @getIsClose,'lsGoodDirVec'));
                end
                copyReachObj.ellTubeRel = curEllTubeRel.getTuples(isThereVec);
                %
                function isPos=getIsClose(dirVec)
                    dirVecNorm=norm(dirVec);
                    dirVec=dirVec./dirVecNorm;
                    dirMat=repmat(dirVec,1,size(lsGoodDirMat,2));
                    diffMat=dirMat-lsGoodDirMat;
                    relDistVec=realsqrt(dot(diffMat,diffMat,1));
                    isPos=any(relDistVec<=relTolVal);
                end
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
            import gras.ellapx.smartdb.rels.EllUnionTubeStaticProj;
            if (self.isprojection())
                ellTubeUnionRel = ...
                    EllUnionTubeStaticProj.fromEllTubes(self.ellTubeRel);
            else
                ellTubeUnionRel = ...
                    EllUnionTube.fromEllTubes(self.ellTubeRel);
            end
        end
        %
        function switchTimeVec = getSwitchTimeVec(self)
            switchTimeVec = self.switchSysTimeVec;
        end
        %
        function newReachObj = evolve(self, newEndTime, linSys)
            import elltool.conf.Properties;
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
            import gras.ellapx.uncertcalc.EllApxBuilder;
            import modgen.common.throwerror;
            MAX_ALLOWED_CAT_TOL=1e-12;
            %
            % check and analize input
            %
            if nargin < 2
                throwerror('wrongInput', ['insufficient number ',...
                    'of input arguments.']);
            end
            if self.isProj
                throwerror('wrongInput',...
                    'evolve for projections is not supported');
            end
            if nargin < 3
                newLinSys = self.get_system();
                oldLinSys = newLinSys;
            else
                if ~isa(linSys,self.LINSYS_CLASS_STRING)
                    throwerror('wrongInput',...
                        sprintf(['first input argument ',...
                        'must be linear system object of type %s'],...
                        self.LINSYS_CLASS_STRING));
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
            self.checkIndSTime(newEllTubeRel);
            %
            indVec = [indIntVec; indExtVec];
            [~, indRelVec] = sort(indVec);
            newEllTubeRel = newEllTubeRel.getTuples(indRelVec);
            %
            inpArgList={'commonTimeAbsTol',MAX_ALLOWED_CAT_TOL,...
                'commonTimeRelTol',MAX_ALLOWED_CAT_TOL};
            if self.isBackward
                newReachObj.ellTubeRel =...
                    newEllTubeRel.cat(self.ellTubeRel,inpArgList{:},...
                    'isReplacedByNew',true);
            else
                newReachObj.ellTubeRel =...
                    self.ellTubeRel.cat(newEllTubeRel,inpArgList{:});
            end
        end
    end
end
function [colorVec, shade, lineWidth, isFill,reg] =...
    parceInputForPlot(approxType,varargin)
import gras.ellapx.enums.EApproxType;
import modgen.common.throwerror;
import gras.ellapx.smartdb.F;
DEFAULT_EA_COLOR_VEC = [0 0 1];
DEFAULT_IA_COLOR_VEC = [0 1 0];
DEFAULT_LINE_WIDTH = 2;
DEFAULT_EA_SHADE = 0.3;
DEFAULT_IA_SHADE = 0.1;
DEFAULT_FILL = false;
%
if approxType == EApproxType.External
    [reg, ~, colorVec, shade, lineWidth, isFill,...
        isColorVec, ~, ~, ~] = ...
        modgen.common.parseparext(varargin,...
        {'color', 'shade', 'width', 'fill';...
        DEFAULT_EA_COLOR_VEC, DEFAULT_EA_SHADE,...
        DEFAULT_LINE_WIDTH, DEFAULT_FILL;...
        'isvector(x)',...
        @(x)(isa(x, 'double') && (x >= 0) && (x <= 1)),...
        @(x)(isa(x, 'double') && (x > 0)), 'islogical(x)'});
else
    [reg, ~, colorVec, shade, lineWidth, isFill,...
        isColorVec, ~, ~, ~] = ...
        modgen.common.parseparext(varargin,...
        {'color', 'shade', 'width', 'fill';...
        DEFAULT_IA_COLOR_VEC, DEFAULT_IA_SHADE,...
        DEFAULT_LINE_WIDTH, DEFAULT_FILL;...
        'isvector(x)',...
        @(x)(isa(x, 'double') && (x >= 0) && (x <= 1)),...
        @(x)(isa(x, 'double') && (x > 0)), 'islogical(x)'});
end
%
if ischar(colorVec)
    colorVec = getColorVec(colorVec);
end


%
if ~isempty(reg)
    if ischar(reg{1})
        if isColorVec
            throwerror('ConflictingColor',...
                'Conflicting using of color property');
        else
            colorVec = getColorVec(reg{1});
        end
        reg(1) = [];
    elseif numel(reg) > 1
        if ischar(reg{2})
            if isColorVec
                throwerror('ConflictingColor',...
                    'Conflicting using of color property');
            else
                colorVec = getColorVec(reg{2});
            end
            reg(2) = [];
        end
    end
end


end
function colCodeVec = getColorVec(colChar)
if ~(ischar(colChar))
    colCodeVec = [0 0 0];
    return;
end
switch colChar
    case 'r',
        colCodeVec = [1 0 0];
    case 'g',
        colCodeVec = [0 1 0];
    case 'b',
        colCodeVec = [0 0 1];
    case 'y',
        colCodeVec = [1 1 0];
    case 'c',
        colCodeVec = [0 1 1];
    case 'm',
        colCodeVec = [1 0 1];
    case 'w',
        colCodeVec = [1 1 1];
    otherwise,
        colCodeVec = [0 0 0];
end
end