classdef ReachContinious < elltool.reach.AReach
    properties (Constant, GetAccess = private)
        MIN_EIG_Q_REG_UNCERT = 0.1
        EXTERNAL_SCALE_FACTOR = 1.02
        INTERNAL_SCALE_FACTOR = 0.98
        DEFAULT_INTAPX_S_SELECTION_MODE = 'volume'
    end
    properties (Access = private)
        ellTubeRel
    end
    methods (Access = private)
        function projSet = getProjSet(self, projMat,...
                approxType, scaleFactor)
            import gras.ellapx.enums.EProjType;
            fProj =...
                @(~, timeVec, varargin)...
                deal(repmat(projMat.', [1 1 numel(timeVec)]),...
                repmat(projMat, [1 1 numel(timeVec)]));
            isProjSpaceList = false(1, size(projMat, 1));
            isProjSpaceList(1 : size(projMat, 2)) = true;
            isProjSpaceCList = {isProjSpaceList};
            projType = EProjType.Static;
            if nargin > 2
                localEllTubeRel = self.ellTubeRel.getTuplesFilteredBy(...
                    'approxType', approxType);
            else
                localEllTubeRel = self.ellTubeRel.getCopy();
            end
            if nargin == 4
                localEllTubeRel.scale(@(x) scaleFactor, {'approxType'});
            end
            projSet = localEllTubeRel.project(projType,...
                isProjSpaceCList, fProj);
        end
        %
        function ellTubeRel = makeEllTubeRel(self, smartLinSys, l0Mat,...
                timeVec, isDisturb, calcPrecision, approxTypeVec)
            import gras.ellapx.enums.EApproxType;
            relTol = elltool.conf.Properties.getRelTol();
            goodDirSetObj =...
                gras.ellapx.lreachplain.GoodDirectionSet(...
                smartLinSys, timeVec(1), l0Mat, calcPrecision);
            if (isDisturb)
                extIntBuilder =...
                    gras.ellapx.lreachuncert.ExtIntEllApxBuilder(...
                    smartLinSys, goodDirSetObj, timeVec,...
                    relTol,...
                    self.DEFAULT_INTAPX_S_SELECTION_MODE,...
                    self.MIN_EIG_Q_REG_UNCERT);
                EllTubeBuilder =...
                    gras.ellapx.gen.EllApxCollectionBuilder({extIntBuilder});
                ellTubeRel = EllTubeBuilder.getEllTubes();
            else
                isIntApprox = any(approxTypeVec == EApproxType.Internal);
                isExtApprox = any(approxTypeVec == EApproxType.External);
                if isIntApprox
                    intBuilder =...
                        gras.ellapx.lreachplain.IntEllApxBuilder(...
                        smartLinSys, goodDirSetObj, timeVec,...
                        relTol,...
                        self.DEFAULT_INTAPX_S_SELECTION_MODE);
                    intEllTubeBuilder =...
                        gras.ellapx.gen.EllApxCollectionBuilder({intBuilder});
                    intEllTubeRel = intEllTubeBuilder.getEllTubes();
                    if ~isExtApprox
                        ellTubeRel = intEllTubeRel;
                    end
                end
                if isExtApprox
                    extBuilder =...
                        gras.ellapx.lreachplain.ExtEllApxBuilder(...
                        smartLinSys, goodDirSetObj, timeVec,...
                        relTol);
                    extEllTubeBuilder =...
                        gras.ellapx.gen.EllApxCollectionBuilder({extBuilder});
                    extEllTubeRel = extEllTubeBuilder.getEllTubes();
                    if isIntApprox
                        extEllTubeRel.unionWith(intEllTubeRel);
                    end
                    ellTubeRel = extEllTubeRel;
                end
            end
        end
    end
    methods (Access = private, Static)
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
        %
        function [atStrCMat btStrCMat gtStrCMat...
                ptStrCMat ptStrCVec...
                qtStrCMat qtStrCVec] = prepareSysParam(linSys)
            atMat = linSys.getAtMat();
            btMat = linSys.getBtMat();
            gtMat = linSys.getGtMat();
            if ~iscell(atMat) && ~isempty(atMat)
                atStrCMat =...
                    arrayfun(@num2str, atMat, 'UniformOutput', false);
            else
                atStrCMat = atMat;
            end
            if ~iscell(btMat) && ~isempty(btMat)
                btStrCMat =...
                    arrayfun(@num2str, btMat, 'UniformOutput', false);
            else
                btStrCMat = btMat;
            end
            if isempty(gtMat)
                gtMat = zeros(size(btMat));
            end
            if ~iscell(gtMat)
                gtStrCMat =...
                    arrayfun(@num2str, gtMat, 'UniformOutput', false);
            else
                gtStrCMat = gtMat;
            end
            uEll = linSys.getUBoundsEll();
            if ~isempty(uEll)
                if isa(uEll, 'ellipsoid')
                    [ptVec ptMat] = double(uEll);
                else
                    if isfield(uEll, 'center')
                        ptVec = uEll.center;
                    else
                        ptVec = zeros(size(btMat, 2), 1);
                    end
                    if isfield(uEll, 'shape')
                        ptMat = uEll.shape;
                    else
                        ptMat = zeros(size(btMat, 2));
                    end
                end
            else
                ptMat = zeros(size(btMat, 2));
                ptVec = zeros(size(btMat, 2), 1);
            end
            if ~iscell(ptMat)
                ptStrCMat =...
                    arrayfun(@num2str, ptMat, 'UniformOutput', false);
            else
                ptStrCMat = ptMat;
            end
            if ~iscell(ptVec)
                ptStrCVec =...
                    arrayfun(@num2str, ptVec, 'UniformOutput', false);
            else
                ptStrCVec = ptVec;
            end
            vEll = linSys.getDistBoundsEll();
            if ~isempty(vEll)
                if isa(vEll, 'ellipsoid')
                    [qtVec qtMat] = double(vEll);
                else
                    if isfield(vEll, 'center')
                        qtVec = vEll.center;
                    else
                        qtVec = zeros(size(gtMat, 2), 1);
                    end
                    if isfield(vEll, 'shape')
                        qtMat = vEll.shape;
                    else
                        qtMat = zeros(size(gtMat, 2));
                    end
                end
            else
                qtMat = zeros(size(gtMat, 2));
                qtVec = zeros(size(gtMat, 2), 1);
            end
            if ~iscell(qtMat)
                qtStrCMat =...
                    arrayfun(@num2str, qtMat, 'UniformOutput', false);
            else
                qtStrCMat = qtMat;
            end
            if ~iscell(qtVec)
                qtStrCVec =...
                    arrayfun(@num2str, qtVec, 'UniformOutput', false);
            else
                qtStrCVec = qtVec;
            end
        end
    end
    methods
        function self =...
                ReachContinious(linSys, x0Ell, l0Mat, timeVec, OptStruct)
        % ReachContinious - computes reach set approximation of the continious
        %     linear system for the given time interval.
        % Input:
        %     linSys: elltool.linsys.LinSys object - given linear system
        %     x0Ell: ellipsoid[1, 1] - ellipsoidal set of initial conditions
        %     l0Mat: matrix of double - l0Mat 
        %     timeVec: double[1, 2] - time interval
        %         timeVec(1) must be less then timeVec(2)
        %     OptStruct: structure
        %         In this class OptStruct doesn't matter anything
        %
        % Output:
        %     self - reach set object.
        %
        % $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: Jan-2012 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2012 $
        %
            import modgen.common.type.simple.checkgenext;
            import modgen.common.throwerror;
            import gras.ellapx.uncertcalc.EllApxBuilder;
            import gras.ellapx.enums.EApproxType;
            %%
            if (nargin == 0) || isempty(linSys)
                return;
            end
            self.switchSysTimeVec = timeVec;
            self.x0Ellipsoid = x0Ell;
            self.linSysCVec = {linSys};
            self.isCut = false;
            self.isProj = false;
            self.projectionBasisMat = [];
            %% check and analize input
            if nargin < 4
                throwerror(['REACH: insufficient ',...
                    'number of input arguments.']);
            end
            if ~(isa(linSys, 'elltool.linsys.LinSys'))
                throwerror(['REACH: first input argument ',...
                    'must be linear system object.']);
            end
            if ~(isa(x0Ell, 'ellipsoid'))
                throwerror(['REACH: set of initial ',...
                    'conditions must be ellipsoid.']);
            end
            checkgenext('x1==x2&&x2==x3', 3,...
                dimension(linSys), dimension(x0Ell), size(l0Mat, 1));
            %%
            [timeRows, timeCols] = size(timeVec);
            if ~(isa(timeVec, 'double')) ||...
                    (timeRows ~= 1) || (timeCols ~= 2)
                throwerror(['REACH: time interval must be specified ',...
                    'as ''[t0 t1]'', or, in ',...
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
                qtStrCMat qtStrCVec] = self.prepareSysParam(linSys);
            isDisturbance = self.isDisturbance(gtStrCMat, qtStrCMat);
            %% Normalize good directions
            sysDim = size(atStrCMat, 1);
            l0Mat = self.getNormMat(l0Mat, sysDim);
            %%
            relTol = elltool.conf.Properties.getRelTol();
            smartLinSys = self.getSmartLinSys(atStrCMat, btStrCMat,...
                ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                x0Mat, x0Vec, timeVec,...
                relTol, isDisturbance);
            approxTypeVec = [EApproxType.External EApproxType.Internal];
            self.ellTubeRel = self.makeEllTubeRel(smartLinSys, l0Mat,...
                timeVec, isDisturbance,...
                relTol, approxTypeVec);
        end
        %%
        function plot_ea(self, varargin)
            import gras.ellapx.enums.EApproxType;
            if self.dimension() > 2
                projBasisMat = eye(3);
            else
                projBasisMat = eye(self.dimension());
            end
            if self.isProj
                if self.getEllTubeRel().dim() > 3
                    throwerror('Dimension of the projection must be leq 3');                    
                else
                    self.getEllTubeRel().getTuplesFilteredBy(...
                        'approxType', EApproxType.External).plot();
                end
            else
                projSetObj = self.getProjSet(projBasisMat,...
                    EApproxType.External, self.EXTERNAL_SCALE_FACTOR);
                projSetObj.plot();
            end
            
        end
        %%
        function plot_ia(self, varargin)
            import gras.ellapx.enums.EApproxType;
            if self.dimension() > 2
                projBasisMat = eye(3);
            else
                projBasisMat = eye(self.dimension());
            end
            if self.isProj
                if self.getEllTubeRel().dim() > 3
                    throwerror('Dimension of the projection must be leq 3');                    
                else
                    self.getEllTubeRel().getTuplesFilteredBy(...
                        'approxType', EApproxType.Internal).plot();
                end
            else
                projSetObj = self.getProjSet(projBasisMat,...
                    EApproxType.Internal, self.INTERNAL_SCALE_FACTOR);
                projSetObj.plot();
            end
        end
        %% displays only the last lin system
        function display(self)
            import gras.ellapx.enums.EApproxType;
            fprintf('\n');
            disp([inputname(1) ' =']);
            if isempty(self)
                fprintf('Empty reach set object.\n\n');
                return;
            end
            if isdiscrete(self.linSysCVec{end})
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
            if self.isProj
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
            disp(self.x0Ellipsoid);
            fprintf('Number of external approximations: %d\n',...
                sum(self.ellTubeRel.approxType == EApproxType.External));
            fprintf('Number of internal approximations: %d\n',...
                sum(self.ellTubeRel.approxType == EApproxType.Internal));
            fprintf('\n');
        end
        %%
        function cutObj = cut(self, cutTimeVec)
            if self.isProj
                throwerror('Method cut does not work with projections');
            else
                cutObj = elltool.reach.ReachContinious();
                cutObj.ellTubeRel = self.ellTubeRel.cut(cutTimeVec);
                switchTimeIndVec =...
                    self.switchSysTimeVec > cutTimeVec(1) &...
                    self.switchSysTimeVec < cutTimeVec(end);
                cutObj.switchSysTimeVec = [cutTimeVec(1)...
                    self.switchSysTimeVec(switchTimeIndVec) cutTimeVec(end)];
                firstIntInd = find(switchTimeIndVec == 1, 1);
                if ~isempty(firstIntInd)
                    switchTimeIndVec(firstIntInd - 1) = 1;
                else
                    switchTimeIndVec(find(self.switchSysTimeVec >=...
                        cutTimeVec(end), 1) - 1) = 1;
                end
                cutObj.linSysCVec = self.linSysCVec(switchTimeIndVec);
                cutObj.x0Ellipsoid = self.x0Ellipsoid;
                cutObj.isCut = true;
                cutObj.isProj = false;
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
        %% returns the last lin system:
        function linSys = get_system(self)
            linSys = self.linSysCVec{end};
        end
        %%
        function [directionsCVec timeVec] = get_directions(self)
            import gras.ellapx.enums.EApproxType;
            SData = self.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.External);
            directionsCVec = SData.ltGoodDirMat.';
            if nargout > 1
                timeVec = cell2mat(SData.timeVec(1));
            end
        end
        %%
        function [trCenterMat timeVec] = get_center(self)
            trCenterMat = cell2mat(self.ellTubeRel.aMat(1));
            if nargout > 1
                timeVec = cell2mat(self.ellTubeRel.timeVec(1));
            end
        end
        %%
        function [eaEllMat timeVec] = get_ea(self)
            import gras.ellapx.enums.EApproxType;
            SData = self.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.External);
            nTuples = SData.getNTuples();
            if nTuples > 0
                nTimes = numel(SData.timeVec{1});
                for iTuple = nTuples : -1 : 1
                    tupleCentMat = cell2mat(SData.aMat(iTuple));
                    tupleMatArray = cell2mat(SData.QArray(iTuple));
                    for jTime = nTimes : -1 : 1
                        eaEllMat(iTuple, jTime) =...
                            ellipsoid(tupleCentMat(:, jTime),...
                            tupleMatArray(:, :, jTime));
                    end
                end
            else
                eaEllMat = [];
            end
            if nargout > 1
                timeVec = cell2mat(SData.timeVec(1));
            end
        end
        %%
        function [iaEllMat timeVec] = get_ia(self)
            import gras.ellapx.enums.EApproxType;
            SData = self.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.Internal);
            nTuples = SData.getNTuples();
            if nTuples > 0
                nTimes = numel(SData.timeVec{1});
                for iTuple = nTuples : -1 : 1
                    tupleCentMat = cell2mat(SData.aMat(iTuple));
                    tupleMatArray = cell2mat(SData.QArray(iTuple));
                    for jTime = nTimes : -1 : 1
                        iaEllMat(iTuple, jTime) =...
                            ellipsoid(tupleCentMat(:, jTime),...
                            tupleMatArray(:, :, jTime));
                    end
                end
            else
                iaEllMat = [];
            end
            if nargout > 1
                timeVec = cell2mat(SData.timeVec(1));
            end
        end
        %
        function [goodCurvesCVec timeVec] = get_goodcurves(self)
            import gras.ellapx.enums.EApproxType;
            SData = self.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.External);
            goodCurvesCVec = SData.xTouchCurveMat.';
            if nargout > 1
                timeVec = cell2mat(SData.timeVec(1));
            end
        end
        %%
        function projObj = projection(self, projMat)
            import gras.ellapx.enums.EProjType;
            projSet = self.getProjSet(projMat);
            projObj = elltool.reach.ReachContinious();
            projObj.switchSysTimeVec = self.switchSysTimeVec;
            projObj.x0Ellipsoid = self.x0Ellipsoid;
            projObj.ellTubeRel = projSet;
            projObj.linSysCVec = self.linSysCVec;
            projObj.isCut = self.isCut;
            projObj.isProj = true;
            projObj.projectionBasisMat = projMat;
        end
        %%
        function newReachObj = evolve(self, newEndTime, linSys)
            import elltool.conf.Properties;
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
            import gras.ellapx.uncertcalc.EllApxBuilder;
            %% check and analize input
            if nargin < 2
                throwerror(['EVOLVE: insufficient number ',...
                    'of input arguments.']);
            end
            if nargin > 3
                throwerror('EVOLVE: too much arguments.');
            end
            if self.isProj
                throwerror(['EVOLVE: cannot compute ',...
                    'the reach set for projection.']);
            end
            if nargin < 3
                newLinSys = self.get_system();
                oldLinSys = newLinSys;
            else
                if ~(isa(linSys, 'elltool.linsys.LinSys'))
                    throwerror(['REACH: first input argument ',...
                        'must be linear system object.']);
                end
                newLinSys = linSys;
                oldLinSys = self.get_system();
            end
            if isempty(newLinSys)
                return;
            end
            if ~isa(newEndTime, 'double')
                throwerror('EVOLVE: second argument must be double.');
            end
            if newEndTime < self.switchSysTimeVec(end)
                throwerror(['EVOLVE: new end time ',...
                    'must be more than old one.']);
            end
            if newLinSys.dimension() ~= oldLinSys.dimension()
                throwerror(['EVOLVE: dimensions of the ',...
                    'old and new linear systems do not match.']);
            end
            %%
            newReachObj = elltool.reach.ReachContinious();
            newReachObj.switchSysTimeVec =...
                [self.switchSysTimeVec newEndTime];
            newReachObj.x0Ellipsoid = self.x0Ellipsoid;
            newReachObj.linSysCVec = [self.linSysCVec {newLinSys}];
            newReachObj.isCut = false;
            newReachObj.isProj = false;
            newReachObj.projectionBasisMat = [];
            %% prepare ext/int data to evolve
            oldExtData =...
                self.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.External);
            oldIntData =...
                self.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.Internal);
            sysExtDimRows = size(oldExtData.QArray{1}, 1);
            sysExtDimCols = size(oldExtData.QArray{1}, 2);
            sysIntDimRows = size(oldIntData.QArray{1}, 1);
            sysIntDimCols = size(oldIntData.QArray{1}, 2);
            % as we have the same number of ext and int approximations
            dataDimVec = oldExtData.dim;
            l0VecNum = size(dataDimVec, 1);
            l0ExtMat = zeros(dataDimVec(1), l0VecNum);
            x0ExtVecMat = zeros(sysExtDimRows, l0VecNum);
            x0ExtMatArray = zeros(sysExtDimRows, sysExtDimCols, l0VecNum);
            l0IntMat = zeros(dataDimVec(1), l0VecNum);
            x0IntVecMat = zeros(sysIntDimRows, l0VecNum);
            x0IntMatArray = zeros(sysIntDimRows, sysIntDimCols, l0VecNum);
            for il0Num = 1 : l0VecNum
                l0ExtMat(:, il0Num) =...
                    oldExtData.ltGoodDirMat{il0Num}(:, end);
                x0ExtVecMat(:, il0Num) = oldExtData.aMat{il0Num}(:, end);
                x0ExtMatArray(:, :, il0Num) =...
                    oldExtData.QArray{il0Num}(:, :, end);
                l0IntMat(:, il0Num) =...
                    oldIntData.ltGoodDirMat{il0Num}(:, end);
                x0IntVecMat(:, il0Num) = oldIntData.aMat{il0Num}(:, end);
                x0IntMatArray(:, :, il0Num) =...
                    oldIntData.QArray{il0Num}(:, :, end);
            end
            newTimeVec = newReachObj.switchSysTimeVec(end - 1 : end);
            [atStrCMat btStrCMat gtStrCMat ptStrCMat ptStrCVec...
                qtStrCMat qtStrCVec] = self.prepareSysParam(newLinSys);
            %% Normalize good ext/int-directions
            sysDim = size(atStrCMat, 1);
            l0ExtMat = self.getNormMat(l0ExtMat, sysDim);
            l0IntMat = self.getNormMat(l0IntMat, sysDim);
            %% ext/int-approx on the next time interval
            dataCVec = cell(1, 2 * l0VecNum);
            isDisturbance = self.isDisturbance(gtStrCMat, qtStrCMat);
            relTol = elltool.conf.Properties.getRelTol();
            for il0Num = l0VecNum: -1 : 1
                smartExtLinSys = self.getSmartLinSys(atStrCMat,...
                    btStrCMat, ptStrCMat, ptStrCVec, gtStrCMat,...
                    qtStrCMat, qtStrCVec, x0ExtMatArray(:, :, il0Num),...
                    x0ExtVecMat(:, il0Num), newTimeVec,...
                    relTol, isDisturbance);
                smartIntLinSys = self.getSmartLinSys(atStrCMat,...
                    btStrCMat, ptStrCMat, ptStrCVec, gtStrCMat,...
                    qtStrCMat, qtStrCVec, x0IntMatArray(:, :, il0Num),...
                    x0IntVecMat(:, il0Num), newTimeVec,...
                    relTol, isDisturbance);
                ellTubeExtRelVec{il0Num} = self.makeEllTubeRel(...
                    smartExtLinSys, l0ExtMat(:, il0Num), newTimeVec,...
                    isDisturbance, relTol,...
                    EApproxType.External);
                ellTubeIntRelVec{il0Num} = self.makeEllTubeRel(...
                    smartIntLinSys, l0IntMat(:, il0Num), newTimeVec,...
                    isDisturbance, relTol,...
                    EApproxType.Internal);
                dataCVec{il0Num} = ...
                    ellTubeExtRelVec{il0Num}.getTuplesFilteredBy(...
                    'approxType', EApproxType.External).getData();
                dataCVec{l0VecNum + il0Num} = ...
                    ellTubeIntRelVec{il0Num}.getTuplesFilteredBy(...
                    'approxType', EApproxType.Internal).getData();
            end
            %% cat old and new ellTubeRel
            newEllTubeRel =...
                gras.ellapx.smartdb.rels.EllTube.fromStructList(...
                'gras.ellapx.smartdb.rels.EllTube', dataCVec);
            newReachObj.ellTubeRel =...
                self.ellTubeRel.cat(newEllTubeRel);
        end
        %%
        function ellTubeRel = getEllTubeRel(self)
            ellTubeRel = self.ellTubeRel;
        end
    end
end