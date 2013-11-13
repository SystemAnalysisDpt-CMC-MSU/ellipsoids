function run_helpcollector
helpcollectorName = modgen.common.getcallername(1);
[pathstrVec, ~, ~] = fileparts(which(helpcollectorName));
dirName = [pathstrVec filesep '+picgen' filesep '*.m'];
SPicgenFilesArray = dir(dirName);
picDestDir = [modgen.path.rmlastnpathparts(pathstrVec, 3)...
    filesep 'doc' filesep 'pic'];
elltool.doc.picgen.PicGenController.setPicDestDir(picDestDir);
for iElem = 1 : size(SPicgenFilesArray, 1)
    picgenFileName = modgen.string.splitpart(...
        SPicgenFilesArray(iElem).name, '.', 'first');
    picgenFunctionName =  strcat ('elltool.doc.picgen.', picgenFileName);
    fPicGen = str2func(picgenFunctionName);
    fPicGen();
end
elltool.doc.picgen.PicGenController.flush();


import modgen.logging.log4j.Log4jConfigurator;
import modgen.common.throwerror;
logger=Log4jConfigurator.getLogger();
docDirName='doc';
%
texFileName='chap_functions.rst';
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
FuncData=elltool.doc.collecthelp({'ellipsoid','hyperplane',...
    'elltool.conf.Properties', 'elltool.core.GenEllipsoid',...
    {'smartdb.relations.ATypifiedStaticRelation',...
    'smartdb.cubes.CubeStruct','smartdb.relations.ARelation',...
    'smartdb.cubes.FixedDimStCubeStructAppliance',...
    'modgen.common.obj.HandleObjectCloner'},...
    'gras.ellapx.smartdb.rels.EllTube','gras.ellapx.smartdb.rels.EllTubeProj',...
    'gras.ellapx.smartdb.rels.EllUnionTube',...
    'gras.ellapx.smartdb.rels.EllUnionTubeStaticProj',...
    {'elltool.reach.AReach'},'elltool.reach.ReachContinuous',...
    'elltool.reach.ReachDiscrete','elltool.reach.ReachFactory',...
    {'elltool.linsys.ALinSys'}, 'elltool.linsys.LinSysContinuous',...
    'elltool.linsys.LinSysDiscrete',  'elltool.linsys.LinSysFactory'},{},{'test'});
nHelpElems=numel(FuncData.funcName);
if nHelpElems==0
    throwerror('wrongDir',...
        sprintf('no elements were collected from %s',curPath));
end
logger.info(sprintf('%d element(s) collected',nHelpElems));
%



funcNameCell=FuncData.funcName;
helpCell=FuncData.help;
sectionNameCell = FuncData.sectionName;
classNameCell = FuncData.className;
numberOfFunctions = FuncData.numbOfFunc;
numberOfClassInSection = FuncData.numbOfClass;
defClassNameCell = FuncData.defClassName;
inhFuncNameCell = FuncData.inhFuncNameList;
indOfClasses = FuncData.numberOfInhClass;
numberOfInheritedFunctions = FuncData.infoOfInhClass;
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
%
symbListHelp={'\n'};
substListHelp={'\n\t'};

%funcOutputCell=makeNewName(funcOutputCell);
%funcNameCell=makeNewName(funcNameCell);
%
for iSymb=1:length(symbListHelp)
    finalHelpCell=cellfun(@(x) strrep(x,symbListHelp{iSymb},...
        substListHelp{iSymb}),finalHelpCell,'UniformOutput',false);
end

labelFuncCell = cellfun(@(x)fDeleteSymbols(x),funcOutputCell, ...
    'UniformOutput', false);
%% create tex doc
fid = fopen(resultTexFileName, 'wt');
indFunc = 1;
indMethod = 1;
flag = 0;
indInhClass = 1;
iClass = 1;
indClass = 1;
fprintf(fid, '%s\n', 'Function Reference');
fprintf(fid, '%s\n\n', '==================');
for iSect=1:length(sectionNameCell)
    underline = '';
    for jSym = 1:numel(sectionNameCell{iSect})
        underline = [underline '-'];
    end
    fprintf(fid,'%s\n%s\n\n', sectionNameCell{iSect}, underline);
    numbFunc = indFunc + numberOfFunctions(iSect) -1;
    for jClass = indClass:numberOfClassInSection(iSect) + indClass -1
        if ismember(jClass,indOfClasses)
            flag = 1;
            helpPattern = sprintf...
                ('\n\nSee the description of the following methods in `%s`_ for %s:\n',...
                char(defClassNameCell{indInhClass}), char(defClassNameCell{indInhClass}));
        end
        indClass = indClass+1;
    end
    numbFunc = indFunc + numberOfFunctions(iSect)-1;
    for iFunc = indFunc: numbFunc
        underline = '';
        for jSym = 1:numel([sectionNameCell{iSect} '.' funcOutputCell{iFunc}])
            underline = [underline '~'];
        end
        fprintf(fid, '%s\n%s\n\n',[sectionNameCell{iSect}, '.',funcOutputCell{iFunc}], underline);
        % print function help
        fprintf(fid,'::\n\n');
        fprintf(fid,'\t%s\n', finalHelpCell{iFunc});
        fprintf(fid,'\n');
        if flag
            numbInhFunc = numberOfInheritedFunctions(indInhClass);
            fprintf(fid,'%s\n',helpPattern);
            fprintf(fid,'\n');
            for iMethod = 1:numbInhFunc
                fprintf(fid,'- %s_\n',...
                    [char(defClassNameCell{indInhClass}), '.',...
                    char(inhFuncNameCell{indInhClass}{iMethod})]);
                indMethod = indMethod+1;
            end
            fprintf(fid, '\n');
            flag = 0;
            indInhClass = indInhClass + 1;
        end
        indFunc = iFunc + 1;
    end
end
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
nl = repmat({'\n   '}, 1, nLines);
lines = [lines; nl];
result = sprintf(strcat(lines{:}));
end

function result = fDeleteSymbols(str)
result = regexprep(str, '(\\_)', '');
end
function nameList=makeNewName(nameList)
%% substitutions (for TeX requirements)
symbList={'\','_','&'};
substList={'/','\_','\&'};
%
for iSymb=1:length(symbList)
    nameList=strrep(nameList,symbList{iSymb},substList{iSymb});
end
end


