classdef ReachFactory < handle
    properties (Access = private)
        confName
        crm
        crmSys
        linSys
        l0Mat
        x0Ell
        tVec
        isBack
        isEvolve
        isDiscr
        dim
        reachObjMap
        isRegEnabled
        isJustCheck
        regTol
    end
    methods
        function linSysObj = createSysInstance(self, inpAtMat, inpBtMat,...
                inpUBoundMat, inpUBoundVec, inpCtMat, inpDistBoundMat,...
                inpDistBoundVec )
            if (nargin>1)&&~isempty(inpAtMat)
                inpArgList={inpAtMat};
                if nargin>3
                    if nargout<=4
                        inpUBoundVec=[];
                    end
                    uBoundsEll = fGetEll(inpUBoundVec, inpUBoundMat);
                    inpArgList=[inpArgList,{inpBtMat,uBoundsEll}];
                    if nargin>7
                        if nargin<=8
                            inpDistBoundVec=[];
                        end
                        distBoundsEll=fGetEll(inpDistBoundVec,...
                            inpDistBoundMat);
                        inpArgList=[inpArgList,{inpCtMat,distBoundsEll}];
                    end
                end
                if self.isDiscr
                    linSysObj = elltool.linsys.LinSysDiscrete(inpArgList{:});
                else
                    linSysObj = elltool.linsys.LinSysContinuous(inpArgList{:});
                end
            else
                linSysObj = self.linSys.getCopy();
            end
        end
        function self =...
                ReachFactory(confName, crm, crmSys, isBack, isEvolve,...
                isDiscr)
            % Example:
            %   import elltool.reach.ReachFactory;
            %   crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            %   crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            %   rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
            %
            if nargin < 6
                isDiscr = false;
            end
            self.confName = confName;
            self.crm = crm;
            self.crmSys = crmSys;
            self.isBack = isBack;
            self.isEvolve = isEvolve;
            self.isDiscr = isDiscr;
            %
            crm.deployConfTemplate(confName);
            crm.selectConf(confName);
            sysDefConfName = crm.getParam('systemDefinitionConfName');
            crmSys.selectConf(sysDefConfName, 'reloadIfSelected', false);
            %
            self.dim = crmSys.getParam('dim');
            atDefCMat = crmSys.getParam('At');
            btDefCMat = crmSys.getParam('Bt');
            ctDefCMat = crmSys.getParam('Ct');
            ptDefCMat = crmSys.getParam('control_restriction.Q');
            ptDefCVec = crmSys.getParam('control_restriction.a');
            qtDefCMat = crmSys.getParam('disturbance_restriction.Q');
            qtDefCVec = crmSys.getParam('disturbance_restriction.a');
            x0DefMat = crmSys.getParam('initial_set.Q');
            x0DefVec = crmSys.getParam('initial_set.a');
            l0CMat = crm.getParam(...
                'goodDirSelection.methodProps.manual.lsGoodDirSets.set1');
            self.l0Mat = cell2mat(l0CMat.').';
            self.isRegEnabled =...
                crm.getParam('regularizationProps.isEnabled');
            self.isJustCheck =...
                crm.getParam('regularizationProps.isJustCheck');
            self.regTol = crm.getParam('regularizationProps.regTol');
            self.x0Ell = ellipsoid(x0DefVec, x0DefMat);
            if self.isBack
                self.tVec = [crmSys.getParam('time_interval.t1'),...
                    crmSys.getParam('time_interval.t0')];
            else
                self.tVec = [crmSys.getParam('time_interval.t0'),...
                    crmSys.getParam('time_interval.t1')];
            end
            ControlBounds = struct();
            ControlBounds.center = ptDefCVec;
            ControlBounds.shape = ptDefCMat;
            DistBounds = struct();
            DistBounds.center = qtDefCVec;
            DistBounds.shape = qtDefCMat;
            %
            if isDiscr
                self.linSys = elltool.linsys.LinSysDiscrete(atDefCMat,...
                    btDefCMat,...
                    ControlBounds, ctDefCMat, DistBounds, [], [], 'd');
            else
                self.linSys = elltool.linsys.LinSysContinuous(atDefCMat,...
                    btDefCMat, ControlBounds, ctDefCMat, DistBounds);
            end
            self.reachObjMap = containers.Map();
        end
        function reachObj = createInstance(self, varargin)
            % Example:
            %   import elltool.reach.ReachFactory;
            %   crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            %   crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            %   rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
            %   reachObj = rsObj.createInstance();
            %
            import modgen.common.parseparext;
            [~, ~, inpAtMat,inpBtMat, inpUBoundMat,...
                inpUBoundVec, inpCtMat, inpDistBoundMat,...
                inpDistBoundVec, inpX0EllMat, inpX0EllVec,...
                l0DirMat, timeVec] = parseparext(varargin,...
                {'At', 'Bt', 'controlMat', 'controlVec', 'Ct',...
                'disturbMat', 'disturbVec',...
                'x0EllMat','x0EllVec', 'l0Mat','tVec';...
                [], [], [], [], [], [], [],...
                self.x0Ell.getShapeMat(), self.x0Ell.getCenterVec(),...
                self.l0Mat, self.tVec; 'ismatrix(x)', 'ismatrix(x)',...
                'ismatrix(x)', 'isvector(x)', 'ismatrix(x)',...
                'ismatrix(x)', 'isvector(x)', 'ismatrix(x)',...
                'isvector(x)', 'ismatrix(x)','isvector(x)'});
            keyStr = hash(varargin);
            if ~self.reachObjMap.isKey(keyStr)
                linSysObj = self.createSysInstance(inpAtMat, inpBtMat,...
                    inpUBoundMat, inpUBoundVec, inpCtMat,...
                    inpDistBoundMat, inpDistBoundVec);
                x0EllObj = fGetEll(inpX0EllVec, inpX0EllMat);
                %
                if isa(linSysObj, 'elltool.linsys.LinSysDiscrete')
                    if self.isEvolve
                        halfReachObj = elltool.reach.ReachDiscrete(...
                            linSysObj, x0EllObj, l0DirMat,...
                            [timeVec(1) sum(timeVec)/2]);
                        reachObj = halfReachObj.evolve(timeVec(2));
                    else
                        reachObj = elltool.reach.ReachDiscrete(linSysObj,...
                            x0EllObj, l0DirMat, timeVec);
                    end
                elseif self.isEvolve
                    halfReachObj = elltool.reach.ReachContinuous(...
                        linSysObj, x0EllObj, l0DirMat,...
                        [timeVec(1) sum(timeVec)/2], 'isRegEnabled',...
                        self.isRegEnabled, 'isJustCheck',...
                        self.isJustCheck, 'regTol', self.regTol);
                    reachObj = halfReachObj.evolve(timeVec(2));
                else
                    reachObj = elltool.reach.ReachContinuous(...
                        linSysObj, x0EllObj, l0DirMat, timeVec,...
                        'isRegEnabled', self.isRegEnabled,...
                        'isJustCheck', self.isJustCheck,...
                        'regTol', self.regTol);
                end
                self.reachObjMap(keyStr) = reachObj.getCopy();
            else
                reachObj = self.reachObjMap(keyStr).getCopy();
            end
        end
        function linSys = getLinSys(self)
            % Example:
            %   import elltool.reach.ReachFactory;
            %   crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            %   crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            %   rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
            %   linSys = rsObj.getLinSys();
            %
            linSys = self.linSys;
        end
        function dim = getDim(self)
            % Example:
            %   import elltool.reach.ReachFactory;
            %   crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            %   crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            %   rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
            %   dim = rsObj.getDim();
            %
            dim = self.dim;
        end
        function tVec = getTVec(self)
            % Example:
            %   import elltool.reach.ReachFactory;
            %   crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            %   crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            %   rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
            %   tVec = rsObj.getTVec()
            %
            %   tVec =
            %
            %        0    10
            %
            tVec = self.tVec;
        end
        function x0Ell = getX0Ell(self)
            % Example:
            %   import elltool.reach.ReachFactory;
            %   crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            %   crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            %   rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
            %   X0Ell = rsObj.getX0Ell()
            %
            %   X0Ell =
            %
            %   Center:
            %        0
            %        0
            %
            %   Shape Matrix:
            %       0.0100         0
            %            0    0.0100
            %
            %   Nondegenerate ellipsoid in R^2.
            %
            x0Ell = self.x0Ell;
        end
        function l0Mat = getL0Mat(self)
            % Example:
            %   import elltool.reach.ReachFactory;
            %   crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            %   crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            %   rsObj =  ReachFactory('demo3firstTest', crm, crmSys, false, false);
            %   l0Mat = rsObj.getL0Mat()
            %
            %   l0Mat =
            %
            %        1     0
            %        0     1
            %
            l0Mat = self.l0Mat;
        end
    end
end
function ellObj = fGetEll(centerVec, shapeMat)
if ~isempty(centerVec)&&~isempty(shapeMat)
    ellObj = ellipsoid(centerVec, shapeMat);
else
    ellObj = ellipsoid(shapeMat);
end
end