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
    properties (Constant,GetAccess=protected)
        DISPLAY_PARAMETER_STRINGS = {'continuous-time', 'k0 = ', 'k1 = '}
        LINSYS_CLASS_STRING = 'elltool.linsys.LinSysContinuous'
    end
    %
    properties (Constant, GetAccess = private)
        ETAG_ODE_45_REG_TOL = ':Ode45Failed';
        ETAG_BAD_INIT_SET = ':BadInitSet';
    end
    %
    methods (Static, Access = protected)
        function [atStrCMat, btStrCMat, gtStrCMat, ptStrCMat, ...
                ptStrCVec, qtStrCMat, qtStrCVec] = ...
                prepareSysParam(linSys, timeVec)
            [atStrCMat, btStrCMat, gtStrCMat, ptStrCMat, ptStrCVec, ...
                qtStrCMat, qtStrCVec] = ...
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
        function linSys = getProbDynamics(atStrCMat, btStrCMat,...
                ptStrCMat, ptStrCVec, ctStrCMat, qtStrCMat, qtStrCVec,...
                x0Mat, x0Vec, timeVec, calcPrecision, isDisturb)
            timeVec = [min(timeVec) max(timeVec)];
            if isDisturb
                linSys = getSysWithDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, ctStrCMat, qtStrCMat,...
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
            newEllTubeRel = ...
                elltool.reach.ReachContinuous.rotateEllTubeRel(ellTubeRel);
        end
    end
    %
    methods (Access = private)
        function ellTubeRel = auxMakeEllTubeRel(self, probDynObj, ...
                l0Mat, timeVec, isDisturb, calcPrecision, approxTypeVec)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.gen.RegProblemDynamicsFactory;
            import gras.ellapx.lreachplain.GoodDirsContinuousFactory;
            import modgen.common.throwerror;
            %
            timeVec = [min(timeVec) max(timeVec)];
            goodDirSetObj = GoodDirsContinuousFactory.create(...
                probDynObj, timeVec(1), l0Mat, calcPrecision);
            if isDisturb
                extIntBuilder =...
                    gras.ellapx.lreachuncert.ExtIntEllApxBuilder(...
                    probDynObj, goodDirSetObj, timeVec,...
                    self.relTol,...
                    'selectionMethodForSMatrix',...
                    self.DEFAULT_INTAPX_S_SELECTION_MODE,...
                    'minQSqrtMatEig',...
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
                        probDynObj, goodDirSetObj, timeVec,...
                        self.relTol);
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
                        probDynObj, goodDirSetObj, timeVec,...
                        self.relTol,...
                        'selectionMethodForSMatrix',...
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
        end
        %
    end
    methods (Access=protected)
        function ellTubeRel = internalMakeEllTubeRel(self, probDynObj, l0Mat,...
                timeVec, isDisturb, calcPrecision, approxTypeVec)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.gen.RegProblemDynamicsFactory;
            import gras.ellapx.lreachplain.GoodDirsContinuousFactory;
            import modgen.common.throwerror;
            %
            try
                ellTubeRel = self.auxMakeEllTubeRel(...
                    probDynObj,  l0Mat, timeVec, isDisturb, ...
                    calcPrecision, approxTypeVec);
                if self.isbackward()
                    ellTubeRel=self.rotateEllTubeRel(ellTubeRel);
                end
            catch meObj
                errorStr = '';
                errorTag = '';
                %
                if isMatch('GRAS:ODE:ODE45REG:wrongState')||...
                        isMatch('MATLAB:ode45:IntegrationTolNotMet')
                    errorStr = [self.EMSG_R_PROB, self.EMSG_LOW_REG_TOL];
                    errorTag = [self.ETAG_WR_INP, self.ETAG_R_PROB,...
                        self.ETAG_LOW_REG_TOL, self.ETAG_ODE_45_REG_TOL];
                elseif isMatch('ELLAPXBUILDER:wrongInput')
                    errorStr = [self.EMSG_INIT_SET_PROB, ...
                        self.EMSG_SMALL_INIT_SET];
                    errorTag = [self.ETAG_WR_INP, self.ETAG_BAD_INIT_SET];
                elseif isMatch(['EXTINTELLAPXBUILDER:',...
                        'CALCELLAPXMATRIXDERIV:wrongInput'])
                    errorStr = [self.EMSG_R_PROB, self.EMSG_USE_REG];
                    errorTag = [self.ETAG_WR_INP, self.ETAG_R_PROB, ...
                        self.ETAG_R_DISABLED];
                elseif isMatch(['EXTELLAPXBUILDER:CALCELLAPXMATRIXDERIV:',...
                        'wrongInput:degenerateControlBounds'])
                    errorStr=[...
                        'Degenerate control bounds are not supported. ',...
                        self.EMSG_USE_REG];
                    errorTag = [self.ETAG_WR_INP, self.ETAG_R_PROB, ...
                        self.ETAG_R_DISABLED,':degenerateControlBounds'];
                end
                if isempty(errorStr)
                    rethrow(meObj);
                else
                    friendlyMeObj = throwerror(errorTag, errorStr);
                    friendlyMeObj = addCause(friendlyMeObj, meObj);
                    throw(friendlyMeObj);
                end
            end
           
            function isPos=isMatch(patternStr)
                isPos=~isempty(strfind(meObj.identifier,patternStr));
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
        %
        function rotatedEllTubeRel = rotateEllTubeRel(oldEllTubeRel)
            import gras.ellapx.smartdb.F;
            FIELDS_TO_FLIP = {F.Q_ARRAY;F.A_MAT;F.LT_GOOD_DIR_MAT;...
                F.X_TOUCH_CURVE_MAT;F.X_TOUCH_OP_CURVE_MAT;...
                F.LT_GOOD_DIR_NORM_VEC;F.M_ARRAY};
            SData = oldEllTubeRel.getData();
            SData.indSTime=cellfun(@numel,SData.timeVec)+1-SData.indSTime;
            SData.sTime=cellfun(@(x,y)x(y),SData.timeVec,...
                num2cell(SData.indSTime));
            cellfun(@flipField, FIELDS_TO_FLIP);
            %
            rotatedEllTubeRel = oldEllTubeRel.createInstance(SData);
            %
            function flipField(fieldName)
                fieldCVec = SData.(fieldName);
                dim = ndims(fieldCVec{1});
                SData.(fieldName) = cellfun(@(field)flipdim(field, dim),...
                    SData.(fieldName), 'UniformOutput', false);
            end
        end
    end
    methods
        function self =...
                ReachContinuous(varargin)
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
            self=self@elltool.reach.AReach(varargin{:});
        end
    end
end
