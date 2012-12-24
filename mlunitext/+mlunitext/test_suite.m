classdef test_suite<mlunit.test_suite
    %TEST_SUITE_EXTENDED Summary of this class goes here
    %   Detailed explanation goes here
    properties (Access=private,Hidden)
        nParallelProcesses
        hExecFunc
        parallelConfiguration
        parallelMode='blockBased'
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
        function self = test_suite(varargin)
            % TEST_SUITE constructor
            %
            % Input:
            %   optional:
            %     tests: object[,1] - test_case objects. When omitted, an
            %       empty suite is constructed
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
                            error([upper(mfilename),':wrongInput'],...
                                'marker is expected to be a string');
                        end
                        isMarkerSet=true;
                    case 'nparallelprocesses',
                        nProcesses=prop{iProp+1};
                    case 'parallelmode',
                        parMode=prop{iProp+1};
                        if ~(ischar(parMode)&&modgen.common.isrow(parMode))
                            error([upper(mfilename),':wrongInput'],...
                                'parMode is expected to be a string');
                        end
                        if ~any(strcmpi(parMode,...
                            {'blockBased','queueBased'}))
                            error([upper(mfilename),':wrongInput'],...
                                'parallel mode %s is not supported',...
                                parMode);
                        end
                    case 'hexecfunc'
                        evalFh = prop{iProp+1};
                        if ~isscalar(evalFh) ...
                                || ~isa(evalFh, 'function_handle')
                            error([upper(mfilename),':wrongInput'], ...
                                'Invalid size or type of %s', prop{iProp});
                        end
                    case 'parallelconfiguration'
                        parConf = prop{iProp+1};
                        if ~ischar(parConf)
                            error([upper(mfilename),':wrongInput'], ...
                                'Invalid type of %s', prop{iProp});
                        end
                end
            end
            self=self@mlunit.test_suite(reg{:});
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
        end
        %
        function result = run(self, result)
            %test_suite.run executes the test suite and saves the results 
            %in result.
            %
            %  Example:
            %    Running a test suite is done the same way as a single 
            %    test. 
            %         suite = ...; % Create test suite, e.g. with test_loader.
            %         result = test_result;
            %         [suite, result] = run(suite, result);
            %         summary(result)
            %
            %  See also MLUNIT.TEST_SUITE.

            if (get_should_stop(result))
                return;
            end;
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
                    error([upper(mfilename),':wrongInput'],...
                        'Oops, we shouldn''t be here');
            end
            %
            nBlocks=ceil(nTests/blockLen);
            suiteCVec=cell(1,nBlocks);
            resultCVec=repmat({feval(class(result),result)},1,nBlocks);
            mlunit.logprintf('debug',...
                '===== START suite [%s] with %d test(s), %d parallel block(s)', ...
                self.str(), nTests, nBlocks);
            for iTest=1:blockLen:nTests,
                curInd=iTest:min(iTest+blockLen-1,nTests);
                suiteCVec{fix((iTest-1)/blockLen)+1}=...
                    mlunit.test_suite(self,self.tests(curInd));
            end
            parConfProps={'clusterSize',self.nParallelProcesses};
            if ischar(self.parallelConfiguration)
                parConfProps = [parConfProps,...
                    {'configuration', self.parallelConfiguration}];
            end
            resultCVec=feval(self.hExecFunc,'run',suiteCVec,resultCVec,parConfProps{:});
            mlunit.logprintf('debug','===== END   suite [%s]', ...
                self.str());
            result=result.union_test_results(resultCVec{:});
        end
    end
end