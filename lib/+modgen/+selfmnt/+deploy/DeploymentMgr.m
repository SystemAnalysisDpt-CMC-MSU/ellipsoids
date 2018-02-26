% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef DeploymentMgr
    methods
        function deploy(self,installDir)
            %
            warning('on','all');            
            %% Set up Java static class path
            classPathFileName=[installDir,filesep,'javaclasspath.txt'];
            %
            javaPathMgr=self.createJavaStaticPathMgr(classPathFileName);
            javaPathMgr.setUp();   
            %
            %% Set up Matlab path
            %
            repoPath=modgen.io.PathUtils.rmLastPathParts(installDir,1);
            rootDirList={repoPath};
            %
            modgen.selfmnt.MatlabPathMgr.setUp(rootDirList);
            savepath([installDir,filesep,'pathdef.m']);            
            %% Configure logging 
            modgen.logging.log4j.Log4jConfigurator.configureSimply();
            %% Configure temporary directories
            modgen.test.TmpDataManager.setRootDir();
        end
    end
    methods (Access=protected)
        function javaPathMgr=createJavaStaticPathMgr(~,classPathFileName)
            javaPathMgr=...
                modgen.selfmnt.JavaStaticPathMgr(classPathFileName);            
        end
    end
end