classdef LReachProblemDynamicsFactory<handle
    methods (Static, Access = private)
        function linSys = getProbDynamics(atStrCMat,btStrCMat, ...
                ptStrCMat,ptStrCVec,ctStrCMat,qtStrCMat,qtStrCVec, ...
                x0Mat,x0Vec,timeLimVec,relTol,absTol,isDisturb,isDiscrete)
            import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
            isBack = timeLimVec(1) > timeLimVec(2);
            if isDiscrete
                handleObj = LReachProblemDynamicsFactory. ...
                    getDiscrProbDynamicsBuilder(isDisturb,isBack);
            else
                handleObj = LReachProblemDynamicsFactory. ...
                    getContProbDynamicsBuilder(isDisturb,isBack);
            end
            if isDisturb
                linSys = handleObj(atStrCMat,btStrCMat,ptStrCMat, ...
                    ptStrCVec,ctStrCMat,qtStrCMat,qtStrCVec,x0Mat, ...
                    x0Vec,timeLimVec,relTol,absTol);
            else
                linSys = handleObj(atStrCMat,btStrCMat,ptStrCMat, ...
                    ptStrCVec,x0Mat,x0Vec,timeLimVec,relTol,absTol);
            end
        end
        function probDefConstr = getContProbDynamicsBuilder(isDisturb, ...
                isBack) %#ok<INUSD>
            %
            % input argument varargin{end - 2} is a 'timeLimVec'; we
            % transform it to sort(varargin{end-2}) for Continuous systems
            %
            if ~isDisturb
                probDefConstr = @(varargin)gras.ellapx.lreachplain. ...
                    probdyn.LReachProblemDynamicsFactory. ...
                    createByParams (varargin{1:end-3}, ...
                    sort(varargin{end-2}),varargin{end-1:end});
            else
                probDefConstr = @(varargin)gras.ellapx.lreachuncert. ...
                    probdyn.LReachProblemDynamicsFactory.getSysWithDisturb( ...
                    varargin{1:end-3},sort(varargin{end-2}), ...
                    varargin{end-1:end});
            end
        end
        function probDefConstr = getDiscrProbDynamicsBuilder(isDisturb,...
                isBack)
            %
            % creating a probDefConstr with using input arguments
            % varargin{1:end-2}: we ignored last arguments 'relTol' and
            % 'absTol' for discrete systems
            %
            if ~isDisturb&&isBack
                probDefConstr = @(varargin)gras.ellapx.lreachplain. ...
                    probdyn.LReachDiscrBackwardDynamics(gras.ellapx. ...
                    lreachplain.probdef.LReachContProblemDef( ...
                    varargin{1:end-2}));
            elseif ~isDisturb&&~isBack
                probDefConstr = @(varargin)gras.ellapx.lreachplain. ...
                    probdyn.LReachDiscrForwardDynamics (gras.ellapx. ...
                    lreachplain.probdef.LReachContProblemDef( ...
                    varargin{1:end-2}));
            elseif isDisturb&&isBack
                probDefConstr = @(varargin)gras.ellapx.lreachuncert. ...
                    probdyn.LReachDiscrBackwardDynamics(gras.ellapx. ...
                    lreachuncert.probdef.LReachContProblemDef( ...
                    varargin{1:end-2}));
            else
                probDefConstr = @(varargin)gras.ellapx.lreachuncert. ...
                    probdyn.LReachDiscrForwardDynamics (gras.ellapx. ...
                    lreachuncert.probdef.LReachContProblemDef( ...
                    varargin{1:end-2}));
            end
        end
        function probDef = getSysWithDisturb(aCMat,bCMat,pCMat,pCVec,cCMat,...
                qCMat,qCVec,x0Mat,x0Vec,timeLimVec,relTol,absTol)
            isOk=true;
            if gras.ellapx.lreachuncert.probdef.ReachContLTIProblemDef. ...
                    isCompatible(aCMat,bCMat,pCMat,pCVec,cCMat,qCMat, ...
                    qCVec,x0Mat,x0Vec,timeLimVec)
                pDefObj = gras.ellapx.lreachuncert.probdef. ...
                    ReachContLTIProblemDef(aCMat,bCMat,pCMat,pCVec,cCMat,...
                    qCMat,qCVec,x0Mat,x0Vec,timeLimVec);
                probDef = gras.ellapx.lreachuncert.probdyn. ...
                    LReachProblemLTIDynamics(pDefObj,relTol,absTol);
            elseif gras.ellapx.lreachuncert.probdef. ...
                    LReachContProblemDef.isCompatible(aCMat,bCMat,pCMat,...
                    pCVec,cCMat,qCMat,qCVec,x0Mat,x0Vec,timeLimVec)
                pDefObj = gras.ellapx.lreachuncert.probdef. ...
                    LReachContProblemDef(aCMat,bCMat,pCMat,pCVec,cCMat,...
                    qCMat,qCVec,x0Mat,x0Vec,timeLimVec);
                probDef = gras.ellapx.lreachuncert.probdyn. ...
                    LReachProblemDynamicsInterp(pDefObj,relTol,absTol);
            else
                isOk=false;
            end
            if ~isOk
                modgen.common.throwerror('wrongInput', ...
                    'Incorrect system definition');
            end
        end
    end
    %
    methods(Static)
        function pDynamicsObject=create(pDefObj,relTol,absTol)
            import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsInterp;
            import gras.ellapx.lreachuncert.probdyn.LReachProblemLTIDynamics;
            %
            if isa(pDefObj,...
                    'gras.ellapx.lreachuncert.probdef.ReachContLTIProblemDef')
                pDynamicsObject = LReachProblemLTIDynamics(pDefObj,...
                    relTol,absTol);
            elseif isa(pDefObj,...
                    'gras.ellapx.lreachuncert.probdef.LReachContProblemDef')
                pDynamicsObject = LReachProblemDynamicsInterp(pDefObj,...
                    relTol,absTol);
            else
                modgen.common.throwerror(...
                    'wrongInput', 'Incorrect system definition');
            end
        end
        %
        function pDynamicsObject=createByParams(aCMat,bCMat,pCMat,pCVec,...
                cCMat,qCMat,qCVec,x0Mat,x0Vec,timeLimVec,relTol,absTol,...
                isDiscrete)
            import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
            if nargin<13
                isDiscrete = false;
            end
            isDisturb=LReachProblemDynamicsFactory.getIsDisturbance(...
                cCMat,qCMat);
            %
            pDynamicsObject = LReachProblemDynamicsFactory.getProbDynamics( ...
                aCMat,bCMat,pCMat,pCVec,cCMat,qCMat,qCVec,x0Mat,x0Vec, ...
                timeLimVec,relTol,absTol,isDisturb,isDiscrete);
        end
        %
        function isDisturb = getIsDisturbance(ctStrCMat, qtStrCMat)
            import gras.sym.isdependent;
            import gras.gen.MatVector;
            isDisturb = true;
            if isdependent(ctStrCMat)
                gtMat = MatVector.fromFormulaMat(ctStrCMat, 0);
                if all(gtMat(:) == 0)
                    isDisturb = false;
                end
            end
            if isDisturb && isdependent(qtStrCMat)
                qtMat = MatVector.fromFormulaMat(qtStrCMat, 0);
                if all(qtMat(:) == 0)
                    isDisturb = false;
                end
            end
        end
    end
end
