classdef mlunit_test_adaptivecrmversioned < modgen.configuration.test.mlunit_test_crmversioned
    
    properties (Access=protected)
        tcm
    end
    methods (Access=private)
        function self=initData(self)
            import modgen.configuration.test.*;   
            self.cm=self.factory.getInstance();
            self.cm.removeAll();
            clearStorageContent(self.cm);
            %
            self.tcm=self.cm.getTemplateRepo();
            self.tcm.removeAll();
            clearStorageContent(self.tcm);
            %
            self.cm=self.factory.getInstance();
            self.tcm=self.cm.getTemplateRepo();
            %
            SConfA=struct('confName','testConfA','alpha',0,'beta',0);
            SConfB=struct('confName','testConfB','alpha',11,'beta',11);
            %
            self.tcm.putConf('testConfA',SConfA,0);
            self.tcm.putConf('testConfB',SConfB,0);
            function clearStorageContent(cm)
            import modgen.common.throwerror;              
                storageRoot=cm.getStorageLocationRoot();
                if modgen.system.ExistanceChecker.isDir(storageRoot)
                    [indOk,msgStr]=modgen.io.rmdir(...
                        cm.getStorageLocationRoot(),'s');
                    if indOk~=1
                        throwerror('wrongStatus',...
                            'deletion of directory %s has failed :%s',...
                            storageRoot,msgStr);
                    end
                    modgen.io.mkdir(storageRoot);
                end
            end
        end
    end
    methods
        function self = mlunit_test_adaptivecrmversioned(varargin)
            self = self@modgen.configuration.test.mlunit_test_crmversioned(varargin{:});
        end
        function self = set_up_param(self,factory)
            self.factory=factory;
            self=self.initData();
        end
        function self=test_updateAll(self)
            self.cm.updateAll();
            self.aux_checkUpdateAll(self.cm);
            self.aux_checkUpdateAll(self.tcm);
            %
        end
        function testUpdateAllBranches(self)
            curBranchKey=self.cm.getStorageBranchKey();
            isOk=isequal({curBranchKey},self.cm.getBranchKeyList());
            mlunitext.assert(isOk);
            otherBranchKey=[curBranchKey,'_2'];
            templateBranchKey=self.cm.getTemplateBranchKey();
            storageRootDir=self.cm.getStorageLocationRoot();
            [indOk,msgStr]=copyfile([storageRootDir,filesep,...
                templateBranchKey],...
                [storageRootDir,filesep,otherBranchKey]);
            [indOk,msgStr]=copyfile([storageRootDir,filesep,...
                templateBranchKey],...
                [storageRootDir,filesep,curBranchKey]);            
            %
            check({curBranchKey,otherBranchKey});
            check({curBranchKey,otherBranchKey},false);
            %
            check({templateBranchKey,curBranchKey,otherBranchKey},true);
            %
            branchKeyList={templateBranchKey,curBranchKey,otherBranchKey};
            nBranches=numel(branchKeyList);
            %
            self.cm.updateAll();
            checkMaster([true,true,false]);
            self.cm.updateAll(true);
            checkMaster([true,true,true]);            
            %
            function checkMaster(isOkExpVec)
                for iBranch=1:nBranches
                    curBranchKey=branchKeyList{iBranch};
                    cm=self.factory.getInstance('currentBranchKey',...
                        curBranchKey);
                    self.aux_checkUpdateAll(cm,isOkExpVec(iBranch));
                    %
                end
            end
            %
            function check(branchList,varargin)
                mlunitext.assert_equals(indOk,1,msgStr);
                isOk=isequal(sort(branchList),...
                    sort(self.cm.getBranchKeyList(varargin{:})));
                mlunitext.assert(isOk);                
            end
        end
        function self=test_update(self)
            self.cm.deployConfTemplate('testConfA');
            self.cm.updateConfTemplate('testConfA');
            [SConf,confVersion,metaData]=self.tcm.getConf('testConfB');
            self.cm.putConf('testConfB',SConf,confVersion,metaData);
            %
            self.aux_checkUpdate(self.cm);
            self.aux_checkUpdate(self.tcm);
        end        
    end
end