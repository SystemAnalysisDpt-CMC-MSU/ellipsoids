function modifycopyright(pathName,markerName)
% MODIFYCOPYRIGHT - inserts a copyright statement into a line in help  
%                   header. The line is identified based on a presence of
%                   the specified marker. Also the function removes all the 
%                   lines that follow the newly inserted help header and 
%                   contain the same marker
%
% Input:
%   regular:
%       pathName: char[1,] - path to the folder with m-files or a full
%           path to a single m-file
%       markerName: char[1,] - name of the marker used for copyright line
%           detection
%
% $Author: Peter Gagarinov <pgagarinov@gmail.com>$	$Date: 2012-10-16 $
% $Copyright: Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
import modgen.system.ExistanceChecker;
import modgen.common.throwerror;
%
markerName=lower(markerName);
fIsStartLine= @(x)~isempty(regexp(lower(strrep(x,' ','')),...
    markerName,'ONCE'));
fIsDelLine=fIsStartLine;

if ExistanceChecker.isFile(pathName)
    modifyfilecopyright(pathName,fIsStartLine,fIsDelLine);
elseif ExistanceChecker.isDir(pathName)
    SElemInfo=dir(pathName);
    %
    elemNameList={SElemInfo.name};
    isDirVec=[SElemInfo.isdir];
    %
    isRealDir=~(strcmp('..',elemNameList)|strcmp('.',elemNameList));
    elemNameList=elemNameList(isRealDir);
    isDirVec=isDirVec(isRealDir);
    %
    [~,~,extList]=cellfun(@fileparts,elemNameList,'UniformOutput',false);
    isMatlabFileVec=cellfun(@(x)isequal(x,'.m'),extList);
    isProcessedVec=isMatlabFileVec|isDirVec;
    %
    elemNameList=elemNameList(isProcessedVec);
    isDirVec=isDirVec(isProcessedVec);
    %
    nElems=length(elemNameList);
    %
    %strip off the separator
    if pathName(end)=='\' || pathName(end)=='/'
        cleanPathName=pathName(1:end-1);
    else
        cleanPathName=pathName;
    end
    %
    for iElem=1:nElems
        fullElemName=fullfile(cleanPathName,elemNameList{iElem});
        if isDirVec(iElem)
            modgen.doc.modifycopyright(fullElemName,markerName);
        else
            modifyfilecopyright(fullElemName,fIsStartLine,fIsDelLine);
        end
    end
else
    throwerror('wrongInput',['pathName is expected to be ',...
        'either a directory name or file name']);
end
end
function modifyfilecopyright(fullFileName,fIsStartLine,fIsDelLine)
persistent logger;
import modgen.logging.log4j.Log4jConfigurator;
import modgen.system.ExistanceChecker;
import modgen.common.throwerror;
logger=Log4jConfigurator.getLogger();
%
if isempty(logger)
    logger=Log4jConfigurator.getLogger();
end
%
SWAP_FILE_NAME_PREFIX='swap_';
%
EOL_SYMBOL=getEndOfLineSymbol();
%record patter is parameterized by Author,Date and Year
RECORD_PATTERN_LINE_LIST=...
    {'%',...
    '% $Author: #1 $	$Date: #2 $ ',...
    '% $Copyright: Moscow State University,',...
    '%            Faculty of Applied Mathematics and Computer Science,',...
    '%            System Analysis Department #3 $',...
    '%'};
%
% need to check for blank extensions since "exist" in the calling function
% will find M-files without the extension explicitly given.
% skip over any file that is not an M-file
[filePath,shortFileName,fileExt]=fileparts(fullFileName);
if ~strcmpi(fileExt,'.m'),
    throwerror('notSupportedFile','Only m-files are supported');
