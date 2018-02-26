% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function [htmlOut,fullFileNameList,reportList]=...
    scanWithHtmlReport(dirList,patternToExclude)
[fullFileNameList,reportList]=...
    modgen.dev.MLintScanner.scan(dirList,...
    patternToExclude);
[~,fileList]=cellfun(@fileparts,fullFileNameList,'UniformOutput',false);
%
%
SHtmlProxyReportVec = [];
name='';
reportName = getString(message(...
    'MATLAB:codetools:reports:CodeAnalyzerReportName'));
%
nFiles=numel(fullFileNameList);
for iFile = 1:nFiles
    %
    SHtmlProxyReportVec(iFile).fileName = fileList{iFile}; %#ok<*AGROW>
    SHtmlProxyReportVec(iFile).fullFileName = fullFileNameList{iFile};
    %
    SHtmlProxyReportVec(iFile).lineNumber = [];
    SHtmlProxyReportVec(iFile).lineMessage = {};
    %
    SMlintProblemVec = reportList{iFile};
    for iProblem = 1:numel(SMlintProblemVec)
        ln = SMlintProblemVec(iProblem).message;
        ln = code2html(ln);
        for iLine = 1:numel(SMlintProblemVec(iProblem).line)
            SHtmlProxyReportVec(iFile).lineNumber(end+1) = ...
                SMlintProblemVec(iProblem).line(iLine);
            SHtmlProxyReportVec(iFile).lineMessage{end+1} = ln;
        end
    end
    %
    % Now sort the list by line number
    if ~isempty(SHtmlProxyReportVec(iFile).lineNumber)
        lineNum = [SHtmlProxyReportVec(iFile).lineNumber];
        lineMsg = SHtmlProxyReportVec(iFile).lineMessage;
        [~, ndx] = sort(lineNum);
        lineNum = lineNum(ndx);
        lineMsg = lineMsg(ndx);
        SHtmlProxyReportVec(iFile).lineNumber = lineNum;
        SHtmlProxyReportVec(iFile).lineMessage = lineMsg;
    end
    
end
%
% Limit the number of messages displayed to keep from being overwhelmed by
% large pathological files.
displayLimit = 500;
%
% Now generate the HTML
help = [getString(message('MATLAB:codetools:reports:MLintReportDescription')) ' '];
doc = 'matlab_env_mlint';
dirListExpr=modgen.cell.cellstr2expression(dirList);
rerunAction = sprintf(...
    'modgen.dev.MLintScanner.scanWithHtmlReport(%s,''%s'')',...
    dirListExpr,patternToExclude);
runOnThisDirAction = 'mlintrpt';
s = internal.matlab.codetools.reports.makeReportHeader(reportName, ...
    help, doc, rerunAction, runOnThisDirAction);

s{end+1} = '<p>';
%
s{end+1} = getString(message(...
    'MATLAB:codetools:reports:ReportForSpecificFolder',name));
%
s{end+1} = '<p>';
%
s{end+1} = '<table cellspacing="0" cellpadding="2" border="0">';
for n = 1:length(SHtmlProxyReportVec)
    encodedFileName = urlencode(SHtmlProxyReportVec(n).fullFileName);
    decodedFileName = urldecode(encodedFileName);
    %
    s{end+1} = '<tr><td valign="top" class="td-linetop">';
    openInEditor = sprintf('edit(''%s'')',decodedFileName);
    regExpRep = sprintf('%s', SHtmlProxyReportVec(n).fileName);
    %
    s{end+1} = ['<a href="matlab:'  openInEditor '">'];
    s{end+1} = sprintf('<span class="mono">');
    s{end+1} = regExpRep;
    s{end+1} = sprintf('</span> </a> </br>');
    %
    if isempty(SHtmlProxyReportVec(n).lineNumber)
        msgStr = ['<span class="soft">' getString(...
            message('MATLAB:codetools:reports:NoMessages')) '</span>'];
    elseif length(SHtmlProxyReportVec(n).lineNumber)==1
        msgStr = ['<span class="warning">' getString(...
            message('MATLAB:codetools:reports:OneMessage')) '</span>'];
    elseif length(SHtmlProxyReportVec(n).lineNumber) < displayLimit
        msgStr = ['<span class="warning">' getString(...
            message('MATLAB:codetools:reports:SpecifiedNumberOfMessages',...
            length(SHtmlProxyReportVec(n).lineNumber))) '</span>'];
    else
        % Truncate the list of messages if there are too many.
        msgStr = ['<span class="warning">' ...
            getString(...
            message('MATLAB:codetools:reports:SpecifiedNumberOfMessages',...
            length(SHtmlProxyReportVec(n).lineNumber))) ...
            '\n<br/>'  ...
            getString(...
            message('MATLAB:codetools:reports:ShowingOnlyFirstAmountOfMessages',...
            displayLimit)) ...
            '</span>'];
    end
    s{end+1} = sprintf('%s</td><td valign="top" class="td-linetopleft">',msgStr);
    %
    if ~isempty(SHtmlProxyReportVec(n).lineNumber)
        for m = 1:min(length(SHtmlProxyReportVec(n).lineNumber),displayLimit)
            
            openMessageLine = sprintf('opentoline(''%s'',%d)',...
                decodedFileName, SHtmlProxyReportVec(n).lineNumber(m));
            %
            lineNum = sprintf('%d', SHtmlProxyReportVec(n).lineNumber(m));
            lineMsg =  sprintf('%s',SHtmlProxyReportVec(n).lineMessage{m});
            %
            s{end+1} = sprintf('<span class="mono">');
            s{end+1} = ['<a href="matlab:' openMessageLine '">'];
            s{end+1} = lineNum;
            s{end+1} = sprintf('</a> ');
            s{end+1} = lineMsg;
            s{end+1} = sprintf('</span> <br/>');
        end
    end
    s{end+1} = '</td></tr>';
end
%
s{end+1} = '</table>';
s{end+1} = '</body></html>';
%
if nargout==0
    sOut = [s{:}];
    web(['text://' sOut],'-noaddressbox');
else
    htmlOut = s;
end
end