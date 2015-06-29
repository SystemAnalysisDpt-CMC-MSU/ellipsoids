function SInput=patch_002_save_xml_reports(~,SInput)
SInput.reporting.antXMLReport.isEnabled=true;
SInput.reporting.antXMLReport.dirNameByTheFollowingFile='run_matlab_tests_jenkins.bat';
SInput.reporting.antXMLReport.dirNameSuffix='test-xml-reports';