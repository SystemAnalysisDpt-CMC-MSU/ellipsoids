classdef ReachContinious < elltool.reach.AReach
    properties (Constant, GetAccess = private)
        MIN_EIG_Q_REG_UNCERT = 0.1
    end
    properties (Access = private)
        ellTubeRel
    end
    methods (Access = private)
        function projSet = getProjSet(self, projMat)
            import gras.ellapx.enums.EProjType;
            fProj =...
                @(~, timeVec, varargin)...
                deal(repmat(projMat.',[1 1 numel(timeVec)]),...
                repmat(projMat,[1 1 numel(timeVec)]));
            projSpaceList = false(1, size(projMat, 1));
            projSpaceList(1 : size(projMat, 2)) = true;
            projSpaceList = {projSpaceList};
            projType = EProjType.Static;
            projSet = self.ellTubeRel.project(projType,...
                projSpaceList, fProj);
        end
        %
        function ellTubeRel = getEllTubeRel(self, smartLinSys, l0Mat,...
                timeVec, isDisturb, calcPrecision, approxTypeVec)
            import gras.ellapx.enums.EApproxType;
            goodDirSetObj =...
                gras.ellapx.lreachplain.GoodDirectionSet(...
                smartLinSys, timeVec(1), l0Mat, calcPrecision);
            if (isDisturb)
                extIntBuilder =...
                    gras.ellapx.lreachuncert.ExtIntEllApxBuilder(...
                    smartLinSys, goodDirSetObj, timeVec,...
                    elltool.conf.Properties.getRelTol(),...
                    'volume', self.MIN_EIG_Q_REG_UNCERT);
                EllTubeBuilder =...
                    gras.ellapx.gen.EllApxCollectionBuilder({extIntBuilder});
                ellTubeRel = EllTubeBuilder.getEllTubes();
            else
                if (~isempty(find(approxTypeVec == EApproxType.Internal, 1)))
                    intBuilder =...
                        gras.ellapx.lreachplain.IntEllApxBuilder(...
                        smartLinSys, goodDirSetObj, timeVec,...
                        elltool.conf.Properties.getRelTol(), 'volume');
                    intEllTubeBuilder =...
                        gras.ellapx.gen.EllApxCollectionBuilder({intBuilder});
                    intEllTubeRel = intEllTubeBuilder.getEllTubes();
                    if (isempty(find(approxTypeVec ==...
                            EApproxType.External, 1)))
                        ellTubeRel = intEllTubeRel;
                    end
                end
                if (~isempty(find(approxTypeVec == EApproxType.External, 1)))
                    extBuilder =...
                        gras.ellapx.lreachplain.ExtEllApxBuilder(...
                        smartLinSys, goodDirSetObj, timeVec,...
                        elltool.conf.Properties.getRelTol());
                    extEllTubeBuilder =...
                        gras.ellapx.gen.EllApxCollectionBuilder({extBuilder});
                    extEllTubeRel = extEllTubeBuilder.getEllTubes();
                    if (~isempty(find(approxTypeVec ==...
                            EApproxType.Internal, 1)))
                        extEllTubeRel.unionWith(intEllTubeRel);
                    end
                    ellTubeRel = extEllTubeRel;
                end
            end
        end
    end
    methods (Access = private, Static)
        function isDisturb = isDisturbance(gtStrCMat, qtStrCMat)
            gSizeZeroMat = zeros(size(gtStrCMat));
            qSizeZeroMat = zeros(size(qtStrCMat));
            gSizeZeroCMat =...
                reshape(cellstr(num2str(gSizeZeroMat(:))), size(gtStrCMat));
            qSizeZeroCMat =...
                reshape(cellstr(num2str(qSizeZeroMat(:))), size(qtStrCMat));
            isEqGMat = strcmp(gtStrCMat, gSizeZeroCMat);
            isEqQMat = strcmp(qtStrCMat, qSizeZeroCMat);
            if (all(isEqGMat(:)) || all(isEqQMat(:)))
                isDisturb = false;
            else
                isDisturb = true;
            end
        end
        function linSys = getSmartLinSys(atStrCMat, btStrCMat,...
                ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                x0Mat, x0Vec, timeVec, calcPrecision, isDisturb)
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
            if isDisturb
                linSys = getSysWithDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat,...
                    qtStrCVec, x0Mat, x0Vec, timeVec, calcPrecision);
            else
                linSys = getSysWithoutDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, x0Mat, x0Vec,...
                    timeVec, calcPrecision);
            end
        end
        %
        function outMat = getNormMat(inpMat, dim)
            matSqNormVec = sum(inpMat .* inpMat);
            indNonZerSqNormVec = find(matSqNormVec);
            matSqNormVec(indNonZerSqNormVec) =...
                sqrt(matSqNormVec(indNonZerSqNormVec));
            outMat(:, indNonZerSqNormVec) =...
                inpMat(:,indNonZerSqNormVec) ./...
                matSqNormVec(ones(1, dim), indNonZerSqNormVec);
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
                [ptVec ptMat] = double(uEll);
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
                [qtVec qtMat] = double(vEll);
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
            smartLinSys = self.getSmartLinSys(atStrCMat, btStrCMat,...
                ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                x0Mat, x0Vec, timeVec,...
                elltool.conf.Properties.getRelTol(), isDisturbance);
            approxTypeVec = [EApproxType.External EApproxType.Internal];
            self.ellTubeRel = self.getEllTubeRel(smartLinSys, l0Mat,...
                timeVec, isDisturbance,...
                elltool.conf.Properties.getRelTol(), approxTypeVec);
        end
        %%
        function plot_ea(self)
            import gras.ellapx.enums.EApproxType;
            if self.dimension() > 2
                projBasisMat = eye(3);
            else
                projBasisMat = eye(self.dimension());
            end
            projSetObj = self.getProjSet(projBasisMat);
            extProj =...
                projSetObj.getTuplesFilteredBy('approxType',...
                EApproxType.External);
            plotterObj = smartdb.disp.RelationDataPlotter();
            extProj.plot(plotterObj);
        end
        %%
        function plot_ia(self)
            import gras.ellapx.enums.EApproxType;
            if self.dimension() > 2
                projBasisMat = eye(3);
            else
                projBasisMat = eye(self.dimension());
            end
            projSetObj = self.getProjSet(projBasisMat);
            intProj =...
                projSetObj.getTuplesFilteredBy('approxType',...
                EApproxType.Internal);
            plotterObj = smartdb.disp.RelationDataPlotter();
            intProj.plot(plotterObj);
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
            if ~(isempty(self.projectionBasisMat))
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
            cutObj = elltool.reach.ReachContinious();
            cutObj.ellTubeRel = self.ellTubeRel.cut(cutTimeVec);
            switchTimeIndVec =...
                self.switchSysTimeVec > cutTimeVec(1) &...
                self.switchSysTimeVec < cutTimeVec(end);
            cutObj.switchSysTimeVec = [cutTimeVec(1)...
                self.switchSysTimeVec(switchTimeIndVec) cutTimeVec(end)];
            switchTimeIndVec(find(switchTimeIndVec == 1, 1) - 1) = 1;
            cutObj.linSysCVec = self.linSysCVec(switchTimeIndVec);
            cutObj.x0Ellipsoid = self.x0Ellipsoid;
            cutObj.isCut = true;
            cutObj.projectionBasisMat = self.projectionBasisMat;
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
            projSet = self.getProjSet(projMat);
            projObj = elltool.reach.ReachContinious();
            projObj.switchSysTimeVec = self.switchSysTimeVec;
            projObj.x0Ellipsoid = self.x0Ellipsoid;
            projObj.ellTubeRel = projSet;
            projObj.linSysCVec = self.linSysCVec;
            projObj.isCut = self.isCut;
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
            if self.isprojection()
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
            for il0Num = l0VecNum: -1 : 1
                smartExtLinSys = self.getSmartLinSys(atStrCMat,...
                    btStrCMat, ptStrCMat, ptStrCVec, gtStrCMat,...
                    qtStrCMat, qtStrCVec, x0ExtMatArray(:, :, il0Num),...
                    x0ExtVecMat(:, il0Num), newTimeVec,...
                    elltool.conf.Properties.getRelTol(), isDisturbance);
                smartIntLinSys = self.getSmartLinSys(atStrCMat,...
                    btStrCMat, ptStrCMat, ptStrCVec, gtStrCMat,...
                    qtStrCMat, qtStrCVec, x0IntMatArray(:, :, il0Num),...
                    x0IntVecMat(:, il0Num), newTimeVec,...
                    elltool.conf.Properties.getRelTol(), isDisturbance);
                ellTubeExtRelVec{il0Num} = self.getEllTubeRel(...
                    smartExtLinSys, l0ExtMat(:, il0Num), newTimeVec,...
                    isDisturbance, elltool.conf.Properties.getRelTol(),...
                    EApproxType.External);
                ellTubeIntRelVec{il0Num} = self.getEllTubeRel(...
                    smartIntLinSys, l0IntMat(:, il0Num), newTimeVec,...
                    isDisturbance, elltool.conf.Properties.getRelTol(),...
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
    end
end