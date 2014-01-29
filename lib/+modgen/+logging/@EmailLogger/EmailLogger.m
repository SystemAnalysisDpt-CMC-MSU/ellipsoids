classdef EmailLogger<handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=private,Hidden)
        emailDistributionList={};
        emailAttachmentNameList={};
        userName='unknown';
        hostName='unknown';
        subjectSuffix='';
        loggerName='';
        isDryRun=false;
        isThrowExceptions=false;
        %
        smtpUserName=''
        smtpPassword=''
        emailAddress=''
        smtpServer='';
        
    end
    methods (Access=private)
        sendmail(self,to,subject,message,attachments)
    end
    methods
        function self=EmailLogger(varargin)
            logger=modgen.logging.log4j.Log4jConfigurator.getLogger();
            [~,prop]=parseparams(varargin);
            nProp=length(prop);
            for k=1:2:nProp
                switch lower(prop{k})
                    case 'emaildistributionlist',
                        self.emailDistributionList=prop{k+1};
                    case 'emailattachmentnamelist',
                        self.emailAttachmentNameList=prop{k+1};
                    case 'smtpserver',
                        self.smtpServer=prop{k+1};
                    case 'subjectsuffix',
                        self.subjectSuffix=prop{k+1};
                    case 'smtppassword',
                        self.smtpPassword=prop{k+1};
                    case 'smtpusername',
                        self.smtpUserName=prop{k+1};
                    case 'loggername',
                        self.loggerName=prop{k+1};
                    case 'dryrun',
                        self.isDryRun=prop{k+1};
                    case 'isthrowexceptions'
                        self.isThrowExceptions = prop{k+1};
                    otherwise,
                        error([upper(mfilename),':wrongInput'],...
                            'unknown property %s',prop{k});
                end
            end
            %% Configure email notification
            if ~self.isDryRun
                [curUserName,curHostName]=getuserhost();
                if ~isempty(curUserName)
                    self.userName = curUserName;
                end
                if ~isempty(curHostName)
                    self.hostName = curHostName;
                end
                self.emailAddress=[self.userName,'@',self.hostName];
                logger.info(...
                    ['no dry run mode, configured for smtpServer=',...
                    self.smtpServer]);
            else
                logger.info('configured for dry run');
            end
        end
        function sendMessage(self,subjectMessage,varargin)
            import modgen.common.throwerror;
            import modgen.common.parseparext;
            %% Create log4j logger
            logger=modgen.logging.log4j.Log4jConfigurator.getLogger();
            %
            if ~self.isDryRun
                [reg,~,attachNameList]=parseparext(varargin,...
                    {'emailAttachmentNameList';{};'iscellofstring(x)'},...
                    [0 1],'regDefList',{[]});
                bodyMessage=reg{1};
                %
                emailSubjectPrefix=['[',self.loggerName,']:'];
                emailSubjectSuffix=[self.subjectSuffix ,...
                    ', running on ',self.hostName,'(',self.userName,')'];
                emailSubject=[emailSubjectPrefix,subjectMessage,...
                    emailSubjectSuffix];
                attachNameList=[attachNameList,...
                    self.emailAttachmentNameList];
                %
                nAttachemments=length(attachNameList);
                for iFile=1:nAttachemments
                    fileName=attachNameList{iFile};
                    if ~modgen.system.ExistanceChecker.isFile(fileName)
                        throwerror('wrongInput',...
                            'cannot find attachment %s',fileName);
                    end
                end
                %
                logger.info(emailSubject);
                try
                    self.sendmail(self.emailDistributionList,...
                        emailSubject,...
                        bodyMessage,...
                        attachNameList);
                catch causeObj
                    meObj=MException([upper(mfilename),':sendEmailFailed'],...
                        ['something is wrong with the following data: \n',...
                        'distributionList: %s \n',...
                        'subject: %s\n',...
                        'smtpServer: %s\n',...
                        'emailAttachmentNameList: %s'],...
                        cell2sepstr([],self.emailDistributionList,',',...
                        'isMatlabSyntax',true),...
                        emailSubject,...
                        self.smtpServer,...
                        cell2sepstr([],self.emailAttachmentNameList,',',...
                        'isMatlabSyntax',true));
                    meObj=addCause(meObj,causeObj);
                    logger.fatal(sprintf('%s\nMessage body:\n%s',...
                        modgen.exception.me.obj2plainstr(meObj),...
                        bodyMessage));
                    if self.isThrowExceptions
                        throw(meObj);
                    end
                end
            end
        end
        function emailAddress=getEmailAddress(self)
            emailAddress=self.emailAddress;
        end
        function smtpServer=getSMTPServer(self)
            smtpServer=self.smtpServer;
        end
        function suffixStr = getSubjectSuffix(self)
            suffixStr = self.subjectSuffix;
        end
        function setSubjectSuffix(self, suffixStr)
            self.subjectSuffix = suffixStr;
        end
        function addSubjectSuffix(self,suffixStr,isAddedToEnd)
            if nargin<3
                isAddedToEnd=true;
            end
            %
            if isAddedToEnd
                self.subjectSuffix=[self.subjectSuffix,suffixStr];
            else
                self.subjectSuffix=[suffixStr,self.subjectSuffix];
            end
        end
    end
end
