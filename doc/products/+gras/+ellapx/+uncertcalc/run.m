function [SRunProp, SRunAuxProp]=run(confName,varargin)
import gras.ellapx.uncertcalc.log.Log4jConfigurator;
import gras.ellapx.uncertcalc.*;
import gras.ellapx.common.*;
import gras.ellapx.enums.EProjType;
import modgen.common.parseparext;
import gras.ellapx.uncertcalc.EllTubeProjectorBuilder;
import gras.ellapx.uncertcalc.ApproxProblemPropertyBuilder;
import modgen.common.throwerror;
%% Constants
MAX_SUPPORTED_PRECISION=0.001;
%%
tStartGlobal=tic;
%% Parse input
[reg,isRegSpecVec,confRepoMgr,sysConfRepoMgr,isConfRepoMgrSpec,...
    isSysConfRepoMgrSpec]=parseparext(varargin,...
    {'confRepoMgr','sysConfRepoMgr';...
    [],[];...
    @(x)isa(x,'gras.ellapx.uncertcalc.conf.IConfRepoMgr'),...
    @(x)isa(x,'gras.ellapx.uncertcalc.conf.sysdef.AConfRepoMgr')},[0,1],...
    'regCheckList',{'isstring(x)'},'regDefList',{''});
%    
%% Set up configurations
if ~isConfRepoMgrSpec
    confRepoMgr=gras.ellapx.uncertcalc.conf.ConfRepoMgr();
end
if ~isSysConfRepoMgrSpec
    sysConfRepoMgr=gras.ellapx.uncertcalc.conf.sysdef.ConfRepoMgr();
end
confRepoMgr.selectConf(confName,'reloadIfSelected',false);
%% Checking a validity of settings
calcPrecision=confRepoMgr.getParam('genericProps.calcPrecision');
if calcPrecision>MAX_SUPPORTED_PRECISION
    throwerror('wrongInput',['specified calculation precision %d ',...
        'is higher than a maximum supported precision %d'],...
        calcPrecision,MAX_SUPPORTED_PRECISION);
end
%
if isRegSpecVec(1)
    sysConfName=reg{1};
else
    sysConfName=confRepoMgr.getParam('systemDefinitionConfName');
end
sysConfRepoMgr.selectConf(sysConfName,'reloadIfSelected',false);
%
%% Configure logging
Log4jConfigurator.configure(confRepoMgr);
logger=Log4jConfigurator.getLogger();
%% Configure Matrix Operations factory
isSplineUsed=confRepoMgr.getParam(...
    'genericProps.isSplineForMatrixCalcUsed');
gras.mat.MatrixOperationsFactory.setIsSplineUsed(...
    isSplineUsed);
%% Create directory for storing the results
isCustomResDir=confRepoMgr.getParam('customResultDir.isEnabled');
if isCustomResDir
    rootDir=confRepoMgr.getParam('customResultDir.dirName');
else
    rootDir=[fileparts(which(mfilename)),filesep,'_Results'];
end
resDir=[rootDir,filesep,'run_',datestr(now,30)];
%
if ~modgen.system.ExistanceChecker.isDir(resDir)
    mkdir(resDir);
end
%% saveConfiguration as part of the result
saveConf(sysConfRepoMgr,confRepoMgr,resDir);
%
%% Build good directions
[pDynObj,goodDirSetObj]=ApproxProblemPropertyBuilder.build(confRepoMgr,...
    sysConfRepoMgr,logger);
%
%% Building internal ellipsoidal approximations
[ellTubeRel,ellUnionTubeRel]=gras.ellapx.uncertcalc.EllApxBuilder(...
    confRepoMgr,pDynObj,goodDirSetObj).build();
%% Building projections
tStart=tic;
[projectorObj,staticProjectorObj]=...
    EllTubeProjectorBuilder.build(confRepoMgr,goodDirSetObj);
%
ellTubeProjRel=projectorObj.project(ellTubeRel);
ellUnionTubeStaticProjRel=staticProjectorObj.project(ellUnionTubeRel);
logger.info(['building ellipsoidal tubes projections:',...
    num2str(toc(tStart))]);
%
%% Visualize projections
if confRepoMgr.getParam('plottingProps.isEnabled')
    % configure plotting
    gras.ellapx.smartdb.RelDispConfigurator.setViewAngleVec(...
        confRepoMgr.getParam('plottingProps.viewAngleVec'));
    gras.ellapx.smartdb.RelDispConfigurator.setIsGoodCurvesSeparately(...
        confRepoMgr.getParam('plottingProps.isGoodCurvesSeparately'));    
    %
    plotterObj=smartdb.disp.RelationDataPlotter();
    tStart=tic;
    ellTubeRel.plot(plotterObj);
    ellTubeProjRel.plot(plotterObj);
    ellUnionTubeStaticProjRel.plot(plotterObj);
    logger.info(['projection plotting:',num2str(toc(tStart))]);
    %
    % saving projections on disk
    tStart=tic;
    plotterObj.saveAllFigures(resDir,{'fig','png'});
    logger.info(['saving figures to hard drive:',num2str(toc(tStart))]);
    %
    SRunProp.plotterObj=plotterObj;
end
%
%% Form the results
SRunProp.ellTubeRel=ellTubeRel;
SRunProp.ellTubeProjRel=ellTubeProjRel;
SRunProp.ellUnionTubeRel=ellUnionTubeRel;
SRunProp.ellUnionTubeStaticProjRel=ellUnionTubeStaticProjRel;
%
SRunAuxProp.goodDirSetObj = goodDirSetObj;
SRunAuxProp.pDynObj=pDynObj;
%
%
SRunProp.resDir=resDir;
logger.info(['total time:',num2str(toc(tStartGlobal))]);
save([resDir,filesep,'SRunProp'],'SRunProp');
end
function saveConf(sysConfRepoMgr,confRepoMgr,resDir)
SSysDefConf=getSmartConfInternal(sysConfRepoMgr,'systemDefinition');
getSmartConfInternal(confRepoMgr,'genericProperties');
%
%% Save system definition
sysDefFileName=[resDir,filesep,'sysdef.txt'];
convertConf2Text(SSysDefConf,sysDefFileName);
    function SConf=getSmartConfInternal(confRepoMgr,confType)
        import gras.ellapx.uncertcalc.log.Log4jConfigurator;
        logger=Log4jConfigurator.getLogger();
        [SConf,confVersion]=confRepoMgr.getCurConf();
        inpArgList={struct('conf',SConf,'version',confVersion)};
        confStr=evalc('convertConf2Text(inpArgList{:})');
        logger.info(['Loaded configuration for ',confType,': ',confStr]);
        confRepoMgr.copyConfFile([resDir,filesep,confType,filesep]);
    end
end
function convertConf2Text(SConf,varargin)
strucdisp(SConf,varargin{:},'depth',-1,'maxArrayLength',1000);
end