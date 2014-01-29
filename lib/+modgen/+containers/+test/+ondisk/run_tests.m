function results=run_tests()
import modgen.containers.*;
import modgen.containers.test.*;
%
mapFactory=modgen.containers.test.ondisk.HashMapXMLMetaDataFactory();
suiteOD_HM_VersionedXML=...
    modgen.containers.test.ondisk.build_basic_suite_per_factory(...
    mapFactory,{'verxml'});
%
loader = mlunitext.test_loader;
%
suiteNoStorage=loader.load_tests_from_test_case(...
    'modgen.containers.test.ondisk.mlunit_test_nostorage');
runner = mlunitext.text_test_runner(1, 1);
%
suite=mlunitext.test_suite(horzcat(...
    suiteOD_HM_VersionedXML.tests,...
    suiteNoStorage.tests));
%    
results=runner.run(suite);