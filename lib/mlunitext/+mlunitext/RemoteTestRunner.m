classdef RemoteTestRunner<handle
    %REMOTETESTRUNNER Summary of this class goes here
    %   Detailed explanation goes here
    properties
        emailLogger
        fTempDirGetter
    end
    methods
        function self=RemoteTestRunner(emailLogger,fTempDirGetter)
            self.emailLogger=emailLogger;
            self.fTempDirGetter=fTempDirGetter;
        end
        function runTestPack(self,testPackName,varargin)
            import modgen.common.throwerror;
            self.emailLogger.sendMessage('STARTED','');
            try
                logMessageStr=evalc(...
                    'results=feval(testPackName,varargin{:});');
                messageStr=results.getErrorFailMessage();
                %
                if results.isPassed()
                    subjectStr='PASSED';
                else
                    reportStr=results.getReport('minimal');
                    subjectStr=sprintf('FAILED:(%s)',reportStr);
                end
                %
                topsReport=results.getReport('tops');
                messageStr=sprintf('%s\n%s\n%s\n',topsReport,...
                    messageStr,logMessageStr);
            catch meObj
                subjectStr='ERROR';
                messageStr=modgen.exception.me.obj2plainstr(meObj);
            end
            tmpDirName=self.fTempDirGetter(testPackName);
            dstFileName=[tmpDirName,filesep,'output','.txt'];
            [fid,errMsg] = fopen(dstFileName, 'w');
            if fid<0
                throwerror('cantOpenFile',errMsg);
            end
            try
                fprintf(fid,'%s',messageStr);
            catch meObj
                fclose(fid);
                rethrow(meObj);
            end
            fclose(fid);
            self.emailLogger.sendMessage(subjectStr,messageStr);
        end
    end
    
end
