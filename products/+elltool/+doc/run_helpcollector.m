function run_helpcollector
import modgen.logging.log4j.Log4jConfigurator;
import modgen.common.throwerror;
logger=Log4jConfigurator.getLogger();

dataDirName='products';
% ignorDirList
ignorDirList={'.svn','test'};
% is current dir class or not
isClass=false;
% scriptNamePattern
scriptNamePattern='s_\w+\.m';
docDirName='doc';
%
texFileName='functions.tex';
newLineSymbol=10;
% TeX settings
font='pcr';
%%
mode=1;
% mode=0 -- no groups
% mode=1 -- groups by folder
%% obtain full path
curPath=modgen.path.rmlastnpathparts(...
    fileparts(which('elltool.doc.run_helpcollector')),3);
%
dataDirNameCur=[curPath,filesep,dataDirName];
docDirNameCur=[curPath,filesep,docDirName];
%%
resultTexFileName=[docDirNameCur,filesep,texFileName];
if modgen.system.ExistanceChecker.isFile(resultTexFileName)
    delete(resultTexFileName);
end
%
msgBody=sprintf('Recursive scanning of \n%s',dataDirNameCur);
logger.info([msgBody,'...']);
%
FuncData=elltool.doc.collecthelp(dataDirNameCur,...
    'ignorDirList',ignorDirList,...
    'isClass',isClass,'scriptNamePattern',scriptNamePattern);
%
logger.info([msgBody,': done']);
nHelpElems=numel(FuncData.funcName);
if nHelpElems==0
    throwerror('wrongDir',...
        sprintf('no elements were collected from %s',curPath));
end
logger.info(sprintf('%d element(s) collected',nHelpElems));
%
% isChosenFunc=~(FuncData.isScript | FuncData.isClassMethod);
isChosenFunc=~(FuncData.isScript);
dirNameCell=FuncData.dirName(isChosenFunc);
funcNameCell=FuncData.funcName(isChosenFunc);
helpCell=FuncData.help(isChosenFunc);
%isClassFunc=FuncData.isClassMethod(isChosenFunc);
% update dirNameCell (address relative to dirName)
dirNameLen=length(dataDirNameCur);
dirNameCell=cellfun(@(x) x(dirNameLen+1:end),dirNameCell,'UniformOutput',false);
% update funcNameCell (delete '.m')
funcNameCell=cellfun(@(x) x(1:end-2),funcNameCell,'UniformOutput',false);
%% unique list of functions
if isempty(funcNameCell)
    [uniqueFuncNameCell,~,indAccum]=deal(cell(1,0));
else
    [uniqueFuncNameCell,~,indAccum]=unique(funcNameCell);
end
indFunc=accumarray(indAccum,transpose(1:length(funcNameCell)),[],@(x) {x});
%% prepare data for output (for tex doc)
% obtain helpCellNew
%
indAccumCell=cellfun(@(x) [0,cumsum(x==newLineSymbol)]+1,helpCell,'UniformOutput',false);
isEmptyHelp=cellfun('isempty',indAccumCell);
%
helpCellNew=helpCell;
helpCellNew(isEmptyHelp)={'%'};
helpCellNew(~isEmptyHelp)=...
    cellfun(@(x,n) accumarray(transpose(n),transpose([x newLineSymbol]),[],@(y) {transpose(['%';y])}),...
    helpCell(~isEmptyHelp),indAccumCell(~isEmptyHelp),'UniformOutput',false);
%
helpCellNew(~isEmptyHelp)=cellfun(@(x) [x{:}],helpCellNew(~isEmptyHelp),'UniformOutput',false);
%
% obtain briefHelpCell
briefHelpCell=helpCellNew;
%

isnSpace=cellfun(@(x) ~isspace(x) | (x==newLineSymbol),helpCellNew,'UniformOutput',false);
%
indFirstEmptyLine=cellfun(@(x,is) regexp(x(is),['[^%]',newLineSymbol,'%',newLineSymbol]),...
    helpCellNew,isnSpace,'UniformOutput',false);

