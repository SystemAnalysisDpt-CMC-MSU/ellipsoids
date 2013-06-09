classdef SuiteBasic < mlunitext.test_case
    %mlunitext.test_case
    properties (Access=private)
        resTmpDir
    end
    
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function self = set_up_param(self)
        end
        function self = set_up(self)
            self.resTmpDir=modgen.test.TmpDataManager.getDirByCallerKey();
        end
        function self = tear_down(self)
            rmdir(self.resTmpDir,'s');
        end
        function testInMemoryMgr_copyFile(self)
            resTmpDir = self.resTmpDir;
            crm=modgen.configuration.ConfRepoMgrInMemory();
            crm.putConf('test',struct('a',1,'b',2));
            [fid,messageStr]=fopen([resTmpDir,filesep,'test.txt'],'a');
            if fid<0
                modgen.common.throwerror('failedFileCreation',messageStr);
            end
            fclose(fid);
            crm.copyConfFile(resTmpDir);
            crm.copyConfFile(resTmpDir);            
            isOk=modgen.system.ExistanceChecker.isFile(...
                [resTmpDir,filesep,'test.xml']);
            mlunitext.assert_equals(isOk,true);
            resFileName=[resTmpDir,filesep,'res.xml'];
            crm.copyConfFile(resFileName,'destIsFile',true);
            isOk=modgen.system.ExistanceChecker.isFile(resFileName);
            mlunitext.assert_equals(isOk,true);            
        end
        function testPatchRepoAsProp(~)
            import modgen.configuration.test.*;
            cpr=StructChangeTrackerTest();
            crm=ConfRepoMgrAdv('confPatchRepo',cpr);
            crm=ConfRepoMgrAdv('confPatchRepo',cpr,...
                'putStorageHook',@(x,y)x,...
                'getStorageHook',@(x,y)x);
        end
        function test_putConfToStorage(~)
            import modgen.configuration.test.*;
            factory=modgen.configuration.test.ConfRepoManagerFactory(...
                'plain');
            crm=factory.getInstance();
            crm.removeAll();
            SConfA=genteststruct(1);
            metaA=struct('a','1','b','2');
            %
            crm.putConf('testConfA',SConfA,100,metaA);
            crm.setParam('test123',1);
            crm.setParam('test123',2,'writeDepth','cache');
            crm=factory.getInstance();
            crm.selectConf('testConfA');
            resVal=crm.getParam('test123');
            mlunitext.assert_equals(1,resVal);
            crm.setParam('test123',2,'writeDepth','cache');
            crm.storeCachedConf('testConfA');
            crm=factory.getInstance();
            crm.selectConf('testConfA');
            resVal=crm.getParam('test123');
            mlunitext.assert_equals(2,resVal);
            crm.removeAll();
            %
        end        
        function test_emptyVersion(~)
            crm=modgen.configuration.test.AdaptiveConfRepoMgrNanVer();
            %
            crm.setConfPatchRepo(...
                modgen.configuration.test.StructChangeTrackerNoPatches());
            crm.deployConfTemplate('default','overwrite',true);
            %
            crm.selectConf('default');
            %
            crm.setConfPatchRepo(...
                modgen.configuration.test.StructChangeTrackerTest());
            crm.deployConfTemplate('default','forceUpdate',true);
            [~,lastVersion]=crm.getConf('default');
            mlunitext.assert_equals(true,~isnan(lastVersion));
        end
        function test_emptyVersion_ConfRepoMgr(~)
            crm=modgen.configuration.test.ConfRepoMgrNanVer();
            %
            crm.setConfPatchRepo(...
                modgen.configuration.test.StructChangeTrackerNoPatches());
            SData.alpha=0;
            crm.putConf('def',SData);
            %
            crm.updateConf('def');
            crm.flushCache();
            mlunitext.assert_equals(false,crm.isConfSelected('def'));
            crm.selectConf('def');
            mlunitext.assert_equals(true,crm.isConfSelected('def'));
            %
            crm.setConfPatchRepo(...
                modgen.configuration.test.StructChangeTrackerTest());
            crm.updateConf('def');
            [SDataUpd,lastVersion]=crm.getConf('def');
            crm.removeConf('def');
            mlunitext.assert_equals(true,~isnan(lastVersion));
            mlunitext.assert_equals(true,isequal(SDataUpd.alpha,1));            
            mlunitext.assert_equals(true,isequal(SDataUpd.beta,2));
        end     
        %
        function testCopyConfFile(self)
            import modgen.configuration.test.*;
            resDir=self.resTmpDir;
            crm=ConfRepoMgrAdv();
            crm.putConf('def',struct());
            crm.copyConfFile(resDir,'def');
            resFile=[resDir,filesep,'def.xml'];
            check(resFile);
            delete(resFile);
            %
            altResFile=[resDir,filesep,'myfile.xml'];
            crm.copyConfFile(altResFile,'destIsFile',true);
            check(altResFile);
            delete(altResFile);
            %
            crm.copyConfFile(altResFile,'def','destIsFile',true);
            check(altResFile);
            delete(altResFile);            
            %
            crm.selectConf('def');
            crm.copyConfFile(resDir);
            check(resFile);
            function check(resFile)
                isOk=modgen.system.ExistanceChecker.isFile(resFile);
                mlunitext.assert_equals(true,isOk);
            end
        end
        %
        function testSelectConf(self)
            import modgen.configuration.test.*;
            crm=ConfRepoMgrUpd();
            acrm=AdpConfRepoMgrUpd();
            crm.putConf('def',struct(),0);
            acrm.putConf('def',struct(),0);
            [SRes,confVer]=crm.getConf('def');
            mlunitext.assert_equals(true,confVer==0);
            [SRes,confVer]=acrm.getConf('def');
            mlunitext.assert_equals(true,confVer==0);
            crm.selectConf('def');
            acrm.selectConf('def');
            [SRes,confVer]=crm.getConf('def');
            mlunitext.assert_equals(true,confVer==103);
            [SRes,confVer]=acrm.getConf('def');
            mlunitext.assert_equals(true,confVer==103);
        end
        %
        function testSaveLoadHook(self)
            import modgen.configuration.test.*;
            SEP_STR='+';
            CONF_NAME='def';
            SPOIL_SUF='spoil';
            NOT_UPDATE_GET_PATH={{1,1},'alpha2',{1,1},'a'};
            crm=ConfRepoMgrAdv('putStorageHook',@putStorageHook,...
                'getStorageHook',@getStorageHook);
            check();
            confPatchRepo=StructChangeTrackerAdv();
            crm=AdpConfRepoMgr('putStorageHook',@putStorageHook,...
                'getStorageHook',@getStorageHook,...
                'confPatchRepo',confPatchRepo);
            check();
            function check()
                import modgen.configuration.test.*;
                crm.setConfPatchRepo(StructChangeTrackerAdv());
                SInp.alpha.beta={'aaa','bbb';'aa','bbbb'};
                SInp.alpha1={'aaa23','bbb23';'aa23','bbbb23'};
                SInp.alpha2(2,3).a={'aaa23','bbb23';'aa23','bbbb23'};
                SInp.alpha2(1,1).a={'aaa11','bbb11';'aa11','bbbb11'};
                SInp.alpha3=0;
                SInp.alpha4={'a';'b';'c'};
                SInp.alpha5=[1;2;3];
                %
                crm.putConf(CONF_NAME,SInp,0);
                crm.flushCache();
                [SRes,confVer]=getConf();
                mlunitext.assert_equals(0,SRes.alpha3);
                mlunitext.assert_equals(0,confVer);
                mlunitext.assert_equals(true,isequal(SRes,SInp));
                %
                crm.flushCache();
                crm.updateConf(CONF_NAME);
                crm.flushCache();
                [SRes,confVer]=getConf();
                %
                SExp=SInp;
                SExp.alpha3=103;
                SExp.alpha1=strcat(SExp.alpha1,'12103');
                SExp.alpha5=SExp.alpha5*1000;
                mlunitext.assert_equals(103,confVer);
                mlunitext.assert_equals(103,SRes.alpha3);
                mlunitext.assert_equals(true,isequal(SRes,SExp));
            end
            %
            function  [SRes,confVer]=getConf()
                [SRes,confVer]=crm.getConf(CONF_NAME);
                val=getfield(SRes,NOT_UPDATE_GET_PATH{:});
                val=cellfun(@(x)strrep(x,SPOIL_SUF,''),val,...
                    'UniformOutput',false);
                SRes=setfield(SRes,NOT_UPDATE_GET_PATH{:},val);
            end
            function val=putStorageHook(val,pathSpec)
                if iscellstr(val)
                    val=modgen.string.catcellstrwithsep(val,SEP_STR);
                elseif isnumeric(val)
                    val=val+1;
                end
                %
            end
            function val=getStorageHook(val,pathSpec)
                if iscellstr(val)
                    val=modgen.string.sepcellstrbysep(val,SEP_STR);
                    if isequal(pathSpec,NOT_UPDATE_GET_PATH)
                        val=cellfun(@(x)[x,SPOIL_SUF],val,...
                            'UniformOutput',false);
                    end
                elseif isnumeric(val)
                    val=val-1;
                end
            end
        end
        function testReloadIfSelected(~)
            import modgen.configuration.test.*;
            cpr=StructChangeTrackerTest();
            crm=ConfRepoMgrAdv('confPatchRepo',cpr);
            crm.putConf('conf1',struct('a',1));
            crm.putConf('conf2',struct('a',2));
            crm.getConf('conf2');
            crm.selectConf('conf1');
            crm.getConf('conf1');
            crm.selectConf('conf2','reloadIfSelected',false);
            SRes=crm.getCurConf;
            mlunitext.assert_equals(2,SRes.a);
        end        
    end
end
