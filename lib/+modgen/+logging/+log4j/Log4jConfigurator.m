classdef Log4jConfigurator<handle
    %LOG4JCONFIGURATOR simplifies log4j configuration, especially when
    %Parallel Computing Toolbox is used. In the latter case the class forwards
    %the logs of different processees in separate log files
    %
    % The Configurator keeps track of configuration attempts (this works
    % only within a single thread). When configuration is performed using
    % configureInternal, the latest log4j property string is stored and can
    % then be retrieved using getLastLogPropStr.
    %
    % By default, log4j can be reconfigured by successive calls to its
    % configuration methods. However, if the latest configuration is locked
    % using lockConfiguration, subsequent calls to either configureSimply
    % or configureInternal will result in a warning with no configuration
    % change, until unlockConfiguration is called.
    %
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-21 $ 
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %

    properties (Constant,Abstract)
        MASTER_LOG_FILE_NAME
        CHILD_LOG_FILE_NAME_PREFIX
        LOG_FILE_EXT
        MAIN_LOG_FILE_PREFIX
        SP_MAIN_LOG_FILE_NAME
        SP_CUR_PROCESS_NAME
        SP_LOG_DIR_WITH_SEP
        SP_LOG_FILE_EXP
    end
    methods (Static,Access=protected)
        function res = getSetConfStatus(varargin)
            persistent isConfiguredPersistent;
            if isempty(isConfiguredPersistent)
                isConfiguredPersistent = false;
            end
            if ~isempty(varargin)
                isConfiguredPersistent = varargin{1};
            end
            res = isConfiguredPersistent;
        end
        function res = getSetLockStatus(varargin)
            persistent isLockedPersistent;
            if isempty(isLockedPersistent)
                isLockedPersistent = false;
            end
            if ~isempty(varargin)
                isLockedPersistent = varargin{1};
            end
            res = isLockedPersistent;
        end
        function res = getSetLogPropStr(varargin)
            persistent logPropStrPersistent;
            if ~isempty(varargin)
                logPropStrPersistent = varargin{1};
            end
            res = logPropStrPersistent;
        end
    end
    methods (Static)
        function res = isConfigured()
            res = modgen.logging.log4j.Log4jConfigurator.getSetConfStatus();
        end
        function res = isLocked()
            res = modgen.logging.log4j.Log4jConfigurator.getSetLockStatus();
        end
        function configureSimply(logLevel,varargin)
            import org.apache.log4j.BasicConfigurator;
            import org.apache.log4j.Level;
            import org.apache.log4j.Logger;
            import org.apache.log4j.spi.LoggerRepository;
            import modgen.logging.log4j.Log4jConfigurator;
            import modgen.common.throwerror;
            %
            [~,prop]=modgen.common.parseparams(varargin,[],0);
            nProp=length(prop);
            isLock = false;
            for k=1:2:nProp-1
                switch lower(prop{k})
                    case 'islockafterconfigure',
                        isLock=prop{k+1};
                        if ~isscalar(isLock) || ~islogical(isLock)
                            throwerror('wrongInput', ...
                                'Invalid size or tipe of %s', prop{k});
                        end
                    otherwise
                        throwerror('wrongInput', ...
                            'Property %s is not supported', prop{k});
                end
            end
            %
            if modgen.logging.log4j.Log4jConfigurator.isLocked()
                logger=Logger.getLogger('modgen.logging.log4j.Log4jConfigurator');
                logger.warn(['Attempt to change a locked Log4j configuration', sprintf('\n'), ...
                    modgen.exception.me.printstack(dbstack('-completenames'),...
                    'useHyperlink',false,'prefixStr','  ')]);
                return;
            end
            %
            %% set global INFO logging level
            if nargin==0
                logLevel='INFO';
            end
            BasicConfigurator.resetConfiguration();
            BasicConfigurator.configure();
            logger=Logger.getRootLogger();
            repository=logger.getLoggerRepository();
            repository.setThreshold(Level.(logLevel));
            %
            modgen.logging.log4j.Log4jConfigurator.getSetConfStatus(true);
            if isLock
                modgen.logging.log4j.Log4jConfigurator.lockConfiguration();
            end
        end        
        function logger=getLogger(loggerName,isSuffix)
            % GETLOGGER - gets logger for caller (it may be either script or
            %             function or method of some class)
            import org.apache.log4j.Logger;
            if nargin<2,
                isSuffix=false;
            end
            if nargin==0||isSuffix,
                %loggerName=modgen.common.getcallername(2);
                [methodName className]=modgen.common.getcallernameext(2);
                % delete info on subfunctions
                curInd=find(methodName=='/'|methodName=='\',1,'first');
                if ~isempty(curInd),
                    methodName=methodName(1:curInd-1);
                end
                if ~isempty(className),
                    className=[className '.'];
                end
                if isSuffix,
                    loggerName=[className methodName '.' loggerName];
                else
                    loggerName=[className methodName];
                end
            end
            logger=Logger.getLogger(loggerName);
        end
        function lockConfiguration()
            modgen.logging.log4j.Log4jConfigurator.getSetLockStatus(true);
        end
        function unlockConfiguration()
            modgen.logging.log4j.Log4jConfigurator.getSetLockStatus(false);
        end
        function res = getLastLogPropStr()
            res = modgen.logging.log4j.Log4jConfigurator.getSetLogPropStr();
        end
    end
    methods (Static,Abstract)
        logFileName=getMainLogFileName()
        configure(confSource)
    end
    methods (Access=protected)
        function logFileName=getMainLogFileNameInternal(self)
            % GETMAINLOGFILENAMEINTERNAL - returns a full name of the main
            %                              log file
            logFileName=[self.getMainLogFilePathInternal,...
                self.getShortMainLogFileNameInternal()];
        end
        function logFileName=getShortMainLogFileNameInternal(self)
            % GETMAINLOGFILENAME - returns a short name (without path) of 
            %                      the main log file
            import modgen.logging.log4j.Log4jConfigurator;
            logFileName=[self.MAIN_LOG_FILE_PREFIX,...
                self.getCurProcessNameInternal(),'.',...
                self.LOG_FILE_EXT];
        end
        function processName=getCurProcessNameInternal(self)
            % GETCURPROCESSNAME - returns a name of currently running 
            %                     process
            import modgen.logging.log4j.Log4jConfigurator;
            [~,SProp]=modgen.pcalc.gettaskname();
            if SProp.isMain
                processName=self.MASTER_LOG_FILE_NAME;
            else
                curTaskName=['task',num2str(SProp.taskId)];
                %
                processName=[self.CHILD_LOG_FILE_NAME_PREFIX,'.',...
                    curTaskName];
            end
        end
        function curPathWithFileSep=getMainLogFilePathInternal(self)
            metaClass=metaclass(self);
            curPathWithFileSep=[fileparts(which(metaClass.Name)),...
                filesep,'Logs',filesep];
        end
        function configureInternal(self,logPropStr,varargin)
            % CONFIGURE - performs log4j configuration using a log4j 
            %             property string as a source
            import modgen.system.ExistanceChecker;
            import org.apache.log4j.Logger;
            import org.apache.log4j.PropertyConfigurator;
            import modgen.common.throwerror;
            %
            [~,prop]=modgen.common.parseparams(varargin,[],0);
            nProp=length(prop);
            isLock = false;
            isLoggerSuffix = false;
            for k=1:2:nProp-1
                switch lower(prop{k})
                    case 'islockafterconfigure',
                        isLock=prop{k+1};
                        if ~isscalar(isLock) || ~islogical(isLock)
                            throwerror('wrongInput', ...
                                'Invalid size or tipe of %s', prop{k});
                        end
                    case 'loggersuffix',
                        isLoggerSuffix=true;
                        loggerSuffix=prop{k+1};
                    otherwise
                        throwerror('wrongInput', ...
                            'Property %s is not supported', prop{k});
                end
            end
            metaClass=metaclass(self);
            loggerName=metaClass.Name;
            if isLoggerSuffix,
                loggerName=[loggerName '.' loggerSuffix];
            end
            %
            if self.isLocked()
                logger=Logger.getLogger(loggerName);
                logger.warn(...
                    ['Attempt to change a locked Log4j configuration',...
                    sprintf('\n'), ...
                    modgen.exception.me.printstack(dbstack('-completenames'),...
                    'useHyperlink',false,'prefixStr','  ')]);
                return;
            end
            %
            if ~ischar(logPropStr)
                throwerror('wrongInput',...
                    'configuration source should be a property string');
            end
            self.getSetLogPropStr(logPropStr);
            logPropStr=java.lang.String(logPropStr);
            %
            java.lang.System.setProperty(...
                self.SP_MAIN_LOG_FILE_NAME,...
                self.getShortMainLogFileNameInternal);
            %
            logLocPath=self.getMainLogFilePathInternal();
            %
            if ~ExistanceChecker.isDir(logLocPath)
                mkdir(logLocPath);
            end
            %
            java.lang.System.setProperty(...
                self.SP_CUR_PROCESS_NAME,...
                self.getCurProcessNameInternal);
            java.lang.System.setProperty(...
                self.SP_LOG_DIR_WITH_SEP,...
                logLocPath);
            %
            java.lang.System.setProperty(...
                self.SP_LOG_FILE_EXP,...
                self.LOG_FILE_EXT);
            %
            confStream=java.io.ByteArrayInputStream(logPropStr.getBytes());
            logProp=java.util.Properties();
            logProp.load(confStream);
            PropertyConfigurator.configure(logProp);
            logger=Logger.getLogger(loggerName);
            logger.info('Log4j is successfully configured');
            %
            self.getSetConfStatus(true);
            if isLock
                self.lockConfiguration();
            end
        end
    end
end