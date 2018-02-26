% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function [fileList,reportList]=scan(dirNameList,...
    pathPatternToExclude)
pathList=modgen.io.PathUtils.genPathByRootList(dirNameList,...
    pathPatternToExclude);
%
[reportListOfList,fileListOfList]=cellfun(@(x)scanDir(x),pathList,...
    'UniformOutput',false);
isnEmptyVec=~cellfun('isempty',reportListOfList);
fileListOfList=fileListOfList(isnEmptyVec);
reportListOfList=reportListOfList(isnEmptyVec);
fileList=vertcat(fileListOfList{:});
reportList=vertcat(reportListOfList{:});
if isempty(fileList)
    fileList={};
    reportList={};
end
end
%
function [reportList,localFilenames]=scanDir(dirName)
reportName = getString(message(...
    'MATLAB:codetools:reports:CodeAnalyzerReportName'));
fileList = internal.matlab.codetools.reports.matlabFiles(dirName,...
    reportName);
localFilenames = strcat(dirName,filesep,fileList);
reportList=mlint(localFilenames,'-struct');
%
isnEmptyVec=~cellfun('isempty',reportList);
reportList=reportList(isnEmptyVec);
localFilenames=localFilenames(isnEmptyVec);
end