end
%
[fid,openErrMsg]= fopen(fullFileName,'r+');
if fid>0
    try
        swapFileName = [SWAP_FILE_NAME_PREFIX,shortFileName];
        fullSwapFileName = fullfile(filePath,swapFileName);
        if ExistanceChecker.isFile(fullSwapFileName)
            delete(fullSwapFileName);
        end
        [fidSwap,swapOpenErrMsg] = fopen(fullSwapFileName,'w');
        if fidSwap>0
            try
                isFirstMarkerFound= false;
                nextLineContent = fgetl(fid);
                if ischar(nextLineContent)
                    while true
                        % & check for the first marker
                        if ~isFirstMarkerFound...
                                &&fIsStartLine(nextLineContent)
                            leadCharSeqVec=extractLeadSequence(...
                                nextLineContent);
                            isFirstMarkerFound=true;
                            writeRecord(leadCharSeqVec);
                            %
                            nextLineContent = fgetl(fid);
                            if ischar(nextLineContent)
                                writeEol();
                            else
                                break;
                            end
                        else
                            if ~fIsDelLine(nextLineContent)
                                writeCurrentLine();
                                nextLineContent = fgetl(fid);
                                if ischar(nextLineContent);
                                    writeEol();
                                end
                            else
                                nextLineContent = fgetl(fid);
                            end
                            if ~ischar(nextLineContent)
                                break;
                            end
                        end
                    end
                end
                fclose(fidSwap);
            catch meObj
                fclose(fidSwap);
                rethrow(meObj);
            end
            if ~isFirstMarkerFound
                statusString = ['Could not find place to ',...
                    'add Copyright info.'];
                delete(fullSwapFileName)
            else
                isMoved = movefile(fullSwapFileName,fullFileName,'f');
                if ~isMoved,
                    delete(fullSwapFileName)
                    statusString = ['Could not move file!!! ',...
                        'Copyright info is unchanged.'];
                else
                    statusString = 'Copyright info added/modified.';
                end
            end
        else
            statusString = sprintf(...
                '*** Failed to open %s for writing, reason: %s',...
                swapFileName,swapOpenErrMsg);
        end
        fclose(fid);
    catch meObj
        fclose(fid);
        baseMeObj=throwerror('unknownError',...
            sprintf('failed to process file "%s"',fullFileName));
        newMeObj=baseMeObj.addCause(meObj);
        throw(newMeObj);
    end
else
    statusString = sprintf(...
        '*** Failed to open, reason: %s.',openErrMsg);
end
logger.info(sprintf([statusString,'\n file: %s'],fullFileName));
    function writeCurrentLine()
        fprintf(fidSwap,'%s',nextLineContent);
    end
    function writeEol()
        fprintf(fidSwap,'%s',EOL_SYMBOL);
    end
    function writeRecord(leadCharSeqVec)
        [SInfo,isVersioned]=modgen.subversion.getfileinfo(fullFileName);
        if isVersioned
            authorName=authorNick2Name(SInfo.lastChangedAuthor);
            lastChangedTime=SInfo.lastChangedDate;
            lastChangedYear=lastChangedTime(1:4);
            lastChangedDate=lastChangedTime(1:10);
            recordLineList=getRecordLineList(...
                authorName,lastChangedDate,...
                lastChangedYear);
        else
            recordLineList={};
        end
        %
        recordLineList=cellfun(@(x)[leadCharSeqVec,x],recordLineList,...
            'UniformOutput',false);
        writeLineList(recordLineList);
    end
    function writeLineList(lineList)
        nLines=length(lineList);
        if nLines>0
            for iLine=1:nLines-1
                %
                fprintf(fidSwap,'%s',[lineList{iLine},EOL_SYMBOL]);
            end
            fprintf(fidSwap,'%s',lineList{end});
        end
    end
    function lineList=getRecordLineList(authorName,dateStr,yearStr)
        nLines=length(RECORD_PATTERN_LINE_LIST);
        lineList=cell(1,nLines);
        for iLine=1:nLines
            lineList{iLine}=RECORD_PATTERN_LINE_LIST{iLine};
            lineList{iLine}=strrep(lineList{iLine},'#1',authorName);
            lineList{iLine}=strrep(lineList{iLine},'#2',dateStr);
            lineList{iLine}=strrep(lineList{iLine},'#3',yearStr);
        end
    end
