classdef ReachDiscrete < elltool.reach.AReach
    % Discrete reach set library of the Ellipsoidal Toolbox.
    %
    % $Authors: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
    %           Kirill Mayantsev  <kirill.mayantsev@gmail.com> $
    %               $Date: March-2013 $
    %           Igor Kitsenko <kitsenko@gmail.com> $
    %               $Date: May-2013 $
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2013 $
    %
    properties (Constant,GetAccess=protected)
        DISPLAY_PARAMETER_STRINGS = {'discrete-time', 'k0 = ', 'k1 = '}
        LINSYS_CLASS_STRING = 'elltool.linsys.LinSysDiscrete'
    end
    %
    properties (Constant, GetAccess = private)
        ETAG_SH_MAT_CALC_FAILURE = ':ShapeMatCalcFailure';
        EMSG_APPROX_SHAPE_MAT_CALC_PROB = ['There is a problem with ',...
            'calculation of approximation''s shape matrix. '];
        %
        ETAG_DEGRADE=':degradedEstimate';
        EMSG_DEGRADE='Ellipsoidal estimate is degenerate';
    end
    %
    properties (Access = private)
        isMinMax
    end
    %
    methods (Static, Access = protected)
        function [atStrCMat btStrCMat gtStrCMat...
                ptStrCMat ptStrCVec...
                qtStrCMat qtStrCVec] = prepareSysParam(linSys, ~)
            [atStrCMat btStrCMat gtStrCMat...
                ptStrCMat ptStrCVec...
                qtStrCMat qtStrCVec] = ...
                prepareSysParam@elltool.reach.AReach(linSys);
            %
            atStrCMat = unifySym(atStrCMat);
            btStrCMat = unifySym(btStrCMat);
            gtStrCMat = unifySym(gtStrCMat);
            ptStrCMat = unifySym(ptStrCMat);
            ptStrCVec = unifySym(ptStrCVec);
            qtStrCMat = unifySym(qtStrCMat);
            qtStrCVec = unifySym(qtStrCVec);
            %
            function outStrCMat = unifySym(inStrCMat)
                fChangeSymToT = @(str) strrep(str, 'k', 't');
                outStrCMat = cellfun(fChangeSymToT, inStrCMat, ...
                    'UniformOutput', false);
            end
        end
        %
        function linSys = getProbDynamics(atStrCMat, btStrCMat,...
                ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                x0Mat, x0Vec, timeVec, ~, isDisturb)
            isBack = timeVec(1) > timeVec(2);
            if isDisturb
                linSys = getSysWithDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat,...
                    qtStrCVec, x0Mat, x0Vec, timeVec);
            else
                linSys = getSysWithoutDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, x0Mat, x0Vec,...
                    timeVec);
            end
            %
            function linSys = getSysWithDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                    x0Mat, x0Vec, timeVec)
                import gras.ellapx.lreachuncert.probdef.LReachContProblemDef;
                import gras.ellapx.lreachuncert.probdyn.*;
                pDefObj = LReachContProblemDef(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, ...
                    qtStrCVec, x0Mat, x0Vec, timeVec);
                if isBack
                    linSys = LReachDiscrBackwardDynamics(pDefObj);
                else
                    linSys = LReachDiscrForwardDynamics(pDefObj);
                end
            end
            %
            function linSys = getSysWithoutDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, x0Mat, x0Vec, timeVec)
                import gras.ellapx.lreachplain.probdef.LReachContProblemDef;
                import gras.ellapx.lreachplain.probdyn.*;
                pDefObj = LReachContProblemDef(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, x0Mat, x0Vec, timeVec);
                if isBack
                    linSys = LReachDiscrBackwardDynamics(pDefObj);
                else
                    linSys = LReachDiscrForwardDynamics(pDefObj);
                end
            end
        end
    end
    %
    methods (Static, Access = private)
        function [qArrayList ltGoodDirArray] = ...
                calculateApproxShape(probDynObj, l0Mat, ...
                approxType, isDisturb, isMinMax)
            import elltool.conf.Properties;
            import gras.ellapx.enums.EApproxType;
            import gras.la.regposdefmat;
            %
            isBack = isa(probDynObj, ...
                'gras.ellapx.lreachplain.probdyn.LReachDiscrBackwardDynamics');
            %
            xDim = probDynObj.getDimensionality();
            timeVec = probDynObj.getTimeVec();
            nTubes = size(l0Mat, 2);
            qArrayList = repmat({repmat(zeros(xDim), ...
                [1, 1, length(timeVec)])}, 1, nTubes);
            ltGoodDirArray = zeros(xDim, nTubes, length(timeVec));
            lMat = zeros(xDim, length(timeVec));
            %
            if approxType == EApproxType.Internal
                fMinkmp = @(aEll, bEll, cEll, lVec) ...
                    minkmp_ia(aEll, bEll, cEll, lVec);
                fMinksum = @(aEllArray, lVec) minksum_ia(aEllArray, lVec);
                fMinkdiff = @(aEll, bEll, lVec) ...
                    minkdiff_ia(aEll, bEll, lVec);
            else
                fMinkmp = @(aEll, bEll, cEll, lVec) ...
                    minkmp_ea(aEll, bEll, cEll, lVec);
                fMinksum = @(aEllArray, lVec) minksum_ea(aEllArray, lVec);
                fMinkdiff = @(aEll, bEll, lVec) ...
                    minkdiff_ea(aEll, bEll, lVec);
            end
            %
            for iTube = 1:nTubes
                qMat = probDynObj.getX0Mat;
                qMat = 0.5 * (qMat + qMat');
                %
                qArrayList{iTube}(:, :, 1) = qMat;
                lVec = l0Mat(:, iTube);
                lMat(:, 1) = lVec;
                for iTime = 1:(length(timeVec) - 1)
                    aMat = probDynObj.getAtDynamics(). ...
                        evaluate(timeVec(iTime + isBack));
                    aInvMat = inv(aMat);
                    bpbMat = probDynObj.getBPBTransDynamics(). ...
                        evaluate(timeVec(iTime + isBack));
                    bpbMat = 0.5 * (bpbMat + bpbMat');
                    if isDisturb
                        gqgMat = probDynObj.getCQCTransDynamics(). ...
                            evaluate(timeVec(iTime + isBack));
                    end
                    qMat = aMat * qMat * aMat';
                    qMat = 0.5 * (qMat + qMat');
                    lVec = aInvMat' * lVec;
                    lVec = lVec / norm(lVec);
                    if isDisturb
                        if isMinMax
                            eEll = fMinkmp(ellipsoid(0.5 * (qMat + qMat')),...
                                ellipsoid(0.5 * (gqgMat + gqgMat')),...
                                ellipsoid(0.5 * (bpbMat + bpbMat')), lVec);
                        else
                            eEll = fMinksum([ellipsoid(0.5 * (qMat + qMat'))...
                                ellipsoid(0.5 * (bpbMat + bpbMat'))], lVec);
                            eEll = fMinkdiff(eEll, ...
                                ellipsoid(0.5 * (gqgMat + gqgMat')), lVec);
                        end
                    else
                        eEll = fMinksum([ellipsoid(0.5 * (qMat + qMat')) ...
                            ellipsoid(0.5 * (bpbMat + bpbMat'))], lVec);
                    end
                    %
                    if ~isempty(eEll)
                        qMat = double(eEll);
                    else
                        qMat = zeros(xDim, xDim);
                    end
                    qMat = 0.5 * (qMat + qMat');
                    qArrayList{iTube}(:, :, iTime + 1) = qMat;
                    lMat(:, iTime + 1) = aInvMat' * lMat(:, iTime);
                end
                ltGoodDirArray(:, iTube, :) = lMat;
            end
        end
    end
    %
    methods (Access = private)
        function ellTubeRel = auxMakeEllTubeRel(self, probDynObj, ...
                l0Mat, timeLimsVec, isDisturb, calcPrecision, ...
                approxTypeVec)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.lreachplain.GoodDirsDiscrete;
            import gras.ellapx.gen.RegProblemDynamicsFactory;
            %
            probDynObj = RegProblemDynamicsFactory.create(probDynObj,...
                self.isRegEnabled, self.isJustCheck, self.regTol);
            goodDirSetObj = GoodDirsDiscrete(...
                probDynObj, timeLimsVec(1), l0Mat, calcPrecision);
            %
            approxSchemaDescr = char.empty(1,0);
            approxSchemaName = char.empty(1,0);
            timeVec = probDynObj.getTimeVec();
            sTime=timeVec(1);
            if self.isBackward
                timeVec = fliplr(timeVec);
            end
            %
            aMat = probDynObj.getxtDynamics().evaluate(timeVec);
            ltGoodDirArray = ...
                goodDirSetObj.getGoodDirCurveSpline().evaluate(timeVec);
            %
            isIntApprox = any(approxTypeVec == EApproxType.Internal);
            isExtApprox = any(approxTypeVec == EApproxType.External);
            %
            fCalcApproxShape = @(approxType) ...
                elltool.reach.ReachDiscrete.calculateApproxShape(...
                probDynObj, l0Mat,  approxType, ...
                isDisturb, self.isMinMax);
            %
            if isExtApprox
                approxType = EApproxType.External;
                [qArrayList ltGoodDirArray] = fCalcApproxShape(approxType);
                extEllTubeRel = create();
                if ~isIntApprox
                    ellTubeRel = extEllTubeRel;
                end
            end
            if isIntApprox
                approxType = EApproxType.Internal;
                [qArrayList ltGoodDirArray] = fCalcApproxShape(approxType);
                intEllTubeRel = create();
                if isExtApprox
                    intEllTubeRel.unionWith(extEllTubeRel);
                end
                ellTubeRel = intEllTubeRel;
            end
            %
            function rel = create()
                if self.isBackward
                    qArrayList = cellfun(@(x) flipdim(x, 3), qArrayList, ...
                        'UniformOutput', false);
                    ltGoodDirArray = flipdim(ltGoodDirArray, 3);
                end
                %
                rel = gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                    qArrayList, aMat, timeVec, ltGoodDirArray, ...
                    sTime, approxType, approxSchemaName, ...
                    approxSchemaDescr,calcPrecision);
            end
        end
    end
    methods (Access=protected)
        function ellTubeRel = internalMakeEllTubeRel(self, probDynObj, l0Mat,...
                timeVec, isDisturb, calcPrecision, approxTypeVec)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.gen.RegProblemDynamicsFactory;
            import gras.ellapx.lreachplain.GoodDirsContinuousFactory;
            import modgen.common.throwerror;
            import modgen.string.catwithsep;
            %
            try
                ellTubeRel = self.auxMakeEllTubeRel(...
                    probDynObj,  l0Mat, timeVec, isDisturb, ...
                    calcPrecision, approxTypeVec);
            catch meObj
                errorStr = '';
                errorTag = '';
                %
                if isMatch('wrongInput:shapeMat')
                    errorStr = catwithsep(...
                        {self.EMSG_APPROX_SHAPE_MAT_CALC_PROB, ...
                        self.EMSG_BAD_TIME_VEC, self.EMSG_BAD_CONTROL, ...
                        self.EMSG_BAD_DIST, self.EMSG_BAD_INIT_SET},...
                        sprintf('\n'));
                    errorTag = [self.ETAG_WR_INP, ...
                        self.ETAG_SH_MAT_CALC_FAILURE];
                elseif isMatch('CHECKDATACONSISTENCY:wrongInput:QArrayNotPos')
                    errorTag = [self.ETAG_WR_INP,self.ETAG_DEGRADE];
                    errorStr = catwithsep(...
                        {self.EMSG_DEGRADE,...
                        self.EMSG_BAD_TIME_VEC,  ...
                        self.EMSG_BAD_DIST, self.EMSG_BAD_INIT_SET},...
                        sprintf('\n'));
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
    %
    methods
        function self = ReachDiscrete(varargin)
            %
            % ReachDiscrete - computes reach set approximation of the discrete linear
            %                 system for the given time interval.
            %
            %
            % Input:
            %     linSys: elltool.linsys.LinSys object - given linear system
            %     x0Ell: ellipsoid[1, 1] - ellipsoidal set of initial conditions
            %     l0Mat: double[nRows, nColumns] - initial good directions
            %           matrix.
            %     timeVec: double[1, 2] - time interval
            %     properties:
            %       isRegEnabled: logical[1, 1] - if it is 'true' constructor
            %           is allowed to use regularization.
            %       isJustCheck: logical[1, 1] - if it is 'true' constructor
            %           just check if square matrices are degenerate, if it is
            %           'false' all degenerate matrices will be regularized.
            %       regTol: double[1, 1] - regularization precision.
            %       minmax: logical[1, 1] - field, which:
            %           = 1 compute minmax reach set,
            %           = 0 (default) compute maxmin reach set.
            %
            % Output:
            %   regular:
            %     self - reach set object.
            % Example:
            %   adMat = [0 1; -1 -0.5];
            %   bdMat = [0; 1];
            %   udBoundsEllObj  = ellipsoid(1);
            %   dtsys = elltool.linsys.LinSysDiscrete(adMat, bdMat, udBoundsEllObj);
            %   x0EllObj = ell_unitball(2);
            %   timeVec = [0 10];
            %   dirsMat = [1 0; 0 1]';
            %   dRsObj = elltool.reach.ReachDiscrete(dtsys, x0EllObj, dirsMat, timeVec);
            %
            %
            % $Authors: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
            %           Kirill Mayantsev <kirill.mayantsev@gmail.com> $
            % $Date: Jan-2013 $
            %           Igor Kitsenko <kitsenko@gmail.com> $
            % $Date: May-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational
            %             Mathematics and Computer Science,
            %             System Analysis Department 2013 $
            %
            import modgen.common.checkvar;
            %
            if nargin>0
                timeVec=varargin{4};
                checkvar(timeVec,'all(fix(x)==x)',...
                    'errorTag','wrongInput:notIntegerTimeVec',...
                    'errorMessage',...
                    'timeVec is expected to contain integer values');
                %
                [varargin, ~, isMinMax] =...
                    modgen.common.parseparext(varargin, {'isMinMax'; false});
            end
            self=self@elltool.reach.AReach(varargin{:});
            if nargin>0
                self.isMinMax=isMinMax;
            end
        end
    end
end