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
        absTol
        relTol
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
                localEllTubeRel = self.ellTubeRel;
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
        function [dataCVec, indVec]= evolveApprox(self,...
                newTimeVec, newLinSys, approxType)
            import gras.ellapx.smartdb.F;
            APPROX_TYPE = F.APPROX_TYPE;
            [filteredTubes isThereVec]=self.ellTubeRel.getTuplesFilteredBy(...
                APPROX_TYPE, approxType);
            oldData=filteredTubes.getData();
            indVec=find(isThereVec);
            %
            sysDimRows = size(oldData.QArray{1}, 1);
            sysDimCols = size(oldData.QArray{1}, 2);
            %
            dataDimVec = oldData.dim;
            l0VecNum = size(dataDimVec, 1);
            l0Mat = zeros(dataDimVec(1), l0VecNum);
            x0VecMat = zeros(sysDimRows, l0VecNum);
            x0MatArray = zeros(sysDimRows, sysDimCols, l0VecNum);
            for il0Num = 1 : l0VecNum
                l0Mat(:, il0Num) = oldData.ltGoodDirMat{il0Num}(:, end);
                x0VecMat(:, il0Num) = oldData.aMat{il0Num}(:, end);
                x0MatArray(:, :, il0Num) =...
                    oldData.QArray{il0Num}(:, :, end);
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
            %relTol = elltool.conf.Properties.getRelTol();
            for il0Num = l0VecNum: -1 : 1
                smartLinSys = self.getSmartLinSys(atStrCMat,...
                    btStrCMat, ptStrCMat, ptStrCVec, gtStrCMat,...
                    qtStrCMat, qtStrCVec, x0MatArray(:, :, il0Num),...
                    x0VecMat(:, il0Num), [min(newTimeVec),...
                    max(newTimeVec)], self.relTol, isDisturbance);
                ellTubeRelVec{il0Num} = self.makeEllTubeRel(...
                    smartLinSys, l0Mat(:, il0Num),...
                    [min(newTimeVec) max(newTimeVec)], isDisturbance,...
                    self.relTol, approxType);
                dataCVec{il0Num} =...
                    ellTubeRelVec{il0Num}.getTuplesFilteredBy(...
                    APPROX_TYPE, approxType).getData();
            end
        end
        function ellTubeRel = makeEllTubeRel(self, smartLinSys, l0Mat,...
                timeVec, isDisturb, calcPrecision, approxTypeVec)
            import gras.ellapx.enums.EApproxType;
            %relTol = elltool.conf.Properties.getRelTol();
            goodDirSetObj =...
                gras.ellapx.lreachplain.GoodDirectionSet(...
                smartLinSys, timeVec(1), l0Mat, calcPrecision);
            if (isDisturb)
                extIntBuilder =...
                    gras.ellapx.lreachuncert.ExtIntEllApxBuilder(...
                    smartLinSys, goodDirSetObj, timeVec,...
                    self.relTol,...
                    self.DEFAULT_INTAPX_S_SELECTION_MODE,...
                    self.MIN_EIG_Q_REG_UNCERT);
                ellTubeBuilder =...
                    gras.ellapx.gen.EllApxCollectionBuilder({extIntBuilder});
                ellTubeRel = ellTubeBuilder.getEllTubes();
            else
                isIntApprox = any(approxTypeVec == EApproxType.Internal);
                isExtApprox = any(approxTypeVec == EApproxType.External);
                if isExtApprox
                    extBuilder =...
                        gras.ellapx.lreachplain.ExtEllApxBuilder(...
                        smartLinSys, goodDirSetObj, timeVec,...
                        self.relTol);
                    extellTubeBuilder =...
                        gras.ellapx.gen.EllApxCollectionBuilder({extBuilder});
                    extEllTubeRel = extellTubeBuilder.getEllTubes();
                    if ~isIntApprox
                        ellTubeRel = extEllTubeRel;
                    end
                end
                if isIntApprox
                    intBuilder =...
                        gras.ellapx.lreachplain.IntEllApxBuilder(...
                        smartLinSys, goodDirSetObj, timeVec,...
                        self.relTol,...
                        self.DEFAULT_INTAPX_S_SELECTION_MODE);
                    intellTubeBuilder =...
                        gras.ellapx.gen.EllApxCollectionBuilder({intBuilder});
                    intEllTubeRel = intellTubeBuilder.getEllTubes();
                    if isExtApprox
                        intEllTubeRel.unionWith(extEllTubeRel);
                    end
                    ellTubeRel = intEllTubeRel;
                end
                
            end
        end
    end
    methods (Access = private, Static)
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
        function [centerVec shapeMat] = getEllParams(inpEll, relMat)
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
            SData = oldEllTubeRel.getData();
            SData.timeVec = cellfun(@fliplr, SData.timeVec,...
                'UniformOutput', false);
            indSTime = numel(SData.timeVec(1));
            SData.indSTime(:) = indSTime;
            cellfun(@cutStructSTimeField,...
                FIELD_NAME_LIST_TO, FIELD_NAME_LIST_FROM);
            SData.lsGoodDirNorm =...
                cell2mat(SData.lsGoodDirNorm);
            rotatedEllTubeRel = oldEllTubeRel.createInstance(SData);
            %
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
        function [atStrCMat btStrCMat gtStrCMat...
                ptStrCMat ptStrCVec...
                qtStrCMat qtStrCVec] = prepareSysParam(linSys, timeVec)
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
                ReachContinuous(linSys, x0Ell, l0Mat,...
                timeVec, OptStruct, varargin)
        % ReachContinuous - computes reach set approximation of the continuous  
        %                   linear system for the given time interval.
        % Input:
        %     regular:
        %       linSys: elltool.linsys.LinSys object - given linear system 
        %       x0Ell: ellipsoid[1, 1] - ellipsoidal set of initial conditions 
        %       l0Mat: matrix of double - l0Mat 
        %       timeVec: double[1, 2] - time interval; timeVec(1) < timeVec(2)
        %            for forward solving, timeVec(1) > timeVec(2) for backward
        %       OptStruct: structure[1,1] in this class OptStruct doesn't matter
        %           anything
        %
        % Output:
        %   regular:
        %     self - reach set object.
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
            
            neededPropNameList =...
                {'absTol', 'relTol'};
            [absTolVal, relTolVal] =...
                Properties.parseProp(varargin, neededPropNameList);
            
            self.absTol = absTolVal;
            self.relTol = relTolVal;
            
            logger=Log4jConfigurator.getLogger(...
                'elltool.ReachCont.constrCallCount');
            logger.debug(sprintf('constructor is called %s',...
                modgen.exception.me.printstack(...
                dbstack,'useHyperlink',false)));
            %
            if (nargin == 0) || isempty(linSys)
                return;
            end
            self.switchSysTimeVec = timeVec;
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
            if (nargin < 5) || ~(isstruct(OptStruct))
                OptStruct = [];
                OptStruct.approximation = 2;
                OptStruct.saveAll = 0;
                OptStruct.minmax = 0;
            else
                if ~(isfield(OptStruct, 'approximation')) || ...
                        (OptStruct.approximation < 0) ||...
                        (OptStruct.approximation > 2)
                    OptStruct.approximation = 2;
                end
                if ~(isfield(OptStruct, 'saveAll')) || ...
                        (OptStruct.saveAll < 0) || (OptStruct.saveAll > 2)
                    OptStruct.saveAll = 0;
                end
                if ~(isfield(OptStruct, 'minmax')) || ...
                        (OptStruct.minmax < 0) || (OptStruct.minmax > 1)
                    OptStruct.minmax = 0;
                end
            end
            %% create gras LinSys object
            [x0Vec x0Mat] = double(x0Ell);
            [atStrCMat btStrCMat gtStrCMat ptStrCMat ptStrCVec...
                qtStrCMat qtStrCVec] =...
                self.prepareSysParam(linSys, timeVec);
            isDisturbance = self.isDisturbance(gtStrCMat, qtStrCMat);
            %% Normalize good directions
            sysDim = size(atStrCMat, 1);
            l0Mat = self.getNormMat(l0Mat, sysDim);
            %
            %relTol = elltool.conf.Properties.getRelTol();
            smartLinSys = self.getSmartLinSys(atStrCMat, btStrCMat,...
                ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                x0Mat, x0Vec, [min(timeVec) max(timeVec)],...
                self.relTol, isDisturbance);
            approxTypeVec = [EApproxType.External EApproxType.Internal];
            self.ellTubeRel = self.makeEllTubeRel(smartLinSys, l0Mat,...
                [min(timeVec) max(timeVec)], isDisturbance,...
                self.relTol, approxTypeVec);
            if self.isbackward()
                self.ellTubeRel = self.rotateEllTubeRel(self.ellTubeRel);
            end
        end
        %
        function self=refine(self,l0Mat)
            import modgen.common.throwerror;
            import gras.ellapx.enums.EApproxType;
            if isempty(self.ellTubeRel)
                throwerror('wrongInput','empty reach set');
            end
            if ~isa(l0Mat,'double')
                throwerror('wrongInput',strcat('second argument must ',...
                    'be matrix of directions'));
            end
            % Calculate additional tubes
            linSys=self.linSysCVec{1};
            timeVec= self.switchSysTimeVec;
            x0Ell= self.x0Ellipsoid;
            % Normalize good directions
            nDim = dimension(x0Ell);
            l0Mat = self.getNormMat(l0Mat, nDim);
            if self.isprojection();
                projMat=self.projectionBasisMat;
                reachSetObj=elltool.reach.ReachContinuous(...
                    linSys,x0Ell,l0Mat,timeVec);
                projSet = reachSetObj.getProjSet(projMat);
                self.ellTubeRel.unionWith(projSet);
            else
                [x0Vec x0Mat] = double(x0Ell);
                [atStrCMat btStrCMat gtStrCMat ptStrCMat ptStrCVec...
                    qtStrCMat qtStrCVec] =...
                    self.prepareSysParam(linSys, timeVec);
                isDisturbance = self.isDisturbance(gtStrCMat, qtStrCMat);
                %
                %relTol = elltool.conf.Properties.getRelTol();
                smartLinSys = self.getSmartLinSys(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                    x0Mat, x0Vec, [min(timeVec) max(timeVec)],...
                    self.relTol, isDisturbance);
                approxTypeVec = [EApproxType.External EApproxType.Internal];
                ellTubeRelNew = self.makeEllTubeRel(smartLinSys, l0Mat,...
                    [min(timeVec) max(timeVec)], isDisturbance,...
                    self.relTol, approxTypeVec);
                if self.isbackward()
                    ellTubeRelNew = self.rotateEllTubeRel(ellTubeRelNew);
                end
                %Update self.ellTubRel
                self.ellTubeRel.unionWith(ellTubeRelNew);
            end
        end
        %%
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
        %%
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
        %%
        function display(self)
            import gras.ellapx.enums.EApproxType;
            fprintf('\n');
            disp([inputname(1) ' =']);
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
        %
        function cutObj = cut(self, cutTimeVec)
            import modgen.common.throwerror;
            if self.isprojection()
                throwerror('wrongInput',...
                    'Method cut does not work with projections');
            else
                cutObj = elltool.reach.ReachContinuous();
                if self.isbackward()
                    cutTimeVec = fliplr(cutTimeVec);
                    switchTimeVec = fliplr(self.switchSysTimeVec);
                else
                    switchTimeVec = self.switchSysTimeVec;
                end
                cutObj.ellTubeRel = self.ellTubeRel.cut(cutTimeVec);
                switchTimeIndVec =...
                    switchTimeVec > cutTimeVec(1) &...
                    switchTimeVec < cutTimeVec(end);
                cutObj.switchSysTimeVec = [cutTimeVec(1)...
                    switchTimeVec(switchTimeIndVec) cutTimeVec(end)];
                if self.isbackward()
                    cutObj.switchSysTimeVec =...
                        fliplr(cutObj.switchSysTimeVec);
                end
                firstIntInd = find(switchTimeIndVec == 1, 1);
                if ~isempty(firstIntInd)
                    switchTimeIndVec(firstIntInd - 1) = 1;
                else
                    switchTimeIndVec(find(switchTimeVec >=...
                        cutTimeVec(end), 1) - 1) = 1;
                end
                cutObj.linSysCVec = self.linSysCVec(switchTimeIndVec);
                cutObj.x0Ellipsoid = self.x0Ellipsoid;
                cutObj.isCut = true;
                cutObj.isProj = false;
                cutObj.isBackward = self.isbackward();
                cutObj.projectionBasisMat = self.projectionBasisMat;
            end
        end
        %%
        function [rSdim sSdim] = dimension(self)
            rSdim = self.linSysCVec{end}.dimension();
            if ~self.isProj
                sSdim = rSdim;
            else
                sSdim = size(self.projectionBasisMat, 2);
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
            if self.isprojection()
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
                    ~self.isbackward()) ||...
                    (newEndTime > self.switchSysTimeVec(end) &&...
                    self.isbackward())
                throwerror('wrongInput', ['new end time must be more ',...
                    '(if forward) or less (if backward) than the old one.']);
            end
            if newLinSys.dimension() ~= oldLinSys.dimension()
                throwerror('wrongInput', ['dimensions of the ',...
                    'old and new linear systems do not match.']);
            end
            %%
            newReachObj = elltool.reach.ReachContinuous();
            newReachObj.switchSysTimeVec =...
                [self.switchSysTimeVec newEndTime];
            newReachObj.x0Ellipsoid = self.x0Ellipsoid;
            newReachObj.linSysCVec = [self.linSysCVec {newLinSys}];
            newReachObj.isCut = false;
            newReachObj.isProj = false;
            newReachObj.isBackward = self.isbackward();
            newReachObj.projectionBasisMat = [];
            %
            newTimeVec = newReachObj.switchSysTimeVec(end - 1 : end);
            [dataIntCVec indIntVec] = self.evolveApprox(newTimeVec,...
                newLinSys, EApproxType.Internal);
            [dataExtCVec indExtVec] = self.evolveApprox(newTimeVec,...
                newLinSys, EApproxType.External);
            dataCVec = [dataIntCVec dataExtCVec];
            %% cat old and new ellTubeRel
            newEllTubeRel =...
                gras.ellapx.smartdb.rels.EllTube.fromStructList(...
                'gras.ellapx.smartdb.rels.EllTube', dataCVec);
            if self.isbackward()
                newEllTubeRel = self.rotateEllTubeRel(newEllTubeRel);
            end
            %
            indVec=[indIntVec; indExtVec];
            [~,indRelVec]=sort(indVec);
            newEllTubeRel=newEllTubeRel.getTuples(indRelVec);
            %
            newReachObj.ellTubeRel =...
                self.ellTubeRel.cat(newEllTubeRel);
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
        function [isEqual, reportStr] = isEqual(self, reachObj, varargin)
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
        % $Author: Daniil Stepenskiy <reinkarn@gmail.com> $
        % $Date: May-2013 $ 
        % $Copyright: Moscow State University,
        %             Faculty of Computational
        %             Mathematics and Computer Science,
        %             System Analysis Department 2013 $
        %
            import gras.ellapx.smartdb.F;
            import gras.ellapx.enums.EApproxType;
            import elltool.logging.Log4jConfigurator;
            % FIXME: change to self.getAbsTol in the future
            %absTol = elltool.conf.Properties.getAbsTol();
            persistent logger;
            if (nargout == 2)
                reportStr = [];
            end
            %
            APPROX_TYPE = F.APPROX_TYPE;
            SSORT_KEYS={'sTime','lsGoodDirVec','approxType'};
            %
            ellTube = self.ellTubeRel;
            ellTube.sortBy(APPROX_TYPE);
            compEllTube = reachObj.ellTubeRel;
            ellTube.sortBy(SSORT_KEYS);
            compEllTube.sortBy(SSORT_KEYS);
            %
            if nargin == 4
                ellTube = ellTube.getTuplesFilteredBy(APPROX_TYPE,...
                    varargin{2});
                ellTube = ellTube.getTuples(varargin{1});
                compEllTube = compEllTube.getTuplesFilteredBy(APPROX_TYPE,...
                    varargin{2});
            end            
            %
            pointsNum = numel(ellTube.timeVec{1});
            newPointsNum = numel(compEllTube.timeVec{1});
            firstTimeVec = ellTube.timeVec{1};
            secondTimeVec = compEllTube.timeVec{1};
            %
            if isempty(logger)
                logger=Log4jConfigurator.getLogger();
            end
            %
            if logger.isDebugEnabled
                if pointsNum ~= newPointsNum
                    logger.debug('Inequal time knots count');
                else
                    logger.debug('Equal time knots count');
                end                
            end
            %
            % Checking time bounds equality
            %
            if (abs(firstTimeVec(end)-secondTimeVec(end)) > self.absTol)
                isEqual = false;
                if (nargout == 2)
                    reportStr=[reportStr, ...
                        sprintf('Ending times differ by %f. ',...
                        abs(firstTimeVec(end)-secondTimeVec(end)))];
                end
                return;
            end
            if (abs(firstTimeVec(1)-secondTimeVec(1)) > self.absTol)
                isEqual = false;
                if (nargout == 2)
                    reportStr=[reportStr, ...
                        sprintf('Beginning times differ by %f. ',...
                        abs(firstTimeVec(end)-secondTimeVec(end)))];
                end
                return;
            end   
            %
            % Checking enclosion of time vectors
            %
            if (length(firstTimeVec) < length(secondTimeVec))
                [isTimeVecsEnclosed, secondIndexVec] = ...
                    fIsGridSubsetOfGrid(secondTimeVec, firstTimeVec);
            else
                [isTimeVecsEnclosed, firstIndexVec] = ...
                    fIsGridSubsetOfGrid(firstTimeVec, secondTimeVec);
            end
            %
                fieldsNotToCompVec =...
                    F.getNameList(self.FIELDS_NOT_TO_COMPARE);
                fieldsToCompVec =...
                    setdiff(ellTube.getFieldNameList, fieldsNotToCompVec);
            %  
            if (isTimeVecsEnclosed)
                if (nargout == 2)
                    reportStr = [reportStr,...
                        'Enclosed time vectors. Common times checked. '];
                end
                if (length(firstTimeVec) < length(secondTimeVec))
                    compEllTube = ...
                        compEllTube.thinOutTuples(secondIndexVec);
                else                    
                    ellTube = ellTube.thinOutTuples(firstIndexVec);
                end
                [isEqual, eqReportStr] = compEllTube.getFieldProjection(...
                    fieldsToCompVec).isEqual(...
                    ellTube.getFieldProjection(fieldsToCompVec),...
                    'maxTolerance', 2*self.COMP_PRECISION,...
                    'checkTupleOrder','true');
                if (nargout == 2)
                    reportStr = [reportStr, eqReportStr];
                end
                return;
            end
            %
            % Time vectors are not enclosed, 
            % though start and finish at the same time
            % So interpolating from common time knots
            %
            if (nargout == 2)
                reportStr = [reportStr, 'Interpolated from common ',...
                    'time points. '];
            end
            unionTimeVec = union(firstTimeVec, secondTimeVec);
            ellTube = ellTube.interp(unionTimeVec);
            compEllTube = compEllTube.interp(unionTimeVec);
            [isEqual, eqReportStr] = compEllTube.getFieldProjection(...
                fieldsToCompVec).isEqual(...
                ellTube.getFieldProjection(fieldsToCompVec),...
                'maxTolerance', 2*self.COMP_PRECISION,...
                'checkTupleOrder','true');
            if (nargout == 2)
                reportStr = [reportStr, eqReportStr];
            end
            %
            function [isSubset, indexVec] = ...
                    fIsGridSubsetOfGrid(greaterVec, smallerVec)
                indexVec = [];
                if (length(greaterVec) < length(smallerVec))
                    isSubset = false;
                    return;
                end
                greaterIndex = 1;
                smallerIndex = 1;
                while (smallerIndex <= length(smallerVec) &&...
                        greaterIndex <= length(greaterVec))
                    if (abs(smallerVec(smallerIndex)-...
                            greaterVec(greaterIndex))<self.absTol)
                        smallerIndex = smallerIndex + 1;
                        indexVec = [indexVec, greaterIndex];
                    end
                    greaterIndex = greaterIndex + 1;
                end
                if (smallerIndex > length(smallerVec))
                    isSubset = true;
                else
                    isSubset = false;
                end
            end
            %
        end
        %%
        function copyReachObj = getCopy(self)
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
        %
            copyReachObj = elltool.reach.ReachContinuous();
            copyReachObj.switchSysTimeVec = self.switchSysTimeVec;
            copyReachObj.x0Ellipsoid = self.x0Ellipsoid.getCopy();
            copyReachObj.linSysCVec = cellfun(@(x) x.getCopy(),...
                self.linSysCVec, 'UniformOutput', false);
            copyReachObj.isCut = self.isCut;
            copyReachObj.isProj = self.isProj;
            copyReachObj.isBackward = self.isBackward;
            copyReachObj.projectionBasisMat = self.projectionBasisMat;
            copyReachObj.ellTubeRel = self.ellTubeRel.getCopy();
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
    end
end