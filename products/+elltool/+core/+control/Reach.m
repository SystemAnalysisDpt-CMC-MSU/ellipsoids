classdef Reach<handle
    properties (Constant,GetAccess=private)
        MIN_EIG = 0.1
    end
    properties (Access = public)
        linSys
        smartLinSys
        ellTubeRel
    end
    methods
        function self = Reach(linSys, X0Ell, L0Mat, timeVec, OptStruct)
            global ellOptions;
            %%
            if ~isstruct(ellOptions)
                evalin('base', 'ellipsoids_init;');
            end
            %%
            self.linSys = linSys;
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
            AtStrCMat = [];
            BtStrCMat = [];
            PtStrCMat = [];
            ptStrCVec = [];
            GtStrCMat = [];
            QtStrCMat = [];
            qtStrCVec = [];
            [x0Vec X0Mat] = double(X0Ell);
            AtMat = linSys.getAtMat();
            BtMat = linSys.getBtMat();
            GtMat = linSys.getGtMat();
            if ~iscell(AtMat) && ~isempty(AtMat)
                AtStrCMat = reshape(cellstr(num2str(AtMat(:))), size(AtMat));
            end
            if ~iscell(BtMat) && ~isempty(BtMat)
                BtStrCMat = reshape(cellstr(num2str(BtMat(:))), size(BtMat));
            end
            if isempty(GtMat)
               GtMat = zeros(size(BtMat)); 
            end
            if ~iscell(GtMat) && ~isempty(GtMat)
                GtStrCMat = reshape(cellstr(num2str(GtMat(:))), size(GtMat));
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
            end
            if ~iscell(ptVec)
                ptStrCVec =...
                    reshape(cellstr(num2str(ptVec(:))), size(ptVec));
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
            end
            if ~iscell(qtVec)
            	qtStrCVec =...
                	reshape(cellstr(num2str(qtVec(:))), size(qtVec));
            end
            %%
            import gras.ellapx.lreachuncert.LReachProblemDefInterp;
            self.smartLinSys =...
                LReachProblemDefInterp(AtStrCMat, BtStrCMat,...
                PtStrCMat, ptStrCVec, GtStrCMat,...
                QtStrCMat, qtStrCVec, X0Mat, x0Vec,...
                timeVec, ellOptions.rel_tol);
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
            self.ellTubeRel = ellTubeBuilder.getEllTubes();
            ellTubeRel = ellTubeBuilder.getEllTubes();
            %self.ellUnionTubeRel = EllUnionTube.fromEllTubes(ellTubeRel);
            %% plot and proj plot
            %import gras.ellapx.lreachplain.EllTubeDynamicSpaceProjector;
            %import gras.ellapx.proj.EllTubeStaticSpaceProjector;
            %import gras.ellapx.proj.EllTubeCollectionProjector;
            %
            %Orth = eye(2);
            %projSpaceList = reshape(cellstr(num2str(Orth(:))), size(Orth));
            %projSpaceList = {[true true]};
            %projectorList = cell(1, 2);
            %% dyn projection
            %projectorList{2} =...
            %    EllTubeDynamicSpaceProjector(projSpaceList, goodDirSetObj);
            %% static projection
            %staticProjectorObj = EllTubeStaticSpaceProjector(projSpaceList);
            %projectorList{1} = staticProjectorObj;
            %% build proj    
            %isnEmptyVec = ~cellfun('isempty', projectorList);
            %projectorObj =...
            %    EllTubeCollectionProjector(projectorList(isnEmptyVec));
            %ellTubeProjRel = projectorObj.project(ellTubeRel);
            %ellUnionTubeStaticProjRel =...
            %    staticProjectorObj.project(self.ellUnionTubeRel);
            %plotterObj = smartdb.disp.RelationDataPlotter();
            %ellTubeRel.plot(plotterObj);
            %ellTubeProjRel.plot(plotterObj);
            %ellUnionTubeStaticProjRel.plot(plotterObj);
        end
        %%
        %
        %
        %
        function linSys = get_system(self)
            linSys = self.linSys;
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
        %%
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
        function projSet = projection(self, projMat)
            import gras.ellapx.enums.EProjType;
            %import gras.ellapx.lreachplain.EllTubeDynamicSpaceProjector;
            fProj =...
                @(~, timeVec, varargin)...
                deal(repmat(projMat.',[1 1 numel(timeVec)]),...
                repmat(projMat,[1 1 numel(timeVec)]));
            projSpaceList = false(size(projMat, 1));
            projSpaceList(1 : size(projMat, 2)) = true;
            projSpaceList = {projSpaceList};
            projType = EProjType.Static;
            projSet = self.ellTubeRel.project(projType,...
                projSpaceList, fProj);
        end
    end
end