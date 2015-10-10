classdef RemoteTestRunner<handle
    %REMOTETESTRUNNER Summary of this class goes here
    %   Detailed explanation goes here
    properties
        emailLogger
        fTempDirGetter
        isConsoleOutputCollected
    end
    methods
        function self=RemoteTestRunner(emailLogger,fTempDirGetter,...
                varargin)
            import modgen.common.parseparext;
            self.emailLogger=emailLogger;
            self.fTempDirGetter=fTempDirGetter;
            [~,~,self.isConsoleOutputCollected]=parseparext(varargin,...
                {'isConsoleOutputCollected';...
                true;...
                'islogical(x)&&isscalar(x)'},0);
        end
        function resultVec=runTestPack(self,testPackName,varargin)
            import modgen.common.throwerror;
            import modgen.logging.log4j.Log4jConfigurator;
            %
            [testPackArgList,~,isAntXMLReportEnabled,antXMLReportDir,...
                isAntReportEnabledSpec,isAntXMLReportDirSpec]=...
                modgen.common.parseparext(varargin,...
                {'isAntXMLReportEnabled','antXMLReportDir';...
                false,'';...
                'islogical(x)','ischarstring(x)'});
            if isAntReportEnabledSpec&&~isAntXMLReportDirSpec
                throwerror('wrongInput',['antXMLReportDir property',...
                    'is obligatory when isAntXMLReportEnabled=true']);
            end
            %
            self.emailLogger.sendMessage('STARTED','');
            tmpDirName=self.fTempDirGetter(testPackName);
            resultVec=[];
            logger=Log4jConfigurator.getLogger();
            isConsoleOutputCollected=self.isConsoleOutputCollected;
            try
                if isConsoleOutputCollected
                    consoleOutStr=evalc(...
                        'resultVec=feval(testPackName,testPackArgList{:});');
                else
                    resultVec=feval(testPackName,testPackArgList{:});
                end
                if isAntXMLReportEnabled
                    resultVec.saveXMLReport(antXMLReportDir);
                end
                errorFailStr=resultVec.getErrorFailMessage();
                errorHyperStr=errorFailStr;
                isFailed=~resultVec.isPassed();
                %
                subjectStr=resultVec.getReport('minimal');
                %
                if isConsoleOutputCollected
                    consoleOutFileName=writeMessageToFile('console_output',...
                        consoleOutStr);
                    consoleOutZipFileName=[tmpDirName,filesep,'cosoleOutput.zip'];
                    zip(consoleOutZipFileName,consoleOutFileName);
                    attachFileNameList={consoleOutZipFileName};
                else
                    attachFileNameList={};
                end
                %
                topsFileName=getFullFileName('perf_tops','.csv');
                topsTCFileName=getFullFileName(...
                    'perf_tops_tc','.csv');
                resultVec.getRunStatRel().writeToCSV(topsFileName);
                resultVec.getRunStatRel('topsTestCase').writeToCSV(...
                    topsTCFileName);
                attachFileNameList=[attachFileNameList,...
                    topsFileName,topsTCFileName];
            catch meObj
                subjectStr='ERROR';
                errorFailStr=modgen.exception.me.obj2plainstr(meObj);
                errorHyperStr=modgen.exception.me.obj2hypstr(meObj);
                attachFileNameList={};
                isFailed=true;
            end
            if isFailed
                errorFailFileName=writeMessageToFile('error_fail_list',...
                    errorFailStr);
                attachFileNameList=[attachFileNameList,{errorFailFileName}];
                logger.error(errorHyperStr);
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

