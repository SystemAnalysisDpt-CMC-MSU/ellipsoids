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
    properties (Constant, GetAccess = ?elltool.reach.AReach)
        DISPLAY_PARAMETER_STRINGS = {'discrete-time', 'k0 = ', 'k1 = '}
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
        function linSys = getSmartLinSys(atStrCMat, btStrCMat,...
                ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                x0Mat, x0Vec, timeVec, calcPrecision, isDisturb)
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
        %
        function newEllTubeRel = transformEllTube(ellTubeRel)
            newEllTubeRel = ellTubeRel;
        end
    end
    %
    methods (Static, Access = private)
        function [qArrayList ltGoodDirArray] = ...
                calculateApproxShape(smartLinSys, l0Mat, ...
                relTol, approxType, isDisturb)
            import elltool.conf.Properties;
            import gras.ellapx.enums.EApproxType;
            %
            isBack = isa(smartLinSys, ...
                'gras.ellapx.lreachplain.probdyn.LReachDiscrBackwardDynamics');
            %
            xDim = smartLinSys.getDimensionality();
            timeVec = smartLinSys.getTimeVec();
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
            isMinMax = false;
            %
            for iTube = 1:nTubes
                qMat = smartLinSys.getX0Mat;
                qMat = ell_regularize(qMat, relTol);
                qMat = 0.5 * (qMat + qMat');
                qArrayList{iTube}(:, :, 1) = qMat;
                lVec = l0Mat(:, iTube);
                lMat(:, 1) = lVec;
                for iTime = 1:(length(timeVec) - 1)
                    aMat = smartLinSys.getAtDynamics(). ...
                        evaluate(timeVec(iTime + isBack));
                    aInvMat = smartLinSys.getAtInvDynamics(). ...
                        evaluate(timeVec(iTime + isBack));
                    bpbMat = smartLinSys.getBPBTransDynamics(). ...
                        evaluate(timeVec(iTime + isBack));
                    bpbMat = 0.5 * (bpbMat + bpbMat');
                    if isDisturb
                        gqgMat = smartLinSys.getCQCTransDynamics(). ...
                            evaluate(timeVec(iTime + isBack));
                        gqgMat = 0.5 * (gqgMat + gqgMat');
                        gqgMat = ell_regularize(gqgMat, relTol);
                    end
                    qMat = aMat * qMat * aMat';
                    qMat = ell_regularize(qMat, relTol / 1000);
                    bpbMat = ell_regularize(bpbMat, relTol);
                    lVec = aInvMat' * lVec;
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
                    qMat = ell_regularize(qMat, relTol);
                    qMat = 0.5 * (qMat + qMat');
                    qArrayList{iTube}(:, :, iTime + 1) = qMat;
                    lMat(:, iTime + 1) = lVec;
                end
                ltGoodDirArray(:, iTube, :) = lMat;
            end
        end
    end
    %
    methods (Access = protected)
        function ellTubeRel = makeEllTubeRel(self, smartLinSys, l0Mat,...
                timeLimsVec, isDisturb, calcPrecision, approxTypeVec)
            import gras.ellapx.enums.EApproxType;            
            import gras.ellapx.lreachplain.GoodDirsDiscrete;
            relTol = elltool.conf.Properties.getRelTol();            
            goodDirSetObj = GoodDirsDiscrete(...
                smartLinSys, timeLimsVec(1), l0Mat, calcPrecision);
            %
            approxSchemaDescr = char.empty(1,0);
            approxSchemaName = char.empty(1,0);
            sTime = timeLimsVec(1);
            timeVec = smartLinSys.getTimeVec();
            %
            aMat = smartLinSys.getxtDynamics().evaluate(timeVec);
            %
            isIntApprox = any(approxTypeVec == EApproxType.Internal);
            isExtApprox = any(approxTypeVec == EApproxType.External);
            %
            fCalcApproxShape = @(smartLinSys, l0Mat, ...
                relTol, approxType) ...
                elltool.reach.ReachDiscrete.calculateApproxShape(...
                smartLinSys, l0Mat, relTol, approxType, isDisturb);
            %
            if isExtApprox
                approxType = EApproxType.External;
                [qArrayList ~] = ...
                    fCalcApproxShape(smartLinSys, l0Mat, relTol, approxType);
                ltGoodDirArray = ...
                    goodDirSetObj.getGoodDirCurveSpline().evaluate(timeVec);
                extEllTubeRel = create();
                if ~isIntApprox
                    ellTubeRel = extEllTubeRel;
                end
            end
            if isIntApprox
                approxType = EApproxType.Internal;
                [qArrayList ~] = ...
                    fCalcApproxShape(smartLinSys, l0Mat, relTol, approxType);
                ltGoodDirArray = ...
                    goodDirSetObj.getGoodDirCurveSpline().evaluate(timeVec);
                intEllTubeRel = create();
                if isExtApprox
                    intEllTubeRel.unionWith(extEllTubeRel);
                end
                ellTubeRel = intEllTubeRel;
            end
            %
            function rel = create()
                rel = gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                    qArrayList, aMat, timeVec, ltGoodDirArray, ...
                    sTime, approxType, approxSchemaName, ...
                    approxSchemaDescr, relTol / 10);
            end
        end   
    end
    %
    methods
        function self = ReachDiscrete(linSys, x0Ell, l0Mat,...
                timeVec, OptStruct, varargin)
        %
        % ReachDiscrete - computes reach set approximation of the discrete linear 
        %                 system for the given time interval.
        % 
        % 
        % Input:
        %     linSys: elltool.linsys.LinSys object - given linear system 
        %     x0Ell: ellipsoid[1, 1] - ellipsoidal set of initial conditions 
        %     l0Mat: matrix of double - l0Mat 
        %     timeVec: double[1, 2] - time interval 
        %     OptStruct: struct[1, 1] - structure with
        %     fields:
        %         approximation: int[1, 1] - field, which mean the following values 
        %          for type approximation:
        %           = 0 for external,
        %           = 1 for internal, 
        %           = 2 for both (default).
        %         save_all: logical [1, 1] - field, which
        %           = 1 if save intermediate calculation data,
        %           = 0 (default) if delete intermediate calculation data.
        %         minmax: logical[1, 1] - field, which:
        %           = 1 compute minmax reach set,
        %           = 0 (default) compute maxmin reach set.
        %         This option makes sense only for discrete-time systems with 
        %         disturbance.
        %
        % self = ReachDiscrete(linSys, x0Ell, l0Mat,timeVec, Options, prop) is the 
        % same as self = ReachDiscrete(linSys, x0Ell, l0Mat, timeVec, Options), but 
        % with "Properties"  specified in  prop. 
        % In other cases "Properties" are taken from current values stored in 
        % elltool.conf.Properties
        %
        % As "Properties" we understand here such list of ellipsoid properties:
        %         absTol
        %         relTol 
        %         nPlot2dPoints
        %         Plot3dPoints 
        %         nTimeGridPoints
        %
        % Output:
        %   regular:
        %       self - reach set object.
        %
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
            import gras.la.sqrtmpos;
            import elltool.conf.Properties;
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            import elltool.logging.Log4jConfigurator;
            %
            persistent logger;
            %
            neededPropNameList =...
                {'absTol', 'relTol', 'nPlot2dPoints',...
                'nPlot3dPoints','nTimeGridPoints'};
            [absTolVal, relTolVal, nPlot2dPointsVal,...
                nPlot3dPointsVal, nTimeGridPointsVal] =...
                Properties.parseProp(varargin, neededPropNameList);
            self.absTol = absTolVal;
            self.relTol = relTolVal;
            self.nPlot2dPoints = nPlot2dPointsVal;
            self.nPlot3dPoints = nPlot3dPointsVal;
            self.nTimeGridPoints = nTimeGridPointsVal;
            %
            if (nargin == 0) || isempty(linSys)
                return;
            end
            if isstruct(linSys) && (nargin == 1)
                return;
            end
            % check and analize input
            if nargin < 4
                throwerror('wrongInput',...
                    'insufficient number of input arguments.');
            end
            if ~(isa(linSys, 'elltool.linsys.LinSysDiscrete'))
                throwerror('wrongInput',['first input argument ',...
                    'must be discrete linear system object.']);
            end
            linSys = linSys(1, 1);
            [d1, du, dy, dd] = linSys.dimension();
            if ~isa(x0Ell, 'ellipsoid')
                throwerror('wrongInput',...
                    'set of initial conditions must be ellipsoid.');
            end
            x0Ell = x0Ell(1, 1);
            d2 = dimension(x0Ell);
            if d1 ~= d2
                throwerror('wrongInput',...
                    ['dimensions of linear system and ',...
                    'set of initial conditions do not match.']);
            end
            [timeRows, timeCols] = size(timeVec);
            if ~(isa(timeVec, 'double')) || ...
                    (timeRows ~= 1) || (timeCols ~= 2)
                throwerror('wrongInput', ['time interval must be ',...
                    'specified as ''[k0 k1]''.']);
            end
            [m, N] = size(l0Mat);
            if m ~= d2
                throwerror('wrongInput',...
                    ['dimensions of state space ',...
                    'and direction vector do not match.']);
            end
            if (nargin < 5) || ~(isstruct(OptStruct))
                OptStruct               = [];
                OptStruct.approximation = 2;
                OptStruct.save_all      = 0;
                OptStruct.minmax        = 0;
            else
                if ~(isfield(OptStruct, 'approximation')) ||...
                        (OptStruct.approximation < 0) ||...
                        (OptStruct.approximation > 2)
                    OptStruct.approximation = 2;
                end
                if ~(isfield(OptStruct, 'save_all')) ||...
                        (OptStruct.save_all < 0) || (OptStruct.save_all > 2)
                    OptStruct.save_all = 0;
                end
                if ~(isfield(OptStruct, 'minmax')) ||...
                        (OptStruct.minmax < 0) || (OptStruct.minmax > 1)
                    OptStruct.minmax = 0;
                end
            end
            %
            k0 = round(timeVec(1));
            k1 = round(timeVec(2));
            timeVec = [k0 k1];
            %
            self.switchSysTimeVec = timeVec;
            self.x0Ellipsoid = x0Ell;
            self.linSysCVec = {linSys};
            self.isCut = false;
            self.isProj = false;
            self.isBackward = timeVec(1) > timeVec(2);
            self.projectionBasisMat = [];
            self.x0Ellipsoid = x0Ell;
            %
            % create gras LinSys object
            %
            [x0Vec x0Mat] = double(x0Ell);
            [atStrCMat btStrCMat gtStrCMat ptStrCMat ptStrCVec...
                qtStrCMat qtStrCVec] =...
                self.prepareSysParam(linSys);
            isDisturbance = self.isDisturbance(gtStrCMat, qtStrCMat);
            %
            % normalize good directions
            %
            sysDim = size(atStrCMat, 1);
            l0Mat = self.getNormMat(l0Mat, sysDim);
            %
            % create approximation tube
            %
            relTol = elltool.conf.Properties.getRelTol();
            smartLinSys = self.getSmartLinSys(atStrCMat, btStrCMat, ...
                ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec, ...
                x0Mat, x0Vec, timeVec,...
                relTol, isDisturbance);
            approxTypeVec = [EApproxType.External EApproxType.Internal];
            self.ellTubeRel = self.makeEllTubeRel(smartLinSys, l0Mat, ...
                timeVec, isDisturbance, relTol, approxTypeVec);
        end
    end
end