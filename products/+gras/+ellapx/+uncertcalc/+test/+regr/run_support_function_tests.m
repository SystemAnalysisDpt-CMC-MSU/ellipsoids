function results=run_support_function_tests(inpConfNameList)
% $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: 2-11-2012 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Computer Science,
%             System Analysis Department 2012 $
import gras.gen.MatVector;
import gras.mat.symb.iscellofstringconst;
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
BAD_TEST_NAME_LIST = {};
%
crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
if nargin>0
    if ischar(inpConfNameList)
        inpConfNameList={inpConfNameList};
    end
end
%
if nargin==0
    confNameList=crm.deployConfTemplate('*');    
    confNameList = setdiff(confNameList, BAD_TEST_NAME_LIST);    
else
    confNameList=inpConfNameList;
end
%
notToTestConfNameList = {'discrSecondTest'};
testConfIndArray = ones(1, length(confNameList));
for confName = notToTestConfNameList{:}
    testConfIndArray = testConfIndArray & ...
        ~ismember(confNameList, 'discrSecondTest');
end
confNameList = confNameList(testConfIndArray);
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
            isCtZero = isCtZero && iscellofstringconst(pCtCMat);             
        end
        if isQt
            pQtCMat = crmSys.getParam('disturbance_restriction.Q');
            pQtMat = MatVector.fromFormulaMat(pQtCMat, 0);
            isQtZero = ~any(pQtMat(:));
            isQtZero = isQtZero && iscellofstringconst(pQtCMat); 
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
suite=mlunitext.test_suite(horzcat(testLists{:}));
%
results=runner.run(suite);
