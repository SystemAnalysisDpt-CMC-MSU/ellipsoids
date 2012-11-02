function results=run_support_function_tests(inpConfNameList)
runner = mlunit.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
BAD_TEST_NAME_LIST = {'advanced', 'test3d'};
%
crm=gras.ellapx.uncertcalc.test.conf.ConfRepoMgr();
confNameList=crm.deployConfTemplate('*');
if nargin>0
    confNameList=intersect(confNameList,inpConfNameList);
end
confNameList = setdiff(confNameList, BAD_TEST_NAME_LIST);
crmSys=gras.ellapx.uncertcalc.test.conf.sysdef.ConfRepoMgr();
crmSys.deployConfTemplate('*');
nConfs=length(confNameList);
suiteList=cell(1,nConfs);
isnEmptyVec=false(1,nConfs);
for iConf=nConfs:-1:1
    confName=confNameList{iConf};
    crm.selectConf(confName);
    sysConfName=crm.getParam('systemDefinitionConfName');
    crmSys.selectConf(sysConfName,'reloadIfSelected',false);
    %
    sysStartTime=crmSys.getParam('time_interval.t0');
    calcTimeLimVec=crm.getParam('genericProps.calcTimeLimVec');
    confStartTime=calcTimeLimVec(1);
    if sysStartTime==confStartTime
    %
        isCt = crmSys.isParam('Ct');
        isQt = crmSys.isParam('disturbance_restriction.Q');
        %
        if isCt
            CtCMat = crmSys.getParam('Ct');
            zerCMat = cellfun(@(x) num2str(x),...
                num2cell(zeros(size(CtCMat))), 'UniformOutput', false);
            isEqCMat = strcmp(CtCMat, zerCMat);
        end
        if isQt
            QtCMat = crmSys.getParam('disturbance_restriction.Q');
            zerQtCMat = cellfun(@(x) num2str(x),...
                num2cell(zeros(size(QtCMat))), 'UniformOutput', false);
            isEqQMat = strcmp(QtCMat, zerQtCMat);
        end
        isnDisturbance =...
            ~isCt  || ~isQt || all(isEqCMat(:)) || all(isEqQMat(:));
        %
        if isnDisturbance
            suiteList{iConf}=loader.load_tests_from_test_case(...
                'gras.ellapx.uncertcalc.test.mlunit.SuiteSupportFunction',...
                {confName}, crm,crmSys,'marker',confName);
            isnEmptyVec(iConf)=true;
        end
    end
end
suiteList=suiteList(isnEmptyVec);
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));
%
results=runner.run(suite);
