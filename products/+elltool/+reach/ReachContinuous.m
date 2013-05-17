classdef ReachContinuous < elltool.reach.AReach
% Continuous reach set library of the Ellipsoidal Toolbox.
%
%
% $Authors: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%           Kirill Mayantsev <kirill.mayantsev@gmail.com> $   
%               $Date: March-2013 $
%           Igor Kitsenko <kitsenko@gmail.com> $
%               $Date: May-2013 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics 
%             and Computer Science, 
%             System Analysis Department 2013$
    properties (Constant, GetAccess = ?elltool.reach.AReach)
        DISPLAY_PARAMETER_STRINGS = {'continuous-time', 'k0 = ', 'k1 = '}
    end
    %
    methods (Static, Access = protected)
        function [atStrCMat btStrCMat gtStrCMat...
                ptStrCMat ptStrCVec...
                qtStrCMat qtStrCVec] = prepareSysParam(linSys, timeVec)
            [atStrCMat btStrCMat gtStrCMat...
                ptStrCMat ptStrCVec...
                qtStrCMat qtStrCVec] = ...
                prepareSysParam@elltool.reach.AReach(linSys);
            %
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
        %
        function linSys = getSmartLinSys(atStrCMat, btStrCMat,...
                ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                x0Mat, x0Vec, timeVec, calcPrecision, isDisturb)
            timeVec = [min(timeVec) max(timeVec)];
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
        function newEllTubeRel = transformEllTube(ellTubeRel)            
            if self.isbackward()
                newEllTubeRel = self.rotateEllTubeRel(ellTubeRel);
            else
                newEllTubeRel = ellTubeRel;
            end
        end
    end
    %
    methods (Access = protected)
        function ellTubeRel = makeEllTubeRel(self, smartLinSys, l0Mat, ...
                timeVec, isDisturb, calcPrecision, approxTypeVec)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.lreachplain.GoodDirsContinuousFactory;
            relTol = elltool.conf.Properties.getRelTol();
            timeVec = [min(timeVec) max(timeVec)];
            goodDirSetObj = GoodDirsContinuousFactory.create(...
                smartLinSys, timeVec(1), l0Mat, calcPrecision);
            if (isDisturb)
                extIntBuilder =...
                    gras.ellapx.lreachuncert.ExtIntEllApxBuilder(...
                    smartLinSys, goodDirSetObj, timeVec,...
                    relTol,...
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
                        relTol);
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
                        relTol,...
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
    end
    methods
        function self =...
                ReachContinuous(linSys, x0Ell, l0Mat, timeVec, OptStruct)
        % ReachContinuous - computes reach set approximation of the continuous  
        %                   linear system for the given time interval.
        % Input:
        %     regular:
        %       linSys: elltool.linsys.LinSys object - given linear system 
        %       x0Ell: ellipsoid[1, 1] - ellipsoidal set of initial conditions 
        %       l0Mat: matrix of double - l0Mat 
        %       timeVec: double[1, 2] - time interval; timeVec(1) must be less
        %            then timeVec(2)
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
            %%
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
            relTol = elltool.conf.Properties.getRelTol();
            smartLinSys = self.getSmartLinSys(atStrCMat, btStrCMat,...
                ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                x0Mat, x0Vec, timeVec,...
                relTol, isDisturbance);
            approxTypeVec = [EApproxType.External EApproxType.Internal];
            self.ellTubeRel = self.makeEllTubeRel(smartLinSys, l0Mat,...
                timeVec, isDisturbance,...
                relTol, approxTypeVec);
            if self.isbackward()
                self.ellTubeRel = self.rotateEllTubeRel(self.ellTubeRel);
            end
        end
    end
end