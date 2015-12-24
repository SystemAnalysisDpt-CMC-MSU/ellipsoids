function results=run_support_function_tests(varargin)
% $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: 2-11-2012 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Computer Science,
%             System Analysis Department 2012 $
import gras.gen.MatVector;
import gras.mat.fcnlib.isdependent;
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
NOT_TO_TEST_CONF_NAME_LIST = {'discrSecondTest',...
    'check','checkTime','testA0Cunitball'};
%
crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();

[restArgList,~,filterProp]=modgen.common.parseparext(varargin,...
    {'filter';{}});
[reg,suitePropList]=modgen.common.parseparams(restArgList);
if ~isempty(reg)
    confNameList=reg{1};
    if ischar(confNameList)
        confNameList={confNameList};
    end
else
    confNameList=crm.deployConfTemplate('*');
end
%
%
isNotToTestVec=ismember(confNameList,NOT_TO_TEST_CONF_NAME_LIST);
confNameList=confNameList(~isNotToTestVec);
%
crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
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
    %
    if sysStartTime==confStartTime
        %
        isCt = crmSys.isParam('Ct');
        isQt = crmSys.isParam('disturbance_restriction.Q');
        %
        if isCt
            pCtCMat = crmSys.getParam('Ct');
            pCtMat = MatVector.fromFormulaMat(pCtCMat, 0);
            isCtZero = ~any(pCtMat(:));
            isCtZero = isCtZero && isdependent(pCtCMat);
        end
        if isQt
            pQtCMat = crmSys.getParam('disturbance_restriction.Q');
            pQtMat = MatVector.fromFormulaMat(pQtCMat, 0);
            isQtZero = ~any(pQtMat(:));
            isQtZero = isQtZero && isdependent(pQtCMat);
        end
        isnDisturbance =...
            ~isCt  || ~isQt || isCtZero || isQtZero;
        %
        if isnDisturbance
            suiteList{iConf}=loader.load_tests_from_test_case(...
                'gras.ellapx.uncertcalc.test.regr.mlunit.SuiteSupportFunction',...
                {confName}, crm,crmSys,'marker',confName);
            isnEmptyVec(iConf)=true;
        end
    end
end
suiteList=suiteList(isnEmptyVec);
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}),suitePropList{:});
suite=suite.getCopyFiltered(filterProp{:});
%
results=runner.run(suite);
