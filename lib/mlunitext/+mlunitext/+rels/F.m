classdef F<smartdb.gen.AFieldDefs
    properties(Constant)
    	TEST_RUN_TIME='runTime';
        TEST_RUN_TIME_D='Run time in seconds';
        TEST_RUN_TIME_T={'double'};
        %
        TEST_NAME='testName';
        TEST_NAME_D='Test name';
        TEST_NAME_T={'cell','char'};
        %
        TEST_CASE_NAME='testCaseName';
        TEST_CASE_NAME_D='Test case name';
        TEST_CASE_NAME_T={'cell','char'};
        %
        TEST_MARKER='marker';
        TEST_MARKER_D='Test marker';
        TEST_MARKER_T={'cell','char'};
    end
end
