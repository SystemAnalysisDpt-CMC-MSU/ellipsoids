classdef test_case < mlunit.test_case
    properties (Access=private)
        setUpParams={};
        profMode
        profDir
    end
    
    methods
        function self = test_case(varargin)
            % MLUNITEXT.TEST_CASE is an extension of mlunitext.test_case
            % which introduces an additional set of features for profiling
            % and testing
            %
            %
            % Input:
            %   optional:
            %       testCaseName: char[1,] - see mlunit.test_case for
            %          details
            %       subClassName: char[1,] - see mlunit.test_case for
            %          details
            %       testParam1 - test parameter passed into set_up_param
            %       ...
            %       testParam2 - test parameter passed into set_up_param
            %
            %   properties:
            %       profile: char[1,] - profiling mode used by
            %          runAndCheckTime method, the following modes are
            %          supported:
            %
            %           'none'/'off' - no profiling
            %
            %           'viewer' - profiling reports are just displayed
            %
            %           'profiling reports are displayed and saved to the
            %              file
            %
            %
            %      marker: char[1,] - marker for the tests,
            %          it is displayed in the messages indicating start and
            %          end of test runs
            %
            % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
            % Faculty of Computational Mathematics and Cybernetics, System Analysis
            % Department, 7-October-2012, <pgagarinov@gmail.com>$
            %
            [reg,prop]=modgen.common.parseparams(varargin,...
                {'profile','marker'});
            nRegs=length(reg);
            self = self@mlunit.test_case(reg{1:min(nRegs,2)});
            %
            isProfSpec=false;
            isMarkerSet=false;
            nProps=length(prop);
            for k=1:2:nProps-1
                switch prop{k}
                    case 'profile',
                        profMode=prop{k+1};
                        if ~(ischar(profMode)&&modgen.common.isrow(profMode))
                            error([upper(mfilename),':wrongInput'],...
                                'profile property is expected to be a string');
                        end
                        %
                        isProfSpec=true;
                    case 'marker'
                        markerStr=prop{k+1};
                        if ~(ischar(markerStr)&&...
                                modgen.common.isrow(markerStr))
                            error([upper(mfilename),':wrongInput'],...
                                'marker is expected to be a string');
                        end
                        isMarkerSet=true;
                end
            end
            if ~isProfSpec
                profMode='off';
            end
            if isMarkerSet
                self.set_marker(markerStr);
            end
            self.profMode=profMode;
            self.profDir=fileparts(which(class(self)));
            %
            self.setUpParams=[reg(3:end),prop];
        end
        function result = run(self, result)
            try
                self = set_up_param(self,self.setUpParams{:});
                result=run@mlunit.test_case(self,result);
            catch meObj
                if (nargin == 1)
                    result = default_test_result(self);
                end
                
                result = start_test(result, self);
                
                result = add_error(result, self, meObj);
                return;
            end
        end
        function self = set_up_param(self,varargin)
            
        end
        function runAndCheckError(~,commandStr,expIdentifier,varargin)
            % RUNANDCHECKERROR executes the specifies command and checks
            % that it throws an exeption with an identifier containing the
            % specified marker
            %
            % Input:
            %   regular:
            %       self:
            %       commandStr: char[1,]/function_handle[1,1] - command to execute
            %       expIdentifier: char[1,] - expected exeption
            %           identifier marker
            %
            %   optional:
            %       msgCodeStr: char[1,] - expected exception message
            %          marker
            %
            %   properties:
            %       causeCheckDepth: double[1,1] - depth at which causes of
            %          the given exception are checked for matching the
            %          specified patters, default value is 0 (no cause is
            %          checked)
            %
            % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
            % Faculty of Computational Mathematics and Cybernetics, System Analysis
            % Department, 7-October-2012, <pgagarinov@gmail.com>$
            %
            [reg,~,causeCheckDepth]=...
                modgen.common.parseparext(varargin,...
                {'causeCheckDepth';0;'isscalar(x)&&isnumeric(x)'},...
                [0,1],...
                'regDefList',{''},...
                'regCheckList',{'isstring(x)'});
            msgCodeStr=reg{1};
            %
            try
                if ischar(commandStr)
                    evalin('caller',commandStr);
                else
                    feval(commandStr);
                end
            catch meObj
                if ~isempty(expIdentifier)
                    checkCode(meObj,'identifier',expIdentifier);
                end
                if ~isempty(msgCodeStr)
                    checkCode(meObj,'message',msgCodeStr);
                end
                return;
            end
            mlunit.assert_equals(true,false);
            function checkCode(inpMeObj,fieldName,codeStr)
                %
                errMsg=modgen.exception.me.obj2hypstr(inpMeObj);
                
                mlunit.assert_equals(true,...
                    getIsCodeMatch(meObj,causeCheckDepth,...
                    fieldName,codeStr),...
                    sprintf(...
                    ['\n no match found for field %s ',...
                    'with pattern %s, ',...
                    ' exception details: \n %s'],...
                    fieldName,codeStr,errMsg));
            end
            function isPositive=getIsCodeMatch(inpMeObj,checkDepth,fieldName,codeStr)
                isPositive=~isempty(strfind(inpMeObj.(fieldName),codeStr));
                causeList=inpMeObj.cause;
                nCauses=length(causeList);
                if checkDepth>0&&nCauses>0
                    for iCause=1:nCauses
                        isPositive=isPositive||getIsCodeMatch(...
                            causeList{iCause},checkDepth-1,...
                            fieldName,codeStr);
                    end
                end
            end
        end
        function resTime=runAndCheckTime(self,commandStr,varargin)
            % RUNANDCHECKTIME executes the specified command and displayes
            % a profiling report using the specified name as a marker
            %
            % Input:
            %   regular:
            %       self:
            %       commandStr: char[1,] - command to execute
            %   optional:
            %       profCaseName: char[1,] - name of profiling case
            %
            %   properties:
            %       nRuns: numeric[1,1] - number of runs (1 by default)
            %       useMedianTime: logical [1,1] - if true, then median
            %           time of calculation is returned for all runs
            %
            % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
            % Faculty of Computational Mathematics and Cybernetics, System Analysis
            % Department, 7-October-2012, <pgagarinov@gmail.com>$
            %
            [reg,~,nRuns,useMedianTime]=...
                modgen.common.parseparext(varargin,...
                {'nRuns','useMedianTime';1,false;...
                'isreal(x)&&isscalar(x)','islogical(x)&&isscalar(x)'},[0,1],...
                'propRetMode','separate');
            if isempty(reg)
                profCaseName='default';
            else
                profCaseName=reg{1};
            end
            %
            isnDetailed=any(strcmpi(self.profMode,{'no','off'}));
            if isnDetailed,
                profileInfoObject=modgen.profiling.ProfileInfo();
            else
                profileInfoObject=modgen.profiling.ProfileInfoDetailed();
            end
            profileInfoObject.tic();
            if isnDetailed,
                if useMedianTime,
                    resTimeVec=zeros(1,nRuns);
                    curProfileInfoObject=modgen.profiling.ProfileInfo();
                    for iRun=1:nRuns
                        curProfileInfoObject.tic();
                        evalin('caller',commandStr);
                        resTimeVec(iRun)=curProfileInfoObject.toc();
                    end
                else
                    for iRun=1:nRuns
                        evalin('caller',commandStr);
                    end
                end
            else
                try
                    for iRun=1:nRuns
                        evalin('caller',commandStr);
                    end
                catch meObj,
                    profileInfoObject.toc();
                    rethrow(meObj);
                end
            end
            resTime=modgen.profiling.profresult(self.profMode,...
                profileInfoObject,profCaseName,...
                'callerName',modgen.common.getcallername(2),...
                'profileDir',self.profDir);
            if useMedianTime,
                resTime=median(resTimeVec);
            end
        end
    end
end