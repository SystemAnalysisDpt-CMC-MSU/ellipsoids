function listconf()
%LISTCONF - gives a list of existing configurations
%
%No input or output, just displays list of configuration
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    
%$Date: 2012-11-17 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2012 $
%
import elltool.logging.Log4jConfigurator;
logger=Log4jConfigurator.getLogger();

confRepoMgr=elltool.conf.Properties.getConfRepoMgr();
confList=confRepoMgr.getConfNameList();
logger.info([sprintf('%s, ',confList{1:end-1}), confList{end}]);