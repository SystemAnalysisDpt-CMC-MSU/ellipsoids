classdef ProbDefConfigReader
    %ProbDefConfigReader defenetion of a problem from config files 
    % by using CRM system
    
    properties(SetAccess=private)
        aCMat
        bCMat
        cCMat
        pCMat
        pCVec
        qCMat
        qCVec
        x0Mat
        x0Vec
        tLims
        
        isUncert
    end
    
    methods
        function self = ProbDefConfigReader(confName, crm, crmSys)
            crm.deployConfTemplate(confName);
            crm.selectConf(confName);
            sysDefConfName = crm.getParam('systemDefinitionConfName');
            crmSys.selectConf(sysDefConfName, 'reloadIfSelected', false);
            
            self.aCMat  = crmSys.getParam('At');
            self.bCMat  = crmSys.getParam('Bt');
            self.pCMat  = crmSys.getParam('control_restriction.Q');
            self.pCVec  = crmSys.getParam('control_restriction.a');
            self.x0Mat  = crmSys.getParam('initial_set.Q');
            self.x0Vec  = crmSys.getParam('initial_set.a');
            self.tLims  = [crmSys.getParam('time_interval.t0'),...
                crmSys.getParam('time_interval.t1')];
            
            if crmSys.isParam('Ct')&&...
               crmSys.isParam('disturbance_restriction.Q')&&...
               crmSys.isParam('disturbance_restriction.a')
                self.isUncert = true;
                self.cCMat = crmSys.getParam('Ct');
                self.qCMat = crmSys.getParam('disturbance_restriction.Q');
                self.qCVec = crmSys.getParam('disturbance_restriction.a');
            else
                self.isUncert = false;
            end
        end
        
        %Return params to build plain problem defenition class
        function paramsCVec = getPlainParams(self)
            paramsCVec = {self.aCMat,self.bCMat,self.pCMat,self.pCVec,...
                self.x0Mat,self.x0Vec,self.tLims};
        end
        
        %Return params to build uncertain problem defenition class
        function paramsCVec = getUncertParams(self)
            paramsCVec = {self.aCMat,self.bCMat,self.pCMat,self.pCVec,...
                self.cCMat,self.qCMat,self.qCVec,self.x0Mat,self.x0Vec,...
                self.tLims};
        end
    end
    
end

