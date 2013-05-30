classdef ReachContinuous < elltool.reach.AReach
    % Continuous reach set library of the Ellipsoidal Toolbox.
    %
    %
    % $Authors: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
    %           Kirill Mayantsev <kirill.mayantsev@gmail.com> $
    % $Date: March-2013 $
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2013$
    properties (Constant, GetAccess = private)
        MIN_EIG_Q_REG_UNCERT = 0.1
        EXTERNAL_SCALE_FACTOR = 1.02
        INTERNAL_SCALE_FACTOR = 0.98
        DEFAULT_INTAPX_S_SELECTION_MODE = 'volume'
        COMP_PRECISION = 5e-3
        FIELDS_NOT_TO_COMPARE={'LT_GOOD_DIR_MAT';'LT_GOOD_DIR_NORM_VEC';...
            'LS_GOOD_DIR_NORM';'LS_GOOD_DIR_VEC';'IND_S_TIME';...
            'S_TIME';'TIME_VEC'};
    end
    properties (Access = private)
        ellTubeRel
        isRegEnabled
        isJustCheck
        regTol
    end
    methods (Access = private)
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
                localEllTubeRel = self.ellTubeRel.getCopy();
            end
            if nargin == 4
                localEllTubeRel.scale(@(x) scaleFactor, {APPROX_TYPE});
            end
            projSet = localEllTubeRel.project(projType,...
                ProjCMatList, fProj);
        end
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
            DEFAULT_FILL = false;

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
                    scaleFactor = self.EXTERNAL_SCALE_FACTOR;
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
                    scaleFactor = self.INTERNAL_SCALE_FACTOR;
            end
            
            checkIsWrongInput();
            
            if (nargin > 2) && ~isempty(reg)
                if ischar(reg{1})
                    if isColorVec
                        throwerror('ConflictingColor',...
                            'Conflicting using of color property');
                    else
                        colorVec = getColorVec(reg{1});
                    end
                end
            end
            
            if ischar(colorVec)
                colorVec = getColorVec(colorVec);
            end

            %
            if self.isProj
                [~, dim] = self.dimension();
                if dim < 2 || dim > 3
                    throwerror('wrongInput',...
                        'Dimension of projection must be 2 or 3.');
                else
                    plObj = smartdb.disp.RelationDataPlotter();
                    plotter = self.ellTubeRel.getTuplesFilteredBy(...
                        APPROX_TYPE, approxType).plot(plObj, 'fGetColor',...
                        @(x)(colorVec), 'fGetAlpha', @(x)(shade),...
                        'fGetLineWidth', @(x)(lineWidth),...
                        'fGetFill', @(x)(isFill));
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
                plotter = projSetObj.plot(plObj, 'fGetColor',...
                    @(x)(colorVec), 'fGetAlpha', @(x)(shade),...
                    'fGetLineWidth', @(x)(lineWidth),...
                    'fGetFill', @(x)(isFill));
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
            
            function checkIsWrongInput()
                import modgen.common.throwerror;
                cellfun(@(x)checkIfNoColorCharPresent(x),reg);
                cellfun(@(x)checkRightPropName(x),reg);
                checkIfNoColorCharPresent(colorVec);
                checkColorSize(colorVec);
                
                function checkColorSize(colorVec)
                    import modgen.common.throwerror;
                    if isa(colorVec, 'double') && (size(colorVec, 2) ~= 3)
                        throwerror('wrongColorVecSize', ...
                            'ColorVec is a vector of length 3');
                    end
                end
        
                function checkIfNoColorCharPresent(value)
                    import modgen.common.throwerror;
                    if ischar(value)&&(numel(value)==1)&&~isColorDef(value)
                        throwerror('wrongColorChar', ...
                            'You can''t use this symbol as a color');
                    end
                    function isColor = isColorDef(value)
                        isColor = eq(value, 'r') | eq(value, 'g') | eq(value, 'b') | ...
                            eq(value, 'y') | eq(value, 'c') | ...
                            eq(value, 'm') | eq(value, 'w');
                    end
                end
                function checkRightPropName(value)
                    import modgen.common.throwerror;
                    if ischar(value)&&(numel(value)>1)
                        if ~isRightProp(value)
                            throwerror('wrongProperty', ...
                                'This property doesn''t exist');
                        else
                            throwerror('wrongPropertyValue', ...
                                'There is no value for property.');
                        end
                    elseif ~ischar(value)
                        throwerror('wrongPropertyType', 'Property must be a string.');
                    end
                    function isRProp = isRightProp(value)
                        isRProp = strcmpi(value, 'fill') |...
                            strcmpi(value, 'width') | ...
                            strcmpi(value, 'shade') | strcmpi(value, 'color');
                    end
                end
            end
        end
        
        function [dataCVec, indVec]= evolveApprox(self,...
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
            [atStrCMat btStrCMat gtStrCMat ptStrCMat ptStrCVec...
                qtStrCMat qtStrCVec] =...
                self.prepareSysParam(newLinSys, newTimeVec);
            %% Normalize good ext/int-directions
            sysDim = size(atStrCMat, 1);
            l0Mat = self.getNormMat(l0Mat, sysDim);
            %% ext/int-approx on the next time interval
            dataCVec = cell(1, l0VecNum);
            isDisturbance = self.isDisturbance(gtStrCMat, qtStrCMat);
            relTol = elltool.conf.Properties.getRelTol();
            for il0Num = l0VecNum: -1 : 1
                smartLinSys = self.getSmartLinSys(atStrCMat,...
                    btStrCMat, ptStrCMat, ptStrCVec, gtStrCMat,...
                    qtStrCMat, qtStrCVec, x0MatArray(:, :, il0Num),...
                    x0VecMat(:, il0Num), [min(newTimeVec),...
                    max(newTimeVec)], relTol, isDisturbance);
                ellTubeRelVec{il0Num} = self.makeEllTubeRel(...
                    smartLinSys, l0Mat(:, il0Num),...
                    [min(newTimeVec) max(newTimeVec)], isDisturbance,...
                    relTol, approxType);
                dataCVec{il0Num} =...
                    ellTubeRelVec{il0Num}.getTuplesFilteredBy(...
                    APPROX_TYPE, approxType).getData();
            end
        end
        function ellTubeRel = makeEllTubeRel(self, smartLinSys, l0Mat,...
                timeVec, isDisturb, calcPrecision, approxTypeVec)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.gen.RegProblemDynamicsFactory;
            import gras.ellapx.lreachplain.GoodDirsContinuousFactory;
            import modgen.common.throwerror;
            %
            smartLinSys = RegProblemDynamicsFactory.create(smartLinSys,...
                self.isRegEnabled, self.isJustCheck, self.regTol);
            relTol = elltool.conf.Properties.getRelTol();
            goodDirSetObj = GoodDirsContinuousFactory.create(...
                smartLinSys, timeVec(1), l0Mat, calcPrecision);
            try
                if isDisturb
                    extIntBuilder =...
                        gras.ellapx.lreachuncert.ExtIntEllApxBuilder(...
                        smartLinSys, goodDirSetObj, timeVec,...
                        relTol,...
                        self.DEFAULT_INTAPX_S_SELECTION_MODE,...
                        self.MIN_EIG_Q_REG_UNCERT);
                    ellTubeBuilder =...
                        gras.ellapx.gen.EllApxCollectionBuilder(...
                        {extIntBuilder});
                    ellTubeRel = ellTubeBuilder.getEllTubes();
                else
                    isIntApprox =...
                        any(approxTypeVec == EApproxType.Internal);
                    isExtApprox =...
                        any(approxTypeVec == EApproxType.External);
                    if isExtApprox
                        extBuilder =...
                            gras.ellapx.lreachplain.ExtEllApxBuilder(...
                            smartLinSys, goodDirSetObj, timeVec,...
                            relTol);
                        extellTubeBuilder =...
                            gras.ellapx.gen.EllApxCollectionBuilder(...
                            {extBuilder});
                        extEllTubeRel = extellTubeBuilder.getEllTubes();
                        if ~isIntApprox
                            ellTubeRel = extEllTubeRel;
                        end
                    end
                    if isIntApprox
                        intBuilder =...
                            gras.ellapx.lreachplain.IntEllApxBuilder(...
                            smartLinSys, goodDirSetObj, timeVec,...
                            relTol,...
                            self.DEFAULT_INTAPX_S_SELECTION_MODE);
                        intellTubeBuilder =...
                            gras.ellapx.gen.EllApxCollectionBuilder(...
                            {intBuilder});
                        intEllTubeRel = intellTubeBuilder.getEllTubes();
                        if isExtApprox
                            intEllTubeRel.unionWith(extEllTubeRel);
                        end
                        ellTubeRel = intEllTubeRel;
                    end
                end
            catch meObj
                errorStr = '';
                errorTag = '';
                ETAG_WR_INP = 'wrongInput';
                ETAG_R_PROB = ':regProblem';
                ETAG_R_DISABLED = ':RegIsDisabled';
                ETAG_ONLY_CHECK = ':onlyCheckIsEnabled';
                ETAG_LOW_REG_TOL = ':regTolIsTooLow';
                ETAG_ODE_45_REG_TOL = ':Ode45Failed';
                ETAG_BAD_CALC_PREC = ':BadCalcPrec';
                ETAG_BAD_INIT_SET = ':BadInitSet';
                %
                EMSG_R_PROB = 'There is a problem with regularization. ';
                EMSG_INIT_SET_PROB = ['There is a problem with initial',...
                    ' set (x0Ell, second parameter). '];
                EMSG_CALC_PREC_PROB = ['There is a problem with ',...
                    'calculation precision. Try to do some of this: '];
                EMSG_USE_REG = ['Try to enable it: set property ',...
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
                EMSG_BAD_CONTROL = [FIRST_COMMON_PART_BAD_ELL_STR,...
                    'control', SECOND_COMMON_PART_BAD_ELL_STR];
                EMSG_BAD_DIST = [FIRST_COMMON_PART_BAD_ELL_STR,...
                    'disturbance', SECOND_COMMON_PART_BAD_ELL_STR];
                EMSG_BAD_INIT_SET = [FIRST_COMMON_PART_BAD_ELL_STR,...
                    'initial set', SECOND_COMMON_PART_BAD_ELL_STR];
                %
                if strcmp(meObj.identifier,...
                        'MODGEN:COMMON:CHECKVAR:wrongInput')
                    errorStr = [EMSG_R_PROB, EMSG_USE_REG];
                    errorTag = [ETAG_WR_INP, ETAG_R_PROB, ETAG_ONLY_CHECK];
                elseif strcmp(meObj.identifier, 'MATLAB:badsubscript')
                    errorStr = [EMSG_R_PROB, EMSG_LOW_REG_TOL];
                    errorTag = [ETAG_WR_INP, ETAG_R_PROB, ETAG_LOW_REG_TOL];
                elseif strcmp(meObj.identifier,...
                        'GRAS:ODE:ODE45REG:wrongState')
                    errorStr = [EMSG_R_PROB, EMSG_LOW_REG_TOL];
                    errorTag = [ETAG_WR_INP, ETAG_R_PROB,...
                        ETAG_LOW_REG_TOL, ETAG_ODE_45_REG_TOL];
                elseif strcmp(meObj.identifier,...
                        ['GRAS:ELLAPX:SMARTDB:RELS:',...
                        'ELLTUBETOUCHCURVEBASIC:',...
                        'CHECKTOUCHCURVEINDEPENDENCE:',...
                        'wrongInput:touchCurveDependency'])
                    errorStr = [EMSG_CALC_PREC_PROB, EMSG_BAD_TIME_VEC,...
                        EMSG_BAD_CONTROL, EMSG_BAD_DIST,...
                        EMSG_BAD_INIT_SET];
                    errorTag = [ETAG_WR_INP, ETAG_BAD_CALC_PREC];
                elseif strcmp(meObj.identifier,...
                        ['GRAS:ELLAPX:LREACHUNCERT:EXTINTELLAPXBUILDER',...
                        ':EXTINTELLAPXBUILDER:wrongInput'])
                    errorStr = [EMSG_INIT_SET_PROB, EMSG_SMALL_INIT_SET];
                    errorTag = [ETAG_WR_INP, ETAG_BAD_INIT_SET];
                elseif strcmp(meObj.identifier,...
                        ['GRAS:ELLAPX:LREACHUNCERT:EXTINTELLAPXBUILDER',...
                        ':CALCELLAPXMATRIXDERIV:wrongInput']) ||...
                    strcmp(meObj.identifier,...
                        ['GRAS:ELLAPX:SMARTDB:RELS:ELLTUBEBASIC:',...
                        'CHECKDATACONSISTENCY:wrongInput:QArrayNotPos'])
                    errorStr = [EMSG_R_PROB, EMSG_USE_REG];
                    errorTag = [ETAG_WR_INP, ETAG_R_PROB, ETAG_R_DISABLED];
                end
                if isempty(errorStr)
                    throw(meObj);
                else
                    friendlyMeObj = throwerror(errorTag, errorStr);
                    friendlyMeObj = addCause(friendlyMeObj, meObj);
                    throw(friendlyMeObj);
                end
            end
        end
    end
    methods (Access = private, Static)

        function backwardStrCMat = getBackwardCMat(strCMat, tSum, isMinus)
            t = sym('t');
            t = tSum-t;
            %
            evCMat = cellfun(@eval, strCMat, 'UniformOutput', false);
            symIndMat = cellfun(@(x) isa(x, 'sym'), evCMat);
            backwardStrCMat = cell(size(strCMat));
            backwardStrCMat(symIndMat) = cellfun(@char,...
                evCMat(symIndMat), 'UniformOutput', false);
            backwardStrCMat(~symIndMat) = cellfun(@num2str,...
                evCMat(~symIndMat), 'UniformOutput', false);
            if isMinus
                backwardStrCMat = strcat('-(', backwardStrCMat, ')');
            end
        end
        function outStrCMat = getStrCMat(inpMat)
            outStrCMat =...
                arrayfun(@num2str, inpMat, 'UniformOutput', false);
        end
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
        function rotatedEllTubeRel = rotateEllTubeRel(oldEllTubeRel)
            import gras.ellapx.smartdb.F;
            FIELD_NAME_LIST_TO = {F.LS_GOOD_DIR_VEC;F.LS_GOOD_DIR_NORM;...
                F.XS_TOUCH_VEC;F.XS_TOUCH_OP_VEC};
            FIELD_NAME_LIST_FROM = {F.LT_GOOD_DIR_MAT;...
                F.LT_GOOD_DIR_NORM_VEC;F.X_TOUCH_CURVE_MAT;...
                F.X_TOUCH_OP_CURVE_MAT};
            FIELDS_TO_FLIP = {F.Q_ARRAY;F.A_MAT;F.LT_GOOD_DIR_MAT;...
                F.X_TOUCH_CURVE_MAT;F.X_TOUCH_OP_CURVE_MAT;...
                F.LT_GOOD_DIR_NORM_VEC;F.M_ARRAY};
            SData = oldEllTubeRel.getData();
            indSTime = 1;
            SData.indSTime(:) = indSTime;
            cellfun(@flipField, FIELDS_TO_FLIP);
            cellfun(@cutStructSTimeField,...
                FIELD_NAME_LIST_TO, FIELD_NAME_LIST_FROM);
            SData.lsGoodDirNorm =...
                cell2mat(SData.lsGoodDirNorm);
            rotatedEllTubeRel = oldEllTubeRel.createInstance(SData);
            %
            function flipField(fieldName)
                fieldCVec = SData.(fieldName);
                dim = ndims(fieldCVec{1});
                SData.(fieldName) = cellfun(@(field)flipdim(field, dim),...
                    SData.(fieldName), 'UniformOutput', false);
            end
            function cutStructSTimeField(fieldNameTo, fieldNameFrom)
                SData.(fieldNameTo) =...
                    cellfun(@(field) field(:, 1),...
                    SData.(fieldNameFrom), 'UniformOutput', false);
            end
        end
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
        function linSys = getSmartLinSys(atStrCMat, btStrCMat,...
                ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                x0Mat, x0Vec, timeVec, calcPrecision, isDisturb)
            if isDisturb
                linSys = getSysWithDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat,...
                    qtStrCVec, x0Mat, x0Vec, timeVec, calcPrecision);
            else
                linSys = getSysWithoutDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, x0Mat, x0Vec,...
                    timeVec, calcPrecision);
            end
            %
            function linSys = getSysWithDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                    x0Mat, x0Vec, timeVec, calcPrecision)
                import gras.ellapx.lreachuncert.probdyn.*;
                linSys =...
                    LReachProblemDynamicsFactory.createByParams(...
                    atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, gtStrCMat,...
                    qtStrCMat, qtStrCVec, x0Mat, x0Vec,...
                    timeVec, calcPrecision);
            end
            %
            function linSys = getSysWithoutDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, x0Mat, x0Vec, timeVec, calcPrecision)
                import gras.ellapx.lreachplain.probdyn.*;
                linSys =...
                    LReachProblemDynamicsFactory.createByParams(...
                    atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, x0Mat, x0Vec,...
                    timeVec, calcPrecision);
            end
        end
        function outMat = getNormMat(inpMat, dim)
            matSqNormVec = sum(inpMat .* inpMat);
            isNormGrZeroVec = matSqNormVec > 0;
            matSqNormVec(isNormGrZeroVec) =...
                sqrt(matSqNormVec(isNormGrZeroVec));
            outMat(:, isNormGrZeroVec) =...
                inpMat(:, isNormGrZeroVec) ./...
                matSqNormVec(ones(1, dim), isNormGrZeroVec);
        end
        function [atStrCMat, btStrCMat, gtStrCMat, ptStrCMat, ptStrCVec,...
                qtStrCMat, qtStrCVec] = prepareSysParam(linSys, timeVec)
            atMat = linSys.getAtMat();
            btMat = linSys.getBtMat();
            gtMat = linSys.getGtMat();
            if ~iscell(atMat) && ~isempty(atMat)
                atStrCMat = elltool.reach.ReachContinuous.getStrCMat(atMat);
            else
                atStrCMat = atMat;
            end
            if ~iscell(btMat) && ~isempty(btMat)
                btStrCMat = elltool.reach.ReachContinuous.getStrCMat(btMat);
            else
                btStrCMat = btMat;
            end
            if isempty(gtMat)
                gtMat = zeros(size(btMat));
            end
            if ~iscell(gtMat)
                gtStrCMat = elltool.reach.ReachContinuous.getStrCMat(gtMat);
            else
                gtStrCMat = gtMat;
            end
            uEll = linSys.getUBoundsEll();
            [ptVec ptMat] =...
                elltool.reach.ReachContinuous.getEllParams(uEll, btMat);
            if ~iscell(ptMat)
                ptStrCMat = elltool.reach.ReachContinuous.getStrCMat(ptMat);
            else
                ptStrCMat = ptMat;
            end
            if ~iscell(ptVec)
                ptStrCVec = elltool.reach.ReachContinuous.getStrCMat(ptVec);
            else
                ptStrCVec = ptVec;
            end
            vEll = linSys.getDistBoundsEll();
            [qtVec qtMat] =...
                elltool.reach.ReachContinuous.getEllParams(vEll, gtMat);
            if ~iscell(qtMat)
                qtStrCMat = elltool.reach.ReachContinuous.getStrCMat(qtMat);
            else
                qtStrCMat = qtMat;
            end
            if ~iscell(qtVec)
                qtStrCVec = elltool.reach.ReachContinuous.getStrCMat(qtVec);
            else
                qtStrCVec = qtVec;
            end
            if timeVec(1) > timeVec(2)
                tSum = sum(timeVec);
                %
                atStrCMat =...
                    elltool.reach.ReachContinuous.getBackwardCMat(...
                    atStrCMat, tSum, true);
                btStrCMat =...
                    elltool.reach.ReachContinuous.getBackwardCMat(...
                    btStrCMat, tSum, true);
                gtStrCMat =...
                    elltool.reach.ReachContinuous.getBackwardCMat(...
                    gtStrCMat, tSum, true);
                ptStrCMat =...
                    elltool.reach.ReachContinuous.getBackwardCMat(...
                    ptStrCMat, tSum, false);
                ptStrCVec =...
                    elltool.reach.ReachContinuous.getBackwardCMat(...
                    ptStrCVec, tSum, false);
                qtStrCMat =...
                    elltool.reach.ReachContinuous.getBackwardCMat(...
                    qtStrCMat, tSum, false);
                qtStrCVec =...
                    elltool.reach.ReachContinuous.getBackwardCMat(...
                    qtStrCVec, tSum, false);
            end
        end
    end
    methods
        function self =...
                ReachContinuous(linSys, x0Ell, l0Mat, timeVec, varargin)
            % ReachContinuous - computes reach set approximation of the continuous
            %     linear system for the given time interval.
            % Input:
            %     regular:
            %       linSys: elltool.linsys.LinSys object -
            %           given linear system .
            %       x0Ell: ellipsoid[1, 1] - ellipsoidal set of
            %           initial conditions.
            %       l0Mat: double[nRows, nColumns] - initial good directions
            %           matrix.
            %       timeVec: double[1, 2] - time interval.
            %
            %     properties:
            %       isRegEnabled: logical[1, 1] - if it is 'true' constructor
            %           is allowed to use regularization.
            %       isJustCheck: logical[1, 1] - if it is 'true' constructor
            %           just check if square matrices are degenerate, if it is
            %           'false' all degenerate matrices will be regularized.
            %       regTol: double[1, 1] - regularization precision.
            %
            % Output:
            %   regular:
            %     self - reach set object.
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
            %
            % $Author: Kirill Mayantsev
            % <kirill.mayantsev@gmail.com> $
            % $Date: Jan-2013$
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2013$
            %
            import modgen.common.type.simple.checkgenext;
            import modgen.common.throwerror;
            import gras.ellapx.uncertcalc.EllApxBuilder;
            import gras.ellapx.enums.EApproxType;
            import elltool.logging.Log4jConfigurator;
            import elltool.conf.Properties;
            %%
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
            if (nargin == 0) || isempty(linSys)
                return;
            end
            self.switchSysTimeVec = [min(timeVec), max(timeVec)];
            self.x0Ellipsoid = x0Ell;
            self.linSysCVec = {linSys};
            self.isCut = false;
            self.isProj = false;
            self.isBackward = timeVec(1) > timeVec(2);
            self.projectionBasisMat = [];
            %% check and analize input
            if nargin < 4
                throwerror('wrongInput', ['insufficient ',...
                    'number of input arguments.']);
            end
            if ~(isa(linSys, 'elltool.linsys.LinSysContinuous'))
                throwerror('wrongInput', ['first input argument ',...
                    'must be linear system object.']);
            end
            if ~(isa(x0Ell, 'ellipsoid'))
                throwerror('wrongInput', ['set of initial ',...
                    'conditions must be ellipsoid.']);
            end
            checkgenext('x1==x2&&x2==x3', 3,...
                dimension(linSys), dimension(x0Ell), size(l0Mat, 1));
            %%
            [timeRows, timeCols] = size(timeVec);
            if ~(isa(timeVec, 'double')) ||...
                    (timeRows ~= 1) || (timeCols ~= 2)
                throwerror('wrongInput', ['time interval must be ',...
                    'specified as ''[t0 t1]'', or, in ',...
                    'discrete-time - as ''[k0 k1]''.']);
            end
            regTolerance = elltool.conf.Properties.getRegTol();
            [reg, ~, self.isRegEnabled, self.isJustCheck, self.regTol] =...
                modgen.common.parseparext(varargin,...
                {'isRegEnabled', 'isJustCheck', 'regTol';...
                false, false, regTolerance});
            if ~isempty(reg)
                throwerror('wrongInput', 'wrong input arguments format.');
            end
            %% create gras LinSys object
            [x0Vec, x0Mat] = double(x0Ell);
            [atStrCMat, btStrCMat, gtStrCMat, ptStrCMat, ptStrCVec,...
                qtStrCMat, qtStrCVec] =...
                self.prepareSysParam(linSys, timeVec);
            isDisturbance = self.isDisturbance(gtStrCMat, qtStrCMat);
            %% Normalize good directions
            sysDim = size(atStrCMat, 1);
            l0Mat = self.getNormMat(l0Mat, sysDim);
            %
            relTol = elltool.conf.Properties.getRelTol();
            smartLinSys = self.getSmartLinSys(atStrCMat, btStrCMat,...
                ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                x0Mat, x0Vec, [min(timeVec), max(timeVec)],...
                relTol, isDisturbance);
            approxTypeVec = [EApproxType.External, EApproxType.Internal];
            self.ellTubeRel = self.makeEllTubeRel(smartLinSys, l0Mat,...
                [min(timeVec), max(timeVec)], isDisturbance,...
                relTol, approxTypeVec);
            if self.isBackward
                self.ellTubeRel = self.rotateEllTubeRel(self.ellTubeRel);
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
                throwerror('wrongInput', ['second argument must ',...
                    'be matrix of directions']);
            end
            % Calculate additional tubes
            %TODO: we need to use all linear systems in self.linSysCVec:
            linSys = self.linSysCVec{1};
            timeVec = self.switchSysTimeVec;
            if numel(timeVec) > 2
                throwerror('unsupportedFunctionality',...
                    'refine currently cannot be applied after evolve');
            end
            if self.isBackward
                timeVec = [timeVec(end), timeVec(1)];
            end
            x0Ell = self.x0Ellipsoid;
            % Normalize good directions
            nDim = dimension(x0Ell);
            l0Mat = self.getNormMat(l0Mat, nDim);
            if self.isProj
                projMat = self.projectionBasisMat;
                reachSetObj = elltool.reach.ReachContinuous(...
                    linSys, x0Ell, l0Mat, timeVec);
                projSet = reachSetObj.getProjSet(projMat);
                self.ellTubeRel.unionWith(projSet);
            else
                [x0Vec x0Mat] = double(x0Ell);
                [atStrCMat btStrCMat gtStrCMat ptStrCMat ptStrCVec...
                    qtStrCMat qtStrCVec] =...
                    self.prepareSysParam(linSys, timeVec);
                isDisturbance = self.isDisturbance(gtStrCMat, qtStrCMat);
                %
                relTol = elltool.conf.Properties.getRelTol();
                smartLinSys = self.getSmartLinSys(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                    x0Mat, x0Vec, [min(timeVec) max(timeVec)],...
                    relTol, isDisturbance);
                approxTypeVec = [EApproxType.External EApproxType.Internal];
                ellTubeRelNew = self.makeEllTubeRel(smartLinSys, l0Mat,...
                    [min(timeVec) max(timeVec)], isDisturbance,...
                    relTol, approxTypeVec);
                if self.isBackward
                    ellTubeRelNew = self.rotateEllTubeRel(ellTubeRelNew);
                end
                %Update self.ellTubeRel
                self.ellTubeRel.unionWith(ellTubeRelNew);
            end
        end
        %%
        function eaPlotter = plot_ea(self, varargin)
            import gras.ellapx.enums.EApproxType;
            if nargin == 1
                eaPlotter =...
                    self.plotApprox(EApproxType.External);
            else
                eaPlotter =...
                    self.plotApprox(EApproxType.External, varargin{:});
            end
        end
        %%
        function iaPlotter = plot_ia(self, varargin)
            import gras.ellapx.enums.EApproxType;
            if nargin == 1
                iaPlotter =...
                    self.plotApprox(EApproxType.Internal);
            else
                iaPlotter =...
                    self.plotApprox(EApproxType.Internal, varargin{:});
            end
        end
        %%
        function display(self)
            import gras.ellapx.enums.EApproxType;
            fprintf('\n');
            if self.isempty()
                fprintf('Empty reach set object.\n\n');
                return;
            end
            if isa(self.linSysCVec{end}, 'elltool.linsys.LinSysDiscrete')
                sysTypeStr = 'discrete-time';
                sysTimeStartStr = 'k0 = ';
                sysTimeEndStr = 'k1 = ';
            else
                sysTypeStr = 'continuous-time';
                sysTimeStartStr = 't0 = ';
                sysTimeEndStr = 't1 = ';
            end
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
        %%
        function cutObj = cut(self, cutTimeVec)
            import modgen.common.throwerror;
            if self.isProj
                throwerror('wrongInput',...
                    'Method cut does not work with projections');
            else
                cutObj = elltool.reach.ReachContinuous();
                if self.isBackward
                    cutTimeVec = fliplr(cutTimeVec);
                end
                switchTimeVec = self.switchSysTimeVec;
                cutObj.ellTubeRel = self.ellTubeRel.cut(cutTimeVec);
                %
                if abs(cutTimeVec(1) - cutTimeVec(end)) <= self.absTol
                    cutObj.switchSysTimeVec = cutTimeVec(1);
                    indCutPointVec = switchTimeVec < cutTimeVec(1) &...
                        cutTimeVec(1) <= switchTimeVec;
                    cutObj.linSysCVec = self.linSysCVec(indCutPointVec);
                else
                    switchTimeIndVec =...
                        switchTimeVec > cutTimeVec(1) &...
                        switchTimeVec < cutTimeVec(end);
                    switchSysTimeVec = [cutTimeVec(1)...
                        switchTimeVec(switchTimeIndVec) cutTimeVec(end)];
                    cutObj.switchSysTimeVec = switchSysTimeVec;
                    firstIntInd = find(switchTimeIndVec == 1, 1);
                    if ~isempty(firstIntInd)
                        switchTimeIndVec(firstIntInd - 1) = 1;
                    else
                        firstGreaterInd =...
                            find(switchTimeVec > cutTimeVec(end), 1);
                        if ~isempty(firstGreaterInd)
                            switchTimeIndVec(firstGreaterInd - 1) = 1;
                        else
                            switchTimeIndVec(end - 1) = 1;
                        end
                    end
                    cutObj.linSysCVec =...
                        self.linSysCVec(switchTimeIndVec(1 : end - 1));
                end
                %
                cutObj.x0Ellipsoid = self.x0Ellipsoid.getCopy();
                cutObj.isCut = true;
                cutObj.isProj = false;
                cutObj.isBackward = self.isBackward;
                cutObj.projectionBasisMat = self.projectionBasisMat;
            end
        end
        %%
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
        %%
        function linSys = get_system(self)
            linSys = self.linSysCVec{end}.getCopy();
        end
        %%
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
        %%
        function [trCenterMat timeVec] = get_center(self)
            trCenterMat = self.ellTubeRel.aMat{1};
            if nargout > 1
                timeVec = self.ellTubeRel.timeVec{1};
            end
        end
        %%
        function [eaEllMat timeVec] = get_ea(self)
            import gras.ellapx.enums.EApproxType;
            [eaEllMat timeVec] =...
                self.ellTubeRel.getEllArray(EApproxType.External);
        end
        %%
        function [iaEllMat timeVec] = get_ia(self)
            import gras.ellapx.enums.EApproxType;
            [iaEllMat timeVec] =...
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
        %%
        function projObj = projection(self, projMat)
            import gras.ellapx.enums.EProjType;
            import modgen.common.throwerror;
            %
            projSet = self.getProjSet(projMat);
            projObj = elltool.reach.ReachContinuous();
            projObj.switchSysTimeVec = self.switchSysTimeVec;
            projObj.x0Ellipsoid = self.x0Ellipsoid;
            projObj.ellTubeRel = projSet;
            projObj.linSysCVec = self.linSysCVec;
            projObj.isCut = self.isCut;
            projObj.isProj = true;
            projObj.isBackward = self.isbackward();
            projObj.projectionBasisMat = projMat;
        end
        %%
        function newReachObj = evolve(self, newEndTime, linSys)
            import elltool.conf.Properties;
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
            import gras.ellapx.uncertcalc.EllApxBuilder;
            import modgen.common.throwerror;
            %% check and analize input
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
                if ~(isa(linSys, 'elltool.linsys.LinSysContinuous'))
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
            if (newEndTime < self.switchSysTimeVec(end) &&...
                    ~self.isBackward) ||...
                    (newEndTime > self.switchSysTimeVec(1) &&...
                    self.isBackward)
                throwerror('wrongInput', ['new end time must be more ',...
                    '(if forward) or less (if backward) than the old one.']);
            end
            if newLinSys.dimension() ~= oldLinSys.dimension()
                throwerror('wrongInput', ['dimensions of the ',...
                    'old and new linear systems do not match.']);
            end
            %%
            newReachObj = elltool.reach.ReachContinuous();
            if self.isBackward
                newReachObj.switchSysTimeVec =...
                    [newEndTime, self.switchSysTimeVec];
                newTimeVec = [self.switchSysTimeVec(1), newEndTime];
            else
                newReachObj.switchSysTimeVec =...
                    [self.switchSysTimeVec, newEndTime];
                newTimeVec = [self.switchSysTimeVec(end), newEndTime];
            end
            newReachObj.x0Ellipsoid = self.x0Ellipsoid.getCopy();
            newReachObj.linSysCVec = [self.linSysCVec {newLinSys}];
            newReachObj.isCut = false;
            newReachObj.isProj = false;
            newReachObj.isBackward = self.isbackward();
            newReachObj.projectionBasisMat = [];
            %
            [dataIntCVec, indIntVec] = self.evolveApprox(newTimeVec,...
                newLinSys, EApproxType.Internal);
            [dataExtCVec, indExtVec] = self.evolveApprox(newTimeVec,...
                newLinSys, EApproxType.External);
            dataCVec = [dataIntCVec, dataExtCVec];
            %% cat old and new ellTubeRel
            newEllTubeRel =...
                gras.ellapx.smartdb.rels.EllTube.fromStructList(...
                'gras.ellapx.smartdb.rels.EllTube', dataCVec);
            if self.isBackward
                newEllTubeRel = self.rotateEllTubeRel(newEllTubeRel);
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
        %%
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
        %%
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
        %%
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
        %%
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
        %%
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
            if self.isBackward && numel(self.switchSysTimeVec) == 2 &&...
                    numel(reachObj.switchSysTimeVec) == 2
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
            if pointsNum ~= newPointsNum
                compEllTube =...
                    compEllTube.thinOutTuples(compTimeGridIndVec);
            end
            [isEq,reportStr] = compEllTube.getFieldProjection(...
                fieldsToCompVec).isEqual(...
                ellTube.getFieldProjection(fieldsToCompVec),...
                'maxTolerance', 2*self.COMP_PRECISION,'checkTupleOrder','true');
        end
        %%
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
                copyReachObjArr(sizeCVec{:}) = elltool.reach.ReachContinuous();
                arrayfun(@fSingleCopy,copyReachObjArr,self);
            else
                copyReachObjArr = elltool.reach.ReachContinuous.empty(size(self));
            end
            function fSingleCopy(copyReachObj, reachObj)
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
        %%
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
            %   rsObj. getEllTubeRel();
            %
            ellTubeRel = self.ellTubeRel;
        end
        %%
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
        %%
        function switchTimeVec = getSwitchTimeVec(self)
            switchTimeVec = self.switchSysTimeVec;
        end
    end
end