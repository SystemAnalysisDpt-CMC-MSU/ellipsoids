classdef CVXController < elltool.exttbx.IExtTBXController
    properties (GetAccess=private,Constant)
        CVX_SETUP_FUNC_NAME='cvx_setup';
        CVX_PREF_FILE_NAME='cvx_prefs.mat';
    end
    %
    methods   
        function fullSetup(self,setUpDataCVec)
            self.setUpIfNot();
            defaultSolver = setUpDataCVec{1};
            precisionForCVXVec = setUpDataCVec{2};
            isVerbose = setUpDataCVec{3};
            self.setSolver(defaultSolver);
            self.setPrecision(precisionForCVXVec);
            self.setIsVerbosityEnabled(isVerbose);
        end
        %
        function isPositive=isSetUp(self)
            if self.isOnPath()
                cvxConfFileName=[ prefdir, filesep,...
                    self.CVX_PREF_FILE_NAME];
                isPositive=modgen.system.ExistanceChecker.isFile(...
                    cvxConfFileName);
            else
                isPositive=false;
            end
        end
        %
        function isPositive=isOnPath(self)
            isPositive=modgen.system.ExistanceChecker.isFile(...
                self.CVX_SETUP_FUNC_NAME);
        end
        %
        function setUp(self)
            import modgen.logging.log4j.Log4jConfigurator;
            logger=Log4jConfigurator.getLogger();
            logger.info('Setting up CVX...');
            feval(self.CVX_SETUP_FUNC_NAME);
            logger.info('Setting up CVX: done');
            self.checkIfSetUp();
        end
        %
        function checkIfSetUp(self)
            import modgen.common.throwerror;
            if ~self.isSetUp();
                throwerror('cvxNotSetUp','CVX is not set up');
            end
        end
        %
        function checkIfOnPath(self)
            N_HOR_LINE_CHARS=60;
            if ~self.isOnPath()
                horLineStr=['\n',repmat('-',1,N_HOR_LINE_CHARS),'\n'];
                msgStr=sprintf(['\n',horLineStr,...
                    '\nCVX is not found!!! \n',...
                    'Please put CVX into "cvx" ',...
                    'folder next to "products" folder ',horLineStr]);
                modgen.common.throwerror('cvxNotFound',msgStr);
            end
        end
        %
        function setUpIfNot(self)
            self.checkIfOnPath();
            if ~self.isSetUp()
                self.setUp()
            end
        end
    end
    %
    %
    methods(Static)
        function setSolver(solverName)
            cvx_solver(solverName);
        end
        %
        function setPrecision(relTolVec)
            if abs(relTolVec(1) - relTolVec(2)) > eps
                import modgen.common.throwerror;
                throwerror('cvxError',...
                    'wrong precision format for cvx beta version');
            end
            cvx_precision([relTolVec(1), relTolVec(3)]);
            
        end
        %
        function setIsVerbosityEnabled(isQuiet)
            cvx_quiet(~isQuiet);
        end
        %
        function solverStr = getSolver()
            solverStr = cvx_solver();
        end
        %
        function precisionVec = getPrecision()
            precisionVec = cvx_precision();
        end
        %
        function isVerb = getIsVerbosityEnabled()
            isVerb = ~cvx_quiet();
        end
    end
end