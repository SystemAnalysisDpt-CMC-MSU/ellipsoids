classdef test_suite<handle
    % The class test_suite is a composite class to run multiple tests. A
    % test suite is created as follows:
    %
    %  Example:
    %         suite = test_suite;
    %         suite = add_test(suite, my_test('test_foo'));
    %         suite = add_test(suite, my_test('test_bar'));
    %  or
    %         loader = test_loader;
    %         suite = test_suite(load_tests_from_test_case(loader, 'my_test'));
    %
    %  Running a test suite is done the same way as a single test. Example:
    %         result = test_result;
    %         [suite, result] = run(suite, result);
    %         getReport(result)
    %
    %  See also MLUNIT.TEST_CASE, MLUNIT.TEST_LOADER, MLUNIT.TEST_RESULT.
    %
    % $Authors: Peter Gagarinov <pgagarinov@gmail.com>
    % $Date: March-2013 $
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2012-2013$
    %
    properties (Access=private,Hidden)
        nParallelProcesses
        hExecFunc
        parallelConfiguration
        parallelMode='blockBased'
    end
    %
    properties (Access=private)
        confRepoMgr = [];
        hConfFunc = [];
    end
    
    properties (SetAccess=protected,GetAccess=public)
        tests = {};
        name = '';
        % The marker property is needed so that suites can be treated like
        % tests when they are part of another suite
        marker = '';
    end
    %
    methods (Static)
        function suite=fromTestCaseNameList(testCaseNameList,...
                testCaseConstrArgList)
            % FROMTESTCASENAMELIST creates a test suite from the test cases
            % specified by name
            %
            % Input:
            %   regular:
            %       self:
            %       testCaseNameList: cell[1,nTestCases] of char[1,] - list
            %           of test case names
            %   optional:
            %       testCaseConstrArgList: any[1,] - an arbitrary list of
            %           arguments passed into a test case constructor.
            %
            import modgen.common.type.simple.checkcellofstr;
            import modgen.common.throwerror;
            checkcellofstr(testCaseNameList);
            loaderObj = mlunitext.test_loader;
            nTestCases=length(testCaseNameList);
            if nargin<2
                testCaseConstrArgList={};
            end
            if nTestCases<1
                throwerror('wrongInput',...
                    'at least one test case name is expected');
            end
            suite = loaderObj.load_tests_from_test_case(...
                testCaseNameList{1},testCaseConstrArgList{:});
            %
            for iTestCase=2:nTestCases
                suite.add_test(loaderObj.load_tests_from_test_case(...
                    testCaseNameList{iTestCase},testCaseConstrArgList{:}));
            end
        end
    end
    methods
        function set.tests(self,value)
            % SET.TESTS puts a list of test suites or test cases into the
            % suite
            %
            % Input:
            %   regular:
            %       self:
            %       value: cell[1,] of
            %           mlunitext.test_suite1[1,1]/mlunitext.test_case[1,1] -
            %           list of test suites or test cases to inject into
            %           the suite
            
            if ~all(cellfun(@(x)isa(x,'mlunitext.test_case'),value)|...
                    cellfun(@(x)isa(x,'mlunitext.test_suite'),value))
                throwerror('wrongInput',...
                    ['tests property can only contain ',...
                    'test_case and test_suite class objects']);
            end
            self.tests=value;
        end
        function self = test_suite(varargin)
            % TEST_SUITE constructor
            %
            % Input:
            %   optional:
            %     tests: cell[1,] of object[,1] - test_case objects.
            %       When omitted, an empty suite is constructed
            %
            %   properties:
            %     nParallelProcesses: double[1,1] - the number of parallel
            %       processes to use for test execution (default = 1, i.e.
            %       use the current process only)
            %
            %     hExecFunc: function_handle[1,1] - function that the RUN
            %       method will call in order to run tests in parallel (see
            %       modgen.pcalc.auxdfeval)
            %
            %     parallelMode: char[1,] - defines how the tests are
            %       partitioned across multiple parallel processes
            %           'blockBased' - tests are evenly broken into blocks
            %              which are then run in parallel processes
            %           'queueBased' - tests are fed to parallel processing
            %              units one by one, if some test is completed
            %              sooner, the parallel processing block is used to
            %              process a next test from a test queue
            %     marker: char[1,] - marker for the tests,
            %       it is displayed in the messages indicating start and
            %           end of test runs
            %
            % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
            % Faculty of Computational Mathematics and Cybernetics, System Analysis
            % Department, 7-October-2012, <pgagarinov@gmail.com>$
            %
            [reg,prop]=modgen.common.parseparams(varargin,...
                {'nParallelProcesses','hExecFunc',...
                'parallelConfiguration','parallelMode','marker'});
            %
            nemptyIndsVec = ~cellfun(@isempty, reg);
            if ~all(nemptyIndsVec)
                reg = reg(nemptyIndsVec);
            end
            %
            nProp=length(prop);
            nProcesses=1;
            evalFh = @mlunitext.pcalc.auxdfeval;
            parConf = [];
            parMode=[];
            isMarkerSet=false;
            %
            for iProp=1:2:nProp-1
                switch lower(prop{iProp})
                    case 'marker',
                        markerStr=prop{iProp+1};
                        if ~(ischar(markerStr)&&...
                                modgen.common.isrow(markerStr))
                            throwerror('wrongInput',...
                                'marker is expected to be a string');
                        end
                        isMarkerSet=true;
                    case 'nparallelprocesses',
                        nProcesses=prop{iProp+1};
                    case 'parallelmode',
                        parMode=prop{iProp+1};
                        if ~(ischar(parMode)&&modgen.common.isrow(parMode))
                            throwerror('wrongInput',...
                                'parMode is expected to be a string');
                        end
                        if ~any(strcmpi(parMode,...
                                {'blockBased','queueBased'}))
                            throwerror('wrongInput',...
                                'parallel mode %s is not supported',...
                                parMode);
                        end
                    case 'hexecfunc'
                        evalFh = prop{iProp+1};
                        if ~isscalar(evalFh) ...
                                || ~isa(evalFh, 'function_handle')
                            throwerror('wrongInput', ...
                                'Invalid size or type of %s', prop{iProp});
                        end
                    case 'parallelconfiguration'
                        parConf = prop{iProp+1};
                        if ~ischar(parConf)
                            throwerror('wrongInput', ...
                                'Invalid type of %s', prop{iProp});
                        end
                end
            end
            additionalParse(reg{:});
            self.nParallelProcesses=nProcesses;
            self.hExecFunc = evalFh;
            self.parallelConfiguration = parConf;
            %
            if ~isempty(parMode)
                self.parallelMode=parMode;
            end
            if isMarkerSet
                self.set_marker(markerStr);
            end
            function additionalParse(varargin)
                % TEST_SUITE constructor
                %
                % Case#1: Regular constructor:
                % Input:
                %   optional:
                %     tests: cell[1,] of mlunitext.test_suite/
                %           mlunitext.test_suite[1,1] - test_case objects. When
                %           omitted, an empty suite is constructed
                %   properties:
                %     confRepoMgr: object[1,1] - a ConfRepoManager instance,
                %       used in some applications for configuring a logger (see
                %       hConfFunc)
                %     hConfFunc: function_handle[1,1] - function that the RUN
                %       method will call in order to configure a logger. It
                %       will be passed confRepoMgr as a parameter. Either both
                %       or neither hConfFunc and confRepoMgr should be given.
                %
                % Case#2: Copy constructor:
                % Input:
                %   regular:
                %     testSuite: mlunitext.test_suite[1,1] - an instance of
                %       mlunitext.test_suite
                %   optional:
                %     tests: cell[1,] of mlunitext.test_suite/
                %           mlunitext.test_suite[1,1] - test_case objects. If
                %       specified, these tests are assigned to the copy suite,
                %       instead of the tests in the original suite
                %
                % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
                % Faculty of Computational Mathematics and Cybernetics, System Analysis
                % Department, 7-October-2012, <pgagarinov@gmail.com>$
                %
                import modgen.common.throwerror;
                [reg,prop]=modgen.common.parseparams(varargin);
                nReg = length(reg);
                nProp=length(prop);
                if nReg > 0 && nReg < 3 && isa(reg{1}, class(self))
                    %% Copy constructor
                    %
                    if nProp > 0
                        throwerror('wrongInput', ...
                            'Copy constructor does not take any properties');
                    end
                    testSuite = reg{1};
                    if nReg > 1
                        self.tests = reg{2};
                        checkTests('Invalid size or type of parameter #2');
                    else
                        self.tests = testSuite.tests;
                    end
                    self.name = testSuite.name;
                    self.confRepoMgr = testSuite.confRepoMgr;
                    self.hConfFunc = testSuite.hConfFunc;
                else
                    %% Regular constructor
                    %
                    if (nReg == 0)
                        self.tests = cell(0,1);
                    elseif nReg == 1
                        self.tests = reg{1};
                        checkTests('Invalid size or type of parameter #1');
                    else
                        throwerror('wrongInput', ...
                            'Too many regular arguments');
                    end;
                    %
                    for iProp=1:2:nProp-1,
                        switch lower(prop{iProp})
                            case 'confrepomgr',
                                self.confRepoMgr=prop{iProp+1};
                                if ~isscalar(self.confRepoMgr) ...
                                        || ~isa(self.confRepoMgr, ...
                                        'modgen.configuration.ConfRepoManager')
                                    throwerror('wrongInput', ...
                                        'Invalid size or type of %s',...
                                        prop{iProp});
                                end
                            case 'hconffunc',
                                self.hConfFunc=prop{iProp+1};
                                if ~isscalar(self.hConfFunc) ...
                                        || ~isa(self.hConfFunc,...
                                        'function_handle')
                                    throwerror('wrongInput', ...
                                        'Invalid size or type of %s',...
                                        prop{iProp});
                                end
                            otherwise
                                throwerror('wrongInput', ...
                                    'Unknown property: %s', prop{iProp});
                        end
                    end
                    if isempty(self.confRepoMgr) && ~isempty( self.hConfFunc) ...
                            || ~isempty(self.confRepoMgr) &&...
                            isempty( self.hConfFunc)
                        throwerror('wrongInput', ...
                            ['Either none or both confRepoMgr ',...
                            'and hConfFunc should be specified']);
                    end
                    % Default configuration
                    if isempty(self.hConfFunc)
                        self.hConfFunc = @(x)modgen.logging.log4j.Log4jConfigurator.configureSimply;
                    end
                end
                %
                %
                function checkTests(msg)
                    if ~iscell(self.tests) || ~isvector(self.tests) ...
                            || ~isempty(self.tests) &&...
                            ~all(cellfun(@(x)(isa(x,'mlunitext.test_case')||...
                            isa(x,'mlunitext.test_suite')),self.tests))
                        throwerror('wrongInput', msg);
                    end
                end
            end
        end
        function add_test(self, test)
            % ADD_TEST adds a test to the test suite. If test is empty,
            % nothing is done.
            %
            % Input:
            %   regular:
            %       self:
            %       test: mlunitext.test_case[1,1] /mlunitext.test_suite[1,1] -
            %           source of added tests
            %
            % Example:
            %         suite = test_suite;
            %         suite = add_test(suite, my_test('test_foo'));
            %         suite = add_test(suite, my_test('test_bar'));
            %         count_test_cases(suite); % Should return 2.
            %
            %  See also MLUNITEXT.TEST_SUITE.
            
            if (~isempty(test))
                self.tests{length(self.tests) + 1} = test;
            end;
        end
        
        function add_tests(self, tests)
            % ADD_TEST adds a cell array of tests to the test
            % suite.
            %
            % Example:
            %         suite = test_suite;
            %         suite = add_tests(suite, {my_test('test_foo') ...
            %             my_test('test_bar')});
            %         count_test_cases(suite); % Should return 2.
            %
            %  See also MLUNITEXT.TEST_SUITE.
            %
            modgen.common.type.simple.checkgen(tests,'iscell(x)');
            self.tests = [self.tests,tests];
        end
        function count = count_test_cases(self)
            % COUNT_TEST_CASES returns the number of test cases
            % executed by run.
            %
            % Example:
            %   suite = mlunit_all_tests;
            %   count_test_cases(test);
            %
            % See also MLUNITEXT.TEST_SUITE, MLUNITEXT.TEST_CASE.
            
            nTests = length(self.tests);
            count = 0;
            for i = 1:nTests
                count = count + count_test_cases(self.tests{i});
            end;
        end
        function result=run(self, result)
            %test_suite.run executes the test suite and saves the results
            %in result.
            %
            %  Example:
            %    Running a test suite is done the same way as a single
            %    test.
            %         suite = ...; % Create test suite, e.g. with test_loader.
            %         result = test_result;
            %         [suite, result] = run(suite, result);
            %         getReport(result)
            %
            %  See also MLUNITEXT.TEST_SUITE.
            nTests=length(self.tests);
            if nTests==0,
                return;
            end
            switch lower(self.parallelMode)
                case 'blockbased',
                    blockLen=ceil(nTests/self.nParallelProcesses);
                case 'queuebased',
                    blockLen=1;
                otherwise,
                    throwerror('wrongInput','Oops, we shouldn''t be here');
            end
            %
            nBlocks=ceil(nTests/blockLen);
            suiteCVec=cell(1,nBlocks);
            resultCVec=repmat({feval(class(result),result)},1,nBlocks);
            mlunitext.logprintf('debug',...
                '===== START suite [%s] with %d test(s), %d parallel block(s)', ...
                self.str(), nTests, nBlocks);
            for iTest=1:blockLen:nTests,
                curInd=iTest:min(iTest+blockLen-1,nTests);
                suiteCVec{fix((iTest-1)/blockLen)+1}=...
                    mlunitext.test_suite(self,self.tests(curInd));
            end
            parConfProps={'clusterSize',self.nParallelProcesses};
            if ischar(self.parallelConfiguration)
                parConfProps = [parConfProps,...
                    {'configuration', self.parallelConfiguration}];
            end
            resultCVec=feval(self.hExecFunc,'runInternal',suiteCVec,...
                resultCVec,parConfProps{:});
            mlunitext.logprintf('debug','===== END   suite [%s]', ...
                self.str());
            result.union_test_results(resultCVec{:});
        end
        %
        function result = runInternal(self, result)
            % RUN executes the test suite and saves the results
            % in result.
            %
            % Input:
            %   self:
            %   result: mlunitext.test_result[1,1] - destination object for
            %   the test results
            %
            % Example:
            %    Running a test suite is done the same way as a single
            %    test.
            %       suite = ...; % Create test suite, e.g. with test_loader.
            %       result = test_result;
            %       [suite, result] = run(suite, result);
            %       getReport(result)
            %
            %  See also MLUNITEXT.TEST_SUITE.
            
            feval(self.hConfFunc, self.confRepoMgr);
            %
            nTests = length(self.tests);
            mlunitext.logprintf('debug', '==== START suite [%s] with %d tests', ...
                self.str(), nTests);
            for i = 1:nTests
                result = run(self.tests{i}, result);
            end;
            mlunitext.logprintf('debug', '====  END  suite [%s]', self.str());
        end
        
        function set_name(self, name)
            % SET_NAME sets an optional name for the test suite.
            %  The name is used by gui_test_runner to re-run a test_suite,
            %  which is created by an .m-file.
            %
            % Input:
            %   regular:
            %       self:
            %       name: char[1,] - name of the suite
            %
            %  Example:
            %         function suite = all_tests
            %
            %         suite = test_suite;
            %         suite = set_name(suite, 'all_tests');
            %         suite = add_test(suite, my_test('test_foo'));
            %         suite = add_test(suite, my_test('test_bar'));
            
            self.name = name;
        end
        
        function set_marker(self, marker)
            % MARK_TESTS marks all constituent tests with the
            % same marker
            %
            % Input:
            %   regular:
            %       self:
            %       marker: char[1,] - marker
            %
            cellfun(@(x)x.set_marker(marker), self.tests);
        end
        %
        function s = str(self)
            % STR returns a string with the name of the test
            % suite. The name has to be set with SET_DISPLAY_NAME method
            % first.
            %
            % Example:
            %   str(mlunit_all_tests)
            
            if ~isempty(self.name)
                s = self.name;
            else
                % Concatenate all unique class-name/marker pairs from the
                % constituent tests
                testClassCVec = cellfun(@class, self.tests,...
                    'UniformOutput', false);
                testMarkerCVec = cellfun(@(x)x.marker, self.tests,...
                    'UniformOutput', false);
                isEmptyMarker = cellfun(@isempty, testMarkerCVec);
                testMarkerCVec(~isEmptyMarker) = cellfun(@(x)['[',x,']'],...
                    testMarkerCVec(~isEmptyMarker), 'UniformOutput', false);
                testNameCVec = cellfun(@(x,y)[x,y], testClassCVec,...
                    testMarkerCVec,'UniformOutput', false);
                s = modgen.string.catwithsep(sort(unique(testNameCVec)),...
                    '|' );
            end
        end
        %
        function newSuiteObj=getCopyFiltered(self,markerRegExp,...
                testCaseRegExp,testNameRegExp)
            % GETCOPYFILTERED makes a copy of the suite keeping the
            %   tests based on specified filters for markers, test cases and
            %   tests names
            %
            % Input:
            %   optional:
            %       markerRegExp: char[1,] - regexp for marker AND/OR configuration
            %           names, default is '.*' which means 'all cofigs'
            %       testCaseRegExp: char[1,] - regexp for test case names, same default
            %       testRegExp: char[1,] - regexp for test names, same default
            %
            %
            % Output:
            %   results: mlunitext.text_test_run[1,1] - test result
            %
            % $Authors: Peter Gagarinov <pgagarinov@gmail.com>
            % $Date: March-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational Mathematics
            %             and Computer Science,
            %             System Analysis Department 2012-2013$
            %
            import modgen.logging.log4j.Log4jConfigurator;
            DISP_VERT_SEP_STR='--------------------------';
            %
            if nargin<4
                testNameRegExp='.*';
                if nargin<3
                    testCaseRegExp='.*';
                    if nargin<2
                        markerRegExp='.*';
                    end
                end
            end
            logger=Log4jConfigurator.getLogger();
            testList = self.tests;
            %
            isTestCaseMatchVec=isMatchTest(@class,testList,testCaseRegExp);
            isTestNameMatchVec=isMatchTest(@(x)x.name,testList,...
                testNameRegExp);
            isMarkerMatchVec=isMatchTest(@(x)x.marker,testList,...
                markerRegExp);
            isMatchVec=isTestCaseMatchVec&isTestNameMatchVec&...
                isMarkerMatchVec;
            %
            testList=testList(isMatchVec);
            testNameList=cellfun(@(x)x.str(),testList,'UniformOutput',...
                false);
            testNameStr=modgen.string.catwithsep(testNameList,...
                sprintf('\n'));
            logMsg=sprintf('\n Number of found tests %d\n%s\n%s\n%s',...
                numel(testList),DISP_VERT_SEP_STR,testNameStr,...
                DISP_VERT_SEP_STR);
            %
            logger.info(logMsg);
            newSuiteObj = mlunitext.test_suite(testList);
            function isPosVec=isMatchTest(fGetProp,testList,regExpStr)
                isPosVec=isMatch(cellfun(fGetProp,testList,...
                    'UniformOutput',false),regExpStr);
            end
            function isPosVec=isMatch(tagList,regExpStr)
                isPosVec=~cellfun(@isempty,...
                    regexp(tagList,regExpStr,'emptymatch'));
            end
        end
    end
end