isExistEmptyLine=cellfun(@(x) ~isempty(x),indFirstEmptyLine);
briefHelpCell(isExistEmptyLine)=cellfun(@(x,ind,is) x(1:max(find(is,ind(1),'first'))),...
    briefHelpCell(isExistEmptyLine),indFirstEmptyLine(isExistEmptyLine),isnSpace(isExistEmptyLine),'UniformOutput',false);
% obtain authorListCell
authorListCell=helpCellNew;
%
indLastEmptyLine=cellfun(@(x,is) regexp(x(is),[newLineSymbol,'%',newLineSymbol,'%\S']),...
    helpCellNew,isnSpace,'UniformOutput',false);
%
isExistEmptyLine=cellfun(@(x) ~isempty(x),indLastEmptyLine);
authorListCell(isExistEmptyLine)=cellfun(@(x,ind,is) x(min(find(is,max(1,sum(is)-ind(end)-2),'last')):end),...
    authorListCell(isExistEmptyLine),indLastEmptyLine(isExistEmptyLine),isnSpace(isExistEmptyLine),'UniformOutput',false);
%
helpOutputCell=helpCellNew;
dirNameOutputCell=dirNameCell;
funcOutputCell=uniqueFuncNameCell;
%
%% group help info and dir name by func name
dirNameOutputCell1=cellfun(@(x) dirNameOutputCell(x),indFunc,'UniformOutput',false);
% helpOutputCell1=cellfun(@(x) helpOutputCell(x),indFunc,'UniformOutput',false);
% briefHelpCell1=cellfun(@(x) briefHelpCell(x),indFunc,'UniformOutput',false);
% authorListCell1=cellfun(@(x) authorListCell(x),indFunc,'UniformOutput',false);
% %
% %% list of output functions
% isOutputFunc=true(size(dirNameOutputCell));
% %
% nDirFunc=cellfun(@length,dirNameOutputCell);
%% substitutions (for TeX requirements)
symbList={'\','_','&'};
substList={'/','\_','\&'};
%
symbListHelp={};
substListHelp={};
for iSymb=1:length(symbList)
    funcOutputCell=strrep(funcOutputCell,symbList{iSymb},substList{iSymb});
    funcNameCell=strrep(funcNameCell,symbList{iSymb},substList{iSymb});
    %
    dirNameOutputCell=cellfun(@(x) strrep(x,symbList{iSymb},substList{iSymb}),...
        dirNameOutputCell,'UniformOutput',false);
    dirNameOutputCell1=cellfun(@(x) strrep(x,symbList{iSymb},substList{iSymb}),...
        dirNameOutputCell1,'UniformOutput',false);
end
%
for iSymb=1:length(symbListHelp)
    helpOutputCell=cellfun(@(x) strrep(x,symbListHelp{iSymb},substListHelp{iSymb}),...
        helpOutputCell,'UniformOutput',false);
    briefHelpCell=cellfun(@(x) strrep(x,symbListHelp{iSymb},substListHelp{iSymb}),...
        briefHelpCell,'UniformOutput',false);
    authorListCell=cellfun(@(x) strrep(x,symbListHelp{iSymb},substListHelp{iSymb}),...
        authorListCell,'UniformOutput',false);
end
%% create groups
if mode==0
    groupName={'total'};
elseif mode==1
    [dirUnique,~,indGroup]=unique(dirNameOutputCell);
    groupName=dirUnique;
else    
    modgen.common.throwerror('unknownMode','the specified mode is not supported');
end
%% create tex doc
%
fid = fopen(resultTexFileName, 'wt');
% begin doc
fprintf(fid,'\\documentclass[titlepage,a4paper,12pt]{article}\n');
fprintf(fid,'\\usepackage{config}\n');
fprintf(fid,'\\usepackage{listings}\n');
fprintf(fid,'\\usepackage{makeidx}\n');
fprintf(fid,'\\usepackage{hyperref}\n');
%
fprintf(fid,'\\begin{document}\n');
% section 'List of all functions with brief description'
fprintf(fid,'\\section{List of all functions}\n');
for iGroup=1:length(groupName)
    fprintf(fid,'\\subsection{%s}\n',groupName{iGroup});
    fprintf(fid,'\\begin{enumerate}\n');
    %
    indFunc=find(indGroup==iGroup);
    for idx=1:length(indFunc)
        iFunc=indFunc(idx);
        fprintf(fid,'\\item \\hyperlink{%s}{%s}\n',[groupName{iGroup},'/',funcNameCell{iFunc}],funcNameCell{iFunc});
        %         if length(dirNameOutputCell{iFunc})==1
        % new font
        fprintf(fid,'\\fontfamily{%s}\n',font);
        fprintf(fid,'\\selectfont\n');
        % print brief function help
        fprintf(fid,'\\begin{lstlisting}\n');
        %             fprintf(fid,'%s\n',briefHelpCell{iFunc}{1});
        fprintf(fid,'%s\n',briefHelpCell{iFunc});
        fprintf(fid,'\\end{lstlisting}\n');
        % default font
        fprintf(fid,'\\fontfamily{\\familydefault}\n');
        fprintf(fid,'\\selectfont\n');
    end
    %
    fprintf(fid,'\\end{enumerate}\n');
end

% section 'List of authors'
fprintf(fid,'\\section{List of authors}\n');
for iGroup=1:length(groupName)
    fprintf(fid,'\\subsection{%s}\n',groupName{iGroup});
    fprintf(fid,'\\begin{enumerate}\n');
    %
    %     indFunc=find(isGroup{iGroup});
    indFunc=find(indGroup==iGroup);
    for idx=1:length(indFunc)
        iFunc=indFunc(idx);
        fprintf(fid,'\\item \\hyperlink{%s}{%s}\n',[groupName{iGroup},'/',funcNameCell{iFunc}],funcNameCell{iFunc});
        %         if length(dirNameOutputCell{iFunc})==1
        % new font
        fprintf(fid,'\\fontfamily{%s}\n',font);
        fprintf(fid,'\\selectfont\n');
        % print brief function help
        fprintf(fid,'\\begin{lstlisting}\n');
        %             fprintf(fid,'%s\n',authorListCell{iFunc}{1});
        fprintf(fid,'%s\n',authorListCell{iFunc});
        fprintf(fid,'\\end{lstlisting}\n');
        % default font
        fprintf(fid,'\\fontfamily{\\familydefault}\n');
        fprintf(fid,'\\selectfont\n');

    end
    %
    fprintf(fid,'\\end{enumerate}\n');
end

% section 'Help list'
fprintf(fid,'\\section{Help list}\n');
% %
for iGroup=1:length(groupName)
    fprintf(fid,'\\subsection{%s}\n',groupName{iGroup});
    fprintf(fid,'\\begin{enumerate}\n');
    %
    indFunc=find(indGroup==iGroup);
    for idx=1:length(indFunc)
        iFunc=indFunc(idx);
        fprintf(fid,'\\item\\hypertarget{%s}{%s}\n',...
            [groupName{iGroup},filesep,funcNameCell{iFunc}],funcNameCell{iFunc});
                % new font
        fprintf(fid,'\\fontfamily{%s}\n',font);
        fprintf(fid,'\\selectfont\n');
        % print brief function help
        fprintf(fid,'\\begin{lstlisting}\n');
        %             fprintf(fid,'%s\n',briefHelpCell{iFunc}{1});
        fprintf(fid,'%s\n',helpOutputCell{iFunc});
        fprintf(fid,'\\end{lstlisting}\n');
        % default font
        fprintf(fid,'\\fontfamily{\\familydefault}\n');
        fprintf(fid,'\\selectfont\n');
    end
    %
    fprintf(fid,'\\end{enumerate}\n');
end
% end doc
fprintf(fid,'\\end{document}\n');
% close file
fclose(fid);
logger.info(sprintf('Job completed, the result is written to \n%s',...
    resultTexFileName));
%