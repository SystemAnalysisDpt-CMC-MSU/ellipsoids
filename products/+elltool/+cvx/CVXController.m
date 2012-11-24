classdef CVXController
    properties (GetAccess=private,Constant)
        CVX_SETUP_FUNC_NAME='cvx_setup';
        CVX_PREF_FILE_NAME='cvx_prefs.mat';
    end
    methods (Static)
        function setSolver(solverName)
            cvx_solver(solverName);
        end
        function setPrecision(relTol)
            import elltool.cvx.CVXController;
            TOL_FACTOR = 2;
            cvx_precision([0, TOL_FACTOR*relTol]);
         
        end
        function setIsVerbosityEnabled(isQuiet)
            import elltool.cvx.CVXController;
            cvx_quiet(~isQuiet);
        end
        
        function isPositive=isSetUp()
            import elltool.cvx.CVXController;
            if CVXController.isOnPath()
                cvxConfFileName=[ prefdir, filesep,...
                    CVXController.CVX_PREF_FILE_NAME];
                isPositive=modgen.system.ExistanceChecker.isFile(...
                    cvxConfFileName);
            else
                isPositive=false;
            end
        end
        function isPositive=isOnPath()
            import elltool.cvx.CVXController;
            isPositive=modgen.system.ExistanceChecker.isFile(...
                CVXController.CVX_SETUP_FUNC_NAME);
        end
        function setUp()
            import modgen.logging.log4j.Log4jConfigurator;
            logger=Log4jConfigurator.getLogger();
            logger.info('Setting up CVX...');
            feval(elltool.cvx.CVXController.CVX_SETUP_FUNC_NAME);
            logger.info('Setting up CVX: done');
        end
        function setUpIfNot()
            N_HOR_LINE_CHARS=60;
            import elltool.cvx.CVXController;
            if CVXController.isOnPath()
                if ~CVXController.isSetUp()
                    CVXController.setUp()
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