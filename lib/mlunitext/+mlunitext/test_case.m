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
                set_up_param(self,self.setUpParams{:});
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
            %       commandStr: char[1,]/function_handle[1,1] - command to 
            %                   execute
            %       expIdentifier: char[1,]/cell[1,] of char[1,] - string/
            %           cell array of strings, containig expected exeption
            %           identifier markers
            %
            %   optional:
            %       msgCodeStr: char[1,]/cell[1,] of char[1,] - cell array
            %           of strings, containig expected exception message 
            %           markers. For each field in expIdentifier supposed 
            %           to be one field in msgCodeStr. In case of more then
            %           one argument in expIdentifier, if you don't expect 
            %           any exception messages, put '' in corresponding 
            %           field.
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
            import modgen.common.checkmultvar;
            %
            isCell = isa(expIdentifier,'cell');
            if isCell
                checkStr = 'iscell(x)';
            else
                checkStr = 'isstring(x)';
            end
            %
            [reg,~,causeCheckDepth]=...
                modgen.common.parseparext(varargin,...
                {'causeCheckDepth';0;'isscalar(x)&&isnumeric(x)'},...
                [0,1],...
                'regDefList',{''},...
                'regCheckList',{checkStr});
            msgCodeStr=reg{1};
            %
            if(isCell)
                checkmultvar(@(x,y) size(y,2) == 0 || ...
                    size(y,2) == size(x,2),2,expIdentifier,msgCodeStr);
            end
            %
            try
                if ischar(commandStr)
                    evalin('caller',commandStr);
                else
                    feval(commandStr);
                end
            catch meObj
                if ~isempty(expIdentifier)
                    suitableCodes = checkCode(meObj,'identifier',expIdentifier);
                end
                if ~isempty(msgCodeStr)
                    checkCode(meObj,'message',msgCodeStr,suitableCodes);
                end
                return;
            end
            mlunit.assert_equals(true,false);
            function suitableCodes = checkCode(inpMeObj,fieldName,...
                                                codeStrCArr,varargin)
                %
                errMsg=modgen.exception.me.obj2hypstr(inpMeObj);
                N_USUAL_ARGS = 3;
                %
                if isa(codeStrCArr,'cell')
                    nCodes = size(codeStrCArr,2);
                    isMatchVec = false(1,nCodes);
                    for iCodes = 1:nCodes
                        isMatchVec(iCodes) = getIsCodeMatch(meObj,...
                            causeCheckDepth,fieldName,codeStrCArr{iCodes});
                    end
                    %
                    patternsStr = codeStrCArr{1};
                    for iCodes = 2:nCodes
                        patternsStr = [patternsStr,', ',codeStrCArr{iCodes}];
                    end
                else
                    isMatchVec = getIsCodeMatch(meObj,...
                            causeCheckDepth,fieldName,codeStrCArr);
                    nCodes = 1;
                    patternsStr = codeStrCArr;
                end
                %
                numCodesVec = 1:nCodes;
                isAnyCodeSuited = any(isMatchVec);
                if isAnyCodeSuited
                    suitableCodes = numCodesVec(isMatchVec);
                else
                    suitableCodes = -1;
                end
                %    
                if nargin == N_USUAL_ARGS
                    isOk = isAnyCodeSuited;
                else
                    neededCode = varargin{1};
                    isOk = isAnyCodeSuited && ...
                        any(suitableCodes == neededCode);
                end
                %
                mlunit.assert_equals(true,isOk,...
                    sprintf(...
                    ['\n no match found for field %s ',...
                    'with patterns: %s, ',...
                    ' exception details: \n %s'],...
                    fieldName,patternsStr,errMsg));
            end
            function isPositive=getIsCodeMatch(inpMeObj,checkDepth,fieldName,codeStr)
                str = inpMeObj.(fieldName);
                if isempty(str)
                    isPositive= isempty(codeStr);
                else
                    isPositive=~isempty(strfind(str,codeStr));
                end
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