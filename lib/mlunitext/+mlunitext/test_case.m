classdef test_case<handle
    % TEST_CASE is the base class for all tests. It defines a
    %  fixture to run multiple tests. The constructor is called as follows:
    %
    %  Example: test = test_case('test_foo', 'my_test');
    %  test_foo is the name of the test method, my_test is the name of a
    %  subclass of test_case. Such a class is created as follows:
    %
    %  1) Implement a subclass of test_class with a constructor looking
    %     like this:
    %         function self = my_test(name)
    %
    %         test = test_case(name, 'my_test');
    %         self.dummy = 0;
    %         self = class(self, 'my_test', test);
    %
    %  2) Define instance variables like self.dummy.
    %
    %  3) Override set_up to initialize the fixture.
    %
    %  4) Override tear_down to clean-up after a test.
    %
    %  5) Implement a method for each test looking like:
    %         function self = test_foo(self)
    %
    %         assert_equals(1, mod(4 * 4, 3));
    %
    %  6) Run the test:
    %         test = my_test('test_foo');
    %         [test, result] = run(test);
    %         getReport(result)
    %
    %  See also MLUNITEXT.TEST_RESULT, MLUNITEXT.TEST_SUITE.
    %
    % $Authors: Peter Gagarinov <pgagarinov@gmail.com>
    % $Date: March-2013 $
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2012-2013$
    %
    properties (Access=private)
        setUpParams={};
        profMode
        profDir
    end
    properties (SetAccess=protected,GetAccess=public)
        name
        marker = ''
    end
    %
    methods
        function self = test_case(varargin)
            % MLUNITEXT.TEST_CASE is an extension of mlunitext.test_case
            % which introduces an additional set of features for profiling
            % and testing
            %
            %
            % Input:
            %   optional:
            %       testCaseName: char[1,] - see mlunitext.test_case for
            %          details
            %       subClassName: char[1,] - see mlunitext.test_case for
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
            [reg,~,self.profMode,markerStr,~,isMarkerSet]=...
                modgen.common.parseparext(varargin,...
                {'profile','marker';...
                'off',[];...
                'isstring(x)','isstring(x)'});
            nRegs=length(reg);
            additionalParse(reg{1:min(nRegs,2)});
            %
            if isMarkerSet
                self.set_marker(markerStr);
            end
            self.profDir=fileparts(which(class(self)));
            %
            self.setUpParams=reg(3:end);
            function additionalParse(name, subclass)
                import modgen.common.throwerror;
                if (nargin == 0)
                    self.name = '';
                else
                    self.name = name;
                    %
                    if (nargin == 1)
                        if isempty(self.name)
                            self.name = 'run_test';
                        end
                    else
                        if isempty(self.name)
                            self.name = 'run_test';
                        else
                            r = mlunitext.reflect(subclass);
                            if ~r.method_exists(name)
                                throwerror('noSuchMethod',...
                                    ['Method ', name ' does not exists.']);
                            end
                        end
                    end
                end
            end
        end
        function count = count_test_cases(self) %#ok
            % COUNT_TEST_CASES returns the number of test cases
            %  executed by run.
            %  The default implementation of test_case returns always 1,
            %  because the test_case object consists only of one test
            %  method (whereas it is possible to define more than one test
            %  method within the test_case class).
            %
            %  Example:
            %         test = my_test('test_foo');
            %         count_test_cases(test);     % Returns 1
            count = 1;
        end
        
        function result = default_test_result(self) %#ok
            % DEFAULT_TEST_RESULT returns a default test_result
            % object.
            %  Usually default_test_result is used by the method
            %  test_case.run to obtain a default test result. If the
            %  results of more than tests should be collected within the
            %  same test result, default_test_result could be called before
            %  the execution of the tests.
            %
            %  Example:
            %         test1 = my_test('test_foo1');
            %         test2 = my_test('test_foo2');
            %         result = default_test_result(test1);
            %         [test1, result] = run(test1, result)
            %         [test2, result] = run(test2, result)
            %         getReport(result)
            
            result = mlunitext.test_result;
        end
        
        function s = str(self)
            % STR returns a string with the method and class name
            % of the test.
            %
            % Example:
            %  If a test method is defined as follows
            %           function test_method
            %               assert(0 == sin(0));
            %           end
            %  belonging to a class my_test, which is instantiated as
            %  follows
            %           test = my_test('test_method');
            %  then str will return:
            %           my_test('test_method')
            
            s = class(self);
            if ~isempty(self.marker)
                s = [s, '[', self.marker, ']'];
            end
            s = [s, '(''', self.name, ''')'];
            %
        end
        
        function set_marker(self, marker)
            %test_case.set_marker sets an optional marker for the test case
            
            self.marker = marker;
        end
        function self = run_test(self)
            % RUN_TEST is the default test method of test_case.
            %
            % Example:
            %  Usually run_test (as every test method) is not called
            %  directly, but through the method run.
            %         test = function_test_case(@() assert(0 == sin(0)));
            %         [test, result] = run(test);
            %         getReport(result)
            
        end
        
        function self = set_up(self)
            % SET_UP sets up the fixture and is called everytime
            % before a test is executed.
            %
            % Example:
            %  set_up is not called directly, but through the method run.
            %         test = ... % e.g. created through my_test('test_foo')
            %         [test, result] = run(test);
            %         getReport(result)
            
        end
        function self = tear_down(self)
            % TEAR_DOWN called everytime after a test is executed
            % for cleaning up the fixture.
            %
            % Example:
            %  tear_down is not called directly, but through the method
            %  run.
            %   test = ... % e.g. created through my_test('test_foo')
            %   [test, result] = run(test);
            %   getReport(result)
        end
        function result = run(self, result)
            % RUN executes the test case and saves the results in
            % result.
            %
            % Input:
            %   regular:
            %       self:
            %       result: mlunitext.test_result[1,1] - input result
            %
            % Output:
            %   result: mlunitext.test_result[1,1] -output result
            %
            % Example:
            %  There are two ways of calling run:
            %
            %  1) [test, result] = run(test) uses the default test result.
            %
            %  2) [test, result] = run(test, result) uses the result given
            %     as paramater, which allows to collect the result of a
            %     number of tests within one test result.
            %
            if (nargin == 1)
                result = default_test_result(self);
            end
            
            result.start_test(self);
            try
                try
                    set_up_param(self,self.setUpParams{:});
                    set_up(self);
                catch meObj
                    
                    if (nargin == 1)
                        result = default_test_result(self);
                    end
                    add_error(result, self, meObj);
                    result.stop_test(self);
                    return;
                end
                %
                isOk = false;
                try
                    method = self.name;
                    eval([method, '(self);']);
                    isOk = true;
                catch meObj
                    isFailure = ~isempty(strfind(meObj.identifier,...
                        'MLUNITEXT:TESTFAILURE'));
                    if isFailure
                        result.add_failure(self,meObj);
                    else
                        result.add_error(self,meObj);
                    end
                end
                %
                try
                    tear_down(self);
                catch meObj
                    result.add_error(self,meObj);
                    isOk = false;
                end
                %
                if isOk
                    result.add_success(self);
                end
            catch meObj
                baseMeObj=modgen.common.throwerror('internalError',...
                    'Oops, we should not be here');
                newMeObj=baseMeObj.addCause(meObj);
                throw(newMeObj);
            end
            result.stop_test(self);
            
        end
        %
        function set_up_param(~,varargin)
        end
        %
        function runAndCheckError(~,commandStr,expIdentifierList,varargin)
            % RUNANDCHECKERROR executes the specifies command and checks
            % that it throws an exeption with an identifier containing the
            % specified marker
            %
            % Input:
            %   regular:
            %       self:
            %       commandStr: char[1,]/function_handle[1,1] - command to
            %                   execute
            %       expIdentifierList: double[0,0]/char[1,]/...
            %         cell[1,N] of char[1,] - list of of strings
            %           (a single string), containig expected exeption
            %           identifier markers. double[0,0] means that no
            %           identifier match is performed.
            %
            %
            %   optional:
            %       expMsgCodeList: char[1,]/cell[1,N] of char[1,] - list
            %           of strings (a single string),
            %           containig expected exception message
            %           markers. For each field in expIdentifierList supposed
            %           to be one field in expMsgCodeList. In case of more then
            %           one argument in expIdentifierList, if you don't expect
            %           any exception messages, put '' in corresponding
            %           field. double[0,0] means that no identifier match
            %           is performed
            %
            %   properties:
            %       causeCheckDepth: double[1,1] - depth at which causes of
            %          the given exception are checked for matching the
            %          specified patters, default value is 0 (no cause is
            %          checked)
            %
            %       reportStr: char[1,] - report, published upon test
            %           failure
            %
            % $Authors: Peter Gagarinov <pgagarinov@gmail.com>
            % $Date: March-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2012-2013$
            %
            import modgen.common.checkmultvar;
            import modgen.common.throwerror;
            %
            isNoIdentPatternSpec=false;
            if ischar(expIdentifierList)
                expIdentifierList={expIdentifierList};
            elseif isempty(expIdentifierList)
                isNoIdentPatternSpec=true;
            end
            %
            nExpIdentifiers=length(expIdentifierList);
            %
            [reg,isRegSpec,causeCheckDepth,reportStr,~,isRepStrSpec]=...
                modgen.common.parseparext(varargin,...
                {'causeCheckDepth','reportStr';...
                0,'successful execution when failure is expected';...
                'isscalar(x)&&isnumeric(x)','isstring(x)'},...
                [0,1],...
                'regDefList',{[]},...
                'regCheckList',{'iscellstr(x)||isstring(x)'});
            %
            if isRegSpec
                expMsgCodeList=reg{1};
                if ischar(expMsgCodeList)
                    expMsgCodeList={expMsgCodeList};
                end
                isNoMsgPatternSpecVec=false(1,numel(expMsgCodeList));
            else
                isNoMsgPatternSpecVec=true(1,nExpIdentifiers);
                expMsgCodeList=repmat({''},1,nExpIdentifiers);
            end
            nMsgCodes=numel(expMsgCodeList);
            if isNoIdentPatternSpec
                expIdentifierList=repmat({''},1,nMsgCodes);
                isNoIdentPatternSpecVec=true(1,nMsgCodes);
            else
                isNoIdentPatternSpecVec=false(1,nMsgCodes);
            end
            %
            checkmultvar(@(x,y) size(y,2) == 0 || ...
                size(y,2) == size(x,2),2,expIdentifierList,expMsgCodeList);
            %
            try
                if ischar(commandStr)
                    evalin('caller',commandStr);
                else
                    feval(commandStr);
                end
            catch meObj
                [isIdentMatchVec,identPatternStr] =checkCode(meObj,...
                    'identifier',expIdentifierList);
                [isMsgMatchVec,msgPatternStr] =checkCode(meObj,...
                    'message',expMsgCodeList);
                %
                isOk=any((isIdentMatchVec|isNoIdentPatternSpecVec)&...
                    (isMsgMatchVec|isNoMsgPatternSpecVec));
                patternStr=['identifier(',identPatternStr,')',...
                    'message(',msgPatternStr,')'];
                %
                if isRepStrSpec
                    addSuffix=', %s';
                    addArgList={reportStr};
                else
                    addSuffix='';
                    addArgList={};
                end
                    
                mlunitext.assert_equals(true,isOk,...
                    sprintf(...
                    ['\n no match found for pattern %s',...
                    ' exception details: \n %s',addSuffix],...
                    patternStr,errMsg,addArgList{:}));
                return;
            end
            mlunitext.assert_equals(true,false,reportStr);
            function [isMatchVec,patternsStr]=checkCode(inpMeObj,...
                    fieldName,codeList)
                %
                errMsg=modgen.exception.me.obj2hypstr(inpMeObj);
                isMatchVec=cellfun(...
                    @(x)getIsCodeMatch(...
                    inpMeObj,causeCheckDepth,fieldName,x),codeList);
                %
                patternsStr=modgen.string.catwithsep(codeList,', ');
                %
                
            end
            function isPositive=getIsCodeMatch(inpMeObj,checkDepth,...
                    fieldName,codeStr)
                fieldValue = inpMeObj.(fieldName);
                if isempty(fieldValue)
                    isPositive= isempty(codeStr);
                else
                    isPositive=~isempty(strfind(fieldValue,codeStr));
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