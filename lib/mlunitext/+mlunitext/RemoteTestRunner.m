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
                %
                subjectStr=resultVec.getReport('minimal');
                %
                statRel=resultVec.getRunStatRel();
                
                consoleOutFileName=writeMessageToFile('console_output',...
                    consoleOutStr);
                topsFileName=getFullFileName('performance_tops','.csv');
                statRel.writeToCSV(topsFileName);
                attachFileNameList={consoleOutFileName,topsFileName};
            catch meObj
                subjectStr='ERROR';
                errorFailStr=modgen.exception.me.obj2plainstr(meObj);
                attachFileNameList={};
            end
            consoleOutFileName=writeMessageToFile('error_fail_list',...
                errorFailStr);
            attachFileNameList=[attachFileNameList,{consoleOutFileName}];
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

