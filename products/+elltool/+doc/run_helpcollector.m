function run_helpcollector
import modgen.logging.log4j.Log4jConfigurator;                             
import modgen.common.throwerror;
logger=Log4jConfigurator.getLogger();
docDirName='doc';
%
texFileName='chap_functions.tex';
newLineSymbol=10;

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
FuncData=elltool.doc.collecthelp({
'smartdb.cubes.CubeStruct','smartdb.relations.ARelation',...
 'gras.ellapx.smartdb.rels.EllTube'},...
{},{'test'});

% 'ellipsoid', 'hyperplane',...
% 'elltool.conf.Properties', 'elltool.core.GenEllipsoid',...
% , 'gras.ellapx.smartdb.rels.EllTubeProj',...
% 'gras.ellapx.smartdb.rels.EllUnionTube', ...
% 'gras.ellapx.smartdb.rels.EllUnionTubeStaticProj',...
% 'elltool.reach.AReach','elltool.reach.ReachContinuous',...
% 'elltool.reach.ReachDiscrete','elltool.reach.ReachFactory',...
% 'elltool.linsys.ALinSys',  'elltool.linsys.LinSysContinuous',...
% 'elltool.linsys.LinSysDiscrete',  'elltool.linsys.LinSysFactory'
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
classNameCell = FuncData.className;
numberOfFunctions = FuncData.numbOfFunc;
defClassNameCell = FuncData.defClassName;
inhFuncNameCell = FuncData.inhFuncNameList;
indOfClasses = FuncData.numberOfInhClass;
infoOfInheritedFunctions = FuncData.infoOfInhClass;
numberOfInheritedClasses = FuncData.numbOfInhClasses;
% update funcNameCell (delete '.m')
funcNameCell=cellfun(@(x) x(1:end),funcNameCell,'UniformOutput',false);
classNameCell=cellfun(@(x) x(1:end),classNameCell,'UniformOutput',false);
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
    helpCell(~isEmptyHelp),indAccumCell(~isEmptyHelp),'UniformOutput',...
      false);
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
    finalHelpCell(isExistAuthorLine),...
    indFirstAuthorLine(isExistAuthorLine),isnSpace(isExistAuthorLine),...
    'UniformOutput',false);

finalHelpCell = cellfun(@(x)fDeletePercent(x),finalHelpCell, ...
    'UniformOutput', false);
finalHelpCell = cellfun(@(x)fShiftText(x),finalHelpCell, ...
    'UniformOutput', false);
finalHelpCell = cellfun(@(x)fDeleteEmptyStr(x),finalHelpCell, ...
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
    finalHelpCell=cellfun(@(x) strrep(x,symbListHelp{iSymb},...
        substListHelp{iSymb}),finalHelpCell,'UniformOutput',false);
end

labelFuncCell = cellfun(@(x)fDeleteSymbols(x),funcNameCell, ...
    'UniformOutput', false);
%% create tex doc
%
fid = fopen(resultTexFileName, 'wt');
indFunc = 1;
iCountClass = 1;
flag = 0;
indInhClass = 1;
for iClass=1:length(classNameCell)
    fprintf(fid,'\\section{%s}\\label{secClassDescr:%s}\n',...
        classNameCell{iClass}, classNameCell{iClass});
    numbFunc = indFunc + numberOfFunctions(iClass) - 1;
    if ismember(iClass,indOfClasses)
        flag = 1;
    end
    for iFunc = indFunc: numbFunc
        fprintf(fid,...
        '\\subsection{\\texorpdfstring{%s}{%s}}\\label{method:%s}\n',...
        [classNameCell{iClass}, '.',funcOutputCell{iFunc}],...
        funcOutputCell{iFunc},...
        [classNameCell{iClass}, '.',labelFuncCell{iFunc}]);
        % print function help
        fprintf(fid,'\\begin{verbatim}\n');
        fprintf(fid,'%s\n',finalHelpCell{iFunc});
        fprintf(fid,'\\end{verbatim}\n');
        if flag
            %for iNumbClass = 1:numberOfInheritedClasses(indInhClass)
            numberOfClasses = numberOfInheritedClasses(indInhClass);
            for iBuf = iCountClass: iCountClass + numberOfClasses -1
                helpPattern = sprintf...
('\n\nSee the description of the following methods in section \\ref{secClassDescr:%s}\n for %s:\n',...
  char(defClassNameCell{iBuf}), char(defClassNameCell{iBuf}));
            fprintf(fid,'%s\n',helpPattern);
            fprintf(fid,'\\begin{list}{}{}\n');
            for iMethod = 1:infoOfInheritedFunctions(iBuf)
             fprintf(fid,' \\item \\hyperref[method:%s]{%s}\n',...
             [char(defClassNameCell{iBuf}), '.',...
             char(inhFuncNameCell{iBuf}{iMethod})],...
             char(inhFuncNameCell{iBuf}{iMethod}));
            end
            fprintf(fid,'\\end{list}\n');
            iCountClass = iCountClass+1;
            end
            
            flag = 0;
            indInhClass = indInhClass + 1;
        end
        indFunc = indFunc + 1;
    end

end
% close file
fclose(fid);
logger.info(sprintf('Job completed, the result is written to \n%s',...
    resultTexFileName));
end

function result = fDeletePercent(str)
result = regexprep(str, '(\%)', '');
end

function result = fDeleteEmptyStr(str)
[m startInd] = regexp(str, '(\n){2,}','match', 'start');
result = str(1:(max(startInd)-1));
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

 function result = fDeleteSymbols(str)
     result = regexprep(str, '(\\_)', '');
 end
