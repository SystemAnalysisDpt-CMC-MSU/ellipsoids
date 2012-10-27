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
                logMessageStr=evalc('results=feval(testPackName,varargin{:});');
                [errorCount,failCount]=results.getErrorFailCount();
                messageStr=results.getErrorFailMessage();
                %    
                if (failCount+errorCount)>0
                    subjectStr=sprintf('FAILED:(failures: %d, errors %d)',failCount,errorCount);
                else
                    subjectStr='PASSED';
                end
                messageStr=[messageStr,sprintf('\n'),logMessageStr];
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
