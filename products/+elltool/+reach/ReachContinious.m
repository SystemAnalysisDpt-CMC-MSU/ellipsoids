classdef ReachContinious < elltool.reach.AReach
    properties (Constant,GetAccess = private)
        MIN_EIG = 0.1
    end
    properties (Access = protected)
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
    end
    methods (Access = private, Static)  
        function isDisturb = isDisturbance(GtStrCMat, QtStrCMat)
            GSizeZeroMat = zeros(size(GtStrCMat));
            QSizeZeroMat = zeros(size(QtStrCMat));
            GSizeZeroCMat =...
                reshape(cellstr(num2str(GSizeZeroMat(:))), size(GtStrCMat));
            QSizeZeroCMat =...
                reshape(cellstr(num2str(QSizeZeroMat(:))), size(QtStrCMat));
            isEqGMat = strcmp(GtStrCMat, GSizeZeroCMat);
            isEqQMat = strcmp(QtStrCMat, QSizeZeroCMat);
            if (all(isEqGMat(:)) || all(isEqQMat(:)))
                isDisturb = false;
            else
                isDisturb = true;
            end
        end
        function linSys = getSmartLinSys(AtStrCMat, BtStrCMat,...
                PtStrCMat, ptStrCVec, GtStrCMat, QtStrCMat, qtStrCVec,...
                X0Mat, x0Vec, timeVec, calcPrecision, isDisturb)
            if isDisturb
                linSys =...
                    gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory.createByParams(...
                    AtStrCMat, BtStrCMat,...
                    PtStrCMat, ptStrCVec, GtStrCMat,...
                    QtStrCMat, qtStrCVec, X0Mat, x0Vec,...
                    timeVec, calcPrecision);
            else
                linSys =...
                    gras.ellapx.lreachplain.probdyn.LReachProblemDynamicsFactory.createByParams(...
                    AtStrCMat, BtStrCMat,...
                    PtStrCMat, ptStrCVec, X0Mat, x0Vec,...
                    timeVec, calcPrecision);
            end
        end
        %
        function outMat = getNormMat(inpMat, dim)
            MatSqNormVec = sum(inpMat .* inpMat);
            indNonZerSqNormVec = find(MatSqNormVec);
            MatSqNormVec(indNonZerSqNormVec) =...
                sqrt(MatSqNormVec(indNonZerSqNormVec));
            outMat(:, indNonZerSqNormVec) =...
                inpMat(:,indNonZerSqNormVec) ./...
                MatSqNormVec(ones(1, dim), indNonZerSqNormVec);
        end
        %
        function [AtStrCMat BtStrCMat GtStrCMat...
                  PtStrCMat ptStrCVec...
                  QtStrCMat qtStrCVec] = prepareSysParam(linSys)
            AtMat = linSys.getAtMat();
            BtMat = linSys.getBtMat();
            GtMat = linSys.getGtMat();
            if ~iscell(AtMat) && ~isempty(AtMat)
                AtStrCMat = arrayfun(@num2str, AtMat, 'UniformOutput', false);
            else
                AtStrCMat = AtMat;
            end
            if ~iscell(BtMat) && ~isempty(BtMat)
                BtStrCMat = arrayfun(@num2str, BtMat, 'UniformOutput', false);
            else
                BtStrCMat = BtMat;
            end
            if isempty(GtMat)
                GtMat = zeros(size(BtMat));
            end
            if ~iscell(GtMat)
                GtStrCMat = arrayfun(@num2str, GtMat, 'UniformOutput', false);
            else
                GtStrCMat = GtMat;
            end
            UEll = linSys.getUBoundsEll();
            if ~isempty(UEll)
                [ptVec PtMat] = double(UEll);
            else
                PtMat = zeros(size(BtMat, 2));
                ptVec = zeros(size(BtMat, 2), 1);
            end
            if ~iscell(PtMat)
                PtStrCMat =...
                    arrayfun(@num2str, PtMat, 'UniformOutput', false);
            else
                PtStrCMat = PtMat;
            end
            if ~iscell(ptVec)
                ptStrCVec =...
                    arrayfun(@num2str, ptVec, 'UniformOutput', false);
            else
                ptStrCVec = ptVec;
            end
            VEll = linSys.getDistBoundsEll();
            if ~isempty(VEll)
                [qtVec QtMat] = double(VEll);
            else
                QtMat = zeros(size(GtMat, 2));
                qtVec = zeros(size(GtMat, 2), 1);
            end
            if ~iscell(QtMat)
                QtStrCMat =...
                    arrayfun(@num2str, QtMat, 'UniformOutput', false);
            else
                QtStrCMat = QtMat;
            end
            if ~iscell(qtVec)
                qtStrCVec =...
                    arrayfun(@num2str, qtVec, 'UniformOutput', false);
            else
                qtStrCVec = qtVec;
            end
        end
        %
        function ellTubeRel = getEllTubeRel(smartLinSys, goodDirSetObj,...
                timeVec, isDisturbance, minEig)
            if (isDisturbance)
                extIntBuilder =...
                    gras.ellapx.lreachuncert.ExtIntEllApxBuilder(...
                    smartLinSys, goodDirSetObj, timeVec,...
                    elltool.conf.Properties.getRelTol(), 'volume', minEig);
                EllTubeBuilder =...
                    gras.ellapx.gen.EllApxCollectionBuilder({extIntBuilder});
                ellTubeRel = EllTubeBuilder.getEllTubes();
            else
                extBuilder =...
                    gras.ellapx.lreachplain.ExtEllApxBuilder(...
                    smartLinSys, goodDirSetObj, timeVec,...
                    elltool.conf.Properties.getRelTol());
                intBuilder =...
                    gras.ellapx.lreachplain.IntEllApxBuilder(...
                    smartLinSys, goodDirSetObj, timeVec,...
                    elltool.conf.Properties.getRelTol(), 'volume');
                extEllTubeBuilder =...
                    gras.ellapx.gen.EllApxCollectionBuilder({extBuilder});
                extEllTubeRel = extEllTubeBuilder.getEllTubes();
                intEllTubeBuilder =...
                    gras.ellapx.gen.EllApxCollectionBuilder({intBuilder});
                intEllTubeRel = intEllTubeBuilder.getEllTubes();
                extEllTubeRel.unionWith(intEllTubeRel);
                ellTubeRel = extEllTubeRel;
            end
        end
    end
    methods
        function self =...
                ReachContinious(linSys, X0Ell, L0Mat, timeVec, OptStruct)
            import modgen.common.type.simple.checkgenext;
            import modgen.common.throwerror;
            import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
            import gras.ellapx.uncertcalc.EllApxBuilder;
            %%
            if (nargin == 0) || isempty(linSys)
                return;
            end
            self.switchSysTimeVec = timeVec;
            self.X0Ellipsoid = X0Ell;
            self.linSysVec = linSys;
            self.isCut = false;
            self.projectionBasisMat = [];
            %% check and analize input
            if nargin < 4
                throwerror('REACH: insufficient number of input arguments.');
            end
            if ~(isa(linSys, 'elltool.linsys.LinSys'))
                throwerror(['REACH: first input argument ',...
                    'must be linear system object.']);
            end
            if ~(isa(X0Ell, 'ellipsoid'))
                throwerror(['REACH: set of initial ',...
                    'conditions must be ellipsoid.']);
            end
            checkgenext('x1==x2&&x2==x3', 3,...
                dimension(linSys), dimension(X0Ell), size(L0Mat, 1));
            %%
            [timeRows, timeCols] = size(timeVec);
            if ~(isa(timeVec, 'double')) ||...
                    (timeRows ~= 1) || (timeCols ~= 2)
                throwerror(['REACH: time interval must be specified as ',...
                    '''[t0 t1]'', or, in discrete-time - as ''[k0 k1]''.']);
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
            [x0Vec X0Mat] = double(X0Ell);
            [AtStrCMat BtStrCMat GtStrCMat PtStrCMat ptStrCVec...
                QtStrCMat qtStrCVec] = self.prepareSysParam(linSys);
            isDisturbance = self.isDisturbance(GtStrCMat, QtStrCMat);
            smartLinSys =  self.getSmartLinSys(AtStrCMat, BtStrCMat,...
                PtStrCMat, ptStrCVec, GtStrCMat, QtStrCMat,...
                qtStrCVec, X0Mat, x0Vec, timeVec,...
                elltool.conf.Properties.getRelTol(), isDisturbance);
            %% Normalize good directions
            sysDim = size(AtStrCMat, 1);
            L0Mat = self.getNormMat(L0Mat, sysDim);
            %% Make good direction object
            goodDirSetObj =...
                gras.ellapx.lreachplain.GoodDirectionSet(...
                smartLinSys, timeVec(1), L0Mat,...
                elltool.conf.Properties.getRelTol());
            self.ellTubeRel = self.getEllTubeRel(smartLinSys,...
                goodDirSetObj, timeVec, isDisturbance, self.MIN_EIG);
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
            if isdiscrete(self.linSysVec(end))
                sysType = 'discrete-time';
                sysVar = 'k = ';
                sysT0 = 'k0 = ';
                sysT1 = 'k1 = ';
            else
                sysType = 'continuous-time';
                sysVar = 't = ';
                sysT0 = 't0 = ';
                sysT1 = 't1 = ';
            end
            dim = self.dimension();
            timeVec = [self.switchSysTimeVec(1) self.switchSysTimeVec(end)];
            if size(timeVec, 2) == 1
                back = 0;
                fprintf(['Reach set of the %s linear system ',...
                    'in R^%d at time %s%d.\n'],...
                    sysType, dim, sysVar, timeVec);
            else
                if timeVec(1) > timeVec(end)
                    back = 1;
                    fprintf(['Backward reach set of the %s linear system ',...
                        'in R^%d in the time interval [%d, %d].\n'],...
                        sysType, dim, timeVec(1), timeVec(end));
                else
                    back = 0;
                    fprintf(['Reach set of the %s linear system ',...
                        'in R^%d in the time interval [%d, %d].\n'],...
                        sysType, dim, timeVec(1), timeVec(end));
                end
            end
            if ~(isempty(self.projectionBasisMat))
                fprintf('Projected onto the basis:\n');
                disp(self.projectionBasisMat);
            end
            fprintf('\n');
            if back > 0
                fprintf('Target set at time %s%d:\n', sysT1, timeVec(1));
            else
                fprintf('Initial set at time %s%d:\n', sysT0, timeVec(1));
            end
            disp(self.X0Ellipsoid);
            fprintf('Number of external approximations: %d\n',...
                sum(self.ellTubeRel.approxType == EApproxType.External));
            fprintf('Number of internal approximations: %d\n',...
                sum(self.ellTubeRel.approxType == EApproxType.Internal));
            fprintf('\n');
        end
        %% change
        function cutObj = cut(self, cutTimeVec)
            cutObj = elltool.reach.ReachContinious();
            cutObj.linSysVec = self.linSysVec(end);
            cutObj.ellTubeRel = self.ellTubeRel.cut(cutTimeVec);
            cutObj.isCut = true;
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
            nTuples = size(SData.QArray, 1);
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
            nTuples = size(SData.QArray, 1);
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
        %% change
        function projObj = projection(self, projMat)
            projSet = self.getProjSet(projMat);
            projObj = elltool.reach.ReachContinious();
            projObj.switchSysTimeVec = self.switchSysTimeVec;
            projObj.X0Ellipsoid = self.X0Ellipsoid;
            projObj.ellTubeRel = projSet;
            projObj.linSysVec = self.linSysVec;
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
                throwerror('EVOLVE: insufficient number of input arguments.');
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
                throwerror('EVOLVE: new end time must be more than old one.');
            end
            if newLinSys.dimension() ~= oldLinSys.dimension()
                throwerror(['EVOLVE: dimensions of the ',...
                    'old and new linear systems do not match.']);
            end
            %%
            newReachObj = elltool.reach.ReachContinious();
            newReachObj.switchSysTimeVec = [self.switchSysTimeVec newEndTime];
            newReachObj.X0Ellipsoid = self.X0Ellipsoid;
            newReachObj.linSysVec = [self.linSysVec newLinSys];
            newReachObj.isCut = false;
            newReachObj.projectionBasisMat = [];
            %% prepare ext/int data to evolve
            oldExtData =...
                self.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.External);
            oldIntData =...
                self.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.Internal);
            extDataDimVec = oldExtData.dim;
            l0ExtVecNum = size(extDataDimVec, 1);
            L0ExtMat = zeros(extDataDimVec(1), l0ExtVecNum);
            x0ExtVecMat = zeros(size(oldExtData.aMat{1}, 1), l0ExtVecNum);
            X0ExtMatArray = zeros(size(oldExtData.QArray{1}, 1),...
                size(oldExtData.QArray{1}, 2), l0ExtVecNum);
            for il0Num = 1 : l0ExtVecNum
                L0ExtMat(:, il0Num) = oldExtData.ltGoodDirMat{il0Num}(:, end);
                x0ExtVecMat(:, il0Num) = oldExtData.aMat{il0Num}(:, end);
                X0ExtMatArray(:, :, il0Num) =...
                    oldExtData.QArray{il0Num}(:, :, end);
            end
            intDataDimVec = oldIntData.dim;
            l0IntVecNum = size(intDataDimVec, 1);
            L0IntMat = zeros(intDataDimVec(1), l0IntVecNum);
            x0IntVecMat = zeros(size(oldIntData.aMat{1}, 1), l0IntVecNum);
            X0IntMatArray = zeros(size(oldIntData.QArray{1}, 1),...
                size(oldIntData.QArray{1}, 2), l0IntVecNum);
            for il0Num = 1 : l0IntVecNum
                L0IntMat(:, il0Num) = oldIntData.ltGoodDirMat{il0Num}(:, end);
                x0IntVecMat(:, il0Num) = oldIntData.aMat{il0Num}(:, end);
                X0IntMatArray(:, :, il0Num) =...
                    oldIntData.QArray{il0Num}(:, :, end);
            end
            newTimeVec = newReachObj.switchSysTimeVec(end - 1 : end);
            [AtStrCMat BtStrCMat GtStrCMat PtStrCMat ptStrCVec...
                  QtStrCMat qtStrCVec] = self.prepareSysParam(newLinSys);
            %% Normalize good ext/int-directions
            sysDim = size(AtStrCMat, 1);
            L0ExtMat = self.getNormMat(L0ExtMat, sysDim);
            L0IntMat = self.getNormMat(L0IntMat, sysDim);
            %% ext/int-approx on the next time interval
            dataCVec = cell(1, 2 * l0ExtVecNum);
            isDisturbance = self.isDisturbance(GtStrCMat, QtStrCMat);
            for il0Num = l0ExtVecNum: -1 : 1
                smartExtLinSys = self.getSmartLinSys(AtStrCMat,...
                    BtStrCMat, PtStrCMat, ptStrCVec, GtStrCMat,...
                    QtStrCMat, qtStrCVec, X0ExtMatArray(:, :, il0Num),...
                    x0ExtVecMat(:, il0Num), newTimeVec,...
                    elltool.conf.Properties.getRelTol(), isDisturbance);
                smartIntLinSys = self.getSmartLinSys(AtStrCMat,...
                    BtStrCMat, PtStrCMat, ptStrCVec, GtStrCMat,...
                    QtStrCMat, qtStrCVec, X0IntMatArray(:, :, il0Num),...
                    x0IntVecMat(:, il0Num), newTimeVec,...
                    elltool.conf.Properties.getRelTol(), isDisturbance);
                goodExtDirSetObj =...
                    gras.ellapx.lreachplain.GoodDirectionSet(...
                    smartExtLinSys, newTimeVec(1),...
                    L0ExtMat(:, il0Num), elltool.conf.Properties.getRelTol());
                goodIntDirSetObj =...
                    gras.ellapx.lreachplain.GoodDirectionSet(...
                    smartIntLinSys, newTimeVec(1),...
                    L0IntMat(:, il0Num), elltool.conf.Properties.getRelTol());
                ellTubeExtRelVec{il0Num} =...
                    self.getEllTubeRel(smartExtLinSys, goodExtDirSetObj,...
                    newTimeVec, isDisturbance, self.MIN_EIG);
                ellTubeIntRelVec{il0Num} =...
                    self.getEllTubeRel(smartIntLinSys, goodIntDirSetObj,...
                    newTimeVec, isDisturbance, self.MIN_EIG);
                dataCVec{il0Num} = ...
                    ellTubeExtRelVec{il0Num}.getTuplesFilteredBy(...
                    'approxType', EApproxType.External).getData();
                dataCVec{l0ExtVecNum + il0Num} = ...
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