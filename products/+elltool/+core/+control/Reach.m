classdef Reach<handle
    properties (Constant,GetAccess=private)
        MIN_EIG = 0.1
    end
    properties (Access = public)
        linSys
        smartLinSys
        ellTubeRel
        isCut
        projectionBasisMat
    end
    methods
        function self = Reach(linSys, X0Ell, L0Mat, timeVec, OptStruct)
            global ellOptions;
            
            if nargin == 0
                % create an empty object
                return;
            end
            %%
            if ~isstruct(ellOptions)
                evalin('base', 'ellipsoids_init;');
            end
            %%
            self.linSys = linSys;
            self.isCut = false;
            self.projectionBasisMat = [];
            %% analize input
            import modgen.common.type.simple.checkgenext;
            import modgen.common.throwerror;
            if (nargin == 0) || isempty(linSys)
                return;
            end
            if nargin < 4
                throwerror('REACH: insufficient number of input arguments.');
            end
            if ~(isa(linSys, 'elltool.core.control.LinSys'))
                throwerror('REACH: first input argument must be linear system object.');
            end
            if ~(isa(X0Ell, 'ellipsoid'))
                throwerror('REACH: set of initial conditions must be ellipsoid.');
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
            import gras.ellapx.lreachuncert.LReachProblemDefInterp;
            self.smartLinSys =...
                LReachProblemDefInterp(AtStrCMat, BtStrCMat,...
                PtStrCMat, ptStrCVec, GtStrCMat,...
                QtStrCMat, qtStrCVec, X0Mat, x0Vec,...
                timeVec, ellOptions.rel_tol);
