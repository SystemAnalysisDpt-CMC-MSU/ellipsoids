classdef CVXControllerChecker
    properties (GetAccess=private,Constant)
        CVX_SETUP_FUNC_NAME='cvx_setup';
        CVX_PREF_FILE_NAME='cvx_prefs.mat';
    end
    methods (Static)
        function isPositive=isSetUp()
            import elltool.cvx.CVXControllerChecker;
            if CVXControllerChecker.isOnPath()
                cvxConfFileName=[ prefdir, filesep,...
                    CVXControllerChecker.CVX_PREF_FILE_NAME];
                isPositive=modgen.system.ExistanceChecker.isFile(...
                    cvxConfFileName);
            else
                isPositive=false;
            end
        end
        function isPositive=isOnPath()
            import elltool.cvx.CVXControllerChecker;
            isPositive=modgen.system.ExistanceChecker.isFile(...
                CVXControllerChecker.CVX_SETUP_FUNC_NAME);
        end
        function setUp()
            import modgen.logging.log4j.Log4jConfigurator;
            logger=Log4jConfigurator.getLogger();
            logger.info('Setting up CVX...');
            feval(elltool.cvx.CVXControllerChecker.CVX_SETUP_FUNC_NAME);
            logger.info('Setting up CVX: done');
        end
        function setUpIfNot()
            N_HOR_LINE_CHARS=60;
            import elltool.cvx.CVXControllerChecker;
            if CVXControllerChecker.isOnPath()
                if ~CVXControllerChecker.isSetUp()
                    CVXControllerChecker.setUp()
                end            
            else
                horLineStr=['\n',repmat('-',1,N_HOR_LINE_CHARS),'\n'];
                modgen.common.throwwarn('cvxNotFound',...
                    sprintf(['\n',horLineStr,...
                    '\nCVX is not found!!! Some functionality ',...
                    'won''t be available\n',horLineStr]));
            end
        end
    end
end