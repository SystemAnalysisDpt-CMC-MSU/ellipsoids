classdef ReachContinious < elltool.reach.AReach
    properties (Constant,GetAccess = private)
        MIN_EIG = 0.1
    end
    properties (Access = protected)
        %linSys
        smartLinSys
        ellTubeRel
        %isCut
        %projectionBasisMat
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
        %%
    methods (Static)    
        function [linSys isDisturb] = getSmartLinSys(AtStrCMat, BtStrCMat,...
                PtStrCMat, ptStrCVec, GtStrCMat, QtStrCMat, qtStrCVec,...
                X0Mat, x0Vec, timeVec, calcPrecision)
            GSizeZeroMat = zeros(size(GtStrCMat));
            QSizeZeroMat = zeros(size(QtStrCMat));
            GSizeZeroCMat =...
                reshape(cellstr(num2str(GSizeZeroMat(:))), size(GtStrCMat));
            QSizeZeroCMat =...
                reshape(cellstr(num2str(QSizeZeroMat(:))), size(QtStrCMat));
            %%
            isEqGMat = strcmp(GtStrCMat, GSizeZeroCMat);
            isEqQMat = strcmp(QtStrCMat, QSizeZeroCMat);
            if (all(isEqGMat(:)) || all(isEqQMat(:)))
                linSys =...
                    gras.ellapx.lreachplain.probdyn.LReachProblemDynamicsFactory.createByParams(...
                    AtStrCMat, BtStrCMat,...
                    PtStrCMat, ptStrCVec, X0Mat, x0Vec,...
                    timeVec, calcPrecision);
                isDisturb = false;
            else
                linSys =...
                    gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory.createByParams(...
                    AtStrCMat, BtStrCMat,...
                    PtStrCMat, ptStrCVec, GtStrCMat,...
                    QtStrCMat, qtStrCVec, X0Mat, x0Vec,...
                    timeVec, calcPrecision);
                isDisturb = true;
            end
        end
    end
    methods
        function self = ReachContinious(linSys, X0Ell, L0Mat, timeVec, OptStruct)
            import modgen.common.type.simple.checkgenext;
            import modgen.common.throwerror;
            import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
            import gras.ellapx.uncertcalc.EllApxBuilder;
            %%
            self.linSys = linSys;
            self.isCut = false;
            self.projectionBasisMat = [];
            %% analize input
            if (nargin == 0) || isempty(linSys)
                return;
            end
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
            if ~(isa(timeVec, 'double')) || (timeRows ~= 1) ||...
                    ((timeCols ~= 2) && (timeCols ~= 1))
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
            %% create LinSys object
            [x0Vec X0Mat] = double(X0Ell);
            AtMat = linSys.getAtMat();
            BtMat = linSys.getBtMat();
            GtMat = linSys.getGtMat();
            if ~iscell(AtMat) && ~isempty(AtMat)
                AtStrCMat = reshape(cellstr(num2str(AtMat(:))), size(AtMat));
            else
                AtStrCMat = AtMat;
            end
            if ~iscell(BtMat) && ~isempty(BtMat)
                BtStrCMat = reshape(cellstr(num2str(BtMat(:))), size(BtMat));
            else
                BtStrCMat = BtMat;
            end
            if isempty(GtMat)
                GtMat = zeros(size(BtMat));
            end
            if ~iscell(GtMat)
                GtStrCMat = reshape(cellstr(num2str(GtMat(:))), size(GtMat));
            else
                GtStrCMat = GtMat;
            end
            UEll = linSys.getUBoundsEll();
            VEll = linSys.getDistBoundsEll();
            %%
            if ~isempty(UEll)
                [ptVec PtMat] = double(UEll);
            else
                PtMat = zeros(size(BtMat, 2));
                ptVec = zeros(size(BtMat, 2), 1);
            end
            if ~iscell(PtMat)
                PtStrCMat =...
                    reshape(cellstr(num2str(PtMat(:))), size(PtMat));
            else
                PtStrCMat = PtMat;
            end
            if ~iscell(ptVec)
                ptStrCVec =...
                    reshape(cellstr(num2str(ptVec(:))), size(ptVec));
            else
                ptStrCVec = ptVec;
            end
            %%
            if ~isempty(VEll)
                [qtVec QtMat] = double(VEll);
            else
                QtMat = zeros(size(GtMat, 2));
                qtVec = zeros(size(GtMat, 2), 1);
            end
            if ~iscell(QtMat)
                QtStrCMat =...
                    reshape(cellstr(num2str(QtMat(:))), size(QtMat));
            else
                QtStrCMat = QtMat;
            end
            if ~iscell(qtVec)
                qtStrCVec =...
                    reshape(cellstr(num2str(qtVec(:))), size(qtVec));
            else
                qtStrCVec = qtVec;
            end
            %%
            [self.smartLinSys isDisturbance] =...
                self.getSmartLinSys(AtStrCMat, BtStrCMat,...
                PtStrCMat, ptStrCVec, GtStrCMat, QtStrCMat, qtStrCVec,...
                X0Mat, x0Vec, timeVec, elltool.conf.Properties.getRelTol());
            %% Normalize good directions
            sysDim = size(AtStrCMat, 1);
            L0SqNormVec = sum(L0Mat .* L0Mat);
            indNonZerSqNormVec = find(L0SqNormVec);
            L0SqNormVec(indNonZerSqNormVec) =...
                sqrt(L0SqNormVec(indNonZerSqNormVec));
            L0Mat(:, indNonZerSqNormVec) =...
                L0Mat(:,indNonZerSqNormVec) ./...
                L0SqNormVec(ones(1, sysDim), indNonZerSqNormVec);
            %% Make good direction object
            goodDirSetObj =...
                gras.ellapx.lreachplain.GoodDirectionSet(...
                self.smartLinSys, timeVec(1), L0Mat,...
                elltool.conf.Properties.getRelTol());
            if (isDisturbance)
                extIntBuilder =...
                    gras.ellapx.lreachuncert.ExtIntEllApxBuilder(...
                    self.smartLinSys, goodDirSetObj, timeVec,...
                    elltool.conf.Properties.getRelTol(),...
                    'volume', self.MIN_EIG);
            else
                %% only external approx in this case
                extIntBuilder =...
                    gras.ellapx.lreachplain.ExtEllApxBuilder(...
                    self.smartLinSys, goodDirSetObj, timeVec,...
                    elltool.conf.Properties.getRelTol());
            end
            %% get tubes
            ellTubeBuilder =...
                gras.ellapx.gen.EllApxCollectionBuilder({extIntBuilder});
            %ellTubeRel = ellTubeBuilder.getEllTubes();
            self.ellTubeRel = ellTubeBuilder.getEllTubes();
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
        %%
        function display(self)
            import gras.ellapx.enums.EApproxType;
            fprintf('\n');
            disp([inputname(1) ' =']);
            if isempty(self)
                fprintf('Empty reach set object.\n\n');
                return;
            end
            if isdiscrete(self.linSys)
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
            timeVec = self.ellTubeRel.timeVec{1};
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
            X0Ell = ellipsoid(self.smartLinSys.getx0Vec,...
                self.smartLinSys.getX0Mat);
            disp(X0Ell);
            fprintf('Number of external approximations: %d\n',...
                sum(self.ellTubeRel.approxType == EApproxType.External));
            fprintf('Number of internal approximations: %d\n',...
                sum(self.ellTubeRel.approxType == EApproxType.Internal));
            fprintf('\n');
        end
        %%
        function cutObj = cut(self, cutTimeVec)
            cutObj = elltool.core.control.Reach();
            cutObj.linSys = self.linSys;
            cutObj.smartLinSys = self.smartLinSys;
            cutObj.ellTubeRel = self.ellTubeRel.cut(cutTimeVec);
            cutObj.isCut = true;
        end
        %%
        function [directionsCVec timeVec] = get_directions(self)
            import gras.ellapx.enums.EApproxType;
            SData = self.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.Internal);
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
            if nargout > 1
                timeVec = cell2mat(SData.timeVec(1));
            end
        end
        %
        function [goodCurvesCVec timeVec] = get_goodcurves(self)
            import gras.ellapx.enums.EApproxType;
            SData = self.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.Internal);
            goodCurvesCVec = SData.xTouchCurveMat.';
            if nargout > 1
                timeVec = cell2mat(SData.timeVec(1));
            end
        end
        %%
        function projObj = projection(self, projMat)
            projSet = getProjSet(projMat);
            projObj = elltool.core.control.Reach();
            projObj.ellTubeRel = projSet;
            projObj.linSys = self.linSys;
            projObj.smartLinSys = self.smartLinSys;
            projObj.isCut = self.isCut;
            projObj.projectionBasisMat = projMat;
        end
        %%
        function newReachObj = evolve(self, newEndTime, linSys)
            import elltool.conf.Properties;
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
            import gras.ellapx.uncertcalc.EllApxBuilder;
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
                if ~(isa(linSys, 'elltool.core.control.LinSys'))
                    throwerror(['REACH: first input argument ',...
                        'must be linear system object.']);
                end
                oldLinSys = self.get_system();
                newLinSys = linSys;
            end
            if isempty(newLinSys)
                return;
            end
            if ~isa(newEndTime, 'double')
                throwerror('EVOLVE: second argument must be double.');
            end
            if newEndTime < self.smartLinSys.gett1
                throwerror('EVOLVE: new end time must be more than old one.');
            end
            [stateDim, inpDim, outDim, distDim] = newLinSys.dimension();
            if stateDim ~= oldLinSys.dimension()
                throwerror(['EVOLVE: dimensions of the ',...
                    'old and new linear systems do not match.']);
            end
            newReachObj = elltool.core.control.Reach();
            newReachObj.linSys = newLinSys;
            newReachObj.isCut = false;
            newReachObj.projectionBasisMat = [];
            %%
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
            %
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
            newTimeVec = [self.smartLinSys.gett1 newEndTime];
            %% create LinSys object
            AtMat = oldLinSys.getAtMat();
            BtMat = oldLinSys.getBtMat();
            GtMat = oldLinSys.getGtMat();
            if ~iscell(AtMat) && ~isempty(AtMat)
                AtStrCMat = reshape(cellstr(num2str(AtMat(:))), size(AtMat));
            else
                AtStrCMat = AtMat;
            end
            if ~iscell(BtMat) && ~isempty(BtMat)
                BtStrCMat = reshape(cellstr(num2str(BtMat(:))), size(BtMat));
            else
                BtStrCMat = BtMat;
            end
            if isempty(GtMat)
                GtMat = zeros(size(BtMat));
            end
            if ~iscell(GtMat)
                GtStrCMat = reshape(cellstr(num2str(GtMat(:))), size(GtMat));
            else
                GtStrCMat = GtMat;
            end
            UEll = newLinSys.getUBoundsEll();
            VEll = newLinSys.getDistBoundsEll();
            %%
            if ~isempty(UEll)
                [ptVec PtMat] = double(UEll);
            else
                PtMat = zeros(size(BtMat, 2));
                ptVec = zeros(size(BtMat, 2), 1);
            end
            if ~iscell(PtMat)
                PtStrCMat =...
                    reshape(cellstr(num2str(PtMat(:))), size(PtMat));
            else
                PtStrCMat = PtMat;
            end
            if ~iscell(ptVec)
                ptStrCVec =...
                    reshape(cellstr(num2str(ptVec(:))), size(ptVec));
            else
                ptStrCVec = ptVec;
            end
            %%
            if ~isempty(VEll)
                [qtVec QtMat] = double(VEll);
            else
                QtMat = zeros(size(GtMat, 2));
                qtVec = zeros(size(GtMat, 2), 1);
            end
            if ~iscell(QtMat)
                QtStrCMat =...
                    reshape(cellstr(num2str(QtMat(:))), size(QtMat));
            else
                QtStrCMat = QtMat;
            end
            if ~iscell(qtVec)
                qtStrCVec =...
                    reshape(cellstr(num2str(qtVec(:))), size(qtVec));
            else
                qtStrCVec = qtVec;
            end
            %% Normalize good ext-directions
            sysDim = size(AtStrCMat, 1);
            L0SqNormVec = sum(L0ExtMat .* L0ExtMat);
            indNonZerSqNormVec = find(L0SqNormVec);
            L0SqNormVec(indNonZerSqNormVec) =...
                sqrt(L0SqNormVec(indNonZerSqNormVec));
            L0ExtMat(:, indNonZerSqNormVec) =...
                L0ExtMat(:,indNonZerSqNormVec) ./...
                L0SqNormVec(ones(1, sysDim), indNonZerSqNormVec);
            %% Normalize good int-directions
            sysDim = size(AtStrCMat, 1);
            L0SqNormVec = sum(L0IntMat .* L0IntMat);
            indNonZerSqNormVec = find(L0SqNormVec);
            L0SqNormVec(indNonZerSqNormVec) =...
                sqrt(L0SqNormVec(indNonZerSqNormVec));
            L0IntMat(:, indNonZerSqNormVec) =...
                L0IntMat(:,indNonZerSqNormVec) ./...
                L0SqNormVec(ones(1, sysDim), indNonZerSqNormVec);
            %% ext-approx on the second time interval
            dataCVec = cell(1, 2 * l0ExtVecNum);
            for il0Num = l0ExtVecNum: -1 : 1
                smartExtLinSysVec{il0Num} = getSmartLinSys(AtStrCMat,...
                    BtStrCMat, PtStrCMat, ptStrCVec, GtStrCMat,...
                    QtStrCMat, qtStrCVec, X0ExtMatArray(:, :, il0Num),...
                    x0ExtVecMat(:, il0Num), newTimeVec,...
                    elltool.conf.Properties.getRelTol());
                smartIntLinSysVec{il0Num} = getSmartLinSys(AtStrCMat,...
                    BtStrCMat, PtStrCMat, ptStrCVec, GtStrCMat,...
                    QtStrCMat, qtStrCVec, X0IntMatArray(:, :, il0Num),...
                    x0IntVecMat(:, il0Num), newTimeVec,...
                    elltool.conf.Properties.getRelTol());
                goodExtDirSetObjVec{il0Num} =...
                    gras.ellapx.lreachplain.GoodDirectionSet(...
                    smartExtLinSysVec{il0Num}, newTimeVec(1),...
                    L0ExtMat(:, il0Num), elltool.conf.Properties.getRelTol());
                goodIntDirSetObjVec{il0Num} =...
                    gras.ellapx.lreachplain.GoodDirectionSet(...
                    smartIntLinSysVec{il0Num}, newTimeVec(1),...
                    L0IntMat(:, il0Num), elltool.conf.Properties.getRelTol());
                extApproxBuilderVec{il0Num} =...
                    gras.ellapx.lreachuncert.ExtIntEllApxBuilder(...
                    smartExtLinSysVec{il0Num}, goodExtDirSetObjVec{il0Num},...
                    newTimeVec, elltool.conf.Properties.getRelTol(),...
                    'volume', self.MIN_EIG);
                intApproxBuilderVec{il0Num} =...
                    gras.ellapx.lreachuncert.ExtIntEllApxBuilder(...
                    smartIntLinSysVec{il0Num}, goodIntDirSetObjVec{il0Num},...
                    newTimeVec, elltool.conf.Properties.getRelTol(),...
                    'volume', self.MIN_EIG);
                ellTubeExtBuilderVec{il0Num} =...
                    gras.ellapx.gen.EllApxCollectionBuilder(...
                    {extApproxBuilderVec{il0Num}});
                ellTubeIntBuilderVec{il0Num} =...
                    gras.ellapx.gen.EllApxCollectionBuilder(...
                    {intApproxBuilderVec{il0Num}});
                ellTubeExtRelVec{il0Num} =...
                    ellTubeExtBuilderVec{il0Num}.getEllTubes();
                ellTubeIntRelVec{il0Num} =...
                    ellTubeIntBuilderVec{il0Num}.getEllTubes();
                dataCVec{2*il0Num-1} = ...
                    ellTubeExtRelVec{il0Num}.getTuplesFilteredBy(...
                    'approxType', EApproxType.External).getData();
                dataCVec{2*il0Num} = ...
                    ellTubeIntRelVec{il0Num}.getTuplesFilteredBy(...
                    'approxType', EApproxType.Internal).getData();
            end            
            %%
            newReachObj.ellTubeRel =...
                gras.ellapx.smartdb.rels.EllTube.fromStructList(...
                    'gras.ellapx.smartdb.rels.EllTube', dataCVec);
        end
    end
end