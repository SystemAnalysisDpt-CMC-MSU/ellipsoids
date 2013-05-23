classdef mlunit_test_emaillogger < mlunitext.test_case
    properties (Access=private)
        eMail
        smtpServer
    end
    methods
        function self = mlunit_test_emaillogger(varargin)
            self = self@mlunitext.test_case(varargin{:});
            % Save current Internet preferences
            if ispref('Internet','SMTP_Server')
                self.smtpServer = getpref('Internet','SMTP_Server');
            else
                self.smtpServer = '';
            end
            if ispref('Internet','E_mail')
                self.eMail = getpref('Internet','E_mail');
            else
                self.eMail = '';
            end
        end
        %
        function self = test_emaillogger_fail(self)
            obj=modgen.logging.EmailLogger(...
                'emailDistributionList',{'billy@microsoft.com'},...
                'emailAttachmentNameList',{},...
                'smtpServer','invalid.server',...
                'subjectSuffix','for mydatabase on mypc',...
                'loggerName','MyApplication',...
                'isThrowExceptions',true);
            commandStr=['obj.sendMessage(''calculation started'',',...
                '''calculation started'')'];
            self.runAndCheckError('evalc(commandStr)','sendEmailFailed');
        end
        %
        function self = test_emaillogger_preferences(self)
            % E-mail settings that will be used to configure test EmailLogger
            testSmtpServer = 'some.server';
            [userName,hostName]=getuserhost();
            if isempty(userName)
                userName = 'unknown';
            end
            if isempty(hostName)
                hostName = 'unknown';
            end
            testEmail = [userName, '@', hostName];
            % EmailLogger sets preferences Internet.SMTP_Server and
            % Internet.E_mail
            logger=modgen.logging.EmailLogger(...
                'emailDistributionList',{'billy@microsoft.com'},...
                'smtpServer',testSmtpServer,...
                'subjectSuffix','for mydatabase on mypc',...
                'loggerName','MyApplication');
            mlunitext.assert_equals(testSmtpServer, logger.getSMTPServer());
            mlunitext.assert_equals(testEmail, logger.getEmailAddress());
            % EmailLogger should warn about changed preferences and reset
            % them to their original values
            setpref('Internet','SMTP_Server','some.other.server');
            setpref('Internet','E_mail','some.other@email');
            outputText = evalc(...
                ['logger.sendMessage(''calculation started'',',...
                '''calculation started'')']);
            nWarnings = length( findstr('Warning:',outputText) );
            mlunitext.assert_equals(0,nWarnings)
            mlunitext.assert_equals(testSmtpServer, logger.getSMTPServer());
            mlunitext.assert_equals(testEmail, logger.getEmailAddress());
            % If 'dryRun' property is set, EmailLogger should also change
            % e-mail preferences
            logger=modgen.logging.EmailLogger(...
                'emailDistributionList',{'billy@microsoft.com'},...
                'smtpServer','some.other.server',...
                'subjectSuffix','for mydatabase on mypc',...
                'loggerName','MyApplication',...
                'dryRun',true);
            mlunitext.assert_equals('some.other.server',logger.getSMTPServer());
        end
        %
        function self = tear_down(self)
            if ~isempty(self.smtpServer)
                setpref('Internet','SMTP_Server',self.smtpServer);
            elseif ispref('Internet','SMTP_Server')
                rmpref('Internet','SMTP_Server');
            end
            if ~isempty(self.eMail)
                setpref('Internet','E_mail',self.eMail);
            elseif ispref('Internet','E_mail')
                rmpref('Internet','E_mail');
            end
        end
    end
end