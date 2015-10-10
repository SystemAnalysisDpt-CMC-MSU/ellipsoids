classdef mlunit_test_savexml < mlunitext.test_case
    % MLUNIT_TEST_SAVEXML Tests method saveXMLReport in test_result
    % 
    % Two mock test cases with several test methods in each are included in
    % a result array. Some tests are grouped in one result, others are
    % added separately. Some results receive different markers and some
    % don't. Two tests check the method's behavior with and without
    % consolidation of marked results.
    %
    % The test creates a temporary subdirectory in the system temporary
    % directory, where report files are saved. At the end of each test the
    % temporary directory is deleted.
    %
    % Created by Dmitry Epstein, Allied Testing Limited (2015/06/30)
    
    properties (Access=private)
        tempDirName
    end
    %%
    methods
        function self=mlunit_test_savexml(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function set_up(self)
            self.tempDirName=...
                modgen.test.TmpDataManager.getDirByCallerKey();
        end
        function tear_down(self)
            modgen.io.rmdir(self.tempDirName,'s');
        end
        function testSaveXmlReportWithConsolidation(self)
            self.runTestSaveXmlReport(true);
        end
        function testSaveXmlReportWithoutConsolidation(self)
            self.runTestSaveXmlReport(false);
        end
        function runTestSaveXmlReport(self,isConsolidateMarkedResults)
            runner = mlunitext.text_test_runner(1, 1);
            loader = mlunitext.test_loader();
            % First test case: mlunit_test.mock_test
            % All tests are marked with 'AAA'
            suite = loader.load_tests_from_test_case(...
                'mlunit_test.mock_test','marker','AAA');
            results = runner.run(suite,...
                'isConsolidateMarkedResults',isConsolidateMarkedResults);
            % Second test case: mlunit_test.mock_sec_test
            % Some tests marked with 'AAA', some with 'BBB', some unmarked
            tests{1} = mlunit_test.mock_sec_test('test_method');
            tests{2} = mlunit_test.mock_sec_test('test_broken_method');
            suite = mlunitext.test_suite(tests,'marker','AAA');
            results = [results,runner.run(suite,...
                'isConsolidateMarkedResults',isConsolidateMarkedResults)];
            test = mlunit_test.mock_sec_test('test_method_no_return');
            test.set_marker('AAA');
            results = [results,runner.run(test,...
                'isConsolidateMarkedResults',isConsolidateMarkedResults)];
            test = mlunit_test.mock_sec_test('test_sec_fail_method');
            test.set_marker('BBB');
            results = [results,runner.run(test,...
                'isConsolidateMarkedResults',isConsolidateMarkedResults)];
            test = mlunit_test.mock_sec_test('test_sec_broken_method');
            results = [results,runner.run(test,...
                'isConsolidateMarkedResults',isConsolidateMarkedResults)];
            results.saveXMLReport(self.tempDirName);
            % Analyze test reports
            % mlunit_test.mock_test
            StTestInfo=self.getTestInfo(getReportFileName(...
                'mlunit_test.mock_test','AAA'));
            mlunitext.assert_equals(getReportClassName(...
                'mlunit_test.mock_test','AAA'),StTestInfo.name);
            mlunitext.assert_equals(3,StTestInfo.nTests);
            mlunitext.assert_equals(1,StTestInfo.nErrors);
            mlunitext.assert_equals(0,StTestInfo.nFailures);
            mlunitext.assert_equals('pass',StTestInfo.tests(...
                getReportTestName('test_method','AAA')).status);
            mlunitext.assert_equals('pass',StTestInfo.tests(...
                getReportTestName('test_method_no_return','AAA')).status);
            mlunitext.assert_equals('error',StTestInfo.tests(...
                getReportTestName('test_broken_method','AAA')).status);
            % mlunit_test.mock_sec_test
            % With consolidation all results are in one file. Without
            % consolidation there should be 3 files: one without a marker,
            % one [AAA] and one [BBB]
            StTestInfo=self.getTestInfo(getReportFileName(...
                'mlunit_test.mock_sec_test',''));
            mlunitext.assert_equals(getReportClassName(...
                'mlunit_test.mock_sec_test',''),StTestInfo.name);
            if isConsolidateMarkedResults
                mlunitext.assert_equals(5,StTestInfo.nTests);
                mlunitext.assert_equals(2,StTestInfo.nErrors);
                mlunitext.assert_equals(1,StTestInfo.nFailures);
            else
                mlunitext.assert_equals(1,StTestInfo.nTests);
                mlunitext.assert_equals(1,StTestInfo.nErrors);
                mlunitext.assert_equals(0,StTestInfo.nFailures);
            end
            testResult=StTestInfo.tests(...
                getReportTestName('test_sec_broken_method',''));
            mlunitext.assert_equals('error',testResult.status);
            mlunitext.assert_equals(sprintf(['Error: one\ntwo\nthree, ',...
                'Identifier: mlunit:test:mockError']),testResult.message);
            if ~isConsolidateMarkedResults
                StTestInfo=self.getTestInfo(getReportFileName(...
                    'mlunit_test.mock_sec_test','AAA'));
                mlunitext.assert_equals(getReportClassName(...
                    'mlunit_test.mock_sec_test','AAA'),StTestInfo.name);
                mlunitext.assert_equals(3,StTestInfo.nTests);
                mlunitext.assert_equals(1,StTestInfo.nErrors);
                mlunitext.assert_equals(0,StTestInfo.nFailures);
            end
            mlunitext.assert_equals('pass',StTestInfo.tests(...
                getReportTestName('test_method','AAA')).status);
            mlunitext.assert_equals('pass',StTestInfo.tests(...
                getReportTestName('test_method_no_return','AAA')).status);
            mlunitext.assert_equals('error',StTestInfo.tests(...
                getReportTestName('test_broken_method','AAA')).status);
            if ~isConsolidateMarkedResults
                StTestInfo=self.getTestInfo(getReportFileName(...
                    'mlunit_test.mock_sec_test','BBB'));
                mlunitext.assert_equals(getReportClassName(...
                    'mlunit_test.mock_sec_test','BBB'),StTestInfo.name);
                mlunitext.assert_equals(1,StTestInfo.nTests);
                mlunitext.assert_equals(0,StTestInfo.nErrors);
                mlunitext.assert_equals(1,StTestInfo.nFailures);
            end
            testResult=StTestInfo.tests(...
                getReportTestName('test_sec_fail_method','BBB'));
            mlunitext.assert_equals('failure',testResult.status);
            mlunitext.assert_equals(sprintf('one\ntwo\nthree'),...
                testResult.message);
            %
            function fullName=getNameWithMarker(name,marker)
                if isempty(marker)
                    fullName=name;
                else
                    fullName=[name,'[',marker,']'];
                end
            end
            function fileName=getReportFileName(testClassName,marker)
                if isConsolidateMarkedResults
                    fileName=[testClassName,'.xml'];
                else
                    fileName=[getNameWithMarker(testClassName,marker),'.xml'];
                end
            end
            function fullName=getReportClassName(testClassName,marker)
                if isConsolidateMarkedResults
                    fullName=testClassName;
                else
                    fullName=getNameWithMarker(testClassName,marker);
                end
            end
            function fullName=getReportTestName(testName,marker)
                if isConsolidateMarkedResults
                    fullName=getNameWithMarker(testName,marker);
                else
                    fullName=testName;
                end
            end
        end
    end
    %%
    methods (Access=protected,Static)
        function nodeList=getNodes(doc,nodeName)
            nodeList=doc.getElementsByTagName(nodeName);
            if isempty(nodeList)
                error('Invalid or missing node: %s',nodeName);
            end
        end
        function node=getFirstNode(doc,nodeName)
            nodeList=mlunitext.test.mlunit_test_savexml.getNodes(doc,nodeName);
            node=nodeList.item(0);
        end
        function varargout=getNodeAttributes(node,varargin)
            attrMap=node.getAttributes();
            attr=cellfun(@(x)attrMap.getNamedItem(x),varargin,...
                'UniformOutput',false);
            isMissing=cellfun(@isempty,attr);
            if any(isMissing)
                error('Node %s is missing attributes %s',...
                    char(node.getNodeName()),...
                    sprintf('%s ',varargin(isMissing)));
            end
            varargout=cellfun(@(x)char(x.getTextContent()),attr,...
                'UniformOutput',false);
        end
    end
    methods (Access=protected)
        function StTestInfo=getTestInfo(self,reportFileName)
            doc=xmlread(fullfile(self.tempDirName,reportFileName));
            suiteNode=self.getFirstNode(doc,'testsuite');
            [StTestInfo.name,StTestInfo.nTests,StTestInfo.nErrors,...
                StTestInfo.nFailures]=self.getNodeAttributes(suiteNode,...
                'name','tests','errors','failures');
            StTestInfo.nTests=str2double(StTestInfo.nTests);
            StTestInfo.nErrors=str2double(StTestInfo.nErrors);
            StTestInfo.nFailures=str2double(StTestInfo.nFailures);
            testNodes=self.getNodes(doc,'testcase');
            StTestInfo.tests=containers.Map('KeyType','char','ValueType','any');
            for iTest=0:testNodes.getLength()-1
                test=testNodes.item(iTest);
                testName=self.getNodeAttributes(test,'name');
                testResult=struct('status','pass','message','');
                subnodes=test.getChildNodes();
                for iNode=0:subnodes.getLength()-1
                    node=subnodes.item(iNode);
                    nodeName=char(node.getNodeName());
                    switch(nodeName)
                        case '#text'
                            % do nothing
                        case {'error','failure'}
                            testResult.status=nodeName;
                            testResult.message=self.getNodeAttributes(node,'message');
                            break;
                        otherwise
                            error('Node %s is not expected at this point',nodeName);
                    end
                end
                StTestInfo.tests(testName)=testResult;
            end
        end
    end
end