%             smartLinSys =...
%                 LReachProblemDefInterp(AtStrCMat, BtStrCMat,...
%                 PtStrCMat, ptStrCVec, GtStrCMat,...
%                 QtStrCMat, qtStrCVec, X0Mat, x0Vec,...
%                 timeVec, ellOptions.rel_tol);
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
                self.smartLinSys, timeVec(1), L0Mat, ellOptions.rel_tol);
            extIntBuilder =...
                gras.ellapx.lreachuncert.ExtIntEllApxBuilder(...
                self.smartLinSys, goodDirSetObj, timeVec,...
                ellOptions.rel_tol, 'volume', self.MIN_EIG);
            %% get tubes
            ellTubeBuilder =...
                gras.ellapx.gen.EllApxCollectionBuilder({extIntBuilder});
            import gras.ellapx.uncertcalc.EllApxBuilder;
            ellTubeRel = ellTubeBuilder.getEllTubes();
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
            newReachObj = self.projection(projBasisMat);
            extProj =...
                newReachObj.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.External);
            plotterObj = smartdb.disp.RelationDataPlotter();
            extProj.plot(plotterObj); 
        end
        %
        function plot_ia(self)
            import gras.ellapx.enums.EApproxType;
            if self.dimension() > 2
               projBasisMat = eye(3);
            else
                projBasisMat = eye(self.dimension());
            end
            newReachObj = self.projection(projBasisMat);
            intProj =...
                newReachObj.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.Internal);
            plotterObj = smartdb.disp.RelationDataPlotter();
            intProj.plot(plotterObj); 
        end
        %
        function display(self)
            global ellOptions;
            if ~isstruct(ellOptions)
                evalin('base', 'ellipsoids_init;');
            end
            %
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
                fprintf('Reach set of the %s linear system in R^%d at time %s%d.\n',...
                    sysType, dim, sysVar, timeVec);
            else
                if timeVec(1) > timeVec(end)
                    back = 1;
                    fprintf('Backward reach set of the %s linear system in R^%d in the time interval [%d, %d].\n',...
                        sysType, dim, timeVec(1), timeVec(end));
                else
                    back = 0;
                    fprintf('Reach set of the %s linear system in R^%d in the time interval [%d, %d].\n',...
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
            import gras.ellapx.enums.EApproxType;
            externalData = self.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.External);
            internalData = self.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.Internal);
            fprintf('Number of external approximations: %d\n',...
                size(externalData.QArray, 1));
            fprintf('Number of internal approximations: %d\n',...
                size(internalData.QArray, 1));
            fprintf('\n');
        end
        %
        function isProj = isprojection(self)
            %isProj = isa(self.ellTubeRel, 'gras.ellapx.smartdb.rels.EllTubeProj');
            isProj = ~isempty(self.projectionBasisMat);
        end
        %
        function isCut = iscut(self)
           isCut = self.isCut; 
        end
        %
        function cutObj = cut(self, cutTimeVec)
            data = self.ellTubeRel.getData();
            %
            if numel(cutTimeVec) == 1
                cutTimeVec = [cutTimeVec(1) cutTimeVec(1)];
            end
            if numel(cutTimeVec) ~= 2
                throwerror('Reach:cut:input vector should contain 1 or 2 elements');
            end
            nTuples = self.ellTubeRel.getNElems();
            s0 = cutTimeVec(1);
            s1 = cutTimeVec(2);
            if s0 > s1
                throwerror('Reach:cut:s0 must be LEQ then s1');
            end
            for iTuple = 1 : nTuples
                timeVec = data.timeVec{iTuple};
                t0 = timeVec(1);
                t1 = timeVec(end);
                if s0 < t0 || s0 > t1 || s1 < t0 || s1 > t1
                    throwerror('Reach:cut:wrong input format');
                end
                indLower = timeVec < s0;
                indGreater = timeVec > s1;
                if cutTimeVec(1) == cutTimeVec(2)
                    indClosest = find(indLower, 1, 'last');
                    indNewTimeVec = false(size(indLower));
                    indNewTimeVec(indClosest) = true;
                else
                    indNewTimeVec = ~ (indLower | indGreater);
                end
                newTimeVec = data.timeVec{iTuple}(indNewTimeVec);
                % s0 ans s1 may not be in timeVec
                newS0 = newTimeVec(1);
                newS1 = newTimeVec(end);
                sTime = data.sTime(iTuple);
                if newS0 <= sTime && sTime <= newS1
                    newSTime = sTime;
                    newIndSTime = find(newTimeVec == newSTime, 1);
                else
                    newSTime = newTimeVec(1);
                    newIndSTime = 1;
                end
                data.timeVec{iTuple} = newTimeVec;
                data.sTime(iTuple) = newSTime;
                data.indSTime(iTuple) = newIndSTime;
                data.QArray{iTuple} = data.QArray{iTuple}(:, :, indNewTimeVec);
                data.aMat{iTuple} = data.aMat{iTuple}(:, indNewTimeVec);
                data.MArray{iTuple} = data.MArray{iTuple}(:, :, indNewTimeVec);
                data.ltGoodDirMat{iTuple} =...
                    data.ltGoodDirMat{iTuple}(:, indNewTimeVec);
                data.lsGoodDirVec{iTuple} =...
                    data.ltGoodDirMat{iTuple}(:, newIndSTime);
                data.ltGoodDirNormVec{iTuple} =...
                    data.ltGoodDirNormVec{iTuple}(indNewTimeVec);
                data.lsGoodDirNorm(iTuple) =...
                    data.ltGoodDirNormVec{iTuple}(newIndSTime);
                data.xTouchCurveMat{iTuple} =...
                    data.xTouchCurveMat{iTuple}(:, indNewTimeVec);
                data.xsTouchVec{iTuple} =...
                    data.xTouchCurveMat{iTuple}(:, newIndSTime);
                data.xTouchOpCurveMat{iTuple} =...
                    data.xTouchOpCurveMat{iTuple}(:, indNewTimeVec);
                data.xsTouchOpVec{iTuple} =...
                    data.xTouchOpCurveMat{iTuple}(:, newIndSTime);
            end
            cutObj = elltool.core.control.Reach();
            cutObj.ellTubeRel = self.ellTubeRel;
            cutObj.linSys = self.linSys;
            cutObj.smartLinSys = self.smartLinSys;            
            cutObj.ellTubeRel.setData(data);
            self.isCut = true;
        end
        %
        function dimension = dimension(self)
            dimension = self.ellTubeRel.dim(1);
        end
        %
        function linSys = get_system(self)
            linSys = self.linSys;
        end
        %
        function [directionsCVec timeVec] = get_directions(self)
            import gras.ellapx.enums.EApproxType;
            SData = self.ellTubeRel.getTuplesFilteredBy('approxType',...
                EApproxType.Internal);
            directionsCVec = SData.ltGoodDirMat.';
            if nargout > 1
                timeVec = cell2mat(SData.timeVec(1));
            end
        end
        %
        function [trCenterMat timeVec] = get_center(self)
            trCenterMat = cell2mat(self.ellTubeRel.aMat(1));
            if nargout > 1
                timeVec = cell2mat(self.ellTubeRel.timeVec(1));
            end
        end
        %
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
        %
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
        %
        function projObj = projection(self, projMat)
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
            %
            projObj = elltool.core.control.Reach();
            projObj.ellTubeRel = projSet;
            projObj.linSys = self.linSys;
            projObj.smartLinSys = self.smartLinSys;
            projObj.isCut = self.isCut;
            projObj.projectionBasisMat = projMat;
        end
        %
        function isEmptyIntersect = intersect(self, intersectObj, approxTypeChar)
            global ellOptions;
            if ~isstruct(ellOptions)
                evalin('base', 'ellipsoids_init;');
            end
            if ~(isa(self, 'elltool.core.control.Reach'))
                throwerror('INTERSECT: first input argument must be reach set.');
            end
            if ~(isa(intersectObj, 'ellipsoid')) &&...
                    ~(isa(intersectObj, 'hyperplane')) &&...
                    ~(isa(intersectObj, 'polytope'))
                throwerror('INTERSECT: second input argument must be ellipsoid, hyperplane or polytope.');
            end
            if (nargin < 3) || ~(ischar(approxTypeChar))
                approxTypeChar = 'e';
            elseif approxTypeChar ~= 'i'
                approxTypeChar = 'e';
            end
            if approxTypeChar == 'i'
                approx = self.get_ia();
                isEmptyIntersect = intersect(approx, intersectObj, 'u');
            else
                approx = self.get_ea();
                n = size(approx, 2);
                isEmptyIntersect = intersect(approx(:, 1), intersectObj, 'i');
                for i = 2 : n
                    isEmptyIntersect =...
                        isEmptyIntersect |...
                        intersect(approx(:, i), intersectObj, 'i');
                end
            end 
        end
        %
        function newReachObj = evolve(reachObj, newEndTime, linSys)
            newReachObj = reachObj;
        end
    end
end