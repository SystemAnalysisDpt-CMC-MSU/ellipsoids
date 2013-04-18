function run_helpcollector
import modgen.logging.log4j.Log4jConfigurator;
import modgen.common.throwerror;
logger=Log4jConfigurator.getLogger();

docDirName='doc';
%
texFileName='functions.tex';
newLineSymbol=10;
% TeX settings
font='pcr';
%% obtain full path
curPath=modgen.path.rmlastnpathparts(...
    fileparts(which('elltool.doc.run_helpcollector')),3);
docDirNameCur = [curPath,filesep,docDirName];
%%
resultTexFileName=[docDirNameCur,filesep,texFileName];
if modgen.system.ExistanceChecker.isFile(resultTexFileName)
    delete(resultTexFileName);
end
%
FuncData=elltool.doc.collecthelp({'ellipsoid','hyperplane'},...
    {'elltool'},{'test'});
%
%
nHelpElems=numel(FuncData.funcName);
if nHelpElems==0
    throwerror('wrongDir',...
        sprintf('no elements were collected from %s',curPath));
end
logger.info(sprintf('%d element(s) collected',nHelpElems));
%

isChosenFunc=~(FuncData.isScript);

funcNameCell=FuncData.funcName(isChosenFunc);
helpCell=FuncData.help(isChosenFunc);

% update funcNameCell (delete '.m')
funcNameCell=cellfun(@(x) x(1:end),funcNameCell,'UniformOutput',false);

%% prepare data for output (for tex doc)
% obtain helpCellNew
%
indAccumCell=cellfun(@(x) [0,cumsum(x==newLineSymbol)]+1,helpCell,...
    'UniformOutput',false);
isEmptyHelp=cellfun('isempty',indAccumCell);
%
helpCellNew=helpCell;
helpCellNew(isEmptyHelp)={'%'};
helpCellNew(~isEmptyHelp)=...
    cellfun(@(x,n) accumarray(transpose(n),transpose([x newLineSymbol]),...
    [],@(y) {transpose(['%';y])}),...
    helpCell(~isEmptyHelp),indAccumCell(~isEmptyHelp),'UniformOutput',false);
%
helpCellNew(~isEmptyHelp)=cellfun(@(x) [x{:}],helpCellNew(~isEmptyHelp),...
    'UniformOutput',false);
%
% obtain finalHelpCell
finalHelpCell=helpCellNew;
%

isnSpace=cellfun(@(x) ~isspace(x) | (x==newLineSymbol),helpCellNew,...
    'UniformOutput',false);
%
indFirstAuthorLine=cellfun(@(x,is) regexp(x(is),'\$Author'),...
    helpCellNew,isnSpace,'UniformOutput',false);

isExistAuthorLine=cellfun(@(x) ~isempty(x),indFirstAuthorLine);
finalHelpCell(isExistAuthorLine)=cellfun(@(x,ind,is)...
    x(1:max(find(is,ind(1),'first'))-1),...
    finalHelpCell(isExistAuthorLine),indFirstAuthorLine(isExistAuthorLine),...
    isnSpace(isExistAuthorLine),'UniformOutput',false);

finalHelpCell = cellfun(@(x)fDeletePercent(x),finalHelpCell, ...
    'UniformOutput', false);

finalHelpCell = cellfun(@(x)fShiftText(x),finalHelpCell, ...
    'UniformOutput', false);
funcOutputCell=funcNameCell;
%% substitutions (for TeX requirements)
symbList={'\','_','&'};
substList={'/','\_','\&'};
%
symbListHelp={};
substListHelp={};
for iSymb=1:length(symbList)
    funcOutputCell=strrep(funcOutputCell,symbList{iSymb},substList{iSymb});
    funcNameCell=strrep(funcNameCell,symbList{iSymb},substList{iSymb});
end
%
for iSymb=1:length(symbListHelp)
    finalHelpCell=cellfun(@(x) strrep(x,symbListHelp{iSymb},substListHelp{iSymb}),...
        finalHelpCell,'UniformOutput',false);
end

%% create tex doc
%
fid = fopen(resultTexFileName, 'wt');
% section 'List of all functions'
fprintf(fid,'\\section{List of all functions}\n');
fprintf(fid,'\\begin{enumerate}\n');
for idx=1:length(funcOutputCell)
    fprintf(fid,'\\item {%s}\n',funcOutputCell{idx});
    fprintf(fid,'\\fontfamily{%s}\n',font);
    fprintf(fid,'\\selectfont\n');
    fprintf(fid,'\\begin{lstlisting}\n');
    fprintf(fid,'%s\n',finalHelpCell{idx});
    fprintf(fid,'\\end{lstlisting}\n');
    fprintf(fid,'\\fontfamily{\\familydefault}\n');
    fprintf(fid,'\\selectfont\n');
end
fprintf(fid,'\\end{enumerate}\n');
% close file
fclose(fid);
logger.info(sprintf('Job completed, the result is written to \n%s',...
    resultTexFileName));
end

function result = fDeletePercent(str)
result = regexprep(str, '(\%)', '');
end

function result = fShiftText(text)
text = regexprep(text, '\t', '    ');
lines = regexp(text,'\n','split');
nLines = numel(lines);
spaceCount = zeros(nLines, 1);
linesForShift = false(nLines, 1);
for iElem = 1:nLines
    ind = find(lines{iElem} ~= ' ', 1, 'first');
    if isempty(ind)
       lines{iElem} = '';
       spaceCount(iElem) = 0;
       linesForShift(iElem) = false;
    else
       spaceCount(iElem) = ind - 1;
       linesForShift(iElem) = true;
    end
end
if any(linesForShift)
    m = min(spaceCount(linesForShift));
    for iElem = find(linesForShift).'
        lines{iElem} = lines{iElem}(m+1:end);
    end
end
nl = repmat({'\n'}, 1, nLines);
lines = [lines; nl];
result = sprintf(strcat(lines{:}));
end
