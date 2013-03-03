function results=run_tests()
import modgen.configuration.*;
import modgen.configuration.test.*;
%
runner = mlunit.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%

factory=modgen.configuration.test.ConfRepoManagerFactory('plain');
suite_crm = loader.load_tests_from_test_case('modgen.configuration.test.mlunit_test_crm',factory);
suite_crm_cm=loader.load_tests_from_test_case('modgen.configuration.test.mlunit_test_common',factory);
%
factory=modgen.configuration.test.ConfRepoManagerFactory('plainver');
suite_crmver_cm=loader.load_tests_from_test_case('modgen.configuration.test.mlunit_test_common',factory);
suite_crmver = loader.load_tests_from_test_case('modgen.configuration.test.mlunit_test_crmversioned',factory);
%
factory=modgen.configuration.test.ConfRepoManagerFactory('adaptivever');
suite_adaptivecrmver_cm=loader.load_tests_from_test_case('modgen.configuration.test.mlunit_test_common',factory);
suite_adaptivecrmver = loader.load_tests_from_test_case('modgen.configuration.test.mlunit_test_adaptivecrmversioned',factory);
%
factory=modgen.configuration.test.ConfRepoManagerFactory('adaptive');
suite_adaptivecrm_cm=loader.load_tests_from_test_case('modgen.configuration.test.mlunit_test_common',factory);
suite_adaptivecrm = loader.load_tests_from_test_case('modgen.configuration.test.mlunit_test_adaptiveconfrepomgr',factory);
%
factory=modgen.configuration.test.ConfRepoManagerFactory('versioned');
suite_versioned_cm=loader.load_tests_from_test_case('modgen.configuration.test.mlunit_test_common',factory);
suite_versioned = loader.load_tests_from_test_case('modgen.configuration.test.mlunit_test_versionedconfrepomgr',factory);
%
factory=modgen.configuration.test.ConfRepoManagerFactory('inmem');
suite_crm_nostorage = loader.load_tests_from_test_case('modgen.configuration.test.mlunit_test_crm_no_storage',factory);
%
suite_adaptive_negative=loader.load_tests_from_test_case('modgen.configuration.test.mlunit.SuiteNegative');
suite_adaptive_basic=loader.load_tests_from_test_case('modgen.configuration.test.mlunit.SuiteBasic');
%
suite = mlunit.test_suite(horzcat(...
    suite_adaptivecrm.tests,...
    suite_crm.tests,...
    suite_crmver.tests,...
    suite_adaptivecrmver.tests,...
    suite_versioned.tests,...
    suite_adaptivecrm_cm.tests,...
    suite_crm_cm.tests,...
    suite_crmver_cm.tests,...
    suite_adaptivecrmver_cm.tests,...
    suite_versioned_cm.tests,...
    suite_crm_nostorage.tests,...
    suite_adaptive_negative.tests,...
    suite_adaptive_basic.tests));
%
results=runner.run(suite);