curLoc=fileparts(mfilename('fullpath'));
testFileName=[curLoc,filesep,'test_file.txt'];
obj=modgen.logging.EmailLogger(...
    %
    % $Author: Peter Gagarinov <pgagarinov@gmail.com> $	$Date: 2012-10-09 $ 
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2012 $
    %
    'emailAttachmentNameList',{testFileName},...
    'subjectSuffix','for trunk_iv_database_1_29 on blue1',...
    'loggerName','IVMetricsCalculator');
obj.sendMessage('calculation started','calculation started');
obj.sendMessage('calculation started');