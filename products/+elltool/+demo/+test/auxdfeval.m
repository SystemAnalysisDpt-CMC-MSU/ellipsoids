function varargout=auxdfeval(processorFunc,varargin)
varargout=cell(1,nargout);
if nargout>0
    [varargout{:}]=modgen.pcalc.auxdfeval(@processorfuncwithinstall,...
        varargin{:});
else
    modgen.pcalc.auxdfeval(@processorfuncwithinstall,varargin{:});
end

    function varargout=processorfuncwithinstall(varargin)
        welcomeString=sprintf('Installing Ellipsoidal Toolbox');
        disp([welcomeString,'...']);
        installexternals(true);
        warning('on','all');
        warning('off','MATLAB:dispatcher:pathWarning');
        % switch off warnings for nargchk for Matlab R2016a and R2016b
        SMatlabInfo=ver('Matlab');
        if any(strcmp(SMatlabInfo.Release,{'(R2016a)','(R2016b)'}))
            warning('off','MATLAB:nargchk:deprecated');
        end
        modgen.logging.log4j.Log4jConfigurator.configureSimply();
        %
        %% Configure CVX is needed
        ellipsoidsinit();
        disp([welcomeString,': done']);
        %% Run task
        varargout=cell(1,nargout);
        if nargout>0
            [varargout{:}]=feval(processorFunc,varargin{:});
        else
            feval(processorFunc,varargin{:});
        end
    end
end