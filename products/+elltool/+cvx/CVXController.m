classdef CVXController
    properties (GetAccess=private,Constant)
        CVX_SETUP_FUNC_NAME='cvx_setup';
        CVX_PREF_FILE_NAME='cvx_prefs.mat';
    end
    methods (Static)
        function setSolver(solverName)
            cvx_solver(solverName);
        end
        %
        function setPrecision(relTolVec)
            import elltool.cvx.CVXController;
            if abs(relTolVec(1) - relTolVec(2)) > eps
                import modgen.common.throwerror;
                throwerror('cvxError',...
                    'wrong precision format for cvx beta version');
            end
            cvx_precision([relTolVec(1), relTolVec(3)]);
            
        end
        %
        function setIsVerbosityEnabled(isQuiet)
            import elltool.cvx.CVXController;
            cvx_quiet(~isQuiet);
        end
        %
        function isPositive=isSetUp()
            import elltool.cvx.CVXController;
            if CVXController.isOnPath()
                cvxPrefDir=modgen.path.rmlastnpathparts(prefdir,1);
                cvxConfFileName = [cvxPrefDir, filesep,...
                    CVXController.CVX_PREF_FILE_NAME ];
                isPositive=modgen.system.ExistanceChecker.isFile(...
                    cvxConfFileName);
            else
                isPositive=false;
            end
        end
        %
        function isPositive=isOnPath()
            import elltool.cvx.CVXController;
            isPositive=modgen.system.ExistanceChecker.isFile(...
                CVXController.CVX_SETUP_FUNC_NAME);
        end
        %
        function setUp()
            import modgen.logging.log4j.Log4jConfigurator;
            import elltool.cvx.CVXController;
            logger=Log4jConfigurator.getLogger();
            logger.info('Setting up CVX...');
            feval(CVXController.CVX_SETUP_FUNC_NAME);
            logger.info('Setting up CVX: done');
            CVXController.checkIfSetUp();
        end
        function checkIfSetUp()
            import elltool.cvx.CVXController;
            import modgen.common.throwerror;
            if ~CVXController.isSetUp();
                throwerror('cvxNotSetUp','CVX is not set up');
            end
        end
        function checkIfOnPath()
            import elltool.cvx.CVXController;
            N_HOR_LINE_CHARS=60;
            if ~CVXController.isOnPath()
                horLineStr=['\n',repmat('-',1,N_HOR_LINE_CHARS),'\n'];
                msgStr=sprintf(['\n',horLineStr,...
                    '\nCVX is not found!!! \n',...
                    'Please put CVX into "cvx" ',...
                    'folder next to "products" folder ',horLineStr]);
                modgen.common.throwerror('cvxNotFound',msgStr);
            end
        end
        function setUpIfNot()
            import elltool.cvx.CVXController;
            CVXController.checkIfOnPath();
            if ~CVXController.isSetUp()
                CVXController.setUp()
            end
        end
        function solverStr = getSolver()
            solverStr = cvx_solver();
        end
        function precisionVec = getPrecision()
            precisionVec = cvx_precision();
        end
        function isVerb = getIsVerbosityEnabled()
            isVerb = ~cvx_quiet();
        end
    end
end