classdef Reach<handle
    properties (Access = public)
        linSys
        smartLinSys
        ellTubeBuilder
        ellUnionTubeRel
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
            %%
            import gras.ellapx.lreachuncert.LReachProblemDefInterp;
            %% analize input
            if (nargin == 0) || isempty(linSys)
                return;
            end
            if nargin < 4
                error('REACH: insufficient number of input arguments.');
            end
            if ~(isa(linSys, 'elltool.core.control.LinSys'))
                error('REACH: first input argument must be linear system object.');
            end
            linSys = linSys(1, 1);
            [firstDim, secondDim, thirdDim, fourthDim] = dimension(linSys);
            if ~(isa(X0Ell, 'ellipsoid'))
                error('REACH: set of initial conditions must be ellipsoid.');
            end
            X0Ell = X0Ell(1, 1);
            ellDim = dimension(X0Ell);
            if firstDim ~= ellDim
                error('REACH: dimensions of linear system and set of initial conditions do not match.');
            end
            [timeRows, timeCols] = size(timeVec);
            if ~(isa(timeVec, 'double')) || (timeRows ~= 1) ||...
                    ((timeCols ~= 2) && (timeCols ~= 1))
                error('REACH: time interval must be specified as ''[t0 t1]'', or, in discrete-time - as ''[k0 k1]''.');
            end
            [dirRows, dirCols] = size(L0Mat);
            if dirRows ~= ellDim
                error('REACH: dimensions of state space and direction vector do not match.');
            end
            if (nargin < 5) || ~(isstruct(OptStruct))
                OptStruct = [];
                OptStruct.approximation = 2;
                OptStruct.save_all = 0;
                OptStruct.minmax = 0;
            else
                if ~(isfield(OptStruct, 'approximation')) || ...
                    (OptStruct.approximation < 0) || (OptStruct.approximation > 2)
                    OptStruct.approximation = 2;
                end
                if ~(isfield(OptStruct, 'save_all')) || ...
                    (OptStruct.save_all < 0) || (OptStruct.save_all > 2)
                    OptStruct.save_all = 0;
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
            %% internal approx
            intBuilder =...
                gras.ellapx.lreachplain.IntEllApxBuilder(...
                self.smartLinSys, goodDirSetObj, timeVec,...
                ellOptions.rel_tol, 'volume');
            %% external approx
            extBuilder=...
                gras.ellapx.lreachplain.ExtEllApxBuilder(...
                self.smartLinSys, goodDirSetObj, timeVec,...
                ellOptions.rel_tol);
            %% int-ext approx
            intExtBuilder =...
                gras.ellapx.lreachplain.IntProperEllApxBuilder(...
                self.smartLinSys, goodDirSetObj, timeVec,...
                ellOptions.rel_tol, 'volume');
            %% get tube builder
            self.ellTubeBuilder =...
                gras.ellapx.gen.EllApxCollectionBuilder(...
                [{intBuilder}, {extBuilder}, {intExtBuilder}]);
            %% preparing plot
            import gras.ellapx.smartdb.rels.EllUnionTube;
            import gras.ellapx.uncertcalc.EllApxBuilder;
            ellTubeRel = self.ellTubeBuilder.getEllTubes();
            self.ellUnionTubeRel = EllUnionTube.fromEllTubes(ellTubeRel);
            %% plot and proj plot
            import gras.ellapx.lreachplain.EllTubeDynamicSpaceProjector;
            import gras.ellapx.proj.EllTubeStaticSpaceProjector;
            import gras.ellapx.proj.EllTubeCollectionProjector;
            
            %Orth = eye(2);
            %projSpaceList = reshape(cellstr(num2str(Orth(:))), size(Orth));
            projSpaceList = {[true true]};
            projectorList = cell(1, 2);
            %% dyn projection
            projectorList{2} =...
                EllTubeDynamicSpaceProjector(projSpaceList, goodDirSetObj);
            %% static projection
            staticProjectorObj = EllTubeStaticSpaceProjector(projSpaceList);
            projectorList{1} = staticProjectorObj;
            %% build proj    
            isnEmptyVec = ~cellfun('isempty', projectorList);
            projectorObj =...
                EllTubeCollectionProjector(projectorList(isnEmptyVec));
            ellTubeProjRel = projectorObj.project(ellTubeRel);
            ellUnionTubeStaticProjRel =...
                staticProjectorObj.project(self.ellUnionTubeRel);
            plotterObj = smartdb.disp.RelationDataPlotter();
            ellTubeRel.plot(plotterObj);
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
        
        %function [dirCArray timeVec] = get_directions(self)
    end
end