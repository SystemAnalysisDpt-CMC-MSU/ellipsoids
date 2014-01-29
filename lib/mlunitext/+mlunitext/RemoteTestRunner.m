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
            tmpDirName=self.fTempDirGetter(testPackName);
            resultVec=[];
            try
                consoleOutStr=evalc(...
                    'resultVec=feval(testPackName,varargin{:});');
                errorFailStr=resultVec.getErrorFailMessage();
                isFailed=~resultVec.isPassed();
                %
                subjectStr=resultVec.getReport('minimal');
                %
                consoleOutFileName=writeMessageToFile('console_output',...
                    consoleOutStr);
                topsFileName=getFullFileName('perf_tops','.csv');
                topsTCFileName=getFullFileName(...
                    'perf_tops_tc','.csv');
                resultVec.getRunStatRel().writeToCSV(topsFileName);
                resultVec.getRunStatRel('topsTestCase').writeToCSV(...
                    topsTCFileName);
                attachFileNameList={consoleOutFileName,...
                    topsFileName,topsTCFileName};
            catch meObj
                subjectStr='ERROR';
                errorFailStr=modgen.exception.me.obj2plainstr(meObj);
                attachFileNameList={};
                isFailed=true;
            end
            if isFailed
                errorFailFileName=writeMessageToFile('error_fail_list',...
                    errorFailStr);
                attachFileNameList=[attachFileNameList,{errorFailFileName}];
            end
            %
            self.emailLogger.sendMessage(subjectStr,...
                'emailAttachmentNameList',attachFileNameList);
            
            function fullFileName=getFullFileName(shortFileName,extName)
                if nargin<2
                    extName='.txt';
                end
                fullFileName=[tmpDirName,filesep,shortFileName,extName];
            end
            function fullFileName=writeMessageToFile(shortFileName,msgStr)
                fullFileName=getFullFileName(shortFileName);
                [fid,errMsg] = fopen(fullFileName, 'w');
                if fid<0
                    throwerror('cantOpenFile',errMsg);
                end
                try
                    fprintf(fid,'%s',msgStr);
                catch meObj
                    fclose(fid);
                    rethrow(meObj);
                end
                fclose(fid);
            end
        end
    end
end