end
%
function name=authorNick2Name(nickName)
map=containers.Map(...
    {'pgagarinov@gmail.com',...
    'irizka91@gmail.com',...
    'kirill.mayantsev@gmail.com',...
    'lubi4ig@gmail.com',...
    'Brickerino@gmail.com',...
    'justenterrr@gmail.com',...
    'vetbar42@gmail.com',...
    'ivan.v.menshikov@gmail.com',...
    'kitsenko@gmail.com',...
    'reinkarn@gmail.com',...
    'swige.ide@gmail.com',...
    'grachev.art@gmail.com',...
    'Alexander.Karev.30@gmail.com',...
    'NoblesseKlo@gmail.com',...
    'DmitryKh92@gmail.com',...
    'illuminati1606@gmail.com'...
    'klivenn@gmail.com',...
    'vkaushanskiy@gmail.com',...
    'N.Aushkap@gmail.com',...
    'glvrst@gmail.com',...
    'igorian.vmk@gmail.com'},...
    {'Peter Gagarinov <pgagarinov@gmail.com>',...
    'Irina Zhukova <irizka91@gmail.com>',...
    'Kirill Mayantsev <kirill.mayantsev@gmail.com>',...
    'Ilya Lubich <lubi4ig@gmail.com>',...
    'Arseniy Kuznetsov <Brickerino@gmail.com>',...
    'Eugene Zaharov <justenterrr@gmail.com>',...
    'Vitaliy Baranov <vetbar42@gmail.com>',...
    'Ivan Menshikov <ivan.v.menshikov@gmail.com>',...
    'Igor Kitsenko <kitsenko@gmail.com>',...
    'Daniil Stepenskiy <reinkarn@gmail.com>',...
    'Yuriy Admiralskiy <swige.ide@gmail.com>',...
    'Artem Grachev <grachev.art@gmail.com>',...
    'Alexander Karev <Alexander.Karev.30@gmail.com>',...
    'Dmitriy Kozlov <NoblesseKlo@gmail.com>',...
    'Dmitriy Khristoforov <DmitryKh92@gmail.com>',...
    'Viktor Gribov <illuminati1606@gmail.com>',...
    'Dmitriy Kovalev <klivenn@gmail.com>',...
    'Vadim Kaushanskiy <vkaushanskiy@gmail.com>',...
    'Nikolay Aushkap <N.Aushkap@gmail.com>',...
    'Rustam Galiev <glvrst@gmail.com>',...
    'Igor Samohin <igorian.vmk@gmail.com>'});
try
    name=map(nickName);
catch meObj
    causeMeObj=modgen.common.throwerror('nickNotFound',sprintf(...
        'Nickname %s not found',nickName));
    newMeObj=meObj.addCause(causeMeObj);
    throw(newMeObj);
end
end
%
function leadCharSeqVec=extractLeadSequence(lineCharVec)
if isempty(lineCharVec)
    leadCharSeqVec=char.empty(1,0);
else
    isLeadSymbVec=(lineCharVec==sprintf(' ')|lineCharVec==sprintf('\t'));
    if isLeadSymbVec(1)
        indLast=find(~isLeadSymbVec,1,'first')-1;
        leadCharSeqVec=lineCharVec(1:indLast);
    else
        leadCharSeqVec=char.empty(1,0);
    end
end
end
%
function endOfLineSymbol=getEndOfLineSymbol()
cr=13;
lf=10;
switch true
    case ispc
        endOfLineSymbol = char([cr,lf]);
    case isunix
        endOfLineSymbol = char(lf);
    otherwise       % if not a pc or unix os, assume it is an old mac os
        endOfLineSymbol = char(cr);
end
end