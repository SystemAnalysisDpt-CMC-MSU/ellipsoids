classdef ContinuousReachProjTestCase2 < mlunitext.test_case
    properties (Access=private, Constant)
        FIELDS_NOT_TO_COMPARE={'LT_GOOD_DIR_NORM_ORIG_VEC';'PROJ_S_MAT';...
        	'LS_GOOD_DIR_ORIG_VEC';'LS_GOOD_DIR_NORM_ORIG'};
        COMP_PRECISION = 5e-5;
        PROJECTION_DIM8_MAT = [-0.1936    0.0434    0.1801    0.3372   -0.0717    0.7744   -0.4447    0.1091;
                               -0.4176   -0.3222   -0.1170    0.2453   -0.7028   -0.2820   -0.0221    0.2718;
                               -0.2262    0.3719   -0.0565    0.2184    0.4048   -0.4508   -0.4716    0.4125;
                               -0.5929   -0.3479   -0.4257    0.1079    0.4623    0.0976    0.1567   -0.2946;
                               -0.3082    0.3135    0.2163   -0.1362   -0.2346   -0.2003   -0.3407   -0.7281;
                               -0.0575   -0.1476    0.7013    0.5397    0.1969   -0.1814    0.3316   -0.1005;
                               -0.4258   -0.1585    0.4721   -0.6740    0.1083    0.0631    0.0201    0.3166;
                               -0.3254    0.6998   -0.0886    0.0518   -0.1333    0.1760    0.5731    0.1293];
        PROJECTION_DIM2_MAT = [-0.9442   -0.3293;
                               -0.3293    0.9442];
    end
    properties (Access=private)
        testDataRootDir
        etalonDataRootDir
        etalonDataBranchKey
        confName
        crm
        crmSys
        linSys
        reachObj
        timeVec
        calcPrecision
    end
    methods (Access = private, Static)
        function newCMat = multiplyCMat(cellMat, doubleMultMatLeft, doubleMultMatRight)
            doubleMat = cellfun(@str2num,cellMat);
            if (nargin == 2)
                newDoubleMat = doubleMultMatLeft*doubleMat;
            elseif (nargin == 3)
                newDoubleMat = doubleMultMatLeft*doubleMat*doubleMultMatRight;
            end
            newCMat = arrayfun(@num2str,newDoubleMat,...
                    'UniformOutput', false);
        end
        function [oMat indVec] = getProjMatrix(self,mode,dim)
            %form projection matrix
            if strcmp(mode,'rand')
                [oMat,~] = qr(rand(dim,dim))
            elseif strcmp(mode,'fix')
                if dim == 2
                    oMat=self.PROJECTION_DIM2_MAT;
                elseif dim == 8    
                    oMat=self.PROJECTION_DIM8_MAT;
                end    
            end
            %form vector of projection indexes
            if dim == 8
                indVec=[1 2 6];
            elseif dim == 2   
                indVec=[1 2];
            end
        end    
    end    
    methods (Access = private)
        function [atDefCMat, btDefCMat, ctDefCMat, ptDefCMat,...
                ptDefCVec, qtDefCMat, qtDefCVec, x0DefMat,...
                x0DefVec, l0Mat] = getSysParams(self)
            atDefCMat = self.crmSys.getParam('At');
            btDefCMat = self.crmSys.getParam('Bt');
            ctDefCMat=arrayfun(@num2str,zeros(size(atDefCMat)),...
                     'UniformOutput', false);
            ptDefCMat = self.crmSys.getParam('control_restriction.Q');
            ptDefCVec = self.crmSys.getParam('control_restriction.a');
            qtDefCMat = self.crmSys.getParam('disturbance_restriction.Q');
            qtDefCVec = self.crmSys.getParam('disturbance_restriction.a');
            x0DefMat = self.crmSys.getParam('initial_set.Q');
            x0DefVec = self.crmSys.getParam('initial_set.a');
            l0CMat = self.crm.getParam(...
                'goodDirSelection.methodProps.manual.lsGoodDirSets.set1');
            l0Mat = cell2mat(l0CMat.').';
        end
    end
    %
    methods
        function self = ContinuousReachProjTestCase2(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir = [fileparts(which(className)),...
                filesep, 'TestData', filesep, shortClassName];
        end
        %
        function self = set_up_param(self, confName, crm, crmSys)
            self.crm = crm;
            self.crmSys = crmSys;
            self.confName = confName;
            %
            self.crm.deployConfTemplate(self.confName);
            self.crm.selectConf(self.confName);
            sysDefConfName = self.crm.getParam('systemDefinitionConfName');
            self.crmSys.selectConf(sysDefConfName,...
                'reloadIfSelected', false);
            %
            [atDefCMat, btDefCMat, ctDefCMat, ptDefCMat,...
                ptDefCVec, qtDefCMat, qtDefCVec,...
                x0DefMat, x0DefVec, l0Mat] = self.getSysParams();
            %
            self.timeVec = [self.crmSys.getParam('time_interval.t0'),...
                self.crmSys.getParam('time_interval.t1')];
            self.calcPrecision =...
                self.crm.getParam('genericProps.calcPrecision');
            ControlBounds = struct();
            ControlBounds.center = ptDefCVec;
            ControlBounds.shape = ptDefCMat;
            DistBounds = struct();
            DistBounds.center = qtDefCVec;
            DistBounds.shape = qtDefCMat;
            
            self.linSys = elltool.linsys.LinSysFactory.create(atDefCMat,...
                btDefCMat, ControlBounds, ctDefCMat, DistBounds);
            self.reachObj = elltool.reach.ReachContinuous(self.linSys,...
                ellipsoid(x0DefVec, x0DefMat), l0Mat, self.timeVec);
        end
        %
        function self = testProjection(self)
            [atDefCMat, btDefCMat, ctDefCMat, ptDefCMat,...
                ptDefCVec, qtDefCMat, qtDefCVec,...
                x0DefMat, x0DefVec, l0Mat] = self.getSysParams();
            [oMat, indVec] = self.getProjMatrix(self,'rand', size(atDefCMat,1));
            newAtCMat = self.multiplyCMat(atDefCMat,oMat,inv(oMat));
            newBtCMat = self.multiplyCMat(btDefCMat,oMat);
            newCtCMat = self.multiplyCMat(ctDefCMat,oMat);
            newPtCMat = ptDefCMat;       
            newQtCMat = qtDefCMat;
            newPtCVec = ptDefCVec;           
            newQtCVec = qtDefCVec;
            newX0Mat = oMat*x0DefMat*oMat';
            newX0Vec = oMat*x0DefVec;
            newL0Mat = oMat*l0Mat;
            ControlBounds = struct();
            ControlBounds.center = newPtCVec;
            ControlBounds.shape = newPtCMat;
            DistBounds = struct();
            DistBounds.center = newQtCVec;
            DistBounds.shape = newQtCMat;
            directionsMat = eye(size(atDefCMat));
            oInvMat=inv(oMat);    
            %
            newLinSys = elltool.linsys.LinSysFactory.create(newAtCMat,...
                newBtCMat, ControlBounds, newCtCMat, DistBounds);
            newReachObj = elltool.reach.ReachContinuous(newLinSys,...
                ellipsoid(newX0Vec, newX0Mat), newL0Mat, self.timeVec);
            secondProjReachObj =...
                newReachObj.projection(oInvMat(indVec,:)');
            firstProjReachObj =...
                self.reachObj.projection(directionsMat(indVec,:)');
            [isEqual,reportStr] = secondProjReachObj.isEqual(firstProjReachObj,...
                self.FIELDS_NOT_TO_COMPARE);
            mlunit.assert_equals(true,isEqual,reportStr);
        end
    end
end