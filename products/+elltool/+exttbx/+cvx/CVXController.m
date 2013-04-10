classdef CVXController < elltool.exttbx.IExtTBXController
    properties (GetAccess=private,Constant)
        CVX_SETUP_FUNC_NAME='cvx_setup';
        CVX_PREF_FILE_NAME='cvx_prefs.mat';
        DEFAULT_SOLVER = 'SeDuMi';
        TOL_FACTOR = 2;
    end
    %
    methods (Access=private)
        function prepPrecVec=getPrepPrecision(self,absTol,relTol)
            prepPrecVec=[0, 0, self.TOL_FACTOR*relTol];
        end
    end
    methods
        function checkSettings(self,absTol,relTol,isVerbose)
            import modgen.common.throwerror;
            precisionVec = self.getPrecision();
            solverStr = self.getSolver();
            isVerbosity = self.getIsVerbosityEnabled();
            if (~isequal(precisionVec, ...
                    self.getPrepPrecision(absTol,relTol))) || ...
                    (~(strcmp(solverStr, self.DEFAULT_SOLVER))) ...
                    || (isVerbosity ~= isVerbose)
                throwerror('cvxError', 'wrong cvx properties');
            end
        end
        function fullSetup(self,absTol,relTol,isVerbose)
            self.setUpIfNot();
            self.setSolver(self.DEFAULT_SOLVER);
            prepPrecVec=self.getPrepPrecision(absTol,relTol);
            self.setPrecision(prepPrecVec);
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
            import modgen.common.throwerror;
            if abs(relTolVec(1) - relTolVec(2)) > eps